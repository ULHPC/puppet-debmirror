# File::      <tt>params.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2015 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# You need the 'future' parser to be able to execute this manifest (that's
# required for the each loop below).
#
# Thus execute this manifest in your vagrant box as follows:
#
#      sudo puppet apply -t --parser future /vagrant/tests/params.pp
#
#

include 'debmirror::params'

$names = ["ensure", "allowed_hosts", "arch", "user", "homedir", "datadir", "archvsync_dir", "archvsync_gitsrc", "cron", "list_arch", "configdir_mode", "configfile_mode", "configfile_owner", "configfile_group"]

notice("debmirror::params::ensure = ${debmirror::params::ensure}")
notice("debmirror::params::allowed_hosts = ${debmirror::params::allowed_hosts}")
notice("debmirror::params::arch = ${debmirror::params::arch}")
notice("debmirror::params::user = ${debmirror::params::user}")
notice("debmirror::params::homedir = ${debmirror::params::homedir}")
notice("debmirror::params::datadir = ${debmirror::params::datadir}")
notice("debmirror::params::archvsync_dir = ${debmirror::params::archvsync_dir}")
notice("debmirror::params::archvsync_gitsrc = ${debmirror::params::archvsync_gitsrc}")
notice("debmirror::params::cron = ${debmirror::params::cron}")
notice("debmirror::params::list_arch = ${debmirror::params::list_arch}")
notice("debmirror::params::configdir_mode = ${debmirror::params::configdir_mode}")
notice("debmirror::params::configfile_mode = ${debmirror::params::configfile_mode}")
notice("debmirror::params::configfile_owner = ${debmirror::params::configfile_owner}")
notice("debmirror::params::configfile_group = ${debmirror::params::configfile_group}")

#each($names) |$v| {
#    $var = "debmirror::params::${v}"
#    notice("${var} = ", inline_template('<%= scope.lookupvar(@var) %>'))
#}
