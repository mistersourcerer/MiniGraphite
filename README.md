# MiniGraphite

Simple wrapper for Graphite and Statsd

## Instructions

Check the `test` folder for examples, if you need more explanations please contact us.

## Installation

Add this line to your application's Gemfile:

    gem 'mini_graphite'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mini_graphite

## Usage

### Config

    Dalia::MiniGraphite.config({
      :graphite_host => "my.graphite.server.com",
      :graphite_port => 2003, # default 2003
      :statsd_host => "my.graphite.server.com",
      :statsd_port => 8125, # default 8125
      :mock_mode => false, # default false
      :debug_mode => true # default false
    })

### Simple signals

    Dalia::MiniGraphite.datapoint("my.key", 120, Time.now) # to Graphite
    Dalia::MiniGraphite.counter("my.key", 120) # to StatSD

### Block wrapper benchmark

     result =
       Dalia::MiniGraphite.benchmark_wrapper("key_prefix") do
         sleep(1)
         "RESULT"
       end

     puts result # => RESULT

This will send 4 signals:

- *key_prefix.ini*            # At the begining of the block
- *key_prefix.count*          # At the begining of the block, keep it for compatibility
- *key_prefix.time, ~1000*    # At the end of the block, with the Benchmark.realtime result of the execution
- *key_prefix.end*            # At the end of the block


## Contributing

1. Fork it ( http://github.com/<my-github-username>/mini_graphite/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
