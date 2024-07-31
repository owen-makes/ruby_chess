Dir[File.join(__dir__, 'pieces', '*.rb')].sort.each { |file| require_relative file }

class Board
  attr_reader :board, :captured

  def initialize(board_size = 8)
    @board = Array.new(board_size) { Array.new(board_size) }
    @size = board_size
    @board_ui = nil
    @captured = { whites: [], blacks: [] }
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
    return nil unless piece.legal_move?(target[0], target[1])

    return nil unless path_clear?(start, target)

    if destination.nil?
      @board[target[0]][target[1]] = @board[start[0]][start[1]]
      @board[target[0]][target[1]].move(target[0], target[1])
      @board[start[0]][start[1]] = nil
      promote_pawn?(target)
      update_board_ui
    else
      capture_piece(start, target)
      promote_pawn?(target)
    end
  end

  def path_clear?(pos_start, pos_end)
    # Check if path is clear to move (King, Queen, Bish, Rook, Pawn)
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
      true
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

    if pos_start[0] == pos_end[0] # Moving forward
      (pos_start[1] + 1..pos_end[1]).all? { |row| @board[pos_start[1]][row].nil? }
    else # Diagonal capture
      @board[pos_end[0]][pos_end[1]].nil? || @board[pos_end[0]][pos_end[1]].color != piece.color
    end
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

  def castle(color, ks_or_qs)
    row = color.zero? ? 7 : 0
    column = ks_or_qs == '0-0' ? 7 : 0
    king = @board[4][row]
    rook = @board[column][row]
    # Check for rook and king to not have moved
    return false unless king.previous_moves.empty? || rook.previous_moves.empty?

    if column.zero?
      false unless @board[1][row].nil? && @board[2][row].nil? && board[3][row].nil?
    else
      false unless @board[5][row].nil? && @board[6][row].nil?
    end
    # To-Do:
    # return false if king in check
    # return false if king passes through check
    # castle_queen_side 0-0-0
  end

  def promote_pawn?(target)
    piece = @board[target[0]][target[1]]
    return false unless piece.is_a?(Pawn)

    end_row = piece.color.zero? ? 0 : 7
    target[1] == end_row ? promote(target, piece.color) : false
  end

  def promote(target, color)
    puts 'Type a letter to choose the piece you want to promote to (Queen(Q)//Knight(N)//Bishop(B)):'
    choice = gets.chomp.to_s
    @board[target[0]][target[1]] = case choice
                                   when 'N'
                                     Knight.new(target, color)
                                   when 'B'
                                     Bishop.new(target, color)
                                   else
                                     Queen.new(target, color)
                                   end
  end
end
