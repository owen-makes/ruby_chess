require_relative 'piece'

class Queen < Piece
  attr_reader :color, :position, :icon

  MOVE_OFFSETS = [
    # ROOK
    [1, 0], [-1, 0], [0, 1], [0, -1], [2, 0], [-2, 0],
    [0, 2], [0, -2], [3, 0], [-3, 0], [0, 3], [0, -3],
    [4, 0], [-4, 0], [0, 4], [0, -4], [5, 0], [-5, 0],
    [0, 5], [0, -5], [6, 0], [-6, 0], [0, 6], [0, -6],
    [7, 0], [-7, 0], [0, 7], [0, -7],
    # BISHOP
    [1, 1], [-1, -1], [1, -1], [-1, 1], [2, 2],
    [-2, -2], [2, -2], [-2, 2], [3, 3], [-3, -3],
    [3, -3], [-3, 3], [4, 4], [-4, -4], [4, -4],
    [-4, 4], [5, 5], [-5, -5], [5, -5], [-5, 5],
    [6, 6], [-6, -6],  [6, -6], [-6, 6], [7, 7],
    [-7, -7], [7, -7], [-7, 7]
  ].freeze

  def initialize(position, color)
    super(color, position)
    @icon = @color.zero? ? '♕' : '♛' # 0 for white, 1 for black
    @notation = @icon + @notation
  end

  def move(x, y)
    return unless legal_move?(x, y)

    update_position(x, y)
  end

  def legal_move?(x, y)
    legal_moves(@position).include?([x, y])
  end

  def legal_moves(start = @position)
    MOVE_OFFSETS.map { |dx, dy| [start[0] + dx, start[1] + dy] }
                .select { |x, y| valid_position?(x, y) }
  end
end
