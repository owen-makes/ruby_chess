require_relative 'board'
require_relative 'player'
require 'colorize'
require 'yaml'
require 'securerandom'

class Game
  attr_reader :whites, :blacks, :board

  FILES = ('a'..'h').to_a.freeze
  RANKS = 8.downto(1).to_a.freeze
  PATTERN = /\A([KQRBN])?([a-h])?([1-8])?([a-h][1-8])\z/ # [1 = piece, 2= file, 3 = rank, 4 = target square]

  def initialize
    @board = Board.new
    @board.populate
    @whites = Player.new(0)
    @blacks = Player.new(1)
    @turn = @whites
  end

  def get_input(player)
    color = player.color.zero? ? 'White' : 'Black'
    opponent = player.color.zero? ? 'Black' : 'White'
    opp_num = player.color.zero? ? 1 : 0
    puts "#{color} to move:"
    input = gets.chomp
    while parse_input(input, player.color).nil?
      puts "#{color} to move:"
      input = gets.chomp
    end
    puts "#{opponent} in check!".colorize(:yellow) if @board.in_check?(opp_num)
  end

  def parse_input(input, player_color)
    case input
    when 'save'
      save_game
    when 'load'
      load_game
    when 'O-O'
      @board.castle_ks(player_color)
      @turn = @turn == @whites ? @blacks : @whites
    when 'O-O-O'
      @board.castle_qs(player_color)
      @turn = @turn == @whites ? @blacks : @whites
    else
      return if PATTERN.match(input).nil?
      return if get_start_square(input, player_color).nil?

      pos_start = get_start_square(input, player_color)
      piece = @board.board[pos_start[0]][pos_start[1]]
      pos_end = get_target_square(input)
      return unless piece.color == player_color

      if @board.simulate_move(piece, pos_end).in_check?(player_color)
        puts 'Invalid move. King in check!'.colorize(:red)
        return
      end
      @board.move_piece([pos_start[0], pos_start[1]], [pos_end[0], pos_end[1]])
      @turn = @turn == @whites ? @blacks : @whites
    end
  end

  def get_target_square(input)
    move = PATTERN.match(input)
    destination_x = FILES.index(move[4][0])
    destination_y = RANKS.index(move[4][1].to_i)

    [destination_x, destination_y]
  end

  def get_start_square(input, color)
    move = PATTERN.match(input)
    piece_type = move[1]
    source_file = move[2]
    source_rank = move[3]
    target_square = get_target_square(input)

    possible_moves = @board.possible_moves(color, target_square)

    candidates = possible_moves.select do |piece|
      next unless piece_matches?(piece, piece_type)
      next if source_file && FILES[piece.position[0]] != source_file
      next if source_rank && RANKS[piece.position[1]] != source_rank.to_i

      true
    end

    case candidates.length
    when 0
      puts "No valid moves found for #{input}"
      nil
    when 1
      candidates.first.position
    else
      puts "Ambiguous move: #{input}. Please provide more specific notation."
      nil
    end
  end

  def piece_matches?(piece, piece_type)
    case piece_type
    when nil
      piece.is_a?(Pawn)
    when 'N'
      piece.is_a?(Knight)
    when 'B'
      piece.is_a?(Bishop)
    when 'R'
      piece.is_a?(Rook)
    when 'Q'
      piece.is_a?(Queen)
    when 'K'
      piece.is_a?(King)
    else
      false
    end
  end

  def welcome_msg # rubocop:disable Metrics/MethodLength
    banner = %(
     ██████╗    ██╗  ██╗    ███████╗    ███████╗    ███████╗
    ██╔════╝    ██║  ██║    ██╔════╝    ██╔════╝    ██╔════╝
    ██║         ███████║    █████╗      ███████╗    ███████╗
    ██║         ██╔══██║    ██╔══╝      ╚════██║    ╚════██║
    ╚██████╗    ██║  ██║    ███████╗    ███████║    ███████║
      ╚═════╝    ╚═╝  ╚═╝    ╚══════╝    ╚══════╝    ╚══════╝
                                            by Owen Botto 😀)
    instructions = %(Play using algebraic notation.
    Castle King Side: O-O / Castle Queen Side: O-O-O / En Passant is done automatically by moving to the target square
    For example, if you want to open with Knight to e3 just do: 'Ne3'. Use long notation for ambiguous moves
    If you'd like to save your game, just type 'save' anytime.)
    puts("#{banner}\n#{instructions}")
  end

  def play
    welcome_msg
    until win? || draw?
      @board.display_board
      get_input(@whites)
      @board.display_board
      break if win? || draw?

      get_input(@blacks)
    end
    @board.display_board
    announce_winner
    announce_draw
  end

  def win?
    @board.checkmate?(0) || @board.checkmate?(1)
  end

  def draw?
    @board.stalemate?(0) || @board.stalemate?(1)
  end

  def announce_winner
    return unless @board.checkmate?(0) || @board.checkmate?(1)

    if @board.checkmate?(1)
      puts 'Checkmate (White wins)'.colorize(:green)
      @whites.score += 1
    else
      puts 'Checkmate (Black wins)'.colorize(:green)
      @blacks.score += 1
    end

    puts "Whites #{whites.score}:#{blacks.score} Blacks".colorize(:green)
  end

  def announce_draw
    return unless @board.stalemate?(0) || @board.stalemate?(1)

    puts 'Draw by stalemate.'.colorize(:yellow)
    puts "Whites #{whites.score}:#{blacks.score} Blacks"
  end

  def continue_play
    until win? || draw?
      @board.display_board
      get_input(@turn)
      @board.display_board
      break if win? || draw?
    end
    @board.display_board
    announce_winner
    announce_draw
  end

  def save_game
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    game_id = SecureRandom.hex(4)

    yaml = YAML.dump({
                       board: @board,
                       whites: @whites,
                       blacks: @blacks,
                       turn: @turn
                     })

    Dir.mkdir('saves') unless Dir.exist?('saves')
    filename = "saves/game_#{timestamp}_#{game_id}.yml"
    File.open(filename, 'w') do |file|
      file.puts yaml
    end
    puts "Game #{timestamp}_#{game_id} saved!"
  end

  def load_game
    Dir.chdir 'saves'
    saves = Dir.entries('.').reject { |f| File.directory?(f) }
    saves.each_with_index { |file, idx| puts "#{idx}. #{file}" }

    puts 'Choose a save using the number'
    choice = gets.chomp.to_i
    return puts 'Invalid choice' if choice < 0 || choice >= saves.length

    string = saves[choice]

    puts "Loading file: #{string}"
    permitted_classes = [Symbol, Board, Piece, Rook, Knight, Bishop, Queen, King, Pawn, Player]
    data = YAML.safe_load(File.read(string),
                          permitted_classes: permitted_classes,
                          aliases: true)
    @board = data[:board]
    @whites = data[:whites]
    @blacks = data[:blacks]
    @turn = data[:turn]
    Dir.chdir '..'
    continue_play
  end
end

game = Game.new
game.play
