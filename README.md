
# Install

**Still in alpha.** Expect more bugs than features.

## What Install is not

`Install` is not a dependency manager. It does not download dependencies from remote repositories or allow you to manage semantic versions of packages.

## Overview

`Install` is a leightweight tool for extracting modules from [META6](https://github.com/jonathanstowe/META6)-compliant projects into a `Rakudo` environment. The META6 attribute that `Install` cares about is `provides`.

The keys in the `provides` attribute are used as targets, while the value is interpreted as the path relative to `META6.json`.

Example:

```
$ tree $RAKULIB
/raku/lib
$ cat META6.json
...
"bin": {
   "my-cli" : "bin/cli"
   "my-log" : "logging/bin/log"
},
"provides": {
   "MyModule"             : "lib/MyModule.rakumod",
   "MyModule::MyClass"    : "lib/MyModule/MyClass.rakumod",
   "MyModule::SomePlugin" : "plugins/SomePlugin.pm6"
}
...
$ install .
$ tree $RAKULIB
/raku/lib
├── MyModule.rakumod
└── MyModule
    ├── MyClass.rakumod
    └── SomePlugin.rakumod

```

# Use

## Manual Bootstrap

To install `Install` itself, simply run

    $ cd raku-install
    $ raku -I ./lib ./bin/install .

## bin

# Before You Ask

## Why not symlinks?

`Install` is primarily intended to aid in the automated setup of `rakudo` environments, particularly Docker containers. While symlinks can technically work, it's more sane to copy files rather than symlink them, as the container cannot necessarily access the link's target.

