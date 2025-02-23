# Makefile for setting up syncthing with rootless podman, as a systemd service managed using quadlet

# Define variables
PROJECT_ROOT := $(patsubst %/,%,$(dir $(CURDIR)))
SYNCTHING_UNIT_DIR := $(HOME)/.config/containers/systemd/syncthing
UNIT_FILES := syncthing*
RED := '\033[0;31m'
GREEN := '\033[0;32m'
YELLOW := '\033[33m'
NC := '\033[0m'

# For Debian based use "/usr/libexec/podman/quadlet"
# For Fedora based use "/usr/libexec/podman/quadlet"
# For Arch based use "/usr/lib/podman/quadlet"
QUADLET_PATH := '/usr/lib/podman/quadlet'

# Check dependencies
check-podman-dependency:
	@command -v podman >/dev/null 2>&1 || { echo -e $(RED)"Podman is required but not installed. Aborting."$(NC); exit 1; }

# Quadlet support for pods in version 5 and above
check-podman-version: check-podman-dependency
	@version=$$(podman -v | sed -n -e 's/^.*version \([0-9]*\).*/\1/p'); \
	if [ $$version -lt 5 ]; then \
		echo -e $(RED)"Podman version is less than 5.0.0. Please upgrade."$(NC); \
		exit 1; \
	fi

# Create directory and copy unit files for rootless container
prepare: check-podman-version
	@mkdir -p $(SYNCTHING_UNIT_DIR)
	@bash ./script.sh
	@echo -e $(GREEN)"Copying files to $(SYNCTHING_UNIT_DIR)"$(NC)
	@cp $(PROJECT_ROOT)/volumes/$(UNIT_FILES) $(SYNCTHING_UNIT_DIR)
	@cp $(PROJECT_ROOT)/containers/$(UNIT_FILES) $(SYNCTHING_UNIT_DIR)
	@systemctl --user daemon-reload

# Start Syncthing container
start: prepare
	@echo -e $(GREEN)"Starting Syncthing systemd service"$(NC)
	@systemctl --user start syncthing-server.service

# Stop Syncthing container
stop:
	@echo -e $(YELLOW)"Stopping Syncthing systemd service"$(NC)
	@systemctl --user stop syncthing-server.service

# Remove Syncthing service and files
uninstall: stop
	@echo -e $(YELLOW)"Deleting Syncthing systemd services"$(NC)
	@rm -rf $(SYNCTHING_UNIT_DIR)
	@systemctl --user daemon-reload
	@rm -f $($XDG_RUNTIME_DIR)/systemd/generator/syncthing*

# Remove Syncthing data volumes
remove-volumes:
	@echo -e $(RED)"Removing all Syncthing volumes"$(NC)
	@podman volume rm --force syncthing-config syncthing-data

# Debug unit files
debug:
	@bash script.sh
	@export QUADLET_UNIT_DIRS="$(PROJECT_ROOT)" ; echo $(QUADLET_UNIT_DIRS) ; $(QUADLET_PATH) -v --user --dryrun ;

# Install (copy files and start service)
install: start