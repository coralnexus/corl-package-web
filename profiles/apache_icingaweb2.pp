/**
 * Icinga2 web interface profile.
 */
class coralnexus::web::profile::apache_icingaweb2 {

  $base_name = 'coralnexus_icinga_interface'
  anchor { $base_name: }

  $apache_vhost_file = global_param('apache_icingaweb2_vhost_name', '100-icingaweb2')
  $apache_vhost_port = global_param('apache_icingaweb2_vhost_port', 80)

  $icingaweb2_admin_user = global_param('apache_icingaweb2_admin_user', 'admin')
  $icingaweb2_admin_password_hash = global_param('apache_icingaweb2_admin_password_hash', '$1$rJk8h0JE$.wu1d81VG9ojwSpXXhtyw0') # admin

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

  class { 'icingaweb2':
    require => [
      Class['coralnexus::core::profile::icinga_server'],
      Class['coralnexus::core::profile::php']
    ]
  }

  #-----------------------------------------------------------------------------
  # Optional systems

  corl::include { 'apache_icingaweb2_classes': require => Class['icingaweb2'] }

  #-----------------------------------------------------------------------------
  # Resources

  $web_dbname   = $icingaweb2::params::resource_config['icingaweb2_db']['dbname']
  $web_username = $icingaweb2::params::resource_config['icingaweb2_db']['username']

  corl::definitions { 'apache_icingaweb2::database':
    type      => 'percona::database',
    resources => {
      icinga_web => {
        ensure        => 'importdb',
        sql_dump_file => "${icingaweb2::params::repo_dir}/etc/schema/mysql.schema.sql",
        database      => $web_dbname,
        user_name     => $web_username,
        permissions   => 'ALL',
        grant         => false,
        allow_remote  => false,
        require       => Class['icingaweb2']
      }
    }
  }

  $password_hash_insert = regsubst($icingaweb2_admin_password_hash, '\$', '\$', 'G')
  $password_hash_check  = regsubst($icingaweb2_admin_password_hash, '\$', '\\\$', 'G')

  corl::definitions { 'apache_icingaweb2::users':
    type => 'percona::query',
    resources => {
      admin => {
        query      => "REPLACE INTO icingaweb_user (name, active, password_hash, ctime, mtime) VALUES ('${icingaweb2_admin_user}', 1, '${password_hash_insert}', NOW(), NOW())",
        access     => 'unless',
        condition  => "SELECT name FROM icingaweb_user WHERE name = '${icingaweb2_admin_user}' AND password_hash = '${password_hash_check}'",
        database   => $web_dbname,
        hide_query => true
      }
    },
    defaults => {
      require => Corl::Definitions['apache_icingaweb2::database']
    }
  }

  #---

  corl::exec { 'apache_icingaweb2':
    resources => {
      enable_setup_module => {
        command  => "${icingaweb2::params::repo_dir}/bin/icingacli module enable setup",
        'unless' => "${icingaweb2::params::repo_dir}/bin/icingacli module list | grep setup",
        require  => Class['icingaweb2']
      },
      apache_vhost => {
        command => "${icingaweb2::params::repo_dir}/bin/icingacli setup config webserver apache --document-root '${icingaweb2::params::repo_dir}/public' > /etc/apache2/sites-available/${apache_vhost_file}.conf",
        creates => "/etc/apache2/sites-available/${apache_vhost_file}.conf",
        require => 'enable_setup_module'
      },
      apache_port => {
        command => "echo 'Listen ${apache_vhost_port}' > /etc/apache2/conf.d/icinga2.conf",
        creates => "/etc/apache2/conf.d/icinga2.conf",
        require => Class['icingaweb2']
      },
      apache_site_enable => {
        command     => "a2ensite ${apache_vhost_file}",
        refreshonly => true,
        subscribe   => [ 'apache_vhost', 'apache_port' ]
      },
      apache_restart => {
        command     => "service apache2 restart",
        refreshonly => true,
        subscribe   => 'apache_site_enable',
        notify      => Service['apache']
      }
    }
  }

  #---

  corl::firewall { 'apache_icingaweb2':
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
