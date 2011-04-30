def start
  puts "Starting Skeeter..."
  `ruby service/skeeter.rb -d -e prod -v -p tmp/pids/skeeter.pid`
end

def stop
  puts "Killing Skeeter..."
  pid_path = File.join(File.dirname(__FILE__), 'tmp', 'pids', 'skeeter.pid')
  pid = File.read(pid_path).to_i
  status = Process.kill("TERM", pid)
  puts "Killed pid #{pid}" if status == 1
end

if ARGV[0] == "start"
  start
elsif ARGV[0] == "stop"
  stop
elsif ARGV[0] == "restart"
  stop
  start
else
  puts "Unknown command"
end
