// vim: noet ts=4 sw=4
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdint.h>

#include "shithouse.h"

struct sh_app *sh_app(const char *entry_point) {
	struct sh_app *new_app = calloc(sizeof(struct sh_app), 1);

	lua_State *L = lua_open();
	luaL_openlibs(L);

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
