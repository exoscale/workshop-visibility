class cyanite {
  include java

  package { 'cyanite':
    require => Package[$java::jdk]
  }

  exec { 'useradd -d /home/cyanite -s /bin/false cyanite':
    path => "/bin:/usr/bin:/sbin:/usr/sbin",
    unless => "grep ^cyanite /etc/passwd"
  }

  file { '/etc/cyanite.yaml':
    source => "puppet:///modules/cyanite/cyanite.yaml",
    notify => Service['cyanite']
  }

  service { 'cyanite':
    ensure => running,
    require => [ Package['cyanite'],
                 Exec['useradd -d /home/cyanite -s /bin/false cyanite'] ]
  }
}
