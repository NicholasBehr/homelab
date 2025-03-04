[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Restore from Backup
1. adapt dns entries
2. adapt ip-addresses in configuration.nix
3. setup server
    ```
    nix run nixpkgs#nixos-anywhere -- --flake .#homelab root@nicholasbehr.ch --build-on-remote
    nix shell nixpkgs#colmena
    colmena apply --on homelab
    ```
4. restore from borgbase
   ```
    borg list --short
    borg extract --dry-run --list /path/to/repo::my-files /var/lib/paperless/export
    mv var/lib/paperless/export .
    sudo chown -R paperless:paperless export
    sudo mv export /var/lib/paperless/
    sudo /var/lib/paperless/paperless-manage document_importer /var/lib/paperless/export
    sudo /var/lib/paperless/paperless-manage document_sanity_checker

    ```
    Tip: You can use `nohup command` to execute a long running command even after disconnecting via SSH!