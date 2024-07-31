require_relative '../lib/board'

describe Board do
  subject(:test_board) { Board.new }

  describe '#populate' do
    before do
      test_board.populate
    end

    it 'adds pawns to the second and sixth row' do
      expect(test_board.board.all? { |column| column[1].is_a?(Pawn) }).to be true
      expect(test_board.board.all? { |column| column[6].is_a?(Pawn) }).to be true
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

  describe '#path_clear?' do
    before do
      test_board.populate
    end

    it 'returns true when moving pawn a2 to a4' do
      expect(test_board.path_clear?([0, 6], [0, 4])).to eq(true)
    end

    it 'returns false when trying to move left white rook from starting pos' do
      expect(test_board.path_clear?([0, 7], [0, 3])).to eq(false)
    end

    it 'returns false when trying to move white queen from starting pos' do
      expect(test_board.path_clear?([3, 7], [5, 5])).to eq(false)
    end

    it 'returns false when trying to move black bishop' do
      expect(test_board.path_clear?([2, 0], [4, 2])).to eq(false)
    end

    it 'returns true when moving white knight' do
      expect(test_board.path_clear?([6, 7], [5, 5])).to eq(true)
    end
  end

  describe '#move_piece' do
    let(:test_pawn) { Pawn.new([0, 6], 0) }
    let(:test_bishop) { Bishop.new([4, 5], 0) }
    let(:black_pawn) { Pawn.new([1, 3], 1) }
    let(:promote_pawn) { Pawn.new([1, 1], 0) }

    before do
      test_board.board[0][6] = test_pawn
      test_board.board[4][5] = test_bishop
      test_board.board[1][3] = black_pawn
      test_board.board[1][1] = promote_pawn
    end

    it 'moves pawn a2 forward to a5' do
      expect { test_board.move_piece([0, 6], [0, 4]) }.to change { test_pawn.position }.from([0, 6]).to([0, 4])
    end

    it 'moves bishop e3 diagonally to b2' do
      expect { test_board.move_piece([4, 5], [1, 2]) }.to change { test_bishop.position }.from([4, 5]).to([1, 2])
    end

    it 'captures pieces when possible' do
      test_board.move_piece([0, 6], [0, 4])
      expect { test_board.move_piece([0, 4], [1, 3]) }.to change { test_pawn.position }.from([0, 4]).to([1, 3])
      expect(test_board.board[1][3] == test_pawn).to eq(true)
    end

    context 'when getting a pawn to end row' do
      it 'allows for pawn promotion' do
        expect(test_board.move_piece([1, 1], [1, 0])).to_not be_nil
        allow(test_board).to receive(:gets).and_return('/n')
        expect(test_board.board[1][0]).to be_a(Queen)
      end
    end
  end

  describe '#capture_piece' do
    let(:white_pawn) { Pawn.new([1, 2], 0) }
    let(:test_queen) { Queen.new([4, 5], 1) }
    let(:black_pawn) { Pawn.new([1, 3], 1) }

    before do
      test_board.board[1][2] = white_pawn
      test_board.board[4][5] = test_queen
      test_board.board[1][3] = black_pawn
    end

    it 'adds captured piece to hash' do
      test_board.capture_piece([4, 5], [1, 2])
      expect(test_board.captured[:whites].include?(white_pawn)).to eq(true)
    end

    it 'returns false when trying ilegal move' do
      expect(test_board.capture_piece([1, 2], [4, 5])).to eq(false)
    end

    it 'returns false when trying to capture forward with pawn' do
      expect(test_board.capture_piece([1, 2], [1, 3])).to eq(false)
    end
  end

  describe '#promote_pawn?' do
    let(:white_pawn) { Pawn.new([1, 0], 0) }
    let(:black_pawn) { Pawn.new([2, 0], 1) }
    let(:black_pawn2) { Pawn.new([2, 7], 1) }

    before do
      test_board.board[1][0] = white_pawn
      test_board.board[2][0] = black_pawn
      test_board.board[2][7] = black_pawn2
    end

    it 'calls promote on white pawn @ b8' do
      expect(test_board).to receive(:promote).with([1, 0], 0)
      test_board.promote_pawn?([1, 0])
    end

    it 'calls promote on black pawn @ c1' do
      expect(test_board).to receive(:promote).with([2, 7], 1)
      test_board.promote_pawn?([2, 7])
    end

    it 'returns false for black pawn @ c8' do
      expect(test_board.promote_pawn?([2, 0])).to eq(false)
    end
  end

  describe '#promote' do
    let(:white_pawn) { Pawn.new([1, 0], 0) }
    let(:black_pawn) { Pawn.new([2, 0], 1) }
    let(:black_pawn2) { Pawn.new([2, 7], 1) }

    before do
      test_board.board[1][0] = white_pawn
      test_board.board[2][0] = black_pawn
    end

    it 'promotes b8 white pawn to queen' do
      allow(test_board).to receive(:gets).and_return('/n')
      test_board.promote([1, 0], 0)
      expect(test_board.board[1][0]).to be_a(Queen)
    end

    it 'promotes c1 black pawn to knight' do
      allow(test_board).to receive(:gets).and_return('N')
      test_board.promote([2, 7], 1)
      expect(test_board.board[2][7]).to be_a(Knight)
    end
  end
end
