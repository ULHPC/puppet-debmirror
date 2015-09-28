# File::      <tt>init.pp</tt>
# Author::    Hyacinthe Cartiaux (hyacinthe.cartiaux@uni.lu)
# Copyright:: Copyright (c) 2011 Hyacinthe Cartiaux
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: debmirror
#
# Manage Debian mirror
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of debmirror
# $allowed_hosts:: *Default*: '*'. Specification of the hosts which can mount
#           this debmirror directory via NFS.
#
# == Actions:
#
# Install and configure debmirror
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     import debmirror
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'debmirror':
#             ensure => 'present'
#         }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
#
# [Remember: No empty lines between comments and class definition]
#
class debmirror(
    $ensure        = $debmirror::params::ensure,
    $allowed_hosts = $debmirror::params::allowed_hosts,
    $datadir       = $debmirror::params::datadir
)
inherits debmirror::params
{
    info ("Configuring debmirror (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("debmirror 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include debmirror::common::debian }
        redhat, fedora, centos: { include debmirror::common::redhat }
        default: {
            fail("Module ${module_name} is not supported on ${::operatingsystem}")
        }
    }
}
