require_relative 'piece'

class Pawn < Piece
  attr_reader :color, :position, :icon, :previous_moves

  def initialize(position, color)
    super(color, position)
    @icon = @color.zero? ? '♙' : '♟' # 0 for white, 1 for black
    @move_offsets = @color.zero? ? [[0, -1], [-1, -1], [0, -2], [1, -1]] : [[0, 1], [0, 2], [1, 1], [-1, 1]]
    @previous_moves = 0
  end

  def move(x, y)
    return unless legal_move?(x, y)

    @previous_moves += 1
    previous_moves == 1 ? update_moves : nil # Remove two square initial move from possible moves
    update_position(x, y)
  end

  def update_moves
    if @move_offsets.include?([0, 2])
      @move_offsets.delete([0, 2])
    else
      @move_offsets.delete([0, -2])
    end
  end

  def legal_move?(x, y)
    legal_moves(@position).include?([x, y])
  end

  private

  def legal_moves(start)
    @move_offsets.map { |dx, dy| [start[0] + dx, start[1] + dy] }
                 .select { |x, y| valid_position?(x, y) }
  end
end
