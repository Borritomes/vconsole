# pre 1.0 software there will be breaking changes and stuff

# Important
- **I haven't tested very thoroughly so theres probably some bugs**
- At the moment there is no interface and if there is one in the future it will be separate.
- There is also no autocomplete I would like to add one in the future but it sounds complicated so I'm putting it off for now 😓.
- there is no wally right now and there probably won't be a pesde package but, I plan to keep everything in one file so that hopefully shouldn't be too much of an issue.

## Installation

copy and paste `vconsole.luau`

## How to use

### Running commands

**commands have a character limit of 1024 characters it can be changed by editing vconsole._MAX_COMMAND_LENGTH**
to run commands use `vconsole.runCommand`.

### Registering commands

commands can be registered with `vconsole.registerCommands`. The function takes a command in the form of a table table but commands can also be constructed with `vconsole.createCommand`.

### Aliases

alias work the same as in the source developer console (i think)

#### Registering aliases

aliases are registered with `vconsole.registerAlias` it takes the alias name as the first parameter and the alias' value as the second

#### Cross session alias storage
aliases are **not** saved across sessions. If you what to save them you get use `vconsole.getAliases` to get a dictionary of all the aliases and save that in a datastore somewhere then use `vconsole.importAliases` to import the aliases.

*there are a few other things you can do but you can look through the code for that. It's only ~250 lines*
