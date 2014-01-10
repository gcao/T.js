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

  get '/spec_runner' do
    erb :spec_runner
  end

  get '/svg' do
    erb :svg
  end

  get '/examples/editor' do
    erb :editor
  end
end

run MyApp

