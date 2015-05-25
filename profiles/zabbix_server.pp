/**
 * Zabbix server / web interface profile.
 */
class coralnexus::web::profile::zabbix_server {

  $base_name = 'coralnexus_zabbix_server'
  anchor { $base_name: }

  $zabbix_vhost_port = global_param('zabbix_server_vhost_port', 80)

  $zabbix_database = global_param('zabbix_server_database', 'zabbix')
  $zabbix_database_user = global_param('zabbix_server_database_user', 'zabbix')

  $zabbix_admin_user = global_param('zabbix_server_admin_user', 'admin')
  $zabbix_admin_password_hash = global_param('zabbix_server_admin_password_hash', '$1$rJk8h0JE$.wu1d81VG9ojwSpXXhtyw0') # admin

  #-----------------------------------------------------------------------------
  # Required systems

  if ! defined('coralnexus::core::profile::zabbix_client') {
    class { 'coralnexus::core::profile::zabbix_client':
      require => Anchor[$base_name]
    }
  }
  if ! defined('coralnexus::web::profile::percona_server') {
    class { 'coralnexus::web::profile::percona_server':
      require => Anchor[$base_name]
    }
  }

  class { 'zabbix::server':
    require => [
      Class['coralnexus::core::profile::zabbix_client'],
      Class['coralnexus::core::profile::percona_server']
    ]
  }

  #-----------------------------------------------------------------------------
  # Optional systems

  corl::include { 'zabbix_server_classes': require => Class['icingaweb2'] }

  #-----------------------------------------------------------------------------
  # Resources

  corl::definitions { 'zabbix_server::database':
    type      => 'percona::database',
    resources => {
      icinga_web => {
        ensure        => 'create',
        database      => $zabbix_database,
        user_name     => $zabbix_database_user,
        permissions   => 'ALL',
        grant         => false,
        allow_remote  => false,
        require       => Class['icingaweb2']
      }
    }
  }
}
