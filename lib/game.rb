require_relative 'board'

class Game
  def initialize
    board = Board.new
    board.populate
    whites = Player.new(0)
    blacks = Player.new(1)
  end

  def get_input(player)
    # until input_valid? do
    #  puts "#{PlayerX.color} to move:"
    #   input = gets.chomp
    #   return input
    #
  end

  def parse_input(input)
    # create function to convert algebraic notation to moves
    # if input.length == 2
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
                   For example, if you want to open with Knight to e3 just do: 'Ne3')
    puts(banner + instructions)
  end
end
