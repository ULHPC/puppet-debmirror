# File::      <tt>debmirror-params.pp</tt>
# Author::    Hyacinthe Cartiaux (hyacinthe.cartiaux@uni.lu)
# Copyright:: Copyright (c) 2011 Hyacinthe Cartiaux
# License::   GPL v3
#
# ------------------------------------------------------------------------------
# = Class: debmirror::params
#
# In this class are defined as variables values that are used in other
# debmirror classes.
# This class should be included, where necessary, and eventually be enhanced
# with support for more OS
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# The usage of a dedicated param classe is advised to better deal with
# parametrized classes, see
# http://docs.puppetlabs.com/guides/parameterized_classes.html
#
# [Remember: No empty lines between comments and class definition]
#
class debmirror::params {

    ######## DEFAULTS FOR VARIABLES USERS CAN SET ##########################
    # (Here are set the defaults, provide your custom variables externally)
    # (The default used is in the line with '')
    ###########################################

    # ensure the presence (or absence) of debmirror
    $ensure = $debmirror_ensure ? {
        ''      => 'present',
        default => "${debmirror_ensure}"
    }

    # source / all / amd64 / 190Go
    $arch = $debmirror_arch ? {
        ''      => 'amd64',
        default => "${debmirror_arch}"
    }

    $user = $debmirror_user ? {
        ''      => 'debmirror',
        default => "${debmirror_user}"
    }

    $homedir = $debmirror_homedir ? {
        ''      => '/var/lib/debmirror',
        default => "${debmirror_homedir}"
    }

    $datadir = $debmirror_datadir ? {
        ''      => '/data/debmirror',
        default => "${debmirror_homedir}"
    }

    $archvsync_dir = $debmirror_archvsync_dir ? {
        ''      => 'archvsync',
        default => "${debmirror_archvsync_dir}"
    }

    $archvsync_gitsrc = $debmirror_archvsync_gitsrc ? {
        ''      => 'https://ftp-master.debian.org/git/archvsync.git',
        default => "${debmirror_archvsync_gitsrc}"
    }

    $cron = $debmirror_cron ? {
        ''      => 'yes',
        default => "yes"
    }


    #### MODULE INTERNAL VARIABLES  #########
    # (Modify to adapt to unsupported OSes)
    #######################################

    $list_arch = ['alpha', 'amd64', 'arm', 'armel', 'hppa', 'hurd-i386', 'i386',
                  'ia64', 'kfreebsd-amd64', 'kfreebsd-i386', 'm68k', 'mipsel',
                  'mips', 'powerpc', 's390', 'sparc']

    $configdir_mode = $::operatingsystem ? {
        default => '0755',
    }

    $configfile_mode = $::operatingsystem ? {
        default => '0644',
    }

    $configfile_owner = $::operatingsystem ? {
        default => "${user}",
    }

    $configfile_group = $::operatingsystem ? {
        default => 'root',
    }

}

