local skynet = require "skynet"
local socket = require "skynet.socket"
local cli_config = require "cli_config"

local conns = {}    -- [fd] = conn
local fw_mgmt = nil

-- 连接类
local function conn()
    local m = {
        fd = nil
    }

    return m
end

-- 字符串消息解码
local str_unpack = function (msgstr)
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

    return msg[1], msg
end

-- 字符串消息编码
local str_pack = function (msg)
    return table.concat(msg, ',')..'\r\n'
end

---解析消息命令
---@param fd any
---@param msgstr any
local process_msg = function(fd, msgstr)
    local cmd, msg = str_unpack(msgstr)
    skynet.error("recv fd "..fd..":["..cmd.."]{"..table.concat(msg, ",").."}")

    if cmd == 'ipmcget' and msg[3] == 'version' then
        skynet.send(fw_mgmt, "lua", msg[3], fd)
    end
end

---解析客户端消息
---@param fd any
---@param readbuff any
---@return any
local process_buff = function(fd, readbuff)
    while true do
        local msgstr, rest = string.match(readbuff, "(.-)\r\n(.*)")
        if msgstr then
            readbuff = rest
            process_msg(fd, msgstr)
        else
            return readbuff
        end
    end
end

---@param fd any
local disconnect = function(fd)
    local c = conns[fd]
    if not c then
        return
    end

    conns[fd] = nil
end

-- 每一条连接接收数据处理
local recv_loop = function(fd)
    socket.start(fd)
    skynet.error("socket connected fd:"..fd)
    local readbuff = ""

    while true do
        local recvstr = socket.read(fd)
        if recvstr then
            readbuff = readbuff..recvstr
            readbuff = process_buff(fd, readbuff)
        else
            skynet.error("socket close fd:"..fd)
            disconnect(fd)
            socket.close(fd)
            return
        end
    end
end

local connect = function(fd, addr)
    skynet.error("connected from " .. addr .. " fd:" .. fd)
    local c = conn()
    conns[fd] = c
    c.fd = fd
    skynet.fork(recv_loop, fd)
end

local CMD = {}

CMD.cli_rsp = function (source, fd, rsp)
    skynet.error("send fd "..fd..str_pack(rsp))
    socket.write(fd, str_pack(rsp))
end

skynet.start(function ()
    skynet.error('-----start cli server------')
    fw_mgmt = skynet.uniqueservice('firmware_mgmt')
    local listenfd = socket.listen(cli_config.cli_ip, cli_config.cli_port)
    skynet.error("cli server listen to:", cli_config.cli_ip, cli_config.cli_port)
    socket.start(listenfd, connect)
    skynet.dispatch('lua', function (session, source, cmd, ...)
        local f = assert(CMD[cmd])
        f(source, ...)
    end)
end)