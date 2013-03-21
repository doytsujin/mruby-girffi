# example_glib.rb
#
# ppibbur tulnor33@gmail.com
#
# Demonstrates using various parts of GLib
#
# LICENSE: likely that of mruby

GirBind.bind(:GObject)

cnt = 0
cnt1 = 0

loop = GLib::MainLoop.new nil

# Execute a command: 'uname -a'
bool,out,error,status = GLib.spawn_command_line_sync("uname -a")
puts out+"\n"

# Add an idle loop
# keep track of times invoked
GLib.idle_add 200 do
  cnt += 1
  GLib.printf("\rIdle    called %08s times.",cnt)
  true
end

GLib.timeout_add 200,330 do
  cnt1 += 1
  true
end

# Quit main loop after 1 second
GLib.timeout_add 200,1000 do
  puts()
  loop.quit
  false
end

loop.run

puts sprintf("Timeout called %08s times.",cnt1)

value=<<EOF
An example
of GLib.file_set_contents
foo
EOF

# Write contents to a file
unless GLib.file_set_contents(n="g_file_set_contents.txt",value,-1)
  raise "File write error"
end

# read contents from a file
bool,contents,len = GLib.file_get_contents(n)
unless bool
  raise "File read error"
end

puts "\nWrote length of #{value.length}"
puts "Read  length of #{len}"


bool = (len == value.length) & (contents.length == value.length)
unless bool
  raise "File contents length not proper"
end

puts "Read/Wrote lengths match."