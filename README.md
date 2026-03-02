# this project is unlikely to recieve any updates in the future

# Important
- **I haven't tested this very thoroughly so there will probably be bugs**
- There is no console interface, you will have to make one yourself.
- There is also no autocomplete.

## Installation

Wally:<br>
```vconsole = "borritomes/vconsole@0.2.1"```<br>
Manual:<br>
copy and paste

## How to use

### Running commands

**commands have a character limit of 1024 characters. This can be changed by editing vconsole._MAX_COMMAND_LENGTH**<br>
Commands are run with `vconsole.runCommand`.

### Registering commands

Commands are registered with `vconsole.registerCommand`. Commands are created with the `vconsole.createCommand` contructor.<br>

Example:
```lua
args = vconsole.args

vconsole.registerCommand("sv_cheats", vconsole.createCommand(
  function()
    --set cheats to true
  end,
  {
    args.boolean
  },
  --protection
  --an optional callback to check if a the command should be ran
  function()
    if canUseCommand then
      return true
    else
      return false
    end
  end,
)
```

### Args

Args is a simple type checker/converter<br>
will return a result (boolean) and value converted from string<br>
will fail by returning false if string can not be converted

### Aliases

Alias work mostly the same as in the source engine developer console.

#### Registering aliases

Aliases are registered with `vconsole.registerAlias`, it takes the alias name as the first parameter and the alias' value as the second.

#### Cross session alias storage
Aliases are **not** automatically saved across sessions. `vconsole.getAliases` can be used to get a map of all registerd aliases, the map can then be stored in a datastore. `vconsole.importAliases` can be used to import a map of aliases usually used for imported aliases saved in datastores.

*there are a few other things you can do that aren't documented. You'll have to look through the code for that*
