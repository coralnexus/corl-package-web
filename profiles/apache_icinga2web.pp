/**
 * Icinga2 web interface profile.
 */
class coralnexus::web::profile::apache_icinga2web {

  $base_name = 'coralnexus_icinga_interface'
  anchor { $base_name: }

  #-----------------------------------------------------------------------------
  # Required systems

  if ! defined('coralnexus::core::profile::icinga_server') {
    class { 'coralnexus::core::profile::icinga_server': }
  }
  if ! defined('coralnexus::web::profile::apache_server') {
    class { 'coralnexus::web::profile::apache_server': }
  }
  if ! defined('coralnexus::core::profile::php') {
    class { 'coralnexus::core::profile::php': }
  }

  class { 'icinga2web':
    require => [
      Class['coralnexus::core::profile::icinga_server'],
      Class['coralnexus::core::profile::php']
    ]
  }

  #---

  apache::vhost::file { $base_name:
    doc_root               => "${icinga2web::params::repo_path}/public",
    server_name            => global_param('apache_icinga2web_domain', $::hostname),
    aliases                => global_array('apache_icinga2web_aliases'),
    admin_email            => global_param('apache_icinga2web_admin_email', $apache::params::admin_email),
    vhost_ip               => global_param('apache_icinga2web_vhost_ip', $apache::params::vhost_ip),
    priority               => global_param('apache_icinga2web_priority',$apache::params::priority),
    options                => global_param('apache_icinga2web_options', $apache::params::options),
    http_port              => global_param('apache_icinga2web_http_port', $apache::params::http_port),
    https_port             => global_param('apache_icinga2web_https_port', $apache::params::https_port),
    use_ssl                => global_param('apache_icinga2web_use_ssl', $apache::params::use_ssl),
    ssl_compression        => global_param('apache_icinga2web_ssl_compression', $apache::params::ssl_compression),
    ssl_honor_cipher_order => global_param('apache_icinga2web_ssl_honor_cipher_order', $apache::params::ssl_honor_cipher_order),
    ssl_cert               => global_param('apache_icinga2web_ssl_cert', $apache::params::ssl_cert),
    ssl_key                => global_param('apache_icinga2web_ssl_key', $apache::params::ssl_key),
    ssl_chain              => global_param('apache_icinga2web_ssl_chain', $apache::params::ssl_chain),
    ssl_protocol           => global_param('apache_icinga2web_ssl_protocol', $apache::params::ssl_protocol),
    ssl_cipher             => global_param('apache_icinga2web_ssl_cipher', $apache::params::ssl_cipher),
    error_log_level        => global_param('apache_icinga2web_error_log_level', $apache::params::error_log_level),
    rewrite_log_level      => global_param('apache_icinga2web_rewrite_log_level', $apache::params::rewrite_log_level),
    require                => Class['icinga2web'],
  }

  #-----------------------------------------------------------------------------
  # Optional systems

  corl::include { 'apache_icinga2web_classes': require => Class['icinga2web'] }
}
