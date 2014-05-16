class grafana {

  include nginx

  package { 'grafana':
    ensure => installed
  }

  nginx::vhost { 'grafana':
    source => "puppet:///modules/grafana/grafana-vhost.conf"
  }
}
