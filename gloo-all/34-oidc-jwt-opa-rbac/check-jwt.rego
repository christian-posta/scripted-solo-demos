package test

default allow = false

allow {
    [header, payload, signature] = io.jwt.decode(input.state.jwt)
    payload["email"] = "admin@example.com"
}
allow {
    [header, payload, signature] = io.jwt.decode(input.state.jwt)
    payload["email"] = "user@example.com"
    not startswith(input.http_request.path, "/owners")
}
