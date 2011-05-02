#!/usr/bin/env ruby

require 'daemons'

dispatcher = File.join(File.dirname(__FILE__), '..', 'bin', 'dispatcher.rb')

Daemons.run(dispatcher)
