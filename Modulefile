name       'debmirror'
version    '0.0.3'
source     'git-admin.uni.lu:puppet-repo.git'
author     'Hyacinthe Cartiaux (hyacinthe.cartiaux@uni.lu)'
license    'GPL v3'
summary    'Manage Debian mirror'
description 'Manage Debian mirror'
project_page 'UNKNOWN'

## List of the classes defined in this module
classes    'debmirror, debmirror::common, debmirror::debian, debmirror::redhat, debmirror::params'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
dependency 'git'
defines    '["debmirror::repository"]'
