require "./EmotivSDK"
require "gosu"
require 'socket'

class GameWindow < Gosu::Window
  
  def initialize
    super 640, 480, false
    self.caption = "Meditation Game"
    Signal.trap("INT") do
      puts "Exiting..."
      @pids.each do |pid|
        Process.kill('INT', pid)
      end
      exit
    end

    @read_sockets = []
    @background_image = Gosu::Image.new(self, 
      File.expand_path("Images/Calm/noaa_boats_calm_fish0581.jpg"), true)
    @pids = []
    if ARGF.argv.length > 0
      ARGF.argv.each do |ipandport|
        ip, port = *(ipandport.split(":"))
        port = true if (port == "true" || port == "1726")
        port = false if (port == "false" || port == "3008" || port.nil?)
        write, read = Socket.pair(:UNIX, :DGRAM, 0)
        @read_sockets << read
        @pids.push(fork do
          Signal.trap("INT"){exit}
          EmotivSDK::Engine.new(ip, port) do |event|
            write.puts "meditation:(#{event.meditation_score},1)"
            false
          end
          ""
        end)
      end
    else
      write, read = Socket.pair(:UNIX, :DGRAM, 0)
      @read_sockets << read
      @pids.push(fork do
        Signal.trap("INT"){exit}
        EmotivSDK::Engine.new("127.0.0.1", true) do |event|
            write.puts "meditation:(#{event.meditation_score},1)"
            false
          end
        ""
      end)
    end
  end
  
  def update
    total = 0
    count = 0
    @read_sockets.each do |socket|
    response = socket.gets
      if /meditation:\(([0-9.]+),(\d+)\)/ =~ response
        my_match = response.match(/meditation:\(([0-9.]+),(\d+)\)/)
        total += my_match[1].to_f
        count += my_match[2].to_i
      end
    end
    puts "Avg: #{total/count}" 
    true
  end
  
  def draw
    @background_image.draw(0,0,0)
  end
  
end

window = GameWindow.new
window.show