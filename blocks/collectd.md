# Collectd

*The system statistics collection daemon*

> collectd is a daemon which collects system performance statistics
> periodically and provides mechanisms to store the values in a
> variety of ways, for example in RRD files.

[collectd](http://collectd.org)

## What does collectd do ?

collectd gathers statistics about the system it is running on and
stores this information. Those statistics can then be used to find
current performance bottlenecks (i.e. _performance analysis_) and
predict future system load (i.e. _capacity planning_)

## A typical collectd config

    Hostname    "web1"
    Interval     10

    Timeout      2
    ReadThreads  5
    WriteThreads 5

    LoadPlugin logfile

    <Plugin logfile>
      LogLevel info
      File STDOUT
      Timestamp true
      PrintSeverity false
    </Plugin>

    LoadPlugin cpu
    LoadPlugin load
    LoadPlugin memory
    LoadPlugin df
    LoadPlugin write_graphite
    LoadPlugin swap

    <Plugin cpu>
      ValuesPercentage true
      ReportByCpu false
    </Plugin>

    <Plugin df>
      MountPoint "/"
      ValuesPercentage true
    </Plugin>

    <Plugin load>
      ReportRelative true
    </Plugin>

    <Plugin memory>
      ValuesPercentage true
    </Plugin>

    <Plugin swap>
      ValuesPercentage true
    </Plugin>

    <Plugin write_graphite>
      <Carbon>
        Host "localhost"
        Port "2003"
        StoreRates false
        AlwaysAppendDS false
        EscapeCharacter "."
      </Carbon>
    </Plugin>
                                            
