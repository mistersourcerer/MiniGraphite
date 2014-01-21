require "minitest/autorun"
require "mocha/setup"
require_relative "../lib/mini_graphite"

class MiniGraphiteTest < MiniTest::Unit::TestCase

	def test_debug
		Kernel.expects(:puts).with(regexp_matches(/MESSAGE/))
		logger = Dalia::MiniGraphite::Logger.new
		logger.debug("MESSAGE")
	end

	def test_debug_when_not_debug_mode
		Kernel.expects(:puts).never
		logger = Dalia::MiniGraphite::Logger.new(false)
		logger.debug("MESSAGE")
	end

	def test_debug_when_rails_actived
		Kernel.const_set("Rails", mock(:logger => mock(:info)))
		logger = Dalia::MiniGraphite::Logger.new
		logger.debug("MESSAGE")
		Kernel.send(:remove_const, :Rails)
	end

end
