import "stages.pp"
class { 'base': stage => repo }
class { 'shorten': }
class { 'collectd': }
