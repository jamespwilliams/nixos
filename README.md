### nixos

NixOS configuration.

#### Setup

Something along the lines of:

```console
$ chmod -R jpw:jpw /etc/nixos
$ git clone https://github.com/jamespwilliams/nixos.git /etc/nixos
```

Then edit `configuration.nix` to import the appropriate host's configuration.
