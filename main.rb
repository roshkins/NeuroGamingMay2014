require "./EmotivSDK"
require "gosu"
require 'socket'
require "./Average"

class GameWindow < Gosu::Window
  include Draw
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

    @read_sockets_med = []
    @read_sockets_focus = []
    
    @pids = []
    if ARGF.argv.length > 0
      ARGF.argv.each do |ipandport|
        ip, port = *(ipandport.split(":"))
        port = true if (port == "true" || port == "1726")
        port = false if (port == "false" || port == "3008" || port.nil?)
            writer, reader = Socket.pair(:UNIX, :DGRAM, 0)
            writer2,  reader2 = Socket.pair(:UNIX, :DGRAM, 0)
            @read_sockets_med << reader
            @read_sockets_focus << reader2
        @pids.push(fork do
            reader.close
            reader2.close
          Signal.trap("INT"){exit}
          EmotivSDK::Engine.new(ip, port) do |event|
            writer.puts "meditation:(#{event.meditation_score},1)"
            writer2.puts "focus:(#{event.cognitiv_action == :COG_LIFT ? event.cognitiv_action_power : 0 },1)"
              false
          end
          ""
        end)
      end
    else
      #write, read = Socket.pair(:UNIX, :DGRAM, 0)
      #@read_sockets << read
      @pids.push(fork do
        Signal.trap("INT"){exit}
        EmotivSDK::Engine.new("127.0.0.1", true) do |event|
          reader, writer = IO.pipe
            @read_sockets << reader
            writer.puts "meditation:(#{event.meditation_score},1)"
            writer.puts "focus:(#{event.cognitiv_action == :COG_LIFT ? event.cognitiv_action_power : 0 },1)"
            writer.close
            false
          end
        ""
      end)
    end
  end
  
  def update
    med_total = 0
    med_count = 0
    @read_sockets_med.each do |socket|
      response = socket.gets
      if /meditation:\(([0-9.]+),(\d+)\)/ =~ response
        my_match = response.match(/meditation:\(([0-9.]+),(\d+)\)/)
        med_total += my_match[1].to_f
        med_count += my_match[2].to_i
      end
    end
    med_avg = med_total/med_count 
    
    @med_symb = if med_avg < 0.25
      :Rocky
    elsif med_avg < 0.5
       :Moderate
    elsif med_avg < 0.75
      :Mild
    else
      :Calm
    end
    #puts "Meditation Avg: #{med_total/med_count}" 
    
    @focus_array = []
    @read_sockets_focus.each do |socket|
      
    begin
      response = socket.gets
    rescue
      response = "focus:(0.0,1)"
    end
    
      if /focus:\(([0-9.]+),(\d+)\)/ =~ response
        my_match = response.match(/focus:\(([0-9.]+),(\d+)\)/)
        @focus_array << my_match[1].to_f
      end
    end
    puts "Focus: #{@focus_array}" 
    @last ||= 0
    @ms_percent = (Gosu::milliseconds - @last) / 4000.0
    p (Gosu::milliseconds - @last) 
    @imgs ||= [load_image(@med_symb.to_s)] * 2
    if (((@ms_percent) * self.height  - @imgs[1].height) > self.height) 
      img = load_image(@med_symb.to_s)
      @imgs.pop
      @imgs .unshift img
      @last = Gosu::milliseconds
    end
    
    
    
    #boats
    
    @boats ||= [load_boat("boats")] * @focus_array.length
    @boats_hash = @boats.map.with_index do |img, i|
      descrete_part = (self.width/@focus_array.length)
      
      p amplitude = (descrete_part/2.0) * (1.0-@focus_array[i])
      p my_sin = Math.sin((Gosu::milliseconds/1000.0) * 2.0 * Math::PI)
      {img: img, x: (( amplitude * my_sin + descrete_part * 1.5 + (i-1) * descrete_part))}
 
    end
    true
  end
  
  def draw
    draw_it @ms_percent
  end
  

end

window = GameWindow.new
window.show