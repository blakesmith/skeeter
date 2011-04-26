require 'em-zeromq'

context = EM::ZeroMQ::Context.new(1)
config['context'] = context
config['req_socket'] = context.connect(ZMQ::REQ, "tcp://127.0.0.1:5555")
