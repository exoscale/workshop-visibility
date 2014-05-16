class nginx {

  package { 'nginx':
    ensure => installed
  }

  service { 'nginx':
    ensure => running,
    require => Package['nginx']
  }

  file { '/etc/nginx/sites-enabled/default':
    ensure => absent,
    require => Package['nginx']
  }

  define vhost($source) {
    file { "/etc/nginx/sites-enabled/${name}.conf":
      require => Package['nginx'],
      notify => Service['nginx'],
      source => $source,
      ensure => present
    }
  }

}
