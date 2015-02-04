
class coralnexus::web::default::apache {

  $web_home = $coralnexus::web::default::web_home

  #---

  $modules = [
    "headers",
    "alias",
    "autoindex",
    "deflate",
    "env",
    "mime",
    "proxy",
    "proxy_http",
    "rewrite",
    "ssl",
    "vhost_alias"
  ]
}
