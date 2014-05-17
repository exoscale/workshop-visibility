class cyanite {
  include java

  package { 'cyanite':
    ensure => installed,
    require => Package[$java::jdk]
  }

  package { 'graphite-api':
    ensure => installed
  }

  exec { 'useradd -d /home/cyanite -s /bin/false cyanite':
    path => "/bin:/usr/bin:/sbin:/usr/sbin",
    unless => "grep ^cyanite /etc/passwd"
  }

  file { '/etc/cyanite.yaml':
    source => "puppet:///modules/cyanite/cyanite.yaml",
    notify => Service['cyanite']
  }

  exec { 'curl https://raw.githubusercontent.com/pyr/cyanite/master/doc/schema.cql | cqlsh':
    unless => "echo describe keyspaces | cqlsh | grep metric",
    path => "/bin:/usr/bin",
    require => Service['cassandra']
  }

  service { 'cyanite':
    ensure => running,
    require => [ Package['cyanite'],
                 Exec['useradd -d /home/cyanite -s /bin/false cyanite'] ]
  }

  file { '/etc/graphite-api.yaml':
    source => "puppet:///modules/cyanite/graphite-api.yaml",
    notify => Service['graphite-api']
  }

  service { 'graphite-api':
    ensure => running,
    require => Package['graphite-api']
  }
}
