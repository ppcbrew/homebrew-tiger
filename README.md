# ppcbrew/homebrew-tiger, a tap for tigerbrew

This is a [tap](https://docs.brew.sh/Taps)
for the [tigerbrew](https://github.com/mistydemeo/tigerbrew) project,
which is a fork of [homebrew](https://brew.sh/)
for [PowerPC](https://en.wikipedia.org/wiki/PowerPC)
[Macs](https://en.wikipedia.org/wiki/Macintosh)
running OS X [Tiger](https://en.wikipedia.org/wiki/Mac_OS_X_Tiger) (10.4)
or [Leopard](https://en.wikipedia.org/wiki/Mac_OS_X_Leopard) (10.5).

I use this tap to host [my](https://jason.pepas.com)
pre-built [bottles](https://docs.brew.sh/Bottles).

## Using this tap

If you would like to use this tap:

```
brew tap ppcbrew/tiger
```

Then, to install a package:

```
brew update
brew install ppcbrew/tiger/gcc
```

Or, use the `ppcbrew` script, which wraps brew and automatically prefixes the formula with the tap name.

```
ppcbrew install gcc
```

The `ppcbrew` script and other scripts are available in the
[bin](https://github.com/ppcbrew/homebrew-tiger/tree/master/bin) directory of this repo.
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


## Merging these formula upstream (to tigerbrew)

Pulling these updated formulae back into tigerbrew will require undoing the tap-specific modifications which I perform:
- I add `revision 100` to each formula to avoid naming naming conflicts
- I prefix all dependencies with my tap name
- I add bottle shas for the bottles I build
- I add a `root_url` for my bottles

Something like this should (mostly) do it:

```
sed -i.bak '/revision 100/d' foo.rb
sed -i.bak 's?ppcbrew/tiger??g' foo.rb
sed -i.bak '/sha.*=> :tiger_g3/d' foo.rb
sed -i.bak '/sha.*=> :tiger_g4e/d' foo.rb
sed -i.bak '/sha.*=> :tiger_g5/d' foo.rb
sed -i.bak '/root_url/d' foo.rb
rm foo.rb.bak
```
