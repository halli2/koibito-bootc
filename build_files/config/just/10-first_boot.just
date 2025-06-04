# Change keyboard layout
changekey LAYOUT:
	localectl set-keymap {{LAYOUT}}
# Europe/Oslo
change_time TIMEZONE:
	timedatectl set-timezone {{TIMEZONE}}
dns:
	sudo resolvectl dns wg0 11.8.1.3
	sudo resolvectl domain wg0 "~."
