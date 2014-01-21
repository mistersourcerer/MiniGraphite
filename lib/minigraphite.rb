require_relative "minigraphite/version"
require_relative "minigraphite/log"

require "socket"

module Dalia
end

module Dalia::MiniGraphite

	def self.config(options = {})
		@@mock_mode = options[:mock_mode] || false
		debug_mode = options[:debug_mode].nil? ? true : options[:debug]
		@@graphite_host = options[:graphite_host]
		@@graphite_port = options[:graphite_port]
		@@statsd_host = options[:statsd_host]
		@@statsd_port = options[:statsd_port]
		@@log = Dalia::MiniGraphite::Log.new(debug_mode)
		@@log.debug("INITIALIZED")
	end

	def self.datapoint(key, value, timestamp = Time.now)
		return if @@mock_mode
		signal = "#{key} #{value} #{timestamp.to_i}\n"
		socket = TCPSocket.new(@@graphite_host, @@graphite_port)
		socket.print(signal)
		socket.close
		@@log.debug("DATAPOINT SIGNAL SENT: " + signal)
	end

	def self.counter(key, value = 1)
		return if @@mock_mode
		signal = "#{key}:#{value}|c"
		socket = UDPSocket.new
		socket.send(signal, 0, @@statsd_host, @@statsd_port)
		@@log.debug("COUNTER SIGNAL SENT: " + signal)
	end

end
