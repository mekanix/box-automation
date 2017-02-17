PROJECT=box-automation-freebsd
GITHUB_BASE=https://github.com/mekanix/bhyve-base/releases/download/0.0.1/freebsd-11-base.img
TMP_FILE!=mktemp
RANDOM_MAC_STRING!=openssl rand -hex 6
RANDOM_MAC!=echo $(RANDOM_MAC_STRING) | sed 's/\(..\)/\1:/g; s/.$$//'
IMAGE_SIZE=10G


provision: up setup wait
	@ansible-playbook -i provision/inventory/bhyve provision/site.yml

base:
.if !exists(/cbsd/jails-data/freebsd-11-base-data)
	@fetch $(GITHUB_BASE) -o $(TMP_FILE)
	@sudo cbsd bremove freebsd-11-base || true
	@sudo cbsd bimport jname=$(TMP_FILE) new_jname=$(RANDOM_MAC_STRING)
	@sudo sqlite3 /cbsd/jails-system/$(RANDOM_MAC_STRING)/local.sqlite 'DELETE FROM bhyvedsk WHERE jname != "$(RANDOM_MAC_STRING)"'
	@sudo sqlite3 /cbsd/jails-system/$(RANDOM_MAC_STRING)/local.sqlite 'DELETE FROM bhyvenic WHERE jname != "$(RANDOM_MAC_STRING)"'
	@sudo cbsd bclone old=$(RANDOM_MAC_STRING) new=freebsd-11-base
	@sudo sqlite3 /cbsd/jails-system/freebsd-11-base/local.sqlite 'DELETE FROM bhyvedsk WHERE jname != "freebsd-11-base"'
	@sudo sqlite3 /cbsd/jails-system/freebsd-11-base/local.sqlite 'DELETE FROM bhyvenic WHERE jname != "freebsd-11-base"'
	@sudo cbsd bremove $(RANDOM_MAC_STRING)
.endif
	@rm $(TMP_FILE)

init: base
.if !exists(/cbsd/jails-data/$(PROJECT)-data)
	@sudo cbsd bclone old=freebsd-11-base new=$(PROJECT)
	@sudo sqlite3 /cbsd/jails-system/$(PROJECT)/local.sqlite 'DELETE FROM bhyvenic WHERE jname != "$(PROJECT)"'
	@sudo sqlite3 /cbsd/jails-system/$(PROJECT)/local.sqlite 'UPDATE bhyvenic SET nic_hwaddr = "$(RANDOM_MAC)"'
	@sudo sh -c 'echo "dhcp-host=$(RANDOM_MAC),$(PROJECT)" >/usr/local/etc/dnsmasq.d/$(PROJECT).vm.conf'
	@sudo zfs set volsize=$(IMAGE_SIZE) tank/cbsd/bcbsd-$(PROJECT)-dsk1.vhd
	@sudo service dnsmasq restart
.endif

up: init
	@sudo cbsd bstart $(PROJECT) || true

wait_msg:
	@echo "Waiting for SSH to become available"

wait_ping:
	@sleep 1
	@ping -c 1 $(PROJECT) >/dev/null 2>&1 || $(MAKE) wait_ping

wait_ssh:
	@sleep 1
	@ssh -i .ssh/bhyve-insecure devel@$(PROJECT) exit >/dev/null 2>&1 || $(MAKE) wait_ssh

wait: wait_msg wait_ping wait_ssh

setup:
	@sed -e "s:PROJECT:$(PROJECT):g" provision/inventory.tpl >provision/inventory/bhyve
	@sed -e "s:PROJECT:$(PROJECT):g" provision/group_vars/all.tpl >provision/group_vars/all

login:
	@ssh -i .ssh/bhyve-insecure devel@${PROJECT}

down:
	@sudo cbsd bstop $(PROJECT)

destroy:
	@sudo cbsd bremove $(PROJECT)
	@sudo rm -f /usr/local/etc/dnsmasq.d/$(PROJECT).vm.conf
	@sudo service dnsmasq restart
