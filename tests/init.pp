# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
#
#
# You can execute this manifest as follows in your vagrant box:
#
#      sudo puppet apply -t /vagrant/tests/init.pp
#
node default {

    class { 'debmirror':
        ensure        => 'present',
        allowed_hosts => ['10.1.0.0/16'],
        datadir       => '/export/debmirror'
    }

    debmirror::repository { 'debian':
        ensure => 'present',
        mirror => 'ftp.fr.debian.org',
        arch   => 'amd64',
        hour   => '5',
        minute => '05',
        cron   => 'yes',
    }

}
