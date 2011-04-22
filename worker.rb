require 'rubygems'
require 'ffi-rzmq'
require 'open-uri'
require 'json'

context = ZMQ::Context.new

receiver = ZMQ::Socket.new context.pointer, ZMQ::PULL
receiver.connect("ipc://ascii-dispatcher")

def fetch_image(url, width)
  response = `jp2a --width=80 "#{url}"`
end

while true
  str = receiver.recv_string
  message = JSON.parse(str)
  puts "Got message #{message.inspect}"

  # Do some work
  if message['message'] = "convert"
    width = message['width'] || 80
    puts fetch_image(message['url'], width)
  end
end

