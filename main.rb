require "./EmotivSDK"
require "gosu"

class GameWindow < Gosu::Window
  
  def initialize
    super 640, 480, false
    self.caption = "Meditation Game"
  end
  
  def update
    
  end
  
  def draw
    
  end
  
end

window = GameWindow.new
window.show