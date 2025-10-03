# pre 1.0 software there will be breaking changes and stuff

## Installation

copy and paste `devconsole.luau`

## How to use

### Running commands

**commands have a character limit of 1024 characters it can be changed by editing devconsole._MAX_COMMAND_LENGTH**
to run commands use `devconsole.runCommand`. You will have to make your own ui but I do plan on making one with Fusion sometime in the future

### Registering commands

commands can be registered with `devconsole.registerCommands`. The function takes a command in the form of a table table but commands can also be constructed with `devconsole.createCommand`.

### Aliases

alias work the same as in the source developer console (i think)

#### Registering aliases

aliases are registered with `devconsole.registerAlias` it takes the alias name as the first parameter and the alias' value as the second

#### Cross session alias storage
aliases are **not** saved across sessions. If you what to save them you get use `devconsole.getAliases` to get a dictionary of all the aliases and save that in a datastore somewhere then use `devconsole.importAliases` to import the aliases.

*there are a few other things you can do but you can look through the code for that. It's only ~250 lines*
