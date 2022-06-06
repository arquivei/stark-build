# Stark Build System

This is a build system based on Makefiles that provides compilation and publishing capabilities focused on golang projects at Arquivei.

## Requirements

- git
- gnu make

## Setup

Adds this repository as a submodule or download the files inside a directory.

```shell
git submodule add git@bitbucket.org:arquivei/stark-build.git tooling/stark-build
```

NOTE: The `tooling` sub-directory is just a suggestion that most projects follows.

Import the primary Makefile into your Makefile

```makefile
# File: Makefile

## Your other stuff here
## ...

# Enables stark-build
include tooling/stark-build/Makefile
```

## Usage

For information on variables and targets use the `help` target:

```shell
make help
```

The Makefiles contains comments and are relatively well structured. For extra information on default values, for example, you should check the files.

You can override most of the variables but they already come with some sane defaults. It is possible to use this project without any customization.

## Architecture

The entry point of this project is the `Makefile` in the root directory. This should be the only file included by projects using stark-build.

All the features are provided by _modules_. Modules are directories inside `modules/` directory which contains a `Makefile`. The module name is the directory. For example, `modules/golang/Makefile` denotes the `golang` module. The root `Makefile` is loaded, it includes the `Makefile` of each enabled module. If a module is split into multiple files, it's expected that the module's `Makefile` will take care of these includes.

Modules can be dynamically loaded. By default all modules are enabled and should work (at least not break any other module) out of the box. It means that variables should have sane defaults and error checks should be done inside targets.

Important bits should be documented to appears in the `make help` target. The help script uses `##` to extract comments and build the help text. Use the existing documentation as example. Here is an example:

```makefile
## #####################################
##
## Module: My module
##
## Some module description

## Some section

## Important variables should be documented
## Coments can be multiline
MY_VAR ?= sane default

## This documents a target
my-target:
    do stuff
```

## Contributing

Fell free to post comments, open issues or pull-requests.
