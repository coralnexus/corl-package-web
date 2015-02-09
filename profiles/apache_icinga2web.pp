/**
 * Icinga2 web interface profile.
 */
class coralnexus::web::profile::apache_icinga2web {

  $base_name = 'coralnexus_icinga_interface'
  anchor { $base_name: }

  #-----------------------------------------------------------------------------
  # Required systems

  if ! defined('coralnexus::core::profile::icinga_server') {
    class { 'coralnexus::core::profile::icinga_server':
      require => Anchor[$base_name]
    }
  }
  if ! defined('coralnexus::web::profile::apache_server') {
    class { 'coralnexus::web::profile::apache_server':
      require => Anchor[$base_name]
    }
  }
  if ! defined('coralnexus::core::profile::php') {
    class { 'coralnexus::core::profile::php':
      require => Anchor[$base_name]
    }
  }

  class { 'icinga2web':
    require => [
      Class['coralnexus::core::profile::icinga_server'],
      Class['coralnexus::core::profile::php']
    ]
  }

  #-----------------------------------------------------------------------------
  # Optional systems

  corl::include { 'apache_icinga2web_classes': require => Class['icinga2web'] }

  #-----------------------------------------------------------------------------
  # Resources

  corl::definitions { 'apache_icinga2web::database':
    type      => 'percona::database',
    resources => {
      icinga_web => {
        ensure        => 'importdb',
        sql_dump_file => "${icinga2web::params::repo_path}/etc/schema/mysql.schema.sql",
        database      => 'icinga2_web',
        user_name     => 'icinga2_web',
        permissions   => 'ALL',
        grant         => false,
        allow_remote  => false,
        require       => Class['icinga2web']
      }
    }
  }

  #---

  corl::definitions { 'apache_icinga2web::vhost::file':
    type      => 'apache::vhost::file',
    resources => {
      icinga_web => {
        doc_root => "${icinga2web::params::repo_path}/public",
        require  => Class['icinga2web']
      }
    }
  }
}
