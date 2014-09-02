#!/usr/bin/env python2

# GREAT DANE ON THE BEAT

from bottle import error, route, run, template, request, redirect, get, post
import subprocess, json

try:
    LUAJIT = subprocess.check_output(["/usr/bin/env", "luajit"])
except subprocess.CalledProcessError:
    LUAJIT = "luajit-2.0.0-beta9"

@error(404)
def error404(error):
    return "<h1>\"Welcome to die|</h1>\
<!-- Jesus this layout -->"

@post("/")
def root_post():
    mheader = request.get_header("host")
    json_val = json.dumps({k:v for k,v in request.POST.items()})
    return subprocess.check_output([LUAJIT, "./src/root.lua", "--", mheader, json_val])

@get("/")
def root_get():
    mheader = request.get_header("host")
    return subprocess.check_output([LUAJIT, "./src/root.lua", "--", mheader])

def main():
    run(host='localhost', port=8080)

if __name__ == '__main__':
    main()
