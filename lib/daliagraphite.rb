require_relative "daliagraphite/version"

require "socket"

module Dalia
end

module Dalia::MiniGraphite

	def self.config(options = {})
		@@graphite_host = options[:graphite_host]
		@@graphite_port = options[:graphite_port]
		@@statsd_host = options[:statsd_host]
		@@statsd_port = options[:statsd_port]
	end

	def self.datapoint(key, value, timestamp = Time.now)
		socket = TCPSocket.new(@@graphite_host, @@graphite_port)
		signal = "#{key} #{value} #{timestamp.to_i}\n"
		p signal
		socket.print(signal)
		socket.close
	end

	def self.counter(key, value = 1)
		socket = UDPSocket.new
		signal = "#{key}:#{value}|c"
		socket.send(signal, 0, @@statsd_host, @@statsd_port)
	end

end
