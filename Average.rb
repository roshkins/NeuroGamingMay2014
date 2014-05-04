require 'gosu'

module Draw

def draw_it(ms_percent)
  #level: low, med, hi
  #symbol: med avg- calm, lo, med, hi
  # display background based on symbol
  
  @imgs[0].draw(0, ms_percent* self.height, 0 )
  @imgs[1].draw(0, (ms_percent) * self.height - @imgs[1].height, 0 )

  @boats_hash.each do |boat|
    p "x:#{boat[:x]}"
    p "y:#{self.height / 2 - boat[:img].height / 2}"
    boat[:img].draw(boat[:x], self.height / 2 - boat[:img].height / 2, 1)
  end
end

def load_image(folder)
   #random generate number to pick random image
   filepath = "Images/#{folder}/*.*";
   Gosu::Image.new(self,
      File.expand_path(Dir.glob(filepath).sample), true)
end

def load_boat(folder)
  filepath = "Images/#{folder}/*.*";
   Gosu::Image.new(self,
      File.expand_path(Dir.glob(filepath).sample), true)
end

end