import "stages.pp"
class { 'base': stage => repo }
class { 'riemann': }
class { 'riemann::dash': }
