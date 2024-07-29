require_relative '../lib/board'

describe Board do
  subject(:test_board) { Board.new }

  describe '#populate' do
    before do
      test_board.populate
    end

    it 'adds pawns to the second row' do
      expect(test_board.board.all? { |column| column[1].is_a?(Pawn) }).to be true
    end

    it 'adds rooks to the corners' do
      expect(test_board.board[0][0]).to be_a(Rook)
      expect(test_board.board[0][7]).to be_a(Rook)
      expect(test_board.board[7][0]).to be_a(Rook)
      expect(test_board.board[7][7]).to be_a(Rook)
    end

    it 'leaves the middle rows empty' do
      (0..7).each do |column|
        (2..5).each do |row|
          expect(test_board.board[column][row].nil?).to be true
        end
      end
    end

    it 'adds whites to rows 6-7' do
      expect(test_board.board.all? { |column| column[7].color == 0 }).to be true
      expect(test_board.board.all? { |column| column[6].color == 0 }).to be true
    end

    it 'adds blacks to rows 0-1' do
      expect(test_board.board.all? { |column| column[0].color == 1 }).to be true
      expect(test_board.board.all? { |column| column[1].color == 1 }).to be true
    end
  end

  describe '#display_board' do
    before do
      test_board.populate
    end

    it 'puts populated board' do
      expect { test_board.display_board }.to output.to_stdout
    end
  end
end
