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
  def response(env)
    context = EM::ZeroMQ::Context.new(1)
    req_socket = context.connect(ZMQ::REQ, "tcp://127.0.0.1:5555")
    req_socket.handler = Handler.new

    json = {:message => 'convert', :url => "http://localhost:4567/images/briones_yeah.jpg", :width => 60}.to_json
    queued = req_socket.send_msg(json)
    puts "Sending #{json}" if queued
    req_socket.register_readable
    socket, messages = Fiber.yield
    resp = messages.first.copy_out_string

    [200, {}, resp]
  end
end

