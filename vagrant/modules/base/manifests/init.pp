include base {

  stage { 'repo':
    before => Stage['main']
  }

  package { 'curl':
    ensure => installed
  }

  exec { 'curl https://packagecloud.io/install/repositories/exoscale/community/script.deb | sh':
    path => "/bin:/usr/bin",
    creates => "/etc/apt/sources.list.d/exoscale_community.list",
    require => Package['curl'],
    before => Stage['main']
  }
}
