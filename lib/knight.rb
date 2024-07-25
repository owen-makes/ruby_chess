class Knight
  MOVE_OFFSETS = [
    [-2, -1], [-2, 1], [2, -1], [2, 1],
    [-1, -2], [1, -2], [-1, 2], [1, 2]
  ]

  def initialize(color)
    @color = color
    @color == 'w' ? @icon = ♘ : @icon = ♞
  end
  
  private

  def possible_moves(coord)
    MOVE_OFFSETS.map { |dx, dy| [coord[0] + dx, coord[1] + dy] }
                .select { |x, y| valid_position?(x, y) }
  end

  def valid_position?(x, y)
    x.between?(0, @board_size - 1) && y.between?(0, @board_size - 1)
  end
end
