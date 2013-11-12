require "rulers/version"
require "rulers/routing"
require "rulers/util"
require "rulers/dependencies"

module Rulers
  class Application
    def redirect_to(location, status = 302)
      [status, {"Location" => location}, []]
    end

    def call(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404,
                {'Content-Type' => 'text/html'}, []]
      end
      if env['PATH_INFO'] == '/'
        return [404, {'Content-Type' => 'text/plain'}, ["no home page yet"]]
      end
      klass, act = get_controller_and_action(env)
      controller = klass.new(env)
      begin
        text = controller.send(act)
      rescue Exception => e
        text = "<!doctype html><html><head></head><body>"
        text = "Oops! A #{e.class}:#{e.message} exception happened! <br>\n"
        text += "<ul>"
        e.backtrace.each do |line|
          text += "<li>#{line}</li>"
        end
        text += "</ul></body></html>"
      end
      [200, {'Content-Type' => 'text/html'},
        [text]]
    end
  end

  class Controller
    attr_reader :env

    def initialize(env)
      @env = env
    end

  end
end
