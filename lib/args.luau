local lib = {}

function lib.string(input: string): string
	return input
end

function lib.number(input: string): number?
	return tonumber(input)
end

function lib.boolean(input: string): boolean?
	if input == "true" or input == "1" then
		return true
	end
	if input == "false" or input == "0" then
		return false
	end

	return
end

return lib
