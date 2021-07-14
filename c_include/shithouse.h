// vim: noet ts=4 sw=4
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

struct sh_app {
	lua_State *L;
	int64_t sh_lua_app_ref;
};

struct sh_request {
	char *verb;
	char *path;
	char *host;
	char *post_data_json;
};

struct sh_response {
	int64_t status_code;
	size_t body_len;
	char *body;

	size_t ctype_len;
	char *ctype;
};

struct sh_app *sh_app(const char *entry_point);
struct sh_response *sh_process_request(struct sh_app *app, const struct sh_request *req);
void sh_free_response(struct sh_response *r);
