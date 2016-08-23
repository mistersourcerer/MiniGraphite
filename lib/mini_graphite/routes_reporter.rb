module Dalia
  module MiniGraphite
    class RoutesReporter
      def initialize(app, &routes_block)
        @app = app
        @routes = {}
        instance_eval(&routes_block) if block_given?
      end

      def call(env)
        start_time = Time.now
        status, headers, body  = @app.call(env)
        time_taken = (1000 * (Time.now - start_time))

        current_route = env["sinatra.route"]
        route = @routes.select { |graphite_key, route_regexp| current_route =~ route_regexp}

        if route
          graphite_key = route.keys.first

          Dalia::MiniGraphite.counter("#{graphite_key}.count") if graphite_key
          Dalia::MiniGraphite.counter("#{graphite_key}.duration", time_taken) if graphite_key
        end

        [status, headers, body]
      end

      private
        def set_graphite_key(graphite_key, route_regexp)
          @routes[graphite_key] = route_regexp
        end
    end
  end
end