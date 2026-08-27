# Installation

These notes cover installing the workstation from scratch. The repo ships one
host: `workstation` (the main PC). A new machine follows the same steps with
its own hardware module.

## Hosts

The flake auto-discovers hosts under `modules/hosts/`. There is one host today;
to add a new machine:

- Create `modules/hosts/<name>.nix` by mirroring `workstation.nix`; set
  `networking.hostName` to the machine name.
- Create `modules/hosts/<name>/hardware.nix` by mirroring the workstation file.
  For a real PC, generate the base with `nixos-generate-config --root /mnt`
  and adapt the bootloader and file systems.
- No Justfile change needed: it defaults to `workstation` and can be overridden
  with `NIXOS_HOST=<name> just rebuild`; the Fish aliases pick up `$hostname`
  automatically.
- Add the machine age key to `.sops.yaml` and re-encrypt the secrets:
  `nix-shell -p sops --run "sops updatekeys secrets/secrets.yaml"`.

## Fresh Install

Boot the NixOS installer, partition the disk, and format it. The workstation
uses systemd-boot UEFI with a FAT32 ESP, btrfs root, and a swap partition. The
exact steps are in the README Fresh Install section.

Clone the repo into the mounted target and install:

```sh
sudo nixos-install --flake /mnt/path/to/Documents/nixos-workstation#workstation
```

If the disk was reformatted, update the root UUID in
`modules/hosts/workstation/hardware.nix` using `blkid`.

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
