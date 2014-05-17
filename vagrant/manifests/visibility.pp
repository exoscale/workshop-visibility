import "stages.pp"
class { 'base': stage => repo }
class { 'shorten': }
class { 'collectd': }
class { 'riemann': }
class { 'riemann::dash': }
class { 'cyanite': }
class { 'cassandra': }
class { 'grafana': }
