--!nolint LocalUnused
--!nolint FunctionUnused

export type command = {
	callback: (any) -> boolean,
	args: { (string) -> any }?,
	protection: (() -> boolean)?,
}

local commandRegistry: { [string]: command? } = {}
local aliasRegistry: { [string]: string? } = {}

local vconsole = {}
vconsole.args = require("./args")

vconsole._MAX_COMMAND_LENGTH = 1024

local function parseCommand(commandString: string): {
	func: (any) -> boolean?,
	protection: (() -> boolean)?,
	args: { string? },
	argConverter: { (string) -> any }?,
}?
	if commandString == "" then
		return
	end
	local isInParentheses = false

	local words = {}
	local currentWord = ""
	local chars = ""

	--split into words and make stuff in parentheses its own word
	for i, char in commandString:split("") do
		chars ..= char
		if char == '"' then
			isInParentheses = not isInParentheses
			continue
		end

		if isInParentheses == true then
			if char == '"' then
				isInParentheses = false
				continue
			end

			currentWord ..= char
			continue
		end

		if char == " " then
			if currentWord ~= "" then
				table.insert(words, currentWord)
				currentWord = ""
			end
			continue
		end

		currentWord ..= char
	end
	if currentWord ~= "" then
		table.insert(words, currentWord)
	end

	local commandName = words[1]

	--if there is no command name
	if commandName == nil then
		warn("invalid command")
		return
	end

	local args = {}

	if #words >= 2 then
		args = table.clone(words)
		table.remove(args, 1)
	end

	local command = commandRegistry[commandName]
	if command ~= nil and command.callback ~= nil then
		return {
			func = command.callback,
			protection = command.protection,
			args = args,
			argConverter = command.args,
		}
	elseif aliasRegistry[commandName] ~= nil then
		return {
			func = function()
				local alias = aliasRegistry[commandName]
				if alias ~= nil then
					return vconsole.runCommand(alias)
				else
					warn("no alias found with the name " .. commandName)
					return false
				end
			end,
			args = {},
		}
	end

	warn("no command or alias found named " .. commandName)
	return
end

local function splitCommand(command: string)
	local commands = command:split(";")

	for i, command in commands do
		--make command easier to work with
		--converts '   a b   "  c  "  d ' to 'a b "  c  "  d'
		local quoted = {}
		command:gsub('"(.-)"', function(q)
			table.insert(quoted, q)
			return "\0" .. #quoted
		end)

		command:gsub("%s+", " ")

		command:gsub("\0(%d+)", function(i: string)
			return '"' .. quoted[tonumber(i) or 1] .. '"'
		end)

		if command:gsub("%s+", "") == "" then
			table.remove(commands, i)
		end
	end

	return commands
end

--[[
    Run a command from a string
    <p><strong>examples:</strong><br><code>
    vconsole.runCommand("bind w +forward")<br>
    vconsole.runCommand('alias jumpthrow "+jump; +attack"')</code>
    <br><sup>bind and action commands not included</sup></p>
]]
function vconsole.runCommand(commandString: string)
	if commandString:len() > vconsole._MAX_COMMAND_LENGTH then
		warn(
			"Command of length " .. commandString:len() .. " is to long. Max length is " .. vconsole._MAX_COMMAND_LENGTH
		)
		return false
	end
	local commands = splitCommand(commandString)

	for _, command in commands do
		local result = parseCommand(command)
		if result == nil then
			return false
		end

		local convertedArgs = {}

		if result.argConverter ~= nil then
			for i, arg in result.args do
				if arg == nil then
					continue
				end
				if result.argConverter[i] ~= nil then
					table.insert(convertedArgs, result.argConverter[i](arg))
				end
			end
		end

		if result.protection == nil then
			result.func(table.unpack(convertedArgs))
		elseif result.protection() == true then
			result.func(table.unpack(convertedArgs))
		else
			warn("command is protected")
		end
	end

	return true
end

--[[
    The same as <code>runCommand</code> but without the character limit<br>
    <sup>character limit can be changed with the <code>vconsole._MAX_COMMAND_LENGTH</code> variable</sup>
]]
function vconsole.runCommandUnrestriced(commandString: string): boolean
	local commands = splitCommand(commandString)

	for _, command in commands do
		local result = parseCommand(command)
		if result == nil then
			return false
		end
		result.func(table.unpack(result.args))
	end

	return true
end

--[[
    Register a command to the command registry<br>
    The command registry is a table of commands that can be executed
    <p>commands can are just dictionaries but can also be created with the <code>vconsole.createCommand</code> function</p>
]]
function vconsole.registerCommand(name: string, command: command)
	commandRegistry[name] = command
end

--[[
    Remove an alias from the registry
    @param command name
    @return if the alias existed
]]
function vconsole.removeCommand(name: string) end

--[[
    Function to create commands
]]
function vconsole.createCommand(callback: (any) -> boolean, protection: (() -> boolean)?): command
	return {
		callback = callback,
		protection = protection,
	}
end

--[[
    Get all currently registered commands<br>
    register commands with <code>registerCommand</code>
]]
function vconsole.getCommands()
	return commandRegistry
end

--[[
        <p>Import a table <code>{[string]: string}</code> of aliases</p>
        <strong>Warning: overwrites all existing aliases</strong>, 
        this is mainly meant for importing aliases from a datastore when a player joins
]]
function vconsole.importAliases(aliases: { [string]: string })
	aliasRegistry = aliases
end

--[[
    Register a alias to the alias registry<br>
    the built in <code>alias</code> command adds aliases to the registry
]]
function vconsole.registerAlias(name: string, commandString: string)
	aliasRegistry[name] = commandString
end

--[[
    Get all currently registered aliases<br>
    register aliases with <code>importAliases</code> or <code>registerAlias</code>
]]
function vconsole.getAliases()
	return aliasRegistry
end

--[[
    Remove specified alias from the registry
    @param alias name
    @return if the alias existed
]]
function vconsole.removeAlias(aliasName: string): boolean
	if aliasRegistry == nil then
		return false
	end

	aliasRegistry[aliasName] = nil
	return true
end

vconsole.registerCommand(
	"alias",
	vconsole.createCommand(function(aliasName: unknown, aliasString: unknown)
		if typeof(aliasName) == "string" and typeof(aliasString) == "string" then
			print("alias registered")
			vconsole.registerAlias(aliasName, aliasString)
			return true
		end
		return false
	end)
)

return vconsole
