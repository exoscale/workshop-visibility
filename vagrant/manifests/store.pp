import "stages.pp"
class { 'base': stage => repo }
class { 'cyanite': }
class { 'cassandra': }
class { 'grafana': }
