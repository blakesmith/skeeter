require 'rubygems'
require 'ffi-rzmq'

context = ZMQ::Context.new

front_addr = "tcp://127.0.0.1:5555"
back_addr = "ipc://dispatch-back.ipc"

frontend = context.socket(ZMQ::XREP)
frontend.bind(front_addr)

backend = context.socket(ZMQ::XREQ)
backend.bind(back_addr)

queue = ZMQ::Device.new(ZMQ::QUEUE, frontend, backend)

frontend.close
backend.close
context.terminate
