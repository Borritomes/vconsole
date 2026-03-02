--arg converters don't have to be from here
--you can use any function that takes a string and return (boolean, any)

--[[
types:
- player
- string
- number
- boolean

others stuff:
- option (allows the type to be optional)
]]

local lib = {}

--this in disabled because it has a roblox dependancy
--if you want to use this I would recommend copy and pasting it into your codebase
--[[
function lib.player(input: string): (boolean, Player?)
	local player: Player?
		for i, potentialPlayer in Players:GetPlayers() do
			if potentialPlayer.Name:lower() == input:lower() then
				player = potentialPlayer
			elseif potentialPlayer.DisplayName:lower() == input:lower() then
				if player == nil then
					player = potentialPlayer
				end
			end
		end

	if player == nil then
		return false, nil
	end

	return true, player
end
]]

function lib.string(input: string): (boolean, string)
	return true, input
end

function lib.number(input: string): (boolean, number?)
	local toNum = tonumber(input)
	if toNum == nil then
		return false, nil
	else
		return true, toNum
	end
end

--the number converter but with a inclusive clamp
function lib.clampedNumber(min: number, max: number): (string) -> (boolean, number?)
	return function(input: string)
		local ok, checked = lib.number(input)
		if ok == true and checked ~= nil then
			if checked >= min and checked <= max then
				return true, checked
			end
		end
		return false, nil
	end
end

--convert to boolean
function lib.boolean(input: string): (boolean, boolean?)
	if input == "true" or input == "1" then
		return true, true
	end
	if input == "false" or input == "0" then
		return true, false
	end

	return false, nil
end

--[[
	Makes an argument optional<br>
	```
	args = {
		t.number, -- not needed but can put non-optionals before optional
		t.option(t.boolean)
	}
	```
]]
function lib.option<T>(typeCheck: (string) -> (boolean, T)): (string) -> (boolean, T)
	return function(input: string): (boolean, T)
		local ok, checked = typeCheck(input)
		if ok == true then
			return true, checked
		else
			return false, nil
		end
	end
end

return lib
