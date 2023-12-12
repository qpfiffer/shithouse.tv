// vim: noet ts=4 sw=4
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#include "shithouse.h"
#include "vector.h"

struct dir_iterator {
	uint64_t iter;
	char *path;
	vector *files;
};

struct file {
	struct stat sb;
	char name[256];
};

static int ctime_compare(const void *item_a, const void *item_b) {
	const struct file *file_a = (struct file *)item_a;
	const struct file *file_b = (struct file *)item_b;

	return file_a->sb.st_mtim.tv_sec < file_b->sb.st_mtim.tv_sec;
}

static int l_dir(lua_State *L) {
	/* Straight out of the docs */
	/* https://www.lua.org/pil/29.1.html */
	const char *path = luaL_checkstring(L, 1);

	/* create a userdatum to store a DIR address */
	struct dir_iterator *d = (struct dir_iterator *)lua_newuserdata(L,
			sizeof(struct dir_iterator));
	d->path = strdup(path);

	d->iter = 0;
	d->files = vector_new(sizeof(struct file), 2048);

	/* set its metatable */
	luaL_getmetatable(L, "LuaBook.dir");
	lua_setmetatable(L, -2);

	DIR *dir = opendir(path);
	if (!dir) {
		luaL_error(L, "Cannot open dir %s: %s", path, strerror(errno));
	}

	struct dirent *entry = NULL;
	while ((entry = readdir(dir))) {
		char pathname[1024] = {0};
		int ret = 0;
		struct file fil = {0};

		if (!strcmp(entry->d_name, ".") || !strcmp(entry->d_name, "..")) {
			continue;
		}

		strncpy(fil.name, entry->d_name, sizeof(fil.name));
		snprintf(pathname, sizeof(pathname), "%s/%s", path, entry->d_name);

		ret = stat(pathname, &fil.sb);
		if (ret) {
			/* TODO: Clear out buffers, manage memory, return nothing. */
			luaL_error(L, "Cannot stat %s: %s", pathname, strerror(errno));
		}

		vector_append(d->files, &fil, sizeof(struct file));
	}

	qsort(d->files->items, d->files->count, d->files->item_size, &(ctime_compare));

	closedir(dir);

	lua_pushcclosure(L, dir_iter, 1);
	return 1;
}

static int dir_iter(lua_State *L) {
	struct dir_iterator *dirs = (struct dir_iterator *)lua_touserdata(L, lua_upvalueindex(1));
	if (dirs->iter < dirs->files->count) {
		const struct file *fil = vector_get(dirs->files, dirs->iter);
		lua_pushstring(L, fil->name);
		dirs->iter++;
		return 1;
	}

	return 0;
}

static int dir_gc(lua_State *L) {
	struct dir_iterator *d = (struct dir_iterator *)lua_touserdata(L, 1);
	if (d->files)
		vector_free(d->files);
	if (d->path)
		free(d->path);
	return 0;
}

struct sh_app *sh_app(const char *entry_point) {
	struct sh_app *new_app = calloc(sizeof(struct sh_app), 1);

	lua_State *L = lua_open();
	luaL_openlibs(L);

	luaL_newmetatable(L, "LuaBook.dir");

	/* set its __gc field */
	lua_pushstring(L, "__gc");
	lua_pushcfunction(L, dir_gc);
	lua_settable(L, -3);

	/* register the `dir' function */
	lua_pushcfunction(L, l_dir);
	lua_setglobal(L, "dir");

	if (luaL_loadfile(L, entry_point)) {
		luaL_error(L, "Cannot load %s: %s", entry_point, lua_tostring(L, -1));
		return NULL;
	}

	if (lua_pcall(L, 0, 1, 0)) {
		luaL_error(L, "Cannot run main: %s", lua_tostring(L, -1));
		return NULL;
	}

	new_app->L = L;
	new_app->sh_lua_app_ref = luaL_ref(L, LUA_REGISTRYINDEX);

	if (new_app->sh_lua_app_ref == LUA_REFNIL) {
		luaL_error(L, "Reference to app is nil");
		return NULL;
	}

	return new_app;

}

struct sh_response *sh_process_request(struct sh_app *app, const struct sh_request *req) {
	/* Push the app onto the stack */
	lua_rawgeti(app->L, LUA_REGISTRYINDEX, app->sh_lua_app_ref);
	/* Push the function we're calling */
	lua_getfield(app->L, -1, "handle_request");
	/* Push a reference to the table itself ("self") */
	lua_pushvalue(app->L, -2);
	lua_pushstring(app->L, req->host);
	lua_pushstring(app->L, req->path);
	lua_pushstring(app->L, req->verb);
	lua_pushstring(app->L, req->post_data_json);

	/* Call "handle_request" */
	if (lua_pcall(app->L, 5, 1, 0)) {
		luaL_error(app->L, "Cannot run view: %s", lua_tostring(app->L, -1));
		lua_pop(app->L, 1);
		return NULL;
	}

	struct sh_response *new_response = calloc(sizeof(struct sh_response), 1);
	const char *body, *ctype = NULL;

	lua_pushstring(app->L, "body_len");
	lua_gettable(app->L, -2);
	int64_t possible_body_len = lua_tointeger(app->L, -1);
	if (possible_body_len > 0) {
		new_response->body_len = possible_body_len;
	}
	lua_pop(app->L, 1);

	/* Get body response */
	lua_pushstring(app->L, "body");
	lua_gettable(app->L, -2);
	body = lua_tostring(app->L, -1);
	if (!body) {
		lua_pop(app->L, 1);
		new_response->body = NULL;
		new_response->status_code = 500;
		new_response->body_len = 0;
		new_response->ctype = NULL;
		return new_response;
	}

	if (!new_response->body_len) {
		new_response->body_len = strlen(body);
	}

	new_response->body = calloc(new_response->body_len + 1, 1);
	memcpy(new_response->body, body, new_response->body_len);
	new_response->body[new_response->body_len] = '\0';
	lua_pop(app->L, 1);

	/* Get status code */
	lua_pushstring(app->L, "status_code");
	lua_gettable(app->L, -2);
	new_response->status_code = lua_tointeger(app->L, -1);
	lua_pop(app->L, 1);

	lua_pushstring(app->L, "content_type");
	lua_gettable(app->L, -2);
	ctype = lua_tostring(app->L, -1);
	if (ctype) {
		new_response->ctype = calloc(strlen(ctype) + 1, 1);
		new_response->ctype_len = strlen(ctype);
		strncpy(new_response->ctype, ctype, new_response->ctype_len + 1);
	} else {
		const char DEFAULT_CTYPE[] = "text/html; charset=utf-8";
		new_response->ctype = calloc(strlen(DEFAULT_CTYPE) + 1, 1);
		new_response->ctype_len = strlen(DEFAULT_CTYPE);
		strncpy(new_response->ctype, DEFAULT_CTYPE, new_response->ctype_len + 1);
	}

	lua_pop(app->L, 1);
	return new_response;
}

void sh_free_response(struct sh_response *r) {
	if (r->body && r->body_len)
		free(r->body);
	if (r->ctype && r->ctype_len)
		free(r->ctype);
	free(r);
}
