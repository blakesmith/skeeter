require 'rubygems'
require 'ffi-rzmq'
require 'open-uri'
require 'json'

context = ZMQ::Context.new

receiver = ZMQ::Socket.new context.pointer, ZMQ::PULL
receiver.connect("ipc://ascii-dispatcher")

while true
  str = receiver.recv_string
  message = JSON.parse(str)
  puts "Got message #{message.inspect}"

  # Do some work
  sleep 1
end

def fetch_image(url)
  image = open_uri(url)
end
