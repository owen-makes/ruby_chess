require_relative '../lib/game'

describe '#parse_input' do
  let(:game) { Game.new }

  it 'returns nil when input is invalid' do
    input = 'askdjaskj'
    expect(game.parse_input(input, game.whites.color)).to be_nil
  end

  it 'calls castle_ks when receiving O-O as input' do
    input = 'O-O'
    expect(game.board).to receive(:castle_ks).with(0)
    expect(game.parse_input(input, game.whites.color)).to be_nil
  end

  it 'calls castle_qs when receiving O-O-O as input' do
    input = 'O-O-O'
    expect(game.board).to receive(:castle_qs).with(1)
    expect(game.parse_input(input, game.blacks.color)).to be_nil
  end

  it 'calls move_piece and returns true when input is valid (c3)' do
    input = 'c3'
    expect(game.parse_input(input, game.whites.color)).to_not be_nil
    expect(game.board.piece_at(input)).to be_a(Pawn)
  end

  it 'does not allow moves that put the king in check' do
    input1 = 'e4' # white
    input2 = 'g5' # black
    input3 = 'Qh5' # white
    input_check = 'f5' # black
    game.parse_input(input1, 0)
    game.parse_input(input2, 1)
    game.parse_input(input3, 0)
    expect(game.parse_input(input_check, 1)).to be_nil
    game.board.display_board
  end

  it 'handles long notation' do
    input1 = 'a4' # white
    input2 = 'Ra3' # white
    input3 = 'h4' # white
    long_input = 'Rh1h3'
    game.parse_input(input1, 0)
    game.parse_input(input2, 0)
    game.parse_input(input3, 0)
    game.board.display_board
    expect(game.parse_input(long_input, game.whites.color)).to_not be_nil
    expect(game.board.piece_at('h3')).to be_a(Rook)
    expect(game.board.piece_at('a3')).to be_a(Rook)
  end
end

describe '#get_start_square' do
  subject(:game) { Game.new }

  it 'returns [2, 6] when input move is c3 (white)' do
    input = 'c3'
    expect(game.get_start_square(input, game.whites.color)).to eq([2, 6])
  end

  it 'returns [6, 7] when input move is Nf3 (white)' do
    input = 'Nf3'
    expect(game.get_start_square(input, game.whites.color)).to eq([6, 7])
  end
end
