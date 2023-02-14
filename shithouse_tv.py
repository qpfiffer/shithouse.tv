#!/usr/bin/env python3

# GREAT DANE ON THE BEAT

import json
import os
import subprocess
import sys
import threading
from ctypes import (CDLL, POINTER, Structure, byref, c_char, c_char_p, c_int64,
                    c_size_t, c_void_p)

from bottle import HTTPResponse, error, get, post, request, run

TMPFILE_LOC = "/tmp/"
SRV_DIR = "./"
LUA_ENTRYPOINT = f"{SRV_DIR}src/shithouse_tv.lua"

debug = True
reloader = False


class ShithouseRequest(Structure):
    _fields_ = [
        ("verb", c_char_p),
        ("path", c_char_p),
        ("host", c_char_p),
        ("post_data_json", c_char_p),
    ]


class ShithouseResponse(Structure):
    _fields_ = [
        ("status_code", c_int64),
        ("body_len", c_size_t),
        ("body", c_void_p),
        ("ctype_len", c_size_t),
        ("ctype", c_char_p),
    ]


class ShithouseApp(Structure):
    pass


libshithouse = CDLL("libshithouse.so")

libshithouse.sh_process_request.restype = POINTER(ShithouseResponse)

libshithouse.sh_free_response.argtypes = [POINTER(ShithouseResponse)]

libshithouse.sh_app.restype = POINTER(ShithouseApp)
libshithouse.sh_app.argtypes = [c_char_p]

_sh_app = None
def get_sh_app():
    global _sh_app
    if not _sh_app:
        _sh_app = libshithouse.sh_app(LUA_ENTRYPOINT.encode())
        if not _sh_app:
            print("Could not init app.")
            sys.exit(1)

    return _sh_app

libshithouse_lock = threading.Lock()


def bottle_request_2_lua(req, post_data_json: str) -> ShithouseRequest:
    return ShithouseRequest(
        req.method.encode(),
        req.path.encode(),
        req.urlparts.netloc.split(":")[0].encode(),
        post_data_json,
    )


def good_old_500():
    output = (
        f"<!DOCTYPE html><html><body><p>Fat error with Lua somewhere</p></body></html>"
    )
    resp = HTTPResponse(body=output, status=500)
    return resp


@error(404)
def catchall_route(error):
    json_val = None
    if request.POST:
        json_val = {k: v for k, v in request.forms.items()}

        for k in ("image", "music"):
            fil = request.files.get(k)
            if fil:
                json_val[k] = TMPFILE_LOC + fil.filename
                fil.save(TMPFILE_LOC, overwrite=True)

    s_req = bottle_request_2_lua(request, json.dumps(json_val).encode())
    resp = None

    with libshithouse_lock:
        sh_app = get_sh_app()
        s_resp = libshithouse.sh_process_request(sh_app, byref(s_req))

        unwrapped = s_resp.contents
        buf = (c_char * unwrapped.body_len).from_address(s_resp.contents.body)
        new_barray = bytes(bytearray(buf))

        headers = {"Content-Length": unwrapped.body_len}
        resp = HTTPResponse(
            body=new_barray,
            status=unwrapped.status_code,
            content_type=unwrapped.ctype,
            headers=headers,
        )
        libshithouse.sh_free_response(s_resp)

    if not resp.body:
        return good_old_500()

    if request.get_header("host", "").startswith("api."):
        resp.content_type = "application/json"
        resp.headers["Access-Control-Allow-Origin"] = "*"
        resp.headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
        resp.headers[
            "Access-Control-Allow-Headers"
        ] = "Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token"

    return resp


def main():
    print(f"Moving to {SRV_DIR}")
    os.chdir(SRV_DIR)
    print("New vars are:\n  - SRV_DIR: {}\n  - LUA_ENTRYPOINT: {}".format(SRV_DIR, LUA_ENTRYPOINT))
    run(server="paste", host="localhost", debug=debug, port=8090, reloader=reloader)


if __name__ == "__main__":
    for i, arg in enumerate(sys.argv):
        if arg in ("-s", "--serve-dir"):
            print(f"SETTINGS SRV_DIR TO {sys.argv[i+1]}")
            SRV_DIR = sys.argv[i + 1]
            LUA_ENTRYPOINT = os.path.join(f"{SRV_DIR}", "src/shithouse_tv.lua")
        elif arg in ("-d", "--debug"):
            debug = True
        elif arg in ("-r", "--reloader"):
            reloader = True

    main()
