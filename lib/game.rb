require_relative 'placeholder'

class Game
  def initialize
    board = Board.new
    board.populate # create method for board to populate
    whites = Player.new(0)
    blacks = Player.new(1)
  end

  def get_input
    # create
  end
end
