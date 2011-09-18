require 'rubygems'
require 'ffi-rzmq'
require 'json'

context = ZMQ::Context.new

client = context.socket(ZMQ::REQ)
client.connect("ipc:///tmp/dispatch-front.ipc")

images = [
  "http://localhost:4567/images/InBed.jpg",
  "http://localhost:4567/images/programming-motherfuckers.jpg"
]

puts "Press enter when the workers are ready..."
gets

while true
  json = {:message => 'convert', :url => images[rand(images.size)], :width => 60}.to_json
  puts "Sending #{json}"

  client.send_string(json)
  response = client.recv_string
  puts response
  sleep(rand(0.7))
end

client.close
context.terminate
