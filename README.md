# this project is unlikely to recieve any updates in the future

# Important
- **I haven't tested very thoroughly so theres probably bugs**
- There is no command interface, you will have to make one yourself.
- There is also no autocomplete.

## Installation

Wally:
```vconsole = "borritomes/vconsole@0.1.7"```
Manual:
copy and paste

## How to use

### Running commands

**commands have a character limit of 1024 characters it can be changed by editing vconsole._MAX_COMMAND_LENGTH**<br>
Commands are run with `vconsole.runCommand`.

### Registering commands

Commands are registered with `vconsole.registerCommands`. Commands are created with the `vconsole.createCommand` contructer.

### Args

The code is very simple so it should be easy to figure out yourself

### Aliases

Alias work mostly the same as in the source engine developer console.

#### Registering aliases

Aliases are registered with `vconsole.registerAlias`, it takes the alias name as the first parameter and the alias' value as the second.

#### Cross session alias storage
Aliases are **not** automatically saved across sessions. `vconsole.getAliases` can be used to get a map of all registerd aliases, the map can then be stored in a datastore. `vconsole.importAliases` can be used to import a map of aliases usually used for imported aliases saved in datastores.

*there are a few other things you can do that aren't documented. You'll have to look through the code for that*
