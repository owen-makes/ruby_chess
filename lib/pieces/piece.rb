class Piece
  attr_reader :color

  def initialize(color, position)
    @color = color
    @position = position
  end

  def valid_position?(x, y)
    x.between?(0, 7) && y.between?(0, 7)
  end

  def update_position(x, y)
    @position = [x, y]
  end
end
