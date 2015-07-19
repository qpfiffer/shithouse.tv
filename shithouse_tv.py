#!/usr/bin/env python2

# GREAT DANE ON THE BEAT

from bottle import error, route, run, template, request, redirect, get, post, HTTPResponse
import subprocess, json

LUAJIT = "luajit"
TMPFILE_LOC = "/tmp/"

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


def call_lua(filename, *args):
    return subprocess.check_output([LUAJIT, filename, "--"] + list(args), stderr=subprocess.STDOUT)

@error(404)
@lua_500
def error404(error):
    mheader = request.get_header("host")
    output = call_lua("./src/static.lua", mheader, request.path)
    mimetype="application/octet-stream"

    resp = HTTPResponse(body=output, status=200)
    mtype = "application/octet-stream"
    lowered = request.path.lower()
    if lowered.endswith("jpg") or lowered.endswith("jpeg"):
        mtype = "image/jpeg"
    elif lowered.endswith("gif"):
        mtype = "image/gif"
    elif lowered.endswith("png"):
        mtype = "image/png"
    elif lowered.endswith("webm"):
        mtype = "video/webm"

    resp.content_type = mtype
    return resp

@get("/tags/<tag>")
def tag_thing(tag=None):
    return call_lua("./src/tag.lua", tag)

@post("/")
@get("/")
@lua_500
def root_post():
    mheader = request.get_header("host")
    if request.POST:
        json_val = {k:v for k,v in request.forms.items()}

        image = request.files.get("image")
        if image:
            json_val["image"] = TMPFILE_LOC + image.filename
            image.save(TMPFILE_LOC, overwrite=True)

        music = request.files.get("music")
        if music:
            json_val["music"] = TMPFILE_LOC + music.filename
            music.save(TMPFILE_LOC, overwrite=True)
        return call_lua("./src/root.lua", mheader, json.dumps(json_val))
    return call_lua("./src/root.lua", mheader)

def main():
    run(server='paste', host='localhost', debug=debug, port=8090, reloader=True)

if __name__ == '__main__':
    main()
