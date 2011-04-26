require 'goliath'
require 'json'

class EM::Protocols::ZMQHandler
  attr_reader :received

  def initialize(connection)
    @connection = connection
    @client_fiber = Fiber.current
    @connection.setsockopt(ZMQ::IDENTITY, "web-req#{@client_fiber.object_id}")
    @connection.handler = self
  end

  def send_msg(msg)
    queued = @connection.send_msg(msg)
    @connection.register_readable
    puts "Sending #{msg}" if queued
    messages = Fiber.yield
    messages.map(&:copy_out_string)
  end

  def on_readable(socket, messages)
    @client_fiber.resume(messages)
  end
end

class Service < Goliath::API
  use Goliath::Rack::Params
  use Goliath::Rack::Validation::RequiredParam, {:key => 'image_url'}

  def response(env)
    json = {:message => 'convert', :width => params['width'], :url => params['image_url']}.to_json
    connection_pool.execute(false) do |conn|
      handler = EM::Protocols::ZMQHandler.new(conn)
      resp = handler.send_msg(json).first
      [200, {}, resp]
    end
  end
end

