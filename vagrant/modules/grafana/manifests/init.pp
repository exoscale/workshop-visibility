class grafana {
  include nginx

  package { 'grafana':
    ensure => installed
  }

  file { '/srv/www/grafana/config.js':
    source => "puppet:///modules/grafana/grafana.conf.js",
    require => Package['grafana']
  }

  nginx::vhost { 'grafana':
    source => "puppet:///modules/grafana/grafana-nginx.conf"
  }
}
