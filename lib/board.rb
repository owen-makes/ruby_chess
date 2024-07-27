Dir[File.join(__dir__, 'pieces', '*.rb')].sort.each { |file| require_relative file }

class Board
  attr_reader :board

  def initialize(board_size = 8)
    @board = Array.new(board_size) { Array.new(board_size) }
    @size = board_size
    @board_ui = 'to be created'
  end

  def populate
    pop_white
    pop_black
  end

  def pop_white
    @board[4][7] = King.new([4, 7], 0)
    @board[3][7] = Queen.new([3, 7], 0)
    @board[2][7], @board[5][7] = Bishop.new([2, 7], 0)
    @board[1][7], @board[6][7] = Knight.new([1, 7], 0), Knight.new([6, 7], 0)
    @board[0][7], @board[7][7] = Rook.new([0, 7], 0), Rook.new([7, 7], 0)
    @board.each_with_index { |column, idx| column[6] = Pawn.new([idx, 6], 0) }
  end

  def pop_black
    @board[4][0] = King.new([4, 0], 1)
    @board[3][0] = Queen.new([3, 0], 1)
    @board[2][0], @board[5][0] = Bishop.new([2, 0], 1)
    @board[1][0], @board[6][0] = Knight.new([1, 0], 1), Knight.new([6, 0], 1)
    @board[0][0], @board[7][0] = Rook.new([0, 0], 1), Rook.new([7, 0], 1)
    @board.each_with_index { |column, idx| column[1] = Pawn.new([idx, 1], 1) }
  end
end
