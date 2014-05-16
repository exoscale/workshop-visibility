class cyanite {
  include java

  package { 'cyanite':
    require => Package[$java::jdk]
  }

  file { '/etc/cyanite.yaml':
    source => "puppet:///modules/cyanite/cyanite.yaml",
    notify => Service['cyanite']
  }

  service { 'cyanite':
    ensure => running,
    require => Package['cyanite']
  }
}
