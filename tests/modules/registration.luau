local vconsole = require("../../vconsole")
local args = vconsole.args

function test()
    vconsole.registerCommand(
        "output",
        vconsole.createCommand(
            function(output: string): boolean
                print(output)
                return true
            end,
            {args.string}
        )
    )
    
    print('registered command "output"')
    vconsole.registerCommand(
        "output2",
        vconsole.createCommand(
            function(output1: string, output2: string): boolean
                print(output1, output2)
                return true
            end,
            {args.string, args.string}
        )
    )
	vconsole.registerCommand(
		"sum",
		vconsole.createCommand(function(rhs: number, lhs: number): boolean
			print(rhs + lhs)
			return true
		end, { args.number, args.number })
	)
	print('registered command "sum"')
	vconsole.registerCommand(
		"printVec",
		vconsole.createCommand(function(arg: vector): boolean
            print(`vector {arg}`)
			return true
		end,
        {function(input: string): (boolean, vector?)
            input:gsub("%s+", " ")
            local vecs = input:split(" ")

            return true, vector.create(tonumber(vecs[1]) or 0, tonumber(vecs[2]) or 0, tonumber(vecs[3]) or 0)
		end}
    )
	)
	print('registered command "printVec"')
    vconsole.runCommand('printVec "6 7 2"')
end

return {test = test}