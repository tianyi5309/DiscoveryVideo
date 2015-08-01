class DiscoveryVideo
  def initialize (uri, file_name, init)
    if uri.nil?
      abort("uri required")
    end
    if init.nil?
      init = 0
    end
    if file_name.nil?
      file_name = "output.ts"
    end
    
    @uri = uri
    @n_init = init.to_i
    @n = @n_init
    @file_name = file_name + ".ts"
    @input = ""
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
  
  def terminate (name)
    size = File.size(name)
    puts "#{@n}\t#{size}"
    if size < 50000
      puts "All downloaded, combining..."
      return true
    end
    false
  end
  
  def update_input
    name = get_name(@n)
    if @n == @n_init
      @input << name
    else
      @input << "|" << name
    end
  end
  
  def gen_vid
    `ffmpeg -i "concat:#{@input}" -c copy #{@file_name}`
  end
  
  def cleanup
    puts "Cleaning up..."
    (@n_init..@n).each do |n|
      name = get_name(n)
      File.delete(name)
    end
  end
  
  def run
    mkdir
    puts "Downloading videos..."
    puts "No.\tSize"
    
    while true
      name = get_name(@n)
      get(name)
      if terminate(name)
        puts "All downloaded, combining..."
        break
      else
        update_input
        @n += 1
      end
    end
    gen_vid
    cleanup
    puts "All done, check output at #{@file_name}"
  end
end

c = DiscoveryVideo.new(ARGV[0], ARGV[1], ARGV[2])
c.run

# Code pre-refactoring
## Make directory for video
#dir_name = "DiscoveryVideo-" + Time.now.to_i.to_s
#Dir.mkdir(dir_name)
#Dir.chdir(dir_name)
#
#uri = "http://ri.evvoclass.com/Panopto/Content/Sessions4/abddcf8a-c5ca-4483-b1f1-613c13b53580/25c05560-a8d0-4523-ad37-cc0590fd954e-f1132954-6a37-4c32-98e9-d3d3815baee7.hls/436279/"
#n_init = 350
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
