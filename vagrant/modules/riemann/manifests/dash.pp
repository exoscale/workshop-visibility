class riemann::dash {

  package { 'ruby-full':
    ensure => installed
  }
->
  exec { 'gem install riemann-dash':
    path => "/bin:/usr/bin",
    unless => "gem list | grep riemann-dash",
    require => Package['ruby-full']
  }
->
  file { '/etc/riemann-dash.conf':
    notify => Service['riemann-dash'],
    content => "set :bind, \"0.0.0.0\"\n"
  }
->
  file { '/etc/init/riemann-dash.conf':
    source => "puppet:///modules/riemann/riemann-dash-upstart.conf"
  }
->
  service { 'riemann-dash':
    provider => upstart,
    require => File['/etc/init/riemann-dash.conf']
  }


}
