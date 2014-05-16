class java {
  $jdk = 'openjdk-7-jre-headless'

  package { $jdk:
    ensure => installed
  }
}
