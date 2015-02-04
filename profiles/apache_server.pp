/**
 * Apache base profile (included in other profiles).
 */
class coralnexus::web::profile::apache_server {

  $base_name = 'coralnexus_apache_server'
  anchor { $base_name: }

  #-----------------------------------------------------------------------------
  # Required systems

  class { 'apache': require => Anchor[$base_name] }

  #-----------------------------------------------------------------------------
  # Optional systems

  corl::include { 'apache_server_classes':
    require => Class['apache']
  }

  #-----------------------------------------------------------------------------
  # Resources

  corl_resources('apache::conf', 'apache::conf', 'apache::conf_defaults')
  corl_resources('apache::module', 'apache::module', 'apache::module_defaults')

  corl_resources('apache::vhost', 'apache::vhost', 'apache::vhost_defaults')
  corl_resources('apache::vhost::file', 'apache::vhost::file', 'apache::vhost::file_defaults')
  corl_resources('apache::vhost::proxy', 'apache::vhost::proxy', 'apache::vhost::proxy_defaults')
  corl_resources('apache::vhost::redirect', 'apache::vhost::redirect', 'apache::vhost::redirect_defaults')
}
