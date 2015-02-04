/**
 * Apache powered static HTML sites.
 */
class coralnexus::web::profile::apache_static {

  $base_name = 'coralnexus_apache_static'
  anchor { $base_name: }

  #-----------------------------------------------------------------------------
  # Required systems

  include git

  if ! defined('coralnexus::web::profile::apache_server') {
    class { 'coralnexus::web::profile::apache_server': }
  }

  #-----------------------------------------------------------------------------
  # Optional systems

  corl::include { 'apache_site_classes':
    require => Class['coralnexus::web::profile::apache_server']
  }

  #-----------------------------------------------------------------------------
  # Resources

  corl_resources('coralnexus::web::profile::apache_static::git_site', 'apache::git_site', 'apache::git_site_defaults')
}

#-------------------------------------------------------------------------------
# Resource definitions

define coralnexus::web::profile::apache_static::git_site (
  $domain                        = $name,
  $doc_root                      = undef,
  $server_user                   = $apache::params::user,
  $server_group                  = $apache::params::group,
  $source                        = undef,
  $revision                      = $git::params::revision,
  $aliases                       = $apache::params::aliases,
  $admin_email                   = $apache::params::admin_email,
  $apache_vhost_ip               = $apache::params::vhost_ip,
  $apache_priority               = $apache::params::priority,
  $apache_options                = $apache::params::options,
  $apache_http_port              = $apache::params::http_port,
  $apache_https_port             = $apache::params::https_port,
  $apache_use_ssl                = $apache::params::use_ssl,
  $apache_ssl_compression        = $apache::params::ssl_compression,
  $apache_ssl_honor_cipher_order = $apache::params::ssl_honor_cipher_order,
  $apache_ssl_cert               = $apache::params::ssl_cert,
  $apache_ssl_key                = $apache::params::ssl_key,
  $apache_ssl_chain              = $apache::params::ssl_chain,
  $apache_ssl_protocol           = $apache::params::ssl_protocol,
  $apache_ssl_cipher             = $apache::params::ssl_cipher,
  $apache_error_log_level        = $apache::params::error_log_level,
  $apache_rewrite_log_level      = $apache::params::rewrite_log_level
) {

  $static_home_dir = "${apache::params::web_home}/static/${domain}"
  $static_doc_root = ensure($doc_root, "${static_home_dir}/${doc_root}", $static_home_dir)

  #---

  corl::file { $name:
    resources => {
      static_dir => {
        path    => "${apache::params::web_home}/static",
        ensure  => 'directory',
        require => File['apache_web_home']
      }
    }
  }

  #-----------------------------------------------------------------------------
  # HTML repository

  git::repo { $name:
    path              => $static_home_dir,
    user              => $server_user,
    owner             => $server_user,
    group             => $server_group,
    home_dir          => '',
    source            => $source,
    revision          => $revision,
    base              => false,
    monitor_file_mode => false,
    update_notify     => Apache::Vhost::File[$name]
  }

  #---

  apache::vhost::file { $name:
    doc_root               => $static_doc_root,
    server_name            => $domain,
    aliases                => $aliases,
    admin_email            => $admin_email,
    vhost_ip               => $apache_vhost_ip,
    priority               => $apache_priority,
    options                => $apache_options,
    http_port              => $apache_http_port,
    https_port             => $apache_https_port,
    use_ssl                => $apache_use_ssl,
    ssl_compression        => $apache_ssl_compression,
    ssl_honor_cipher_order => $apache_ssl_honor_cipher_order,
    ssl_cert               => $apache_ssl_cert,
    ssl_key                => $apache_ssl_key,
    ssl_chain              => $apache_ssl_chain,
    ssl_protocol           => $apache_ssl_protocol,
    ssl_cipher             => $apache_ssl_cipher,
    error_log_level        => $apache_error_log_level,
    rewrite_log_level      => $apache_rewrite_log_level
  }
}
