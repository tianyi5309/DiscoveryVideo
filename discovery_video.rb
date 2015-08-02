class DiscoveryVideo
  def initialize (uri, file_name, init)
    if uri.nil?
      abort("uri required")
    end
    if init.nil?
      init = 0
    end
    if file_name.nil?
      file_name = "output"
    end
    
    @uri = uri
    @n_init = init.to_i
    @file_name = file_name + ".ts"
  end
  
  def mkdir
    dir_name = "DiscoveryVideo-" + Time.now.to_i.to_s
    Dir.mkdir(dir_name)
    Dir.chdir(dir_name)
  end
  
  def get_name (n)
    n.to_s.rjust(5, "0") + ".ts"
  end
  
  def get (name)
    cur_uri = @uri + name
    `curl -OsS #{cur_uri}`
  end
  
  def download (interval = 10)
    n = @n_init
    cont = true
    while cont
      print "\r#{n}"
      threads = []
      (0..interval-1).each do |i|
        threads << Thread.new do
          get(get_name(n+i))
        end
      end
      
      threads.each do |t|
        t.join
      end
      
      del = false
      (0..interval-1).each do |i|
        if cont && terminate(get_name(n+i)) # First instance of termination stops while loop and triggers deletion of further files
          puts "\nAll downloaded. Combining..."
          cont = false
          del = true
          @n_fin = n + i - 1
        end
        if del
          File.delete(get_name(n+i))
        end
      end
      
      n += interval
    end
  end
  
  def terminate (name)
    size = File.size(name)
    if size < 50000
      return true
    else
      return false
    end
  end
  
  def gen_input
    input = get_name(@n_init)
    (@n_init+1..@n_fin).each do |n|
      input << '|' << get_name(n)
    end
    input
  end
  
  def gen_vid
    `ffmpeg -loglevel 16 -i "concat:#{gen_input}" -c copy "#{@file_name}"`
  end
  
  def cleanup
    puts "Cleaning up..."
    (@n_init..@n_fin).each do |n|
      name = get_name(n)
      File.delete(name)
    end
  end
  
  def run
    start = Time.now
    mkdir
    puts "Downloading videos..."
    download
    gen_vid
    cleanup
    fin = Time.now
    puts "All done in #{fin-start}s, check output at #{@file_name}"
  end
end

c = DiscoveryVideo.new(ARGV[0], ARGV[1], ARGV[2])
c.run

## Code pre-refactoring
## Make directory for video
#dir_name = "DiscoveryVideo-" + Time.now.to_i.to_s
#Dir.mkdir(dir_name)
#Dir.chdir(dir_name)
#
#n_init = 50
#n = n_init # Video number
#input = ""  # Passed to ffmpeg
#puts "No.\tSize"
#
#while true
#  # Get video
#  file_name = n.to_s.rjust(5, "0") + ".ts"
#  cur_uri = uri + file_name
#  `curl -OsS #{cur_uri}`
#  
#  # Termination condition
#  size = File.size(file_name)
#  puts "#{n}\t#{size}"
#  if size < 50000
#    puts "All downloaded, combining..."
#    break
#  end
#  
#  # Generate name for ffmpeg
#  if n == n_init
#    input << file_name
#  else
#    input << "|" << file_name
#  end
#  
#  n += 1
#end
#
#`ffmpeg -i "concat:#{input}" -c copy output.ts`
#
## Cleanup
#puts "Cleaning up..."
#(n_init..n).each do |i|
#  file_name = i.to_s.rjust(5, "0") + ".ts"
#  File.delete(file_name)
#end
#
#puts "Check output at output.ts"
