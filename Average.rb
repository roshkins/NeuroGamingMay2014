require 'gosu'

module Draw

def update(meditation,focus_array)
   #level: low, med, hi
   #symbol: med avg- calm, lo, med, hi
   # display background based on symbol
   case meditation
   when :Calm
      #load image from Calm file
   when :Mild
      #load image from Mild file
   when :Moderate
      #load image from Moderate file
   when :Rocky
      #load image from Rocky file
   end
end

end