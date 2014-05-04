require 'gosu'

module Draw

def draw(window,meditation,focus_array)
   #level: low, med, hi
   #symbol: med avg- calm, lo, med, hi
   # display background based on symbol
   load_image(meditation.to_s)
   
end

def load_image(folder)
   #random generate number to pick random image
   filepath = "Images/#{folder}/*.*";
   @background_image = Gosu::Image.new(self,
      File.expand_path(Dir.glob(filepath).sample), true)
end

end