class collectd {

  package { 'collectd':
    ensure => installed
  }

  file { '/opt/collectd/etc/collectd.conf':
    source => "puppet:///modules/collectd/collectd.conf",
    require => Package['collectd'],
    notify => Service['collectd']
  }

  file { '/etc/init/collectd.conf':
    source => "puppet:///modules/collectd/collectd-upstart.conf",
    require => Package['collectd']
  }

  service { 'collectd':
    provider => upstart,
    ensure => running
  }


}
