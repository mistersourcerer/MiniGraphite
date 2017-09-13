require "minitest/autorun"
require "mocha/setup"
require "rack"

require_relative "../lib/mini_graphite"

class RoutesReporter < Minitest::Test
  def setup
    @app = Proc.new do |env|
      ['200', {'Content-Type' => 'text/html'}, ['Test App']]
    end

    routes_block = Proc.new do
      set_graphite_key "app.test_app.test.routes.active_surveys", /active_surveys\/this_should_be_a_password/
      set_graphite_key "app.test_app.test.routes.get_surveys", /\:offer_click_id\/\:panel_user_id\/\:panel_user_id_kind/
      set_graphite_key "app.test_app.test.routes.error", /error/
      set_graphite_key "app.test_app.test.routes.homepage", /\/$/
    end

    @graphite_routes_reporter = Dalia::MiniGraphite::RoutesReporter.new(@app, &routes_block)
    @request = Rack::MockRequest.new(@graphite_routes_reporter)
  end

  def test_send_routes_metrics_to_graphite
    Dalia::MiniGraphite.expects(:counter).with("app.test_app.test.routes.homepage.duration", instance_of(Float))
    Dalia::MiniGraphite.expects(:counter).with("app.test_app.test.routes.homepage.count")
    Dalia::MiniGraphite.expects(:time).with("app.test_app.test.routes.homepage.duration_stats", instance_of(Float))
    @request.get("/", {"sinatra.route" => "/"})

    Dalia::MiniGraphite.expects(:counter).with("app.test_app.test.routes.get_surveys.duration", instance_of(Float))
    Dalia::MiniGraphite.expects(:counter).with("app.test_app.test.routes.get_surveys.count")
Dalia::MiniGraphite.expects(:time).with("app.test_app.test.routes.get_surveys.duration_stats", instance_of(Float))
    @request.get("/OFFER_CLICK_ID/PANEL_USER_ID/PANEL_USER_ID_KIND", {"sinatra.route" => "/:offer_click_id/:panel_user_id/:panel_user_id_kind/"})

    Dalia::MiniGraphite.expects(:counter).with("app.test_app.test.routes.error.duration", instance_of(Float))
    Dalia::MiniGraphite.expects(:counter).with("app.test_app.test.routes.error.count")
    Dalia::MiniGraphite.expects(:time).with("app.test_app.test.routes.error.duration_stats", instance_of(Float))
    @request.get("/error", {"sinatra.route" => "/error"})

    Dalia::MiniGraphite.expects(:counter).with("app.test_app.test.routes.active_surveys.duration", instance_of(Float))
    Dalia::MiniGraphite.expects(:counter).with("app.test_app.test.routes.active_surveys.count")
    Dalia::MiniGraphite.expects(:time).with("app.test_app.test.routes.active_surveys.duration_stats", instance_of(Float))
    @request.get("/active_surveys/this_should_be_a_password", {"sinatra.route" => "/active_surveys/this_should_be_a_password" })

    Dalia::MiniGraphite.expects(:counter).never
    @request.get("/ANOTHER_URL")
  end
end
