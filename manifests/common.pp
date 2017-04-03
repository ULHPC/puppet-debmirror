# File::      <tt>common.pp</tt>
# Author::    Hyacinthe Cartiaux (hyacinthe.cartiaux@uni.lu)
# Copyright:: Copyright (c) 2011 Hyacinthe Cartiaux
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: debmirror::common
#
# Base class to be inherited by the other debmirror classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class debmirror::common {

    # Load the variables used in this module. Check the debmirror-params.pp file
    require debmirror::params

    ####################################
    # Create the user
    user { $debmirror::params::user:
        ensure     => $debmirror::params::ensure,
        allowdupe  => false,
        comment    => 'Local Debian archive mirror',
        home       => $debmirror::params::homedir,
        managehome => false,
        shell      => '/bin/bash',
    }

    # NFS
    if (! defined( Class['nfs::server'] )) {
        class { 'nfs::server':
            ensure     => $debmirror::ensure,
            nb_servers => '64'
        }
    }
    nfs::server::export { $debmirror::datadir:
        ensure        => $debmirror::ensure,
        comment       => 'This directory exports the local Debian mirror',
        allowed_hosts => $debmirror::allowed_hosts,
        options       => 'async,ro,no_root_squash,no_subtree_check',
    }

    if $debmirror::ensure == 'present' {

        file { $debmirror::params::homedir:
            ensure  => 'directory',
            owner   => $debmirror::params::configfile_owner,
            group   => $debmirror::params::configfile_group,
            mode    => $debmirror::params::configfile_mode,
            require => User[$debmirror::params::user],
        }

        exec { 'debmirror_mkdir_datadir':
            path    => [ '/bin', '/usr/bin' ],
            command => "mkdir -p ${debmirror::datadir}",
            unless  => "test -d ${debmirror::datadir}",
        }

        file { $debmirror::datadir:
            ensure  => 'directory',
            owner   => $debmirror::params::configfile_owner,
            group   => $debmirror::params::configfile_group,
            mode    => $debmirror::params::configfile_mode,
            require => [ User[$debmirror::params::user] , Exec['debmirror_mkdir_datadir'] ],
        }

        ####################################
        # ~/archvsync
        # Clone the ftpsync scriptset from Debian git repository
        vcsrepo { "${debmirror::params::homedir}/${debmirror::params::archvsync_dir}":
            ensure   => $debmirror::params::ensure,
            path     => "${debmirror::params::homedir}/${debmirror::params::archvsync_dir}",
            source   => $debmirror::params::archvsync_gitsrc,
            provider => git,
            require  => File[$debmirror::params::homedir]
        }

        file { [
          "${debmirror::params::homedir}/bin",
          "${debmirror::params::homedir}/etc",
          "${debmirror::params::homedir}/log"
        ]:
            ensure  => 'directory',
            owner   => $debmirror::params::configfile_owner,
            group   => $debmirror::params::configfile_group,
            mode    => $debmirror::params::configfile_mode,
            require => File[$debmirror::params::homedir],
        }

        #################################
        # ~/bin

        file { "${debmirror::params::homedir}/bin/ftpsync":
            ensure  => 'link',
            owner   => $debmirror::params::configfile_owner,
            group   => $debmirror::params::configfile_group,
            mode    => $debmirror::params::configfile_mode,
            target  => "${debmirror::params::homedir}/${debmirror::params::archvsync_dir}/bin/ftpsync",
            require => File["${debmirror::params::homedir}/bin"],
        }
        file { "${debmirror::params::homedir}/bin/common":
            ensure  => 'link',
            owner   => $debmirror::params::configfile_owner,
            group   => $debmirror::params::configfile_group,
            mode    => $debmirror::params::configfile_mode,
            target  => "${debmirror::params::homedir}/${debmirror::params::archvsync_dir}/bin/common",
            require => File["${debmirror::params::homedir}/bin"],
        }

        file { "${debmirror::params::homedir}/bin/run_ftpsync":
            ensure  => 'present',
            owner   => $debmirror::params::configfile_owner,
            group   => $debmirror::params::configfile_group,
            mode    => $debmirror::params::configdir_mode,
            source  => 'puppet:///modules/debmirror/run_ftpsync',
            require => File["${debmirror::params::homedir}/bin"],
        }

        #################################
        # ~/etc

        file { "${debmirror::params::homedir}/etc/common":
            ensure  => 'link',
            owner   => $debmirror::params::configfile_owner,
            group   => $debmirror::params::configfile_group,
            mode    => $debmirror::params::configfile_mode,
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
            path    => '/usr/bin:/usr/sbin:/bin',
            command => "rm -rf ${debmirror::params::homedir}",
            onlyif  => "test -d ${debmirror::params::homedir}"
        }

        # Delete debmiror data directory
        exec { "rm -rf ${debmirror::datadir}":
            path    => '/usr/bin:/usr/sbin:/bin',
            command => "rm -rf ${debmirror::datadir}",
            onlyif  => "test -d ${debmirror::datadir}"
        }

    }

}
