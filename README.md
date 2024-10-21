# cfx-http ![](https://img.shields.io/github/v/release/itIsMaku/cfx-http)

Lightweight HTTP server and client library designed for the [CitizenFX framework](https://github.com/citizenfx/fivem) (such as [FiveM](https://fivem.net)). It allows developers to easily create and manage HTTP servers within their scripts, as well as send HTTP requests to external services. With built-in support for GET and POST methods, route handling, and optional authorization mechanisms, cfx-http simplifies HTTP communication in your projects. It also provides synchronous and asynchronous request capabilities, making it flexible for various use cases.

## Usage

### Setting Up an HTTP Server
This example sets up an HTTP server that handles a GET request at /status and a POST request at /data, with optional authorization for the POST route.
```lua
local server = exports['cfx-http']:http().server()

-- Handle GET request at "/status" route
server.get("/status", function(req, res)
    res(200, "Server is running!", { ["Content-Type"] = "text/plain" })
end)

-- Handle POST request at "/data" route with authorization
server.post("/data", function(req, res)
    local requestBody = json.decode(req.body)

    -- Process incoming data
    ...

    res(...)
end, "Bearer my_secret_token")

-- Start the server
server.build()
```

#### Builder
This example demonstrates how to use the [builder pattern](https://refactoring.guru/design-patterns/builder) with method chaining, allowing you to define routes and then build the server in one fluent flow.

```lua
local http = exports['cfx-http']:http()

http.server()
   .get("/status", function(req, res)
       res(200, "Server is running!", { ["Content-Type"] = "text/plain" })
   end)
   .post("/data", function(req, res)
       local requestBody = json.decode(req.body)

       -- Process incoming data
       ...

        res(...)
   end, "Bearer my_secret_token")
   .build()
```

## HTTP Requests as a Client
In this example, the client sends a GET request to an external URL and a POST request with JSON data.

```lua
local http = exports['cfx-http']:http()

local response = http.get("https://yourserver:30120/<resource>/status")
local response = http.get("https:/google.com")
print("Response Status: " .. response.status)
print("Response Body: " .. response.body)
```

```lua
local http = exports['cfx-http']:http()

local response = http.post("https://yourserver:30120/<resource>/setdata", {
    ["Content-Type"] = "application/json"
})

print("Response Status: " .. response.status)
print("Response Body: " .. response.body)
```

### Asynchronous Requests
For asynchronous use, you can provide a callback to handle the response when it's ready.

```lua
local http = exports['cfx-http']:http()

http.post("https://api.example.com/data", {
    ["Content-Type"] = "application/json"
}, function(response)
    print("Async Response Status: " .. response.status)
    print("Async Response Body: " .. response.body)
end)
```

## License 

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.


This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.


You should have received a copy of the GNU General Public License
along with this program.
If not, see <https://www.gnu.org/licenses/>
