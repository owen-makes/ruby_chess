Dir[File.join(__dir__, 'pieces', '*.rb')].sort.each { |file| require_relative file }

class Board
  attr_reader :board

  def initialize(board_size = 8)
    @board = Array.new(board_size) { Array.new(board_size) }
    @size = board_size
    @board_ui = nil
  end

  def populate
    pop_white
    pop_black
  end

  def pop_white
    @board[4][7] = King.new([4, 7], 0)
    @board[3][7] = Queen.new([3, 7], 0)
    @board[2][7], @board[5][7] = Bishop.new([2, 7], 0), Bishop.new([5, 7], 0)
    @board[1][7], @board[6][7] = Knight.new([1, 7], 0), Knight.new([6, 7], 0)
    @board[0][7], @board[7][7] = Rook.new([0, 7], 0), Rook.new([7, 7], 0)
    @board.each_with_index { |column, idx| column[6] = Pawn.new([idx, 6], 0) }
  end

  def pop_black
    @board[4][0] = King.new([4, 0], 1)
    @board[3][0] = Queen.new([3, 0], 1)
    @board[2][0], @board[5][0] = Bishop.new([2, 0], 1), Bishop.new([5, 0], 1)
    @board[1][0], @board[6][0] = Knight.new([1, 0], 1), Knight.new([6, 0], 1)
    @board[0][0], @board[7][0] = Rook.new([0, 0], 1), Rook.new([7, 0], 1)
    @board.each_with_index { |column, idx| column[1] = Pawn.new([idx, 1], 1) }
  end

  def update_board_ui
    @board_ui = generate_board
  end

  def generate_board
    # Create the column labels
    board_string = "  a b c d e f g h\n"

    8.downto(1) do |row|
      board_string += "#{row} " # Add row index on left side

      8.times do |col|
        piece = @board[col][row - 1] # Adjust for 0-based index
        icon = piece ? piece.icon : '·' # If piece exists, assign icon, if not middle dot
        board_string += "#{icon} "
      end

      board_string += "#{row}\n"
    end

    # Add the bottom column labels
    board_string += '  a b c d e f g h'

    board_string
  end

  def display_board
    # If @board_ui hasn't been generated yet, generate it
    update_board_ui if @board_ui.nil?
    puts @board_ui
  end

  def move_piece(start, target)
    piece = @board[start[0]][start[1]]
    destination = @board[target[0]][target[1]]
    nil unless piece.legal_move?(target[0], target[1])
    # if piece.is_a(Knight)
    #   destination.nil? ? piece.move(target[0], target[1])
    # end
  end

  def path_clear?(pos_start, pos_end)
    # Check if path is clear to move (King, Queen, Bish, Rook, Pawn)
  end

  def take_piece
    # How?
  end

  def castle
    # Handle Castling
    # castle_king_side 0-0
    # castle_queen_side 0-0-0
    # Should check King.previous_moves and Rook.previous_moves
  end

  def promote_pawn_to(piece)
    # Handle pawn promotion
  end
end
