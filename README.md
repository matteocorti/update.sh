
 &copy; Matteo Corti, 2018-2022

# Command line automatic updates on macOS

## Description

Updates a macOS system. Following software packages are analyzed and automatically updated

 - Apple products
 - Apple Store apps (requires mas)
 - Microsoft products
 - Adobe products
 - Products supported by [MacUpdater](https://www.corecode.io/macupdater/) (requires MacUpdater with a professional license)
C - Perlbrew and installed CPAN modules
 - Homebrew and installed packages
 - MacPorts and installed ports

## Usage

```
Usage: update.sh [OPTIONS]

Options:
   -c,--clear            clear the terminal screen before updating
   -h,--help,-?          this help message
   -n,--name             show machine name
   -q,--quiet            minimal output
   -v,--verbose          verbose output
```

## Bugs

Report bugs to [https://github.com/matteocorti/update.sh/issues](https://github.com/matteocorti/update.sh/issues)
