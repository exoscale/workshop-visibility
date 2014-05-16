class cassandra {

  file { '/etc/apt/sources.list.d/cassandra.list':
    content => "deb http://www.apache.org/dist/cassandra/debian 20x main\n"
  }

  exec { 'gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00':
    path => "/bin:/usr/bin",
    unless => "gpg --list-keys | grep 2B5C1B00"
  }

  exec { 'gpg --export --armor 2B5C1B00 | sudo apt-key add -':
    path => "/bin:/usr/bin",
    unless => "apt-key list | grep 2B5C1B00",
    notify => Exec['apt-get update']
  }

  exec { 'apt-get update':
    path => "/bin:/usr/bin",
    refreshonly => true
  }

  package { 'cassandra':
    ensure => installed,
    require => Exec['gpg --export --armor 2B5C1B00 | sudo apt-key add -']
  }

}
