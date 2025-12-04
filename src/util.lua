local Util = {}

function Util.isWindows()
    return package.config:sub(1, 1) == '\\'
end

function Util.isUnix()
    return package.config:sub(1, 1) == '/'
end

return Util
