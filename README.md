# Koibito

Personal bootc fedora setup.

## Packages are defined in yaml files

- base.yaml
- koibito.yaml
- dev-packages.yaml
- hyprland/hyprland.yaml
- cosmic/cosmic.yaml (not in use)

## To run as a VM

The justfile contains commands for building/starting a VM, it needs a configuration file.
Create a `config.toml` in the main directory like this, replace name and password as wanted and change the key to your public ssh key:

```toml
[[customizations.user]]
name = "core"
password = "core"
key = "ssh-ed25519 AAA...core@fedora"
groups = ["wheel"]
```

## Manual setup

### brew.yml

### Set up devpods with podman (cli)

```sh
curl -L -o devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64" && install -c -m 0755 devpod .local/bin/ && rm -f devpod
devpod provider add docker --name podman -o DOCKER_PATH=podman
```
