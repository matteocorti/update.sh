
 &copy; Matteo Corti, 2018-2025

![](https://img.shields.io/github/v/release/matteocorti/update.sh)&nbsp;![](https://img.shields.io/github/downloads/matteocorti/update.sh/latest/total)&nbsp;![](https://img.shields.io/github/downloads/matteocorti/update.sh/total)&nbsp;![](https://img.shields.io/github/license/matteocorti/update.sh)&nbsp;![](https://img.shields.io/github/stars/matteocorti/update.sh)&nbsp;![](https://img.shields.io/github/forks/matteocorti/update.sh)

# Command line automatic updates on macOS

## Description

Updates a macOS system. Following software packages are analyzed and automatically updated

 - Apple products
 - Apple Store apps (requires mas)
 - Microsoft products
 - Adobe products
 - Products supported by [MacUpdater](https://www.corecode.io/macupdater/) (requires MacUpdater with a professional license)
 - Perlbrew and installed CPAN modules
 - Ruby dependencies
 - Homebrew and installed packages
 - MacPorts and installed ports
 - Steam games

## Usage

```
Usage: update.sh [OPTIONS]

Options:
      --adobe            update Adobe products
      --apple            update Apple products
      --brew             update Homebrew packages
   -c,--clear            clear the terminal screen before updating
      --emacs            update emacs packages
   -h,--help,-?          this help message
      --macupdater       update with MacUpdater
      --mas              update Apple Store applications
      --msupdate         update Microsoft products
   -n,--name             show machine name
      --no-adobe         do not update Adobe products
      --no-apple         do not update Apple products
      --no-brew          do not update Homebrew packages
      --no-emacs         do not update emacs packages
      --no-macupdater    do not update with MacUpdater
      --no-mas           do not update Apple Store applications
      --no-msupdate      do not update Microsoft products
      --no-perl          do not update Perl and CPAN modules with Perlbrew
      --no-ruby          do not update ruby
      --no-steam         do not update steam
      --perl             update Perl and CPAN modules with Perlbrew
   -q,--quiet            minimal output
      --ruby             update ruby
      --steam            update Steam
   -v,--verbose          verbose output

Report bugs to https://github.com/matteocorti/update.sh/issues
```

## Bugs

Report bugs to [https://github.com/matteocorti/update.sh/issues](https://github.com/matteocorti/update.sh/issues)
