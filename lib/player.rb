class Player
  attr_accessor :pieces, :color, :name, :score

  def initialize(color)
    @color = color # 0 for white, 1 for black
    @name = name
    @pieces = []
    @score = 0
  end
end
