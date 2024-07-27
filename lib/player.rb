class Player
  attr_accesor :pieces, :color, :name
  
  def initialize(color)
    @color = color #0 for white, 1 for black
    @name = name
    @pieces = []
  end
end