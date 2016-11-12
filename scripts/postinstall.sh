#!/bin/sh --

set -e

echo 'Running post-install..'

echo 'Updating /boot/loader.conf...'
echo '  * Disabling Beastie boot screen'
cat <<'EOF' >> /boot/loader.conf
beastie_disable="YES"
EOF

echo 'Bootstrapping pkg(1)...'
ASSUME_ALWAYS_YES=yes pkg bootstrap -f

echo 'Setting up VM Tools...'
pkg install -y virtualbox-ose-additions
sysrc vboxguest_enable="YES"
sysrc vboxservice_enable="YES"

echo
echo 'Setting up sudo...'
pkg install -y sudo python
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /usr/local/etc/sudoers.d/vagrant

echo
echo 'Setting up the vagrant ssh keys...'
mkdir ~vagrant/.ssh
chmod 700 ~vagrant/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > ~vagrant/.ssh/authorized_keys
chown -R vagrant ~vagrant/.ssh
chmod 600 ~vagrant/.ssh/authorized_keys

echo
echo 'Setting root shell'
chsh -s /bin/sh

echo
echo 'Post-install complete.'
