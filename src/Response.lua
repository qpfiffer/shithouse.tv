local Response = {}
Response.__index = Response

function Response:init(body, status_code, content_type, body_len)
    init = {
        status_code = status_code or 200,
        body = body or "",
        content_type = content_type or "text/html; charset=utf-8",
        body_len = body_len or 0
    }

    setmetatable(init, self)
    return init
end

return Response
