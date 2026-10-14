# Secrets

This repo is prepared for `sops-nix`. Do not commit plaintext secrets.

The default configuration uses the host SSH key as an age identity. It is
generated because `modules/nixos/security/ssh.nix` sets
`services.openssh.generateHostKeys = true` (with the daemon itself disabled);
sops-nix derives the identity from the ed25519 entry of
`services.openssh.hostKeys`. To print the recipient:

```sh
sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key
```

The secrets are encrypted only for this workstation's age key, so it is the
single point of failure. Keep a private backup of
`/etc/ssh/ssh_host_ed25519_key` somewhere safe off this machine; if it is lost,
`secrets/secrets.yaml` cannot be decrypted.

For a cleaner long-term setup, create a dedicated age key under `/var/lib/sops-nix/key.txt`, add its public recipient to `.sops.yaml`, then update `modules/nixos/security/secrets.nix`.
