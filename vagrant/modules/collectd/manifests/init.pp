class collectd {

  package { 'collectd':
    ensure => installed
  }

  file { '/opt/collectd/etc/collectd.conf':
    source => "puppet:///modules/collectd/collectd.conf",
    require => Package['collectd'],
    notify => Service['collectd']
  }

  file { '/etc/init.d/collectd':
    ensure => absent
  }

  file { '/etc/init/collectd.conf':
    ensure => present,
    source => "puppet:///modules/collectd/collectd-upstart.conf"
  }

  service { 'collectd':
    ensure => running,
    provider => upstart,
    require => File['/etc/init/collectd.conf']
  }


}
