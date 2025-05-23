# Update flatpak, cargo, and python tools
update:
	flatpak update -y
	cargo install-update -a -- y
	uv tool upgrade --all

# Clean cached python packages (uv) and container images (podman)
clean:
	uv cache clean
	podman image prune --all -f
