class riemann::dash {

  exec { 'gem install riemann-dash':
    path => "/bin:/usr/bin",
    unless => "gem list | grep riemann-dash",
  }

  file { '/etc/riemann-dash.conf':
    source => "puppet:///modules/riemann/riemann-dash.conf",
    notify => Service['riemann-dash'],
    content => "set :bind, \"0.0.0.0\"\n"
  }

  file { '/etc/init/riemann-dash.conf':
    source => "puppet:///modules/riemann/riemann-dash-upstart.conf"
  }

  service { 'riemann-dash':
    provider => upstart,
    require => File['/etc/init/riemann-dash.conf']
  }

  package { 'riemann':
    ensure => installed
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
