#!/usr/bin/env python2

from bottle import route, run, template, request
import subprocess

try:
    LUAJIT = subprocess.check_output(["/usr/bin/env", "luajit"])
except subprocess.CalledProcessError:
    LUAJIT = "luajit-2.0.0-beta9"

@route("/")
def root():
    mheader = request.get_header("host")
    return subprocess.check_output([LUAJIT, "./src/root.lua", "--", mheader])

def main():
    run(host='localhost', port=8080)

if __name__ == '__main__':
    main()
