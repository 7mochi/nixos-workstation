# Secrets

This repo is prepared for `sops-nix`. Do not commit plaintext secrets.

The default configuration uses the host SSH key as an age identity:

```sh
sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key
```

The secrets are encrypted only for this workstation's age key, so it is the
single point of failure. Keep a private backup of
`/etc/ssh/ssh_host_ed25519_key` and `~/.config/sops/age/keys.txt` somewhere
safe off this machine; if they are lost, `secrets/secrets.yaml` cannot be
decrypted.

For a cleaner long-term setup, create a dedicated age key under `/var/lib/sops-nix/key.txt`, add its public recipient to `.sops.yaml`, then update `modules/nixos/security/secrets.nix`.
