require "./app.rb"
use Rack::Session::Cookie

run Sinatra::Application
