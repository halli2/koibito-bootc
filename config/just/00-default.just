# Update flatpak and brew
update:
	flatpak update -y
	cargo install-update -a -- y

# Clean cached python packages (uv) and container images (podman)
clean:
	uv cache clean
	podman image prune --all -f
