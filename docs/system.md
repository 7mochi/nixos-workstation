# System

These notes cover the system-level pieces that are easy to forget when changing
the workstation.

## Boot

Boot modules live under `modules/nixos/boot/`.

- `kernel.nix` enables the shared CachyOS BORE kernel. The bootloader is set in
  `modules/hosts/workstation/hardware.nix`: systemd-boot UEFI with a FAT32 ESP
  at `/boot`.

## Storage

The root filesystem and the btrfs data disks are declared per host in
`modules/hosts/workstation/hardware.nix`. Weekly scrub on the btrfs data disks
(`/media/ssd`, `/media/hdd`) and `fstrim` for the ext4 root live in
`modules/hosts/workstation/btrfs.nix`.

The host hardware module expects an ext4 root mounted by disk UUID; `/home` and
`/nix` are plain directories on it. The data disks stay btrfs.

```text
<root-uuid>  ext4 mounted at /
```

The workstation additionally pins a swap partition and its ESP UUID in
`modules/hosts/workstation/hardware.nix`.

Use `nixos-rebuild boot` and reboot when changing mount options or filesystem
devices.

## Secrets

Secrets are managed with `sops-nix`. Encrypted files live under `secrets/` and
are committed to the repo; no plaintext secrets belong here.

The age identity is the host SSH key. `modules/nixos/security/ssh.nix` sets
`generateHostKeys = true` (with the sshd daemon kept disabled) so the key exists
even though OpenSSH is off. `sops-nix` then defaults its age identity to that key
(`age.sshKeyPaths` defaults to the ed25519 entry of
`config.services.openssh.hostKeys`), so `secrets.nix` needs no explicit path:

```nix
# ssh.nix
services.openssh.generateHostKeys = true;
```

That means a fresh machine needs its host SSH key in place before secrets can be
decrypted. The key is generated on first boot by `sshd-keygen.service`; on a
brand-new install, restore the backed-up key (see `docs/installation.md`) before
the first rebuild so activation can decrypt. For the `sops` CLI, set up the edit
identity once from the host SSH key (`ssh-to-age` and `sops` are already in the
system profile, no `nix-shell` needed):

```sh
# 1. One-time: set up the age edit identity from the host SSH key (sudo to
#    read /etc/ssh; the file must stay private)
mkdir -p ~/.config/sops/age
sudo bash -c 'ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key' > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# 2. Get the public age key (used for .sops.yaml creation rules)
ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub

# 3. Create or edit an encrypted secrets file
cd ~/Documents/nixos-workstation
sops secrets/secrets.yaml
#   each key becomes a secret, e.g.:
#   opencode-api-key: <KEY>

# 4. Commit the encrypted file, then rebuild
just rebuild
```

If `sops` fails with "Failed to get the data key required to decrypt the SOPS
file ... Did not find keys in ... `~/.config/sops/age/keys.txt`", the edit
identity is missing or stale, run step 1 again. The derived public key must
match one of the recipients in `.sops.yaml`; the host SSH keys are restored
from backup when reinstalling (see `docs/installation.md`), so a restored key
keeps the same age identity.

Declare each secret in `modules/nixos/security/secrets.nix` (`sops.secrets`).
Each one is decrypted at activation time to `/run/secrets/<name>` with the
configured owner/group/mode.

### Recipients

Each machine derives its own age key from its SSH host key. Private keys are
never shared or committed. A machine can decrypt a secret only if its age
public key is listed in `.sops.yaml`.

The repo has two recipients: the workstation's `main_workstation` and a
dedicated `offline_recovery` key. Either one can decrypt `secrets/secrets.yaml`;
the recovery key is what makes a lost host key or a reinstall survivable. Keep
its private half outside the machine, encrypted with a passphrase, and test it
periodically:

```sh
SOPS_AGE_KEY_FILE=/path/to/age-recovery.key sops -d secrets/secrets.yaml >/dev/null && echo OK
```

Also back up `/etc/ssh/ssh_host_ed25519_key` (and
`~/.config/sops/age/keys.txt`) to a safe place outside the machine. The host key
should be owned by `root:root` with mode `0600`; if it is readable by the
desktop user, that user can decrypt every secret.

To add a machine, add its recipient to the same `key_groups` entry. Do not put
a leading `-` before `age:`, that enables Shamir secret sharing and requires
every key:

```yaml
keys:
  - &main_workstation age1xxxx...
  - &new_machine age1xxxx...
creation_rules:
  - path_regex: secrets/[^/]+\.yaml$
    key_groups:
      - age:
          - *main_workstation
          - *new_machine
```

Re-encrypt the secrets for the new recipient from any machine that can still
decrypt them:

```sh
nix-shell -p sops --run "sops updatekeys secrets/secrets.yaml"
```

Any backup of the private key is a copy of the decryption key. Keep backups of
`/etc/ssh/ssh_host_ed25519_key` or `~/.config/sops/age/keys.txt` private.

## Containers

Docker is enabled for workflow compatibility. The `docker` group is effectively
root-equivalent, so do not add users to it casually.

Podman is present as a disabled default. Enable it only when the workflow no
longer depends on Docker socket semantics.
