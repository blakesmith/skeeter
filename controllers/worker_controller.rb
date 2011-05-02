#!/usr/bin/env ruby

require 'daemons'

worker = File.join(File.dirname(__FILE__), '..', 'bin', 'worker.rb')

Daemons.run(worker)
