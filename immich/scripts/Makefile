# Makefile for setting up immich with rootless podman, as a systemd service managed using quadlet

# Define variables
PROJECT_ROOT := $(patsubst %/,%,$(dir $(CURDIR)))
IMMICH_UNIT_DIR := $(HOME)/.config/containers/systemd/immich
UNIT_FILES := immich*
DB_PASS_FILE := "IMMICH_DATABASE_PASSWORD.txt"
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
	@mkdir -p $(IMMICH_UNIT_DIR)
	@bash ./script.sh
	@echo -e $(GREEN)"Copying files to $(IMMICH_UNIT_DIR)"$(NC)
	@cp $(PROJECT_ROOT)/$(UNIT_FILES) $(IMMICH_UNIT_DIR)
	@cp $(PROJECT_ROOT)/volumes/$(UNIT_FILES) $(IMMICH_UNIT_DIR)
	@cp $(PROJECT_ROOT)/containers/$(UNIT_FILES) $(IMMICH_UNIT_DIR)
	@systemctl --user daemon-reload

# Generate a secure password for the database and store it as a podman secret
database-password: prepare
	@if [ -f $(PROJECT_ROOT)/config/$(DB_PASS_FILE) ]; then \
		echo -e $(GREEN)"Using existing password from $(DB_PASS_FILE)"$(NC); \
		cat $(PROJECT_ROOT)/config/$(DB_PASS_FILE) | podman secret create --replace immich-database-password - > /dev/null 2>&1; \
	else \
		echo -e $(GREEN)"Generating a new password for the database and storing it in $(DB_PASS_FILE). Keep this file safe."$(NC); \
		LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c 64 | tee $(PROJECT_ROOT)/config/$(DB_PASS_FILE) | podman secret create --replace immich-database-password - > /dev/null 2>&1; \
	fi
	@chmod 600 $(PROJECT_ROOT)/config/$(DB_PASS_FILE)

# Start Immich pod
start: database-password
	@echo -e $(GREEN)"Starting Immich pod systemd service"$(NC)
	@systemctl --user start immich-pod.service

# Stop Immich pod
stop:
	@echo -e $(YELLOW)"Stopping Immich pod systemd service"$(NC)
	@systemctl --user stop immich-pod.service

# Remove Immich service and files
uninstall: stop
	@echo -e $(YELLOW)"Deleting Immich systemd services"$(NC)
	@rm -rf $(IMMICH_UNIT_DIR)
	@systemctl --user daemon-reload
	@rm -f /run/user/1000/systemd/generator/immich*

# Remove Immich data volumes
remove-volumes:
	@echo -e $(RED)"Removing Immich data volumes"$(NC)
	@podman volume rm --force immich-database immich-redis immich-machine_learning immich-server

# Debug unit files
debug:
	@bash script.sh
	@export QUADLET_UNIT_DIRS="$(PROJECT_ROOT)" ; echo $(QUADLET_UNIT_DIRS) ; $(QUADLET_PATH) -v --user --dryrun ;


# Install (copy files and start service)
install: start

# Remove pod without deleting data volumes
remove: uninstall