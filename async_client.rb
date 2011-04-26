require 'rubygems'
require 'em-zeromq'
require 'json'
require 'fiber'

class Handler
  attr_reader :received

  def on_readable(socket, messages)
    messages.each do |m|
      puts m.copy_out_string
    end
  end
end

images = [
  "http://localhost:4567/images/briones_yeah.jpg",
  "http://localhost:4567/images/InBed.jpg",
  "http://localhost:4567/images/programming-motherfuckers.jpg"
]

EM.run do
  context = EM::ZeroMQ::Context.new(1)
  req_socket = context.connect(ZMQ::REQ, "tcp://127.0.0.1:5555", Handler.new)


  EM::PeriodicTimer.new(3.3) do
    json = {:message => 'convert', :url => images[rand(images.size)], :width => 60}.to_json
    puts "Sending #{json}"

    req_socket.send_msg(json)
    req_socket.register_readable
  end
end

