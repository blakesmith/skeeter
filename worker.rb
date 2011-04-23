require 'rubygems'
require 'ffi-rzmq'
require 'open-uri'
require 'json'
require 'json_message'

context = ZMQ::Context.new(1)

receiver = context.socket(ZMQ::REP)
receiver.connect("ipc://dispatch-back.ipc")

def fetch_image(url, width)
  response = `jp2a --width=#{width} "#{url}"`
end

while true
  str = receiver.recv_string
  puts str

  message = JSON.parse(str)
  puts "Got message #{message.inspect}"

  # Do some work
  if message['message'] = "convert"
    width = message['width'] || 80
    image = fetch_image(message['url'], width)
    receiver.send_string(image)
  end
end

