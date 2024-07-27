require_relative 'piece'

class Queen < Piece
  attr_reader :color, :position

  def initialize(position, color)
    super(color, position)
    @icon = @color.zero? ? '♕' : '♛' # 0 for white, 1 for black
  end
end
