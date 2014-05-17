class cassandra {

  file { '/etc/apt/sources.list.d/cassandra.list':
    ensure => absent
  }

  exec { 'apt-get update':
    path => "/bin:/usr/bin",
    refreshonly => true
  }

  package { 'cassandra':
    ensure => installed
  }

  service { 'cassandra':
    ensure => running,
    require => Package['cassandra']
  }

}
