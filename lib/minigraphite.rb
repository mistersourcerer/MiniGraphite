require_relative "minigraphite/version"
require_relative "minigraphite/log"

require "socket"

module Dalia
end

module Dalia::MiniGraphite

	def self.config(options = {})
		@@graphite_host = options[:graphite_host]
		@@graphite_port = options[:graphite_port]
		@@statsd_host = options[:statsd_host]
		@@statsd_port = options[:statsd_port]
		@@log = Dalia::MiniGraphite::Log.new
		@@log.debug("INITIALIZED")
	end

	def self.datapoint(key, value, timestamp = Time.now)
		signal = "#{key} #{value} #{timestamp.to_i}\n"
		socket = TCPSocket.new(@@graphite_host, @@graphite_port)
		socket.print(signal)
		socket.close
		@@log.log("DATAPOINT SIGNAL SENT: " + signal)
	end

	def self.counter(key, value = 1)
		signal = "#{key}:#{value}|c"
		socket = UDPSocket.new
		socket.send(signal, 0, @@statsd_host, @@statsd_port)
		@@log.log("COUNTER SIGNAL SENT: " + signal)
	end

end
