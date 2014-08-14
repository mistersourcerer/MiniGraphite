require_relative "mini_graphite/version"
require_relative "mini_graphite/logger"

require "socket"

module Dalia
  module MiniGraphite
    DEFAULTS = {
      :graphite_host => "graphite.host.com",
      :graphite_port => 2003,
      :statsd_host => "statsd.host.com",
      :statsd_port => 8125,
      :mock_mode => false,
      :debug_mode => false
    }

    def self.config(opts = {})
      @opts = DEFAULTS.merge(opts)
      @logger = Dalia::MiniGraphite::Logger.new(opts[:debug_mode])
      logger.debug("Initalized with opts")
      logger.debug(opts.inspect)
    end

    def self.datapoint(key, value = 1, timestamp = Time.now)
      signal = "#{key} #{value} #{timestamp.to_i}"
      logger.debug("Sending datapoint: '#{signal}'")

      send_tcp(signal) if !opts[:mock_mode]
    end

    def self.counter(key, value = 1)
      signal = "#{key}:#{value}|c"
      logger.debug("Sending counter: '#{signal}'")

      send_udp(signal) if !opts[:mock_mode]
    end

  private

    def self.opts
      @opts
    end

    def self.logger
      @logger
    end

    def self.send_tcp(message)
      socket = TCPSocket.new(opts[:graphite_host], opts[:graphite_port])
      socket.print("#{message}\n")
      socket.close
    end

    def self.send_udp(message)
      socket = UDPSocket.new
      socket.send(message, 0, opts[:statsd_host], opts[:statsd_port])
      socket.close
    end

  end
end
