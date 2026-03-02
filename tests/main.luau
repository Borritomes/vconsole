local vconsole = require("../vconsole")
local registration = require("./modules/registration")
local args = require("./modules/args")

registration.test()
args.test()

vconsole.test()