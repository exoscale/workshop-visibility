class shorten {

  package { ['redis-server', 'python-pip', 'gunicorn', 'nginx']:
    ensure => installed
  }

  exec { 'pip install url_shortener':
    path => "/bin:/usr/bin",
    unless => "pip freeze -l | grep ^url-shortener",
    require => [ Package['python-pip'],
                 Package['gunicorn'] ]
  }

  service { 'nginx':
    ensure => running,
    require => Package['nginx']
  }

  file { '/etc/init/shorten.conf':
    source => "puppet:///modules/shorten/shorten-upstart.conf"
  }

  file { '/etc/nginx/sites-enabled/default':
    ensure => absent,
    require => Package['nginx']
  }

  file { '/etc/nginx/sites-enabled/shorten':
    ensure => present,
    notify => Service['nginx'],
    require => Package['nginx'],
    source => "puppet:///modules/shorten/shorten-nginx.conf"
  }

  service { 'shorten':
    provider => upstart,
    require => File['/etc/init/shorten.conf'],
    ensure => running
  }
}
