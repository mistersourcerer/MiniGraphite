module Dalia

	module MiniGraphite

		class Logger
			attr_reader :debug_mode

		  def initialize(debug_mode = true)
		    @debug_mode = debug_mode
		  end

		  def debug(message)
		    return unless debug_mode

		    result = "Dalia::MiniGraphite [#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}]: #{message}"

		    if defined? ::Rails
		      ::Rails.logger.info result
		    else
		      Kernel.puts result
		    end
		  end

		end

	end

end
