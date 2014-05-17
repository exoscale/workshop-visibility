class riemann {

  include java

  package { 'riemann':
    ensure => installed,
    require => Package[$java::jdk]
  }

  exec { 'useradd -d /home/riemann -s /bin/false riemann':
    path => "/bin:/usr/bin:/sbin:/usr/sbin",
    unless => "grep ^riemann /etc/passwd"
  }

  service { 'riemann':
    ensure => running,
    require => [ Package['riemann'],
                 Exec['useradd -d /home/riemann -s /bin/false riemann'] ]
  }

  file { '/etc/riemann/riemann.config':
    source => "puppet:///modules/riemann/riemann.config",
    require => Package['riemann'],
    notify => Service['riemann']
  }

}
