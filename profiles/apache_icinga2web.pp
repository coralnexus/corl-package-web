/**
 * Icinga2 web interface profile.
 */
class coralnexus::web::profile::apache_icinga2web {

  $base_name = 'coralnexus_icinga_interface'
  anchor { $base_name: }

  $apache_vhost_file = global_param('apache_icinga2web_vhost_name', '100-icingaweb2')
  $apache_vhost_port = global_param('apache_icinga2web_vhost_port', 80)

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

  corl::exec { 'apache_icinga2web':
    resources => {
      apache_vhost => {
        command => "${icinga2web::params::repo_path}/bin/icingacli setup config webserver apache --document-root '${icinga2web::params::repo_path}/public' > /etc/apache2/sites-available/${apache_vhost_file}.conf",
        creates => "/etc/apache2/sites-available/${apache_vhost_file}.conf",
        require => Class['icinga2web']
      },
      apache_port => {
        command => "echo 'Listen ${apache_vhost_port}' > /etc/apache2/conf.d/icinga2.conf",
        creates => "/etc/apache2/conf.d/icinga2.conf",
        require => Class['icinga2web']
      },
      apache_site_enable => {
        command     => "a2ensite ${apache_vhost_file}",
        refreshonly => true,
        subscribe   => [ 'apache_vhost', 'apache_port' ]
      },
      apache_restart => {
        command     => "service apache2 restart",
        refreshonly => true,
        subscribe   => 'apache_site_enable'
      }
    },
    defaults => {
      user  => 'www-data',
      group => 'www-data'
    }
  }

  #---

  corl::firewall { 'apache_icinga2web':
    resources => {
      icinga_http => {
        name   => "1000 INPUT Allow Icinga HTTP connections",
        action => "accept",
        chain  => "INPUT",
        state  => "NEW",
        proto  => "tcp",
        dport  => $apache_vhost_port
      }
    }
  }
}
