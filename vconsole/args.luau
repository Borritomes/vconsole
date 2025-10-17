local lib = {}

function lib.string(input: string): (boolean, string)
	return true, input
end

function lib.number(input: string): (boolean, number?)
	local toNum = tonumber(input)
	if toNum == nil then
		return false
	else
		return true, toNum
	end
end

function lib.boolean(input: string): (boolean, boolean?)
	if input == "true" or input == "1" then
		return true, true
	end
	if input == "false" or input == "0" then
		return true, false
	end

	return false
end

function lib.option<T>(typeCheck: (string) -> (boolean, T))
	return function(input: string): T?
		local ok, checked = typeCheck(input)
		if ok == true then
			return checked
		else
			return nil
		end
	end
end

return lib
