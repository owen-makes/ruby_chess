class Board
  def initialize(board_size = 8)
    @board = Array.new(board_size) { Array.new(board_size) }
    @size = board_size
    @board_ui = 'to be created'
  end
end