class Piece
  attr_reader :color, :notation, :position

  FILES = ('a'..'h').to_a.freeze
  RANK = 8.downto(1).to_a.freeze

  def initialize(color, position)
    @color = color
    @position = position
    @notation = "#{FILES.at(@position[0])}#{RANK.at(@position[1])}"
  end

  def valid_position?(x, y)
    x.between?(0, 7) && y.between?(0, 7)
  end

  def capture
    update_position(nil, nil)
  end

  protected

  def update_position(x, y)
    @position = [x, y]
  end
end
