require "minitest/unit"
require "minitest/autorun"
require "mocha/setup"
require_relative "../lib/minigraphite"
require_relative "../lib/minigraphite/log"

class MiniGraphiteTest < MiniTest::Unit::TestCase

	def test_datapoint
		Dalia::MiniGraphite::Log.any_instance.expects(:debug).with("INITIALIZED")

		Dalia::MiniGraphite.config({ :graphite_host => "graphite.it.daliaresearch.com", :graphite_port => 2003 })

		socket_mock = mock()
		TCPSocket.expects(:new).with("graphite.it.daliaresearch.com", 2003).returns(socket_mock)
		socket_mock.expects(:print).with("test.age 31 1357117860\n")
		socket_mock.expects(:close)

		Dalia::MiniGraphite::Log.any_instance.expects(:log).with("DATAPOINT SIGNAL SENT: test.age 31 1357117860\n")

		Dalia::MiniGraphite.datapoint("test.age", 31, Time.parse("2013-01-02 10:11"))
	end

	def test_counter
		Dalia::MiniGraphite::Log.any_instance.expects(:debug).with("INITIALIZED")

		Dalia::MiniGraphite.config({ :statsd_host => "graphite.it.daliaresearch.com", :statsd_port => 8125 })

		socket_mock = mock()
		UDPSocket.expects(:new).returns(socket_mock)
		socket_mock.expects(:send).with("height:231|c", 0, "graphite.it.daliaresearch.com", 8125 )

		Dalia::MiniGraphite::Log.any_instance.expects(:log).with("COUNTER SIGNAL SENT: height:231|c")

		Dalia::MiniGraphite.counter("height", 231)
	end

end
