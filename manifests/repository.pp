# File::      <tt>debmirror-repository.pp</tt>
# Author::    Hyacinthe Cartiaux (<hyacinthe.cartiaux@uni.lu>)
# Copyright:: Copyright (c) 2011 Hyacinthe Cartiaux
# License::   GPLv3
# ------------------------------------------------------------------------------
# = Define: debmirror::repository
#
# Create the mirror of a repository
# You are expected to use as name when defining this resource the name of the repository
#
# == Parameters:
#
# [*mirror*]
#   The source of the Git repo. It can be either a local file OR an url.
#
# [*arch*]
#   The directory from which to run the 'git clone' command. If this directory
#   does not exist, the command will fail.
#
# [*ensure*]
#   The basic property that the resource should be in. Valid values are present,
#   absent.
#
# [*cron*]
#   If set to yes, the repository will be synced regularly by a cron job.
#
# [*hour*] , [*minute*]
#   The time at which the repository whill be synchronized.
#
# = Usage:
#
#          debmirror::repository { "debian-security":
#                mirror  => "security.debian.org",
#                arch    => "amd64"
#                ensure  => "present",
#                hour    => "1",
#                minute  => "30",
#          }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define debmirror::repository(
    $mirror,
    $arch   = $debmirror::params::arch,
    $cron   = $debmirror::params::cron,
    $hour   = '2',
    $minute = '0',
    $ensure = 'present'
)
{

    include debmirror::params

    # $name is provided by define invocation and is the name of the directory
    # used in the ftpsync configuration file
    $repository   = $name
    $mirror_dir   = "${debmirror::datadir}/${repository}"
    $config_file  = "${debmirror::params::homedir}/etc/ftpsync.${repository}.conf"
    $arch_exclude = join(delete($debmirror::params::list_arch, $arch), ' ')

    # Create ftpsync configuration file from template
    file { $config_file:
        ensure  => $ensure,
        owner   => $debmirror::params::configfile_owner,
        group   => $debmirror::params::configfile_group,
        mode    => $debmirror::params::configfile_mode,
        content => template('debmirror/ftpsync.sample.conf.erb'),
    }

    if ($ensure == 'absent')
    {
        # Delete mirror directory
        exec { "rm -rf ${mirror_dir}":
            path    => '/usr/bin:/usr/sbin:/bin',
            command => "rm -rf ${mirror_dir}",
            onlyif  => "test -d ${mirror_dir}"
        }
    } else {
        file { $mirror_dir:
            ensure  => 'directory',
            owner   => $debmirror::params::configfile_owner,
            group   => $debmirror::params::configfile_group,
            mode    => $debmirror::params::configfile_mode,
            require => User[$debmirror::params::user],
        }

        File[$config_file] {
            require => File["${debmirror::params::homedir}/etc"],
        }
    }

    # Cronjob

    $ensure_cron = $cron ? {
        'yes' => $ensure,
        'no'  => 'absent',
        default  => 'absent'
    }

    cron { "debmirror-cronjob-${repository}":
        ensure  => $ensure_cron,
        command => "${debmirror::params::homedir}/bin/run_ftpsync ${repository}",
        user    => 'root',
        minute  => $minute,
        hour    => $hour,
    }

}


