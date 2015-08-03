require 'optparse'
require 'ostruct'

class DiscoveryVideo
  def initialize (options)
    @both = options.both
    if @both
      @av = options.av
    else
      @a = options.a
      @v = options.v
    end
    
    @n_init = options.init
    @file_name = options.file_name
  end
  
  def mkdir
    dir_name = "DiscoveryVideo-" + Time.now.to_i.to_s
    Dir.mkdir(dir_name)
    Dir.chdir(dir_name)
  end
  
  def get_name (n)
    n.to_s.rjust(5, "0") + ".ts"
  end
  
  def get (uri, n, prefix = "")
    name = get_name(n)
    `curl -sS #{uri + name} -o #{prefix + name}`
  end
  
  def download (uri, prefix = "", interval = 1)
    puts "Downloading from #{uri}..."
    n = @n_init
    cont = true
    while cont
      print "\r#{n}"
      threads = []
      (0..interval-1).each do |i|
        threads << Thread.new do
          get(uri, n+i, prefix)
        end
      end
      
      threads.each do |t|
        t.join
      end
      
      del = false
      (0..interval-1).each do |i|
        if cont && terminate(prefix + get_name(n+i)) # First instance of termination stops while loop and triggers deletion of further files
          cont = false
          del = true
          @n_fin = n + i - 1
        end
        if del
          File.delete(prefix + get_name(n+i))
        end
      end
      
      n += interval
    end
  end
  
  def terminate (name)
    size = File.size(name)
    if size < 50000
      return true
    end
    false
  end
  
  def gen_input
    input = ""
    (@n_init..@n_fin).each do |n|
      input << get_name(n) << " "
    end
    input
  end
  
  def gen_vid
    `cat #{gen_input} > #{@file_name}.ts`
  end
  
  def to_mp4
    `ffmpeg -loglevel 16 -i #{@file_name}.ts -vcodec copy -acodec copy -bsf:a aac_adtstoasc #{@file_name}.mp4`
    File.delete(@file_name + ".ts")
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
    download(@av)
    puts "\nAll downloaded. Combining..."
    gen_vid
    to_mp4
    cleanup
    fin = Time.now
    puts "All done in #{fin-start}s, check output at #{@file_name}.mp4"
  end
end

options = OpenStruct.new(both: true, file_name: "output", init: 0)
if ARGV[0] == "true"
  options.av = ARGV[1]
  if !ARGV[2].nil?
    options.file_name = ARGV[2]
  end
  if !ARGV[3].nil?
    options.init = ARGV[3].to_i
  end
else
  options.both = false
  options.a = ARGV[1]
  options.v = ARGV[2]
  if !ARGV[3].nil?
    options.file_name = ARGV[3]
  end
  if !ARGV[4].nil?
    options.init = ARGV[4].to_i
  end
end

puts options
c = DiscoveryVideo.new(options)
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
