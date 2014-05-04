require "./EmotivSDK"
require "gosu"

class GameWindow < Gosu::Window
  
  def initialize
    super 640, 480, false
    self.caption = "Meditation Game"
    has_already_int = false
    Signal.trap("INT") do
      puts "Exiting..."
      @pids.each do |pid|
        p pid
        Process.kill('INT', pid)
      end
    end
    
    @total = 0
    @num = 1
    @background_image = Gosu::Image.new(self, 
      File.expand_path("Images/Calm/noaa_boats_calm_fish0581.jpg"), true)
    @pids = []
    game_proc = Proc.new do |event|
            @total += event.meditation_score
            @num += 1
            false
          end
    if ARGF.argv.length > 0
      ARGF.argv.each do |ipandport|
        ip, port = *(ipandport.split(":"))
        port = true if (port == "true" || port == "1726")
        port = false if (port == "false" || port == "3008" || port.nil?)
        @pids.push(fork do
          Signal.trap("INT"){exit}
          EmotivSDK::Engine.new(ip, port, &game_proc) 
        end)
      end
    else
      @pids.push(fork do
        Signal.trap("INT"){exit}  
        EmotivSDK::Engine.new("127.0.0.1", true, &game_proc)
      end)
    end
  end
  
  def update
    
  end
  
  def draw
    @background_image.draw(0,0,0)
  end
  
end

window = GameWindow.new
window.show