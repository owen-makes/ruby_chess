require_relative 'piece'

class Knight < Piece
  attr_reader :color, :position, :icon

  MOVE_OFFSETS = [
    [-2, -1], [-2, 1], [2, -1], [2, 1],
    [-1, -2], [1, -2], [-1, 2], [1, 2]
  ].freeze

  def initialize(position, color)
    super(color, position)
    @icon = @color.zero? ? '♘' : '♞' # 0 for white, 1 for black
    @notation = @icon + @notation
  end

  def move(x, y)
    return unless legal_move?(x, y)

    update_position(x, y)
  end

  def legal_move?(x, y)
    legal_moves(@position).include?([x, y])
  end

  # Checks for valid & legal moves
  def legal_moves(start = @position)
    MOVE_OFFSETS.map { |dx, dy| [start[0] + dx, start[1] + dy] }
                .select { |x, y| valid_position?(x, y) }
  end
end
