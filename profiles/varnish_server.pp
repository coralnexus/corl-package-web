/**
 * Varnish proxy server profile.
 */
class coralnexus::web::profile::varnish_server {

  $base_name = 'coralnexus_varnish_server'
  anchor { $base_name: }

  #-----------------------------------------------------------------------------
  # Required systems

  class { 'varnish':
    require => Anchor[$base_name]
  }
  class { 'varnish::vcl':
    require => Class['varnish']
  }

  #-----------------------------------------------------------------------------
  # Optional systems

  corl::include { 'varnish_server_classes':
    require => Class['varnish::vcl']
  }

  #-----------------------------------------------------------------------------
  # Resources

  corl_resources('varnish::acl', 'varnish_server::acl', 'varnish_server::acl_defaults')
  corl_resources('varnish::probe', 'varnish_server::probe', 'varnish_server::probe_defaults')
  corl_resources('varnish::backend', 'varnish_server::backend', 'varnish_server::backend_defaults')
  corl_resources('varnish::director', 'varnish_server::director', 'varnish_server::director_defaults')
  corl_resources('varnish::selector', 'varnish_server::selector', 'varnish_server::selector_defaults')
}
