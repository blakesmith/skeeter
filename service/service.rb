require 'goliath'
require 'json'

class Handler
  attr_reader :received

  def initialize
    @f = Fiber.current
  end

  def on_readable(socket, messages)
    @f.resume(messages)
  end
end

class Service < Goliath::API
  use Goliath::Rack::Params
  use Goliath::Rack::Validation::RequiredParam, {:key => 'image_url'}

  def response(env)
    json = {:message => 'convert', :width => params['width'], :url => params['image_url']}.to_json
    connection_pool.execute(false) do |socket|
      socket.setsockopt(ZMQ::IDENTITY, "web-req#{Fiber.current.object_id}")
      socket.handler = Handler.new
      queued = socket.send_msg(json)
      puts "Sending #{json}" if queued
      socket.register_readable
      messages = Fiber.yield
      resp = messages.first.copy_out_string
      [200, {}, resp]
    end
  end
end

