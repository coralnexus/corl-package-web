
class coralnexus::web::default {
  $web_home = '/var/www'

  $apache_icinga2web_classes = [
    "php::mod::curl",
    "php::mod::gd",
    "php::mod::xmlrpc",
    "php::mod::uploadprogress",
    "php::mod::xdebug"
  ]
}

