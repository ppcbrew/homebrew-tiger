# homebrew-tiger

This is a [tap](https://docs.brew.sh/Taps)
for the [tigerbrew](https://github.com/mistydemeo/tigerbrew) project,
a fork of [homebrew](https://brew.sh/)
for [PowerPC](https://en.wikipedia.org/wiki/PowerPC)
[Macs](https://en.wikipedia.org/wiki/Macintosh)
running OS X [Tiger](https://en.wikipedia.org/wiki/Mac_OS_X_Tiger) (10.4)
or [Leopard](https://en.wikipedia.org/wiki/Mac_OS_X_Leopard) (10.5).

I use this tap to host [my](https://jason.pepas.com)
pre-built [bottles](https://docs.brew.sh/Bottles).

If you would like to use this tap:

```
$ brew tap ppcbrew/tiger
```

Then, to install a package:

```
$ brew update
$ brew install ppcbrew/tiger/gcc
```

Or, use the `ppcbrew` script, which wraps brew and automatically prefixes the formula with the tap name.

```
$ ppcbrew install gcc
```

The `ppcbrew` script and other scripts are available in the [bin]() directory of this repo.
Symlink them into your $PATH (e.g. `~/bin`):

```
cd ~/bin
ln -s /usr/local/Library/Taps/ppcbrew/homebrew-tiger/bin/* .
```

I am currently building bottles for Leopard/G5, Tiger/G4e and Tiger/G3.

Use `grep` to see which bottles are available for your OS/arch combo, e.g.:

```
$ grep tiger_g3 /usr/local/Library/Taps/ppcbrew/homebrew-tiger/Formula/*.rb
/usr/local/Library/Taps/ppcbrew/homebrew-tiger/Formula/autoconf.rb:    sha256 "db48bb50432cb22ce5cda7348e4f7a9ecce367f94e30cac554be52e802454978" => :tiger_g3
/usr/local/Library/Taps/ppcbrew/homebrew-tiger/Formula/automake.rb:    sha256 "3686873011c254740d2d8aae21bc712ac6c95d63715d338a6a09c47cd2a14395" => :tiger_g3
/usr/local/Library/Taps/ppcbrew/homebrew-tiger/Formula/gcc.rb:    sha256 "8b1f5a4c26567fd461fe09dba814ecbacab9248612b3847376a84282142377d8" => :tiger_g3
...
```

Or more specifically:

```
$ grep '=> :tiger_g3' /usr/local/Library/Taps/ppcbrew/homebrew-tiger/Formula/*.rb | awk '{ print $1 }' | xargs -n1 basename | sed 's/\.rb://'
autoconf
automake
gcc
gdbm
...
```

If you would like to see bottles built for additional OS/arch combos,
I will happily accept a build machine hardware donation! :)
