local vconsole = require("../../vconsole")
local args = vconsole.args

local function test()
    vconsole.registerCommand("argtest", {
        callback = function(bool: boolean, num: number, str: string)
            print(bool, num, str)
            return true
        end,
        args = {
            args.boolean,
            args.number,
            args.string
        }
    })

    vconsole.runCommand('output2 "goot" "\0' .. '0"')
end

return {test = test}