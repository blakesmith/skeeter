require 'goliath'
require 'json'

class Handler
  attr_reader :received

  def initialize
    @f = Fiber.current
  end

  def on_readable(socket, messages)
    @f.resume(socket, messages)
  end
end

class Service < Goliath::API
  use Goliath::Rack::Params
  use Goliath::Rack::Validation::RequiredParam, {:key => 'image_url'}

  def response(env)
    req_socket.handler = Handler.new

    json = {:message => 'convert', :url => params['image_url']}.to_json
    queued = req_socket.send_msg(json)
    puts "Sending #{json}" if queued
    req_socket.register_readable
    socket, messages = Fiber.yield
    resp = messages.first.copy_out_string

    [200, {}, resp]
  end
end

