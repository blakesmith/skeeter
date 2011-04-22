require 'rubygems'
require 'ffi-rzmq'
require 'json'

context = ZMQ::Context.new

dispatcher = ZMQ::Socket.new context.pointer, ZMQ::PUSH
dispatcher.bind("ipc://ascii-dispatcher")

puts "Press enter when the workers are ready..."
gets

while true
  json = {:message => 'convert', :url => "http://www.images.com/image#{rand(100000)}.jpg"}.to_json
  puts "Sending #{json}"

  dispatcher.send_string(json)
  sleep(rand(0.7))
end

dispatcher.close
