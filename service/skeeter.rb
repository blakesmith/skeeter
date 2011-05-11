require 'goliath'
require 'json'

class EM::Protocols::ZMQConnectionHandler
  attr_reader :received

  def initialize(connection)
    @connection = connection
    @client_fiber = Fiber.current
    @connection.setsockopt(ZMQ::IDENTITY, "req-#{@client_fiber.object_id}")
    @connection.handler = self
  end

  def send_msg(*parts)
    queued = @connection.send_msg(*parts)
    @connection.register_readable
    messages = Fiber.yield
    messages.map(&:copy_out_string)
  end

  def on_readable(socket, messages)
    @client_fiber.resume(messages)
  end
end

class Skeeter < Goliath::API
  use Goliath::Rack::Params
  use Goliath::Rack::ValidationError
  use Goliath::Rack::Validation::RequiredParam, {:key => 'image_url'}

  def response(env)
    json = {:message => 'convert', :width => params['width'], :url => params['image_url']}.to_json
    puts "Sending #{json}"

    connection_pool.execute(false) do |conn|
      handler = EM::Protocols::ZMQConnectionHandler.new(conn)
      resp = handler.send_msg(json).first
      [200, {}, resp]
    end
  end
end

