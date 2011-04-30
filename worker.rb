require 'rubygems'
require 'ffi-rzmq'
require 'open-uri'
require 'json'

WORKER_COUNT = ARGV.size > 0 ? ARGV[0].to_i : 2

pids = []

def fetch_image(url, width)
  response = `jp2a --width=#{width} "#{url}"`
end

def die(pids)
  puts "Killing all workers..."
  pids.map {|p| Process.kill("INT", p) }
end

WORKER_COUNT.times do |i|
  pids << fork do
    trap("INT") { exit }
    puts "Starting worker #{i}..."
    context = ZMQ::Context.new(1)

    receiver = context.socket(ZMQ::REP)
    receiver.connect("ipc://dispatch-back.ipc")

    loop do
      str = receiver.recv_string

      message = JSON.parse(str)
      puts "Worker #{i}: Got message #{message.inspect}"

      # Do some work
      if message['message'] = "convert"
        width = message['width'] || 80
        image = fetch_image(message['url'], width)
        receiver.send_string(image)
      end
    end
  end
end

trap("INT") { die(pids) }
trap("TERM") { die(pids) }

Process.wait
