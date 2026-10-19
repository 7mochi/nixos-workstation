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

The secrets are encrypted for two recipients: the workstation host key and a
dedicated offline recovery key. The recovery key is the fallback if the host
key is lost or the machine is reinstalled:

```text
recipient 1  age1zdvyc7f5953tvnw266z7799n43vk8kq58ykkudgkp704e05qs3hsc93gu7  (workstation host key)
recipient 2  age1yc2drturh2d9qssp377fxs8ne45rctvlc2ez59mfjl7ke8892ctsqhp79e  (offline recovery)
```

Keep the recovery private key outside this machine. Do not store it in the repo
or in `/home`. Encrypt it with a passphrase before uploading it anywhere:

```sh
age -p -o age-recovery.key.age ~/age-recovery.key
# upload age-recovery.key.age, then remove both local copies
shred -u ~/age-recovery.key age-recovery.key.age
```

To test the recovery key without touching the running system:

```sh
SOPS_AGE_KEY_FILE=/path/to/age-recovery.key sops -d secrets/secrets.yaml >/dev/null && echo OK
```

To rotate or replace the recovery key, update its recipient in `.sops.yaml` and
re-encrypt from a machine that can still decrypt the file:

```sh
sops updatekeys secrets/secrets.yaml
```

For a cleaner long-term setup, create a dedicated age key under `/var/lib/sops-nix/key.txt`, add its public recipient to `.sops.yaml`, then update `modules/nixos/security/secrets.nix`.
