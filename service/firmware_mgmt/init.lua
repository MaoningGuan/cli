local skynet = require "skynet"

local CMD = {}

function CMD.version(source, fd)
    local version = {'5.0.0.1', 'B005', '23:08:30 Oct 13 2022'}
    skynet.send(source, "lua", "cli_rsp", fd, version)
end

skynet.start(function ()
    skynet.error('-----start firmware service------')
    skynet.dispatch('lua', function (session, source, cmd, ...)
        local f = assert(CMD[cmd])
        f(source, ...)
    end)
end)