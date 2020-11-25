source "$GENTOO_INSTALL_REPO_DIR/scripts/protection.sh" || exit 1
source "$GENTOO_INSTALL_REPO_DIR/scripts/internal_config.sh" || exit 1


################################################
# Disk configuration

# TODO us layout maybe config
# TODO better explanation for normal password
# This function will be called when the key for a luks device is needed.
# Parameters:
#	$1 will be the id of the luks device as given in `create_luks new_id=<id> ...`.
# Example: Keyfile
#   1. Generate a 512-bit (or anything < 8MiB) keyfile with
#      `dd if=/dev/urandom bs=1024 count=1 of=/path/to/keyfile`
#   2. Copy the keyfile somewhere safe, but don't delete the original,
#      which we will use in the live environment.
#   3. Use `echo -n /path/to/keyfile` below.
# Example: GPG Smartcard
#   Same as above, but do not store a copy of the keyfile and instead store a
#   gpg encrypted copy: `cat /path/to/keyfile | gpg --symmetric --cipher-algo AES256 --s2k-digest-algo SHA512 --output /my/permanent/storage/luks-key.gpg`
luks_getkeyfile() {
	case "$1" in
		#'my_luks_partition') echo -n '/path/to/my_luks_partition_keyfile' ;;
		*) echo -n "/path/to/luks-keyfile" ;;
	esac
}

# Below you can see examples of how to use the two provided default schemes.
# See the respective functions in internal_config.sh if you
# want to use a different disk configuration.

# Create default scheme (efi/boot, (optional swap), root)
# To disable swap, set swap=false
# To disable encryted root, set luks=false
#create_default_disk_layout luks=true root_fs=btrfs swap=8GiB /dev/sdX            # EFI
#create_default_disk_layout luks=true root_fs=btrfs swap=8GiB type=bios /dev/sdX  # BIOS
#create_default_disk_layout swap=8GiB /dev/sdX

# Create default scheme from above on each given device,
# but create two raid0s for all swap partitions and all root partitions
# respectively. Create luks on the root raid.
# Hint: You will get N times the swap amount, so be sure to divide beforehand.
#create_raid0_luks_layout swap=4GiB /dev/sd{X,Y}             # EFI
#create_raid0_luks_layout swap=4GiB type=bios /dev/sd{X,Y}   # BIOS
#create_raid0_luks_layout swap=false type=bios /dev/sd{X,Y}  # BIOS no swap

# Create default scheme from above on first given device,
# encrypt and use the root partition of this first disk plus
# encrypt and use the rest of the devices to create a btrfs raid
# array of specified type. By default is uses striping. Specify
# raid_type=mirror for raid1.
# Hint: Swap will only be on the first disk.
create_btrfs_raid_layout swap=8GiB luks=true /dev/sd{X,Y}                    # EFI
#create_btrfs_raid_layout swap=8GiB type=bios luks=true /dev/sd{X,Y}         # BIOS
#create_btrfs_raid_layout swap=false type=bios raid_type=mirror /dev/sd{X,Y} # BIOS, raid1, no luks, no swap

################################################
# System configuration

# Enter the desired system hostname here,
# be aware that when creating raid arrays, this value will be
# recorded in metadata block. If you change it later, you should
# also update the metadata.
HOSTNAME="gentoo"

# The timezone for the new system
TIMEZONE="Europe/London"
#TIMEZONE="Europe/Berlin"

# The default keymap for the system
KEYMAP="us"
#KEYMAP="de-latin1-nodeadkeys"

# A list of additional locales to generate. You should only
# add locales here if you really need them and want to localize
# your system. Otherwise, leave this list empty, and use C.utf8.
LOCALES=""
# The locale to set for the system. Be careful, this setting differs from the LOCALES
# list entries (e.g. .UTF-8 vs .utf8). Use the name as shown in `eselect locale`
LOCALE="C.utf8"
# For a german system you could use:
# LOCALES="
# de_DE.UTF-8 UTF-8
# de_DE ISO-8859-1
# de_DE@euro ISO-8859-15
# " # End of LOCALES
# LOCALE="de_DE.utf8"


################################################
# Gentoo configuration

# The selected gentoo mirror
GENTOO_MIRROR="https://mirror.eu.oneandone.net/linux/distributions/gentoo/gentoo"
#GENTOO_MIRROR="https://distfiles.gentoo.org"

# The architecture of the target system (only tested with amd64)
GENTOO_ARCH="amd64"

# The stage3 tarball to install
STAGE3_BASENAME="stage3-$GENTOO_ARCH-systemd"
#STAGE3_BASENAME="stage3-$GENTOO_ARCH-hardened+nomultilib"
#STAGE3_BASENAME="stage3-$GENTOO_ARCH-hardened-selinux+nomultilib"

# Set to true if the tarball is based on systemd. In this case
# we need to use slightly different utilities to setup the base system.
SYSTEMD=true


################################################
# Additional (optional) configuration

# Array of additional packages to install
ADDITIONAL_PACKAGES=("app-editors/neovim")
# Install and configure sshd (a reasonably secure config is provided, which
# only allows the use of ed25519 keys, and requires pubkey authentication)
INSTALL_SSHD=true
# Install ansible, and add a user for it. This requires INSTALL_SSHD=true
INSTALL_ANSIBLE=true
# The home directory for the ansible user
ANSIBLE_HOME="/var/lib/ansible"
# An ssh key to add to the .authorized_keys file for the ansible user.
# This variable will become the content of the .authorized_keys file,
# so you may specify one key per line.
ANSIBLE_SSH_AUTHORIZED_KEYS=""


################################################
# Prove that you have read the config

# To prove that you have read and edited the config
# properly, set the following value to true.
I_HAVE_READ_AND_EDITED_THE_CONFIG_PROPERLY=false
