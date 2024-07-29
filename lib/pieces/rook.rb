require_relative 'piece'

class Rook < Piece
  attr_reader :color, :position, :icon, :previous_moves

  MOVE_OFFSETS = [
    [1, 0], [-1, 0], [0, 1], [0, -1], [2, 0], [-2, 0],
    [0, 2], [0, -2], [3, 0], [-3, 0], [0, 3], [0, -3],
    [4, 0], [-4, 0], [0, 4], [0, -4], [5, 0], [-5, 0],
    [0, 5], [0, -5], [6, 0], [-6, 0], [0, 6], [0, -6],
    [7, 0], [-7, 0], [0, 7], [0, -7]
  ].freeze

  def initialize(position, color)
    super(color, position)
    @icon = @color.zero? ? '♖' : '♜' # 0 for white, 1 for black
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

  private

  def legal_moves(start)
    MOVE_OFFSETS.map { |dx, dy| [start[0] + dx, start[1] + dy] }
                .select { |x, y| valid_position?(x, y) }
  end
end
