require "socket"

class Blackbox

	attr_accessor :graphite_host,
								:graphite_port,
								:statsd_host,
								:statsd_port

	def initialize(options = {})
		self.graphite_host = options[:graphite_host]
		self.graphite_port = options[:graphite_port]
		self.statsd_host = options[:statsd_host]
		self.statsd_port = options[:statsd_port]
	end

	def datapoint(key, value, options = {})
		timestamp = options[:timestamp] || Time.now.to_i
		socket = TCPSocket.new(self.graphite_host, self.graphite_host)
		socket.send("#{key} #{value} #{timestamp}")
		socket.close
	end

	def counter(key, options = {})
		socket = TCPSocket.new(self.graphite_host, self.graphite_host)
		socket.send("#{key} #{options[:value]} ")
		socket.close
	end

end
