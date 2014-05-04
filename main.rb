require "./EmotivSDK"
require "gosu"

class GameWindow < Gosu::Window
  
  def initialize
    super 640, 480, false
    self.caption = "Meditation Game"
    
    @background_image = Gosu::Image.new(self, "media/background.png", true)
    EmotivSDK::Engine.new() do |event|
      
    end
  end
  
  def update
    
  end
  
  def draw
    
  end
  
end

window = GameWindow.new
window.show