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
  end

  def move(x, y)
    return unless legal_move?(x, y)

    update_position(x, y)
  end

  def legal_move?(x, y)
    legal_moves(@position).include?([x, y])
  end

  private

  # Checks for valid & legal moves
  def legal_moves(coord)
    MOVE_OFFSETS.map { |dx, dy| [coord[0] + dx, coord[1] + dy] }
                .select { |x, y| valid_position?(x, y) }
  end
end
