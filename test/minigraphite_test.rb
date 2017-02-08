require "minitest/autorun"
require "mocha/setup"
require_relative "../lib/mini_graphite"

class MiniGraphiteTest < MiniTest::Unit::TestCase

  def test_datapoint
    Dalia::MiniGraphite.config({ :graphite_host => "graphite.host.com", :graphite_port => 2003 })

    socket_mock = mock()
    TCPSocket.expects(:new).with("graphite.host.com", 2003).returns(socket_mock)
    socket_mock.expects(:print).with("test.age 31 1357117860\n")
    socket_mock.expects(:close)

    Dalia::MiniGraphite.datapoint("test.age", 31, Time.new(2013,1,2,10,11))
  end

  def test_counter
    Dalia::MiniGraphite.config({ :statsd_host => "statsd.host.com", :statsd_port => 8125 })

    socket_mock = mock()
    UDPSocket.expects(:new).returns(socket_mock)
    socket_mock.expects(:send).with("height:231|c", 0, "statsd.host.com", 8125 )
    socket_mock.expects(:close)

    Dalia::MiniGraphite.counter("height", 231)
  end

  def test_counter_when_nil_value
    Dalia::MiniGraphite.config({ :statsd_host => "statsd.host.com", :statsd_port => 8125 })

    socket_mock = mock()
    UDPSocket.expects(:new).returns(socket_mock)
    socket_mock.expects(:send).with("height:1|c", 0, "statsd.host.com", 8125 )
    socket_mock.expects(:close)

    Dalia::MiniGraphite.counter("height", nil)
  end

  def test_on_config_should_debug
    Dalia::MiniGraphite::Logger.any_instance.expects(:debug).at_least_once
    Dalia::MiniGraphite.config()
  end

  def test_on_counter_should_debug
    Dalia::MiniGraphite.expects(:send_udp)
    Dalia::MiniGraphite.config()

    Dalia::MiniGraphite::Logger.any_instance.expects(:debug).with("Sending counter: 'test.age:31|c'")
    Dalia::MiniGraphite.counter("test.age", 31)
  end

  def test_on_datapoint_should_debug
    Dalia::MiniGraphite.expects(:send_tcp)
    Dalia::MiniGraphite.config()

    Dalia::MiniGraphite::Logger.any_instance.expects(:debug).with("Sending datapoint: 'test.age 31 1357117860'")
    Dalia::MiniGraphite.datapoint("test.age", 31, Time.new(2013,1,2,10,11))
  end

  def test_on_datapoint_not_send_tcp_if_mock_mode
    Dalia::MiniGraphite.config(:mock_mode => true)
    TCPSocket.expects(:new).never
    Dalia::MiniGraphite.datapoint("test.age")
  end

  def test_on_counter_not_send_udp_if_mock_mode
    Dalia::MiniGraphite.config(:mock_mode => true)
    UDPSocket.expects(:new).never
    Dalia::MiniGraphite.counter("test.age")
  end

  def test_benchmark_wrapper
    Dalia::MiniGraphite.expects(:counter).with("key_prefix.ini")
    Dalia::MiniGraphite.expects(:counter).with("key_prefix.time", is_a(Float))
    Dalia::MiniGraphite.expects(:counter).with("key_prefix.result").never
    Dalia::MiniGraphite.expects(:counter).with("key_prefix.end")

    result =
      Dalia::MiniGraphite.benchmark_wrapper("key_prefix") do
        sleep(1)
        "RESULT"
      end

    assert_equal("RESULT", result)
  end

  def test_benchmark_wrapper_sending_result
    Dalia::MiniGraphite.expects(:counter).with("key_prefix.ini")
    Dalia::MiniGraphite.expects(:counter).with("key_prefix.time", is_a(Float))
    Dalia::MiniGraphite.expects(:counter).with("key_prefix.result", 6)
    Dalia::MiniGraphite.expects(:counter).with("key_prefix.end")

    result =
      Dalia::MiniGraphite.benchmark_wrapper("key_prefix", :length) do
        sleep(1)
        "RESULT"
      end

    assert_equal("RESULT", result)
  end

end
