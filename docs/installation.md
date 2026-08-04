# Installation

These notes cover installing hosts from scratch. The repo ships one host,
`7mochi-vm` (a VirtualBox VM). A real machine uses the same steps with 
its own hardware module.

## Hosts

The flake auto-discovers hosts under `modules/hosts/`. To add a new machine:

- Create `modules/hosts/<name>.nix` by mirroring `7mochi-vm.nix`.
- Create `modules/hosts/<name>/hardware.nix` by mirroring `7mochi-vm/hardware.nix`.
  For a real PC, generate the base with `nixos-generate-config --root /mnt` and
  adapt the bootloader and file systems.
- Set the host name in the `Justfile` (`host := "<name>"`).
- Add the machine age key to `.sops.yaml` and re-encrypt the secrets:
  `nix-shell -p sops --run "sops updatekeys secrets/secrets.yaml"`.

## Fresh Install

Boot the NixOS installer, partition the disk, and format it. The VM uses GRUB
legacy on /dev/sda with a single btrfs volume. A real PC can use EFI and
systemd-boot with its own layout. The exact VM steps are in the README Fresh
Install section.

Clone the repo into the mounted target and install:

```sh
sudo nixos-install --flake /mnt/path/to/Documents/nixos-workstation#<host>
```

If the disk was reformatted, update the root UUID in
`modules/hosts/<host>/hardware.nix` using `blkid`.

## Reinstall the VM

Same as Fresh Install, plus a backup step first. Save the state that Nix does
not manage. The SSH host keys are the sops age identity, so restoring them keeps
`secrets/secrets.yaml` decryptable:

```sh
sudo cp -a /etc/ssh/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key.pub <backup-dir>/
cp -a ~/.config/sops/age/keys.txt <backup-dir>/
```

Wallpapers and the Zen profile are not Nix-managed. Back them up or re-create
them after the install. Move the backup off the VM.

## Post Install

Clone the repo to the hardcoded location and restore the backed up state:

```sh
git clone https://github.com/7mochi/nixos-workstation.git ~/Documents/nixos-workstation

sudo cp -a <backup-dir>/ssh_host_ed25519_key* /etc/ssh/
mkdir -p ~/.config/sops/age
cp -a <backup-dir>/keys.txt ~/.config/sops/age/keys.txt
```

Rebuild and verify:

```sh
cd ~/Documents/nixos-workstation
git pull origin main
just check
just rebuild

cat /run/secrets/opencode-api-key
```

For a brand new machine with no backup, add its age key to `.sops.yaml` and
re-encrypt the secrets from a machine that can still decrypt them.

## Notes

- Login works out of the box. `nanamochi` has a `hashedPassword` in
  `modules/nixos/base/users.nix` and `users.mutableUsers = false`.
- If the host keys are lost, the age key in `.sops.yaml` is stale and the
  secrets cannot be decrypted. Recreate or re-encrypt them, see the Secrets
  section of `docs/system.md`.
- Wallpapers: re-clone `https://github.com/dharmx/walls` to
  `~/Pictures/Wallpapers`.
- Zen Browser sessions are not part of this repo. Re-import the profile files
  if you need them.
