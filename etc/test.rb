require_relative "../lib/mini_graphite.rb"

Dalia::MiniGraphite.config({ :graphite_host => "graphite.it.daliaresearch.com", :graphite_port => 2003,
								 						 :statsd_host => "graphite.it.daliaresearch.com", :statsd_port => 8125 })

Dalia::MiniGraphite.datapoint("test.age", 12, Time.now)
Dalia::MiniGraphite.counter("test.height", 94 )
