require 'rubygems'
require 'ffi-rzmq'
require 'json'

context = ZMQ::Context.new

dispatcher = ZMQ::Socket.new context.pointer, ZMQ::PUSH
dispatcher.bind("ipc://ascii-dispatcher")

images = [
  "http://localhost:4567/images/briones_yeah.jpg",
  "http://localhost:4567/images/programming-motherfuckers.jpg",
  "http://localhost:4567/images/InBed.jpg"
]

puts "Press enter when the workers are ready..."
gets

while true
  json = {:message => 'convert', :url => images[rand(images.size)], :width => 70}.to_json
  puts "Sending #{json}"

  dispatcher.send_string(json)
  sleep(rand(0.7))
end

dispatcher.close
