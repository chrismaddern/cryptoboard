require 'json'
require 'bundler'
require 'sinatra'
require 'net/http'

require_relative "app/exchange/bittrex"
require_relative "app/profile/profile"
set :show_exceptions, false

Bundler.require(:default)

get "/" do
  # Make sure that @chrismaddern's profile page
  # doesn't steal mycrypto.fun for future use!
  if request.host.sub("www.","") === "mycrypto.fun"
    redirect "/chris", 303
  else
    render_portfolio
  end
end

# Temporary endpoint until we handle multi-tenancy
get "/chris" do
  render_portfolio
end

def render_portfolio
  exchange = MyCrypto::Exchange::Bittrex.exchange

  # This call may take a while...
  # Lots we can do to improve this
  @portfolio = exchange.portfolio
  erb :portfolio
end
