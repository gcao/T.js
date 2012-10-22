require 'rubygems'
require 'thin'
require 'rack'
require 'sinatra'
require "sinatra/reloader" if development?
require 'rack-livereload'
use Rack::LiveReload

class MyApp < Sinatra::Base
  get '/' do
    erb :index
  end

  get '/spec_runner.html' do
    erb :spec_runner
  end
end

run MyApp

