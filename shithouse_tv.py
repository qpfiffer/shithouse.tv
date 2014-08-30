#!/usr/bin/env python2

# GREAT DANE ON THE BEAT

from bottle import error, route, run, template, request, redirect
import subprocess

try:
    LUAJIT = subprocess.check_output(["/usr/bin/env", "luajit"])
except subprocess.CalledProcessError:
    LUAJIT = "luajit-2.0.0-beta9"

@error(404)
def error404(error):
    return "<h1>\"Welcome to die|</h1>\
<!-- Jesus this layout -->"

@route("/")
def root():
    mheader = request.get_header("host")
    return subprocess.check_output([LUAJIT, "./src/root.lua", "--", mheader])

def main():
    run(host='localhost', port=8080)

if __name__ == '__main__':
    main()
