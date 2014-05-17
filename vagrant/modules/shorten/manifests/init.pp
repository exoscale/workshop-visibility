class shorten {

  include nginx

  package { ['redis-server', 'python-pip', 'gunicorn']:
    ensure => installed
  }

  exec { 'pip install url_shortener':
    path => "/bin:/usr/bin",
    unless => "pip freeze -l | grep ^url-shortener",
    require => [ Package['python-pip'],
                 Package['gunicorn'] ]
  }

  file { '/etc/init/shorten.conf':
    source => "puppet:///modules/shorten/shorten-upstart.conf"
  }

  nginx::vhost { 'shorten':
    source => "puppet:///modules/shorten/shorten-nginx.conf"
  }

  service { 'shorten':
    provider => upstart,
    require => File['/etc/init/shorten.conf'],
    ensure => running
  }
}
