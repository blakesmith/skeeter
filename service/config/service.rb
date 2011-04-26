require 'em-zeromq'
require 'em-synchrony'

context = EM::ZeroMQ::Context.new(1)
config['context'] = context

config['connection_pool'] = EM::Synchrony::ConnectionPool.new(:size => 20) do
  context.connect(ZMQ::REQ, "tcp://127.0.0.1:5555")
end
