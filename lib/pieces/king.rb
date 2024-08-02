require_relative 'piece'

class King < Piece
  attr_reader :color, :position, :icon, :previous_moves

  MOVE_OFFSETS = [
    [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]
  ].freeze

  def initialize(position, color)
    super(color, position)
    @icon = @color.zero? ? '♔' : '♚' # 0 for white, 1 for black
    @previous_moves = 0 # To check if castling available
  end

  def move(x, y)
    return unless legal_move?(x, y)

    @previous_moves += 1

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
