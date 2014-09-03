#!/usr/bin/env python2

# GREAT DANE ON THE BEAT

from bottle import error, route, run, template, request, redirect, get, post
import subprocess, json

LUAJIT = "luajit-2.0.0-beta9"

debug = True

def lua_500(f):
    def wrapped_f(*args, **kwargs):
        output = None
        try:
            output = f(*args, **kwargs)
        except subprocess.CalledProcessError, e:
            if debug:
                output = "<!DOCTYPE html><html><body><p>Fat error</p><pre>" + e.output + "</pre></body></html>"
            else:
                output = "Fug"
        return output
    return wrapped_f


@error(404)
def error404(error):
    return "<h1>\"Welcome to die|</h1>\
<!-- Jesus this layout -->"

@post("/")
@get("/")
@lua_500
def root_post():
    mheader = request.get_header("host")
    if request.POST:
        json_val = json.dumps({k:v for k,v in request.POST.items()})
        return subprocess.check_output([LUAJIT, "./src/root.lua", "--", mheader, json_val], stderr=subprocess.STDOUT)
    return subprocess.check_output([LUAJIT, "./src/root.lua", "--", mheader], stderr=subprocess.STDOUT)

def main():
    run(host='localhost', port=8080)

if __name__ == '__main__':
    main()
