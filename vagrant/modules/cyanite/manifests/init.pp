class cyanite {
  include java

  package { 'cyanite':
    ensure => installed,
    require => Package[$java::jdk]
  }
->
  package { 'graphite-api':
    ensure => installed
  }
->
  user { 'cyanite_user':
    name => "cyanite",
    ensure => "present",

    home => "/home/cyanite",
    shell => "/bin/false"
  }
->
  file { '/etc/cyanite.yaml':
    source => "puppet:///modules/cyanite/cyanite.yaml",
#    notify => Service['cyanite']
  }
->
  exec { 'curl https://raw.githubusercontent.com/pyr/cyanite/master/doc/schema.cql | cqlsh':
    unless => "echo describe keyspaces | cqlsh | grep metric",
    path => "/bin:/usr/bin",
#    require => [ Service['cassandra'],
#                 Service['cyanite'],
#                 Service['graphite-api'] ]
    require => Service['cassandra']
  }
->
  service { 'cyanite':
    ensure => running,
    require => [ Package['cyanite'],
                 User['cyanite_user'],
                 File['/etc/cyanite.yaml'] ]
  }

  file { '/etc/graphite-api.yaml':
    source => "puppet:///modules/cyanite/graphite-api.yaml",
#    notify => Service['graphite-api']
  }
->
  service { 'graphite-api':
    ensure => running,
    require => [ Package['graphite-api'],
                 File['/etc/graphite-api.yaml'] ]
  }
}
