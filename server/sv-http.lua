http = {}

function http.server()
    local self = {
        routes = {}
    }

    function self.route(method, path, callback, auth)
        self.routes[path] = {
            method = method,
            callback = callback,
            auth = auth
        }

        return self
    end

    function self.get(path, callback, auth)
        return self.route('GET', path, callback, auth)
    end

    function self.post(path, callback, auth)
        return self.route('POST', path, callback, auth)
    end

    function self.put(path, callback, auth)
        return self.route('PUT', path, callback, auth)
    end

    function self.patch(path, callback, auth)
        return self.route('PATCH', path, callback, auth)
    end

    function self.delete(path, callback, auth)
        return self.route('DELETE', path, callback, auth)
    end

    function self.build()
        SetHttpHandler(function(request, response)
            for path, route in pairs(self.routes) do
                if request.method == route.method and request.path == path then
                    local p = promise.new()
                    local cb = function(status, responseBody, responseHeaders)
                        p:resolve({
                            status = status,
                            headers = responseHeaders,
                            body = responseBody,
                        })
                    end

                    if route.auth then
                        if request.headers['Authorization'] ~= route.auth then
                            cb(401, json.encode({
                                code = 401,
                                message = 'Unauthorized'
                            }), { ['Content-Type'] = 'application/json' })
                        end
                    end

                    if p.value == nil then
                        route.callback(request, cb)
                    end

                    local res = Citizen.Await(p)

                    response.writeHead(res.status or 200, res.headers or { ['Content-Type'] = 'text/plain' })
                    if res.body then
                        response.write(res.body)
                    end

                    response.send()
                    return
                end
            end
        end)
    end

    return self
end

function http.request(method, url, headers, body, async)
    local p = async == nil and promise.new() or nil

    PerformHttpRequest(url, function(status, responseBody, responseHeaders, errorData)
        local data = {
            status = status,
            body = responseBody,
            headers = responseHeaders,
            errors = errorData
        }

        if async ~= nil then
            async(data)
            return
        end

        p:resolve({
            status = status,
            body = responseBody,
            headers = responseHeaders,
            errors = errorData
        })
    end, method, body or '', headers or {})

    if async ~= nil then
        return
    end

    return Citizen.Await(p)
end

function http.post(url, headers, body, async)
    return http.request('POST', url, headers, body, async)
end

function http.get(url, headers, async)
    return http.request('GET', url, headers, nil, async)
end

exports('http', function()
    return http
end)
