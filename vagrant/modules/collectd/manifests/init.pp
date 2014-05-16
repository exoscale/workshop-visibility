## this needs to be broken into smaller pieces!
class collectd {

  include upstart

  $pkg_defaults = {ensure => latest, require => Apt::Source['exoscale'], notify => Service['collectd']}

  $thresholds = hiera_hash('thresholds', {})

  $cfg = merge({packages => {},
                interval => {interval => {seconds => 60}},
                load => {},
                limits => {rthreads => 5, wthreads => 5},
                standard => {},
                python => {},
                aggregation => {},
                upstart => true,
                hostname => {"${hostname}" => {} },
                config => '/opt/collectd/etc/collectd.conf',
                graphite => {},
                snmp => {},
                snmptypes => {},
                riemann => {},
                json => {}},
                hiera_hash('collectd'))

  $collectd_config = $cfg['config']
  $collectd_upstart = $cfg['upstart']

  $raid_type = hiera('raid-type', false)


  create_resources(package, $cfg['packages'], $pkg_defaults)
  create_resources(collectd::load_plugin, $cfg['load'])
  create_resources(collectd::plugin_config, $cfg['standard'])
  create_resources(collectd::python_module, $cfg['python'])
  create_resources(collectd::aggregation_plugin, $cfg['aggregation'])
  create_resources(collectd::write_graphite_plugin, $cfg['graphite'])
  create_resources(collectd::write_riemann_plugin, $cfg['riemann'])
  create_resources(collectd::interval, $cfg['interval'])
  create_resources(collectd::hostname, $cfg['hostname'])
  create_resources(collectd::snmp_host, $cfg['snmp'])
  create_resources(collectd::json_plugin, $cfg['json'])

  $rthreads = $cfg['limits']['rthreads']
  $wthreads = $cfg['limits']['wthreads']
  $wq_limit_high = $cfg['limits']['wq_limit_high']
  $wq_limit_low = $cfg['limits']['wq_limit_low']

  concat::fragment { 'collectd-limits':
    order => 07,
    target => $collectd::collectd_config,
    content => template("collectd/collectd.limits.erb")
  }

  concat { $collectd_config:
    owner => 'root',
    group => 'root',
    mode => '0644',
    require => Package['collectd'],
    notify => Service['collectd']
  }

  concat::fragment { 'collectd-dbtypes':
    order => 04,
    target => $collectd::collectd_config,
    content => "TypesDB \"/opt/collectd/share/collectd/types.db\" \"/opt/collectd/etc/types.db.custom\"\n"
  }

  define interval($seconds=10, $order=06) {
    concat::fragment { 'collectd-interval':
      order => $order,
      target => $collectd::collectd_config,
      content => "Interval ${seconds}\n"
    }
  }

  define hostname($order=05) {
    concat::fragment { 'collectd-hostname':
      order => $order,
      target => $collectd::collectd_config,
      content => "Hostname ${title}\n"
    }
  }


  class java {
    collectd::load_plugin { 'java': }

    $java_jvm_args = "JVMArg \"-Djava.class.path=/opt/collectd/share/collectd/java/generic-jmx.jar:/opt/collectd/share/collectd/java/collectd-api.jar\""
    $generic_jmx_plugin_arg = "LoadPlugin \"org.collectd.java.GenericJMX\""
    concat::fragment { "java-genericjmx-start":
      order => 70,
      target => $collectd::collectd_config,
      content => "<Plugin java>\n\t${java_jvm_args}\n\t$generic_jmx_plugin_arg\n\t<Plugin GenericJMX>\n"
    }
    concat::fragment { "java-genericjmx-end":
      order => 79,
      target => $collectd::collectd_config,
      content => "\t</Plugin>\n</Plugin>\n"
    }
  }

  define jmx_add_mbean($instanceprefix=false, $object, $instancefrom=false, $values=[]) {
    concat::fragment { "java-genericjmx-beans-${title}":
      order => 72,
      target => $collectd::collectd_config,
      content => template('collectd/collectd.genericjmx.bean.erb')
    }
  }

  define jmx_connection($host=$hostname,$for=$title,$url,$extra_mbeans=[],$add_defaults=true) {
    $default_mbeans = [ "${for}-memory",
                        "${for}-mempool",
                        "${for}-gc",
                        "${for}-os",
                        "${for}-classloading",
                        "${for}-compilation",
                        "${for}-runtime",
                        "${for}-cpu" ]
    if ($add_defaults) {
      $mbeans = flatten([$default_mbeans, $extra_mbeans])
    } else {
      $mbeans = $extra_mbeans
    }
    concat::fragment { "java-genericjmx-connection-${title}":
      order => 78,
      target => $collectd::collectd_config,
      content => template('collectd/collectd.genericjmx.connection.erb')
    }
  }

  define jmx_standard_mbeans() {
    concat::fragment { "java-genericjmx-standardbeans-${title}":
      order => 71,
      target => $collectd::collectd_config,
      content => template('collectd/collectd.genericjmx.standardbean.erb')
    }
  }
  class json {
    collectd::load_plugin { 'curl_json': globals => true, interval => 1800}

    concat::fragment { "collectd-json-start":
      order => 35,
      target => $collectd::collectd_config,
      content => "<Plugin curl_json>\n"
    }

    concat::fragment { "collectd-json-end":
      order => 39,
      target => $collectd::collectd_config,
      content => "</Plugin>\n"
    }
  }

  define json_plugin($instance=$title, $url, $keys={}) {

    include json

    concat::fragment { "collectd-json-plugin-${title}":
      order => 37,
      target => $collectd::collectd_config,
      content => template('collectd/collectd.json.conf.erb')
    }
  }

  class python {
    collectd::load_plugin { 'python': globals => true, interval => 300}

    concat::fragment { "collectd-python-start":
      order => 40,
      target => $collectd::collectd_config,
      content => "<Plugin python>\n\tModulePath \"/opt/collectd/lib/collectd/python\"\n\tLogTraces true\n"
    }

    concat::fragment { "collectd-python-end":
      order => 49,
      target => $collectd::collectd_config,
      content => "</Plugin>\n"
    }
  }

  define python_module($import=$title, $packages={}, $config={}) {

    include python

    concat::fragment { "collectd-python-module-${title}":
      order => 45,
      target => $collectd::collectd_config,
      content => template('collectd/collectd.python.module.conf.erb')
    }

    create_resources(package, $packages, {ensure => latest})
  }

  class snmp {
    collectd::load_plugin { 'snmp': }

    concat::fragment { "collectd-snmp-start":
      order => 50,
      target => $collectd::collectd_config,
      content => "<Plugin snmp>\n"
    }

    concat::fragment { "collectd-snmp-probes":
      order => 52,
      target => $collectd::collectd_config,
      content => template('collectd/collectd.snmp.probes.conf.erb')
    }

    concat::fragment { "collectd-snmp-end":
      order => 59,
      target => $collectd::collectd_config,
      content => "</Plugin>\n"
    }
  }

  define snmp_host($host=$title, $type, $interval='120') {
    $typeconfig = $collectd::cfg['snmptypes'][$type]

    include snmp

    concat::fragment { "collectd-snmp-host-${title}":
      order => 55,
      target => $collectd::collectd_config,
      content => template('collectd/collectd.snmp.host.conf.erb')
    }
  }


  define load_plugin($order=10, $globals=false, $interval=false) {
    concat::fragment { "collectd-plugin-${title}":
      order => $order,
      target => $collectd::collectd_config,
      content => template('collectd/collectd.loadplugin.conf.erb')
    }
  }

  define plugin_config($plugin=$title, $args='', $settings=[], $order=20) {
    concat::fragment { "collectd-pluginconf-${plugin}":
      order => $order,
      target => $collectd::collectd_config,
      content => template('collectd/collectd.plugin.conf.erb')
    }
  }

  define plugin_config_composite($plugin=$title, $args='', $order_start=95, $order_stop=98) {
    concat::fragment { "collectd-composite-plugin-conf-start-${plugin}":
      order => $order_start,
      target => $collectd::collectd_config,
      content => inline_template("<Plugin <%= plugin %> <%= args %>>\n")
    }

    concat::fragment { "collectd-composite-plugin-conf-stop-${plugin}":
      order => $order_stop,
      target => $collectd::collectd_config,
      content => inline_template("</Plugin>\n")
    }

  }

  define aggregation_config($plugin=$title, $host=false, $plugin_instance=false,
  $plugin_type, $type_instance=false, $calc_num=false, $calc_sum=false, $calc_avg=true,
  $calc_min=false, $calc_max=false, $calc_dev=false, $group_by=[], $order=86) {
    concat::fragment { "collectd-aggregation-config-${title}":
      order => $order,
      target => $collectd::collectd_config,
      content => template('collectd/collectd.aggregation.conf.erb')
    }
  }

  define aggregation_plugin($aggregations, $order_start=85, $order_stop=88) {
    plugin_config_composite { "aggregation": order_start => $order_start, order_stop => $order_stop }
    create_resources(collectd::aggregation_config, $aggregations)
  }

  define mysql_database_config($dbname=$title, $host="localhost", $port="3306", $user,
  $password, $masterstats=false, $slavestats=false) {
    concat::fragment { "collectd-mysql-db-config-${title}":
      order => 66,
      target => $collectd::collectd_config,
      content => template('collectd/collectd.database.conf.erb')
    }
  }

  class mysql_plugin {
    collectd::load_plugin { 'mysql': }

    plugin_config_composite { "mysql":
      order_start => 65,
      order_stop => 67
    }
  }

  define carbon_config($host, $port='2003', $escape_char='.', $prefix='collectd.',
  $store_rates='true', $always_append_ds='false', $order=96) {
    concat::fragment { "collectd-carbon-config-${title}":
      order => $order,
      target => $collectd::collectd_config,
      content => template('collectd/collectd.carbon.conf.erb')
    }
  }

  define write_graphite_plugin($carbon_configs, $settings=[], $order=96) {
    plugin_config_composite { "write_graphite": }

    create_resources(collectd::carbon_config, $carbon_configs)
  }

  define riemann_node_config($host, $name=$title, $ttlfactor="2.0", $settings={}, $thresholds=$collectd::thresholds) {
    concat::fragment { "collectd-riemann-node-config-${title}":
      order => 93,
      target => $collectd::collectd_config,
      content => template("collectd/collectd.riemann.conf.erb");
    }
  }

  define write_riemann_plugin($nodes, $settings=[]) {
    plugin_config_composite { "write_riemann":
      order_start => 91,
      order_stop => 94
    }
    concat::fragment { "collectd-riemann-settings":
      order => 92,
      target => $collectd::collectd_config,
      content => inline_template("<% settings.each do |s| -%>\t<%= s %>\n<% end -%>\n");
    }
    create_resources(collectd::riemann_node_config, $nodes)
  }

  if ($collectd_upstart) {
    upstart::job { 'collectd':
      cmd => '/opt/collectd/sbin/collectd',
      daemon => 'fork'
    }

    service { 'collectd':
      require => [ Concat[$collectd_config], Upstart::Job['collectd'] ],
      provider => upstart,
      ensure => running
    }
  } else {
    service { 'collectd':
      require => Concat[$collectd_config],
      start => "/opt/collectd/sbin/collectd",
      stop => "pkill collectd",
      provider => "base",
      ensure => running
    }
  }

  case $raid_type {
    'megaraid': {
      package { 'megaraid-collectd': }
      collectd::load_plugin { 'exec': }
      collectd::plugin_config { 'exec':
        settings => [ 'Exec "exoadmin:exoadmin" "/usr/local/bin/megaraid-collectd.pl"' ]
      }
    }
  }

}
