Dir[File.join(__dir__, 'pieces', '*.rb')].sort.each { |file| require_relative file }

class Board
  attr_reader :board, :captured, :board_ui

  def initialize(board_size = 8)
    @board = Array.new(board_size) { Array.new(board_size) }
    @size = board_size
    @board_ui = nil
    @captured = { whites: [], blacks: [] }
  end

  def populate
    pop_white
    pop_black
    update_board_ui
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
    board_string = "  a b c d e f g h\n"

    8.downto(1) do |row|
      board_string += "#{row} " # Add row index on left side

      8.times do |col|
        piece = @board[col][8 - row] # Adjust for 0-based index
        icon = piece ? piece.icon : '·' # If piece exists, assign icon, if not middle dot
        board_string += "#{icon} "
      end

      board_string += "#{row}\n"
    end

    board_string += '  a b c d e f g h'
    board_string
  end

  def display_board
    update_board_ui
    puts @board_ui
  end

  def move_piece(start, target)
    piece = @board[start[0]][start[1]]
    destination = @board[target[0]][target[1]]
    return nil unless piece.legal_move?(target[0], target[1])
    return nil unless path_clear?(start, target)

    if destination.nil?
      if piece.is_a?(Pawn) && en_passant?(start, target)
        capture_en_passant(start, target)
      else
        @board[target[0]][target[1]] = @board[start[0]][start[1]]
        @board[target[0]][target[1]].move(target[0], target[1])
        @board[start[0]][start[1]] = nil
      end
    else
      capture_piece(start, target)
    end
    promote_pawn?(target)
    @last_move = [piece, target]
  end

  def path_clear?(pos_start, pos_end)
    # Check if path is clear to move
    piece = @board[pos_start[0]][pos_start[1]]
    case piece
    in Pawn
      check_pawn_path(pos_start, pos_end)
    in Rook
      check_hv_path(pos_start, pos_end)
    in Bishop
      check_diag_path(pos_start, pos_end)
    in Queen
      check_queen_path(pos_start, pos_end)
    in King | Knight
      true if @board[pos_end[0]][pos_end[1]].nil? || @board[pos_end[0]][pos_end[1]].color != piece.color
    else
      false
    end
  end

  def check_hv_path(pos_start, pos_end)
    # 0 is X, 1 is Y
    if (pos_end[0] - pos_start[0]).abs > 1
      range = pos_end[0] > pos_start[0] ? (pos_start[0] + 1...pos_end[0]) : (pos_end[0] + 1...pos_start[0])
      range.all? { |column| @board[column][pos_start[1]].nil? }
    elsif (pos_end[1] - pos_start[1]).abs > 1
      range = pos_end[1] > pos_start[1] ? (pos_start[1] + 1...pos_end[1]) : (pos_end[1] + 1...pos_start[1])
      range.all? { |row| @board[pos_start[0]][row].nil? }
    else
      true # If moving only one square, the path is always clear
    end
  end

  def check_diag_path(pos_start, pos_end)
    x_step = pos_end[0] > pos_start[0] ? 1 : -1
    y_step = pos_end[1] > pos_start[1] ? 1 : -1

    x, y = pos_start[0] + x_step, pos_start[1] + y_step
    return true if pos_end[0] == x && pos_end[1] == 1

    while x != pos_end[0] || y != pos_end[1]
      return false unless @board[x][y].nil?

      x += x_step
      y += y_step
    end

    true
  end

  def check_queen_path(pos_start, pos_end)
    if pos_start[0] == pos_end[0] || pos_start[1] == pos_end[1]
      check_hv_path(pos_start, pos_end)
    else
      check_diag_path(pos_start, pos_end)
    end
  end

  def check_pawn_path(pos_start, pos_end)
    piece = @board[pos_start[0]][pos_start[1]]
    target = @board[pos_end[0]][pos_end[1]]

    if pos_start[0] == pos_end[0] # Moving forward
      target.nil?
    elsif target.nil?
      en_passant?(pos_start, pos_end)
    else # Diagonal capture
      !target.nil? &&
        @board[pos_end[0]][pos_end[1]].color != piece.color &&
        ((pos_end[0] - pos_start[0]).abs == 1 && (pos_end[1] - pos_start[1]).abs == 1)
    end
  end

  def en_passant?(pos_start, pos_end)
    piece = @board[pos_start[0]][pos_start[1]]
    capture = @board[pos_end[0]][pos_start[1]] # The pawn to be captured

    return false unless piece.is_a?(Pawn)
    return false unless capture.is_a?(Pawn)
    return false unless capture.color != piece.color
    return false unless capture.previous_moves == 1 # The captured pawn must have just moved two squares

    # Check if the capturing pawn is on the correct rank
    row = piece.color.zero? ? 3 : 4
    return false unless pos_start[1] == row

    # Check if the move is diagonal
    return false unless (pos_end[0] - pos_start[0]).abs == 1
    return false unless (pos_end[1] - pos_start[1]).abs == 1

    # Check if the capture is happening immediately after the two-square move
    return false unless @last_move[1] == capture.position

    true
  end

  def capture_piece(start_pos, end_pos)
    start_piece = @board[start_pos[0]][start_pos[1]]
    target_piece = @board[end_pos[0]][end_pos[1]]

    return false unless target_piece
    return false if start_piece.color == target_piece.color

    if start_piece.is_a?(Pawn) && !((end_pos[0] - start_pos[0]).abs == 1 && (end_pos[1] - start_pos[1]).abs == 1)
      return false
    end

    target_piece.capture
    symbol = target_piece.color.zero? ? :whites : :blacks
    @captured[symbol].push(target_piece)
    @board[end_pos[0]][end_pos[1]] = start_piece
    start_piece.move(end_pos[0], end_pos[1])
    @board[start_pos[0]][start_pos[1]] = nil

    update_board_ui

    true # Capture successful
  end

  def capture_en_passant(start, target)
    piece = @board[start[0]][start[1]]
    target_piece = @board[target[0]][start[1]]

    @board[target[0]][target[1]] = piece
    piece.move(target[0], target[1])
    target_piece.capture
    symbol = target_piece.color.zero? ? :whites : :blacks
    @captured[symbol].push(target_piece)
    @board[start[0]][start[1]] = nil
    @board[target[0]][start[1]] = nil
  end

  def castle?(color, ks_or_qs)
    row = color.zero? ? 7 : 0
    column = ks_or_qs == 'ks' ? 7 : 0 # To get rook
    king = @board[4][row]
    rook = @board[column][row]
    # Check for rook and king to not have moved / Check that king not in check
    return false unless king.previous_moves.zero? || rook.previous_moves.zero?
    return false if in_check?(color)

    # Check that path is clear & king does not pass through check
    if column.zero? # Queenside
      return false unless @board[1][row].nil? && @board[2][row].nil? && board[3][row].nil?
      return false if simulate_move(king, [3, row]).in_check?(color)
      return false if simulate_move(king, [2, row]).in_check?(color)
    else # Kingside
      return false unless @board[5][row].nil? && @board[6][row].nil?
      return false if simulate_move(king, [5, row]).in_check?(color)
      return false if simulate_move(king, [6, row]).in_check?(color)
    end

    true
  end

  def castle_qs(color)
    return nil unless castle?(color, 'qs')

    row = color.zero? ? 7 : 0
    king = [4, row]
    move_piece(king, [3, row])
    move_piece([3, row], [2, row])
    @board[3][row] = @board[0][row]
    @board[3][row].move(3, row)
    @board[0][row] = nil
    @last_move = [@board[king[0]][king[1]], [2, row]]
  end

  def castle_ks(color)
    return nil unless castle?(color, 'ks')

    row = color.zero? ? 7 : 0
    king = [4, row]
    move_piece(king, [5, row])
    move_piece([5, row], [6, row])
    @board[5][row] = @board[7][row]
    @board[5][row].move(5, row)
    @board[7][row] = nil
    @last_move = [@board[king[0]][king[1]], [6, row]]
  end

  def promote_pawn?(target)
    piece = @board[target[0]][target[1]]
    return false unless piece.is_a?(Pawn)

    end_row = piece.color.zero? ? 0 : 7
    target[1] == end_row ? promote(target, piece.color) : false
  end

  def promote(target, color)
    puts 'Type a letter to choose the piece you want to promote to (Queen(Q)/Knight(N)/Bishop(B)/Rook(R)):'
    # choice = gets.chomp.to_s
    @board[target[0]][target[1]] = case gets.chomp.to_s
                                   when 'N'
                                     Knight.new(target, color)
                                   when 'B'
                                     Bishop.new(target, color)
                                   when 'R'
                                     Rook.new(target, color)
                                   else
                                     Queen.new(target, color)
                                   end
  end

  def find_king_position(color)
    @board.each_with_index do |row, i|
      row.each_with_index do |piece, j|
        return [i, j] if piece.is_a?(King) && piece.color == color
      end
    end
  end

  def in_check?(color)
    opponent = color.zero? ? 1 : 0
    king_pos = find_king_position(color)
    get_pieces(opponent).any? do |piece|
      piece.legal_move?(king_pos[0], king_pos[1]) &&
        path_clear?(piece.position, king_pos)
    end
  end

  def checkmate?(color)
    return false unless in_check?(color)

    #  all of the player's pieces have none
    #  legal moves that would get the player out of check.
    get_pieces(color).all? do |piece|
      piece.legal_moves.none? do |move|
        board_after_move = simulate_move(piece, move)
        !board_after_move.in_check?(color)
      end
    end
  end

  def stalemate?(color)
    return false if in_check?(color)

    get_pieces(color).all? do |piece|
      piece.legal_moves.all? do |move|
        board_after_move = simulate_move(piece, move)
        board_after_move.board == @board || board_after_move.in_check?(color)
      end
    end
  end

  def get_pieces(color)
    a = []
    @board.each do |row|
      row.each do |piece|
        a << piece if piece.is_a?(Piece) && piece.color == color
      end
    end
    a
  end

  def simulate_move(piece, move)
    serialized_board = Marshal.dump(self)
    board_copy = Marshal.load(serialized_board)
    board_copy.move_piece(piece.position, move)
    board_copy
  end

  def possible_moves(color, square)
    get_pieces(color).select do |piece|
      piece.legal_move?(square[0], square[1]) &&
        path_clear?(piece.position, square)
    end
  end

  def ambiguous?(color, square)
    false unless possible_moves(color, square).length > 1
  end

  def piece_at(file_rank_square)
    files = ('a'..'h').to_a
    ranks = 8.downto(1).to_a
    @board[files.index(file_rank_square[0])][ranks.index(file_rank_square[1].to_i)]
  end

  def clear_board
    @board.each(&:clear)
  end
end
