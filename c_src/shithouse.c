// vim: noet ts=4 sw=4
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>

#include "shithouse.h"

static void *_load(const char *filepath, size_t *len) {
	void *to_return = NULL;
	struct stat sb = {0};
	int fd = open(filepath, O_RDONLY);
	if (fd < 0)
		return NULL;

    fstat(fd, &sb);
	*len = sb.st_size;
	to_return = mmap(NULL, *len, PROT_READ, MAP_SHARED, fd, 0);
	close(fd);

	return to_return;
}

static void _unload(void *mmaped_region, const size_t len) {
	munmap(mmaped_region, len);
}

int api_get(lua_State* L) {
	if (ruby_setup()) {
		lua_pushliteral(L, "Failed to setup Ruby.");
		return 1;
	}

	ruby_script("r_api_get");

	size_t fsize = 0;
	char *ruby_script = _load("./r_src/api.rb", &fsize);
	if (ruby_script == MAP_FAILED) {
		char buf[255] = {0};
		sprintf(buf, "Error: %s", strerror(errno));
		lua_pushstring(L, buf);
		return 1;
	}

	int rb_state = 0;
	VALUE api_class, api_get_retval;
	rb_eval_string_protect(ruby_script, &rb_state);
	api_class = rb_funcall(Qnil, rb_intern("main"), 0);
	api_get_retval = rb_funcall(api_class, rb_intern("get"), 0);

	char *output = StringValueCStr(api_get_retval);

	lua_pushstring(L, output);

	ruby_cleanup(0);

	return 1;
}

int api_post(lua_State* L) {
	lua_pushliteral(L, "API Post.");
	return 1;
}

int luaopen_libshithouse(lua_State* L) {
	lua_newtable(L);

	lua_pushcfunction(L, api_get);
	lua_setfield(L, -2, "api_get");

	lua_pushcfunction(L, api_post);
	lua_setfield(L, -2, "api_post");

	return 1;
}
