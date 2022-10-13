local params = { ... }
-- print(params[1])-- first parameter, if any.
-- print(params[2]) -- second parameter, if any.
-- print(#params)   -- number of parameters.
local socket = require("socket")

-- 字符串消息解码
local str_unpack = function(msgstr)
    local msg = {}

    while true do
        local arg, rest = string.match(msgstr, "(.-),(.*)")
        if arg then
            msgstr = rest
            table.insert(msg, arg)
        else
            table.insert(msg, msgstr)
            break
        end
    end

    return msg
end

-- 字符串消息编码
local str_pack = function(msg)
    return table.concat(msg, ',') .. '\r\n'
end

-- cli服务端IP和端口
local cli_ip = "127.0.0.1"
local cli_port = 8888

--打开一个TCP连接
local c = assert(socket.connect(cli_ip, cli_port))
c:settimeout(5)  -- 设置超时时间
c:send(str_pack {'ipmcget', params[1], params[2]})  -- 发送：ipmcget,-d,version
local s, status, partial = c:receive()  -- 非阻塞等待
local version = str_unpack(s)
print('Version: '..version[1])
print('BuildNum: '..version[2])
print('ReleaseDate: '..version[3])
c:close()
