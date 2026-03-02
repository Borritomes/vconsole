--!nolint LocalUnused
--!nolint FunctionUnused
--!nolint BuiltinGlobalWrite

export type command = {
	callback: (any) -> boolean,
	args: { (string) -> (boolean, any) }?,
	protection: (() -> boolean)?,
}

--parse command returns this type
--it has the data runCommand need to run a command
type commandData = {
	callback: (any) -> boolean?,
	protection: (() -> boolean)?,
	args: { string? },
	argConverter: { (string) -> (boolean, any) }?,
}

local commandRegistry: { [string]: command? } = {}
local aliasRegistry: { [string]: string? } = {}

--lute doesnt have warn implementation
local warn = print

local vconsole = {}
vconsole.args = require("@self/args")

vconsole._MAX_COMMAND_LENGTH = 1024

local function parseCommand(commandString: string): commandData?
	if commandString == "" then
		return nil
	end
	local isInQuotes = false

	local words: {string?} = {}
	local currentWord = ""

	--split into words and make stuff in parentheses its own word
	for _, char in commandString:split("") do
		if char == '"' then
			isInQuotes = not isInQuotes
			continue
		end

		if isInQuotes == true then
			-- if char == '"' then
			-- 	isInQuotes = false
			-- 	continue
			-- end

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
		return nil
	end

	local args = {}

	if #words >= 2 then
		args = table.clone(words)
		table.remove(args, 1)
	end

	local command = commandRegistry[commandName]
	if command ~= nil and command.callback ~= nil then
		return {
			callback = command.callback,
			protection = command.protection,
			args = args,
			argConverter = command.args,
		}
	elseif aliasRegistry[commandName] ~= nil then
		return {
			callback = function()
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
	return nil
end

local function splitCommand(commandString: string)
	--commands in a commandString are split by semi-colons
	--TODO: make sure semi-colons in whitespace do get split by this
	local commands = commandString:split(";")

	local nonEmptyCommands: {string} = {}

	for _, command in commands do
		--text in double-quotes is stored here temporarily so it gets perserved
		--from the whitespace formatter
		local quoted = {}

		--replaces everything in double-quotes with a token "\0"
		--and the index of the quote in the double-quoted strings table
		--the '"(.-)"' looks for any characters in double quotes
		--passes the characters into the function and replaces it with the returned value
		command:gsub('"(.-)"', function(stringInQuotes: string): string
			table.insert(quoted, stringInQuotes)
			return "\0" .. #quoted
		end)

		--replace white space with a single space
		--%s mean whitespace and the + means include all whitespace to the right until
		--it is interupted by a non-whitespace character
		command:gsub("%s+", " ")

		--puts the text in double-quotes back in the command
		--this looks for the token "\0" and the number after it (the %d means any digit)
		command:gsub("\0(%d+)", function(i: string)
			--if the quoted value is nil default to ""
			return '"' .. (quoted[tonumber(i) or 1] or "") .. '"'
		end)

		--only insert commands that aren't empty
		--the command:gsub returns what the command would be if all whitespace was removed
		if command:gsub("%s+", "") ~= "" then
			table.insert(nonEmptyCommands, command)
		end
	end

	return nonEmptyCommands
end

--[[
    Run a command from a string
    <p><strong>examples:</strong><br><code>
    vconsole.runCommand("bind w +forward")<br>
    vconsole.runCommand('alias jumpthrow "+jump; +attack"')</code>
    <br><sup>bind and action commands not included</sup></p>
]]
function vconsole.runCommand(commandString: string): boolean
	if commandString:len() > vconsole._MAX_COMMAND_LENGTH then
		warn(
			"Command of length " .. commandString:len() .. " is to long. Max length is " .. vconsole._MAX_COMMAND_LENGTH
		)
		return false
	end

	--split the commands by semi-colons and format them
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
					local success, convertResult = result.argConverter[i](arg)
					if success then
						table.insert(convertedArgs, convertResult)
					else
						warn("incorrect args")
						return false
					end
				end
			end
		end

		if result.protection == nil or result.protection() == true then
			result.callback(table.unpack(convertedArgs))
		else
			warn("command is protected")
		end
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
function vconsole.removeCommand(name: string)
	--this was empty until after 0.2.0, not sure why
	commandRegistry[name] = nil
end

--[[
    Function to create commands
]]
function vconsole.createCommand(callback: (any) -> boolean, args: { (string) -> (boolean, any) }?, protection: (() -> boolean)?): command
	return {
		callback = callback,
		args = args,
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
function vconsole.importAliases(aliases: { [string]: string? })
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

function vconsole.test()
	print("ran vconsole.test()")
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

return vconsole :: typeof(vconsole)