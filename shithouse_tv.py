#!/usr/bin/env python2

# GREAT DANE ON THE BEAT

from bottle import error, route, run, template, request, redirect, get, post
import subprocess, json

try:
    LUAJIT = subprocess.check_output(["/usr/bin/env", "luajit"])
except subprocess.CalledProcessError:
    LUAJIT = "luajit-2.0.0-beta9"

debug = True

def lua_500(f):
    def wrapped_f(*args, **kwargs):
        output = None
        try:
            output = f(*args, **kwargs)
        except subprocess.CalledProcessError, e:
            if debug:
                output = "<!DOCTYPE html><html><body><pre>" + e.output + "</pre></body></html>"
            else:
                output = "Fug"
        return output
    return wrapped_f


@error(404)
def error404(error):
    return "<h1>\"Welcome to die|</h1>\
<!-- Jesus this layout -->"

@post("/")
@lua_500
def root_post():
    mheader = request.get_header("host")
    json_val = json.dumps({k:v for k,v in request.POST.items()})
    return subprocess.check_output([LUAJIT, "./src/root.lua", "--", mheader, json_val], stderr=subprocess.STDOUT)

@get("/")
@lua_500
def root_get():
    mheader = request.get_header("host")
    return subprocess.check_output([LUAJIT, "./src/root.lua", "--", mheader])

def main():
    run(host='localhost', port=8080)

if __name__ == '__main__':
    main()
