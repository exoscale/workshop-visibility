class riemann {

  include java

  package { 'riemann':
    ensure => installed,
    require => Package[$java::jdk]
  }

  service { 'riemann':
    ensure => running
  }

  file { '/etc/riemann/riemann.config':
    source => "puppet:///modules/riemann/riemann.config",
    require => Package['riemann'],
    notify => Service['riemann']
  }

}
