# File::      <tt>debmirror.pp</tt>
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
class debmirror( $ensure = $debmirror::params::ensure ) inherits debmirror::params
{
    info ("Configuring debmirror (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("debmirror 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include debmirror::debian }
        redhat, fedora, centos: { include debmirror::redhat }
        default: {
            fail("Module $module_name is not supported on $operatingsystem")
        }
    }
}

# ------------------------------------------------------------------------------
# = Class: debmirror::common
#
# Base class to be inherited by the other debmirror classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class debmirror::common {

    # Load the variables used in this module. Check the debmirror-params.pp file
    require debmirror::params

    include git

    ####################################
    # Create the user
    user { "${debmirror::params::user}":
        ensure     => "${debmirror::params::ensure}",
        allowdupe  => false,
        comment    => 'Local Debian archive mirror',
        home       => "${debmirror::params::homedir}",
        managehome => false,
        shell      => '/bin/bash',
    }

    if $debmirror::ensure == 'present' {

        file { "${debmirror::params::homedir}":
            owner   => "${debmirror::params::configfile_owner}",
            group   => "${debmirror::params::configfile_group}",
            mode    => "${debmirror::params::configfile_mode}",
            ensure  => 'directory',
            require => User["${debmirror::params::user}"],
        }

        exec { 'debmirror_mkdir_datadir':
            path    => [ '/bin', '/usr/bin' ],
            command => "mkdir -p ${debmirror::params::datadir}",
            unless  => "test -d ${debmirror::params::datadir}",
        }

        file { "${debmirror::params::datadir}":
            owner   => "${debmirror::params::configfile_owner}",
            group   => "${debmirror::params::configfile_group}",
            mode    => "${debmirror::params::configfile_mode}",
            ensure  => 'directory',
            require => [ User["${debmirror::params::user}"] , Exec['debmirror_mkdir_datadir'] ],
        }

        ####################################
        # ~/archvsync
        # Clone the ftpsync scriptset from Debian git repository
        git::clone { "${debmirror::params::homedir}/${debmirror::params::archvsync_dir}":
            basedir   => "${debmirror::params::homedir}",
            targetdir => "${debmirror::params::archvsync_dir}",
            source    => "${debmirror::params::archvsync_gitsrc}",
            ensure    => "${debmirror::params::ensure}",
            user      => "${debmirror::params::user}",
            require   => File["${debmirror::params::homedir}"],
        }

    
        file { [ "${debmirror::params::homedir}/bin", 
                 "${debmirror::params::homedir}/etc", 
                 "${debmirror::params::homedir}/log" 
                 ]:
            owner   => "${debmirror::params::configfile_owner}",
            group   => "${debmirror::params::configfile_group}",
            mode    => "${debmirror::params::configfile_mode}",
            ensure  => 'directory',
            require => File["${debmirror::params::homedir}"],
        }

        #################################
        # ~/bin

        file { "${debmirror::params::homedir}/bin/ftpsync":
            owner   => "${debmirror::params::configfile_owner}",
            group   => "${debmirror::params::configfile_group}",
            mode    => "${debmirror::params::configfile_mode}",
            ensure  => 'link',
            target  => "${debmirror::params::homedir}/${debmirror::params::archvsync_dir}/bin/ftpsync",
            require => File["${debmirror::params::homedir}/bin"],
        }

        file { "${debmirror::params::homedir}/bin/run_ftpsync":
            owner   => "${debmirror::params::configfile_owner}",
            group   => "${debmirror::params::configfile_group}",
            mode    => "${debmirror::params::configdir_mode}",
            ensure  => 'present',
            source  => "puppet:///modules/debmirror/run_ftpsync",
            require => File["${debmirror::params::homedir}/bin"],
        }

        #################################
        # ~/etc

        file { "${debmirror::params::homedir}/etc/common":
            owner   => "${debmirror::params::configfile_owner}",
            group   => "${debmirror::params::configfile_group}",
            mode    => "${debmirror::params::configfile_mode}",
            ensure  => 'link',
            target  => "${debmirror::params::homedir}/${debmirror::params::archvsync_dir}/etc/common",
            require => File["${debmirror::params::homedir}/etc"],
        }
        

        #################################
        # ~/log
        # Nothing there

    }
    else
    {
        # Here $debmirror::ensure is absent

        # Delete debmiror user home directory
        exec { "rm -rf ${debmirror::params::homedir}":
            path    => "/usr/bin:/usr/sbin:/bin",
            command => "rm -rf ${debmirror::params::homedir}",
            onlyif  => "test -d ${debmirror::params::homedir}"
        }

        # Delete debmiror data directory
        exec { "rm -rf ${debmirror::params::datadir}":
            path    => "/usr/bin:/usr/sbin:/bin",
            command => "rm -rf ${debmirror::params::datadir}",
            onlyif  => "test -d ${debmirror::params::datadir}"
        }

    }

}


# ------------------------------------------------------------------------------
# = Class: debmirror::debian
#
# Specialization class for Debian systems
class debmirror::debian inherits debmirror::common { }

# ------------------------------------------------------------------------------
# = Class: debmirror::redhat
#
# Specialization class for Redhat systems
class debmirror::redhat inherits debmirror::common { }



