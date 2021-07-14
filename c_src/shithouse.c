// vim: noet ts=4 sw=4
#include "shithouse.h"

int api_get(lua_State* L) {
	lua_pushliteral(L, "API Get.");
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
