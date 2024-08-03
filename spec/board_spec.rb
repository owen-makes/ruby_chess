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

  describe '#in_check?' do
    subject(:new_board) { Board.new }

    after do
      new_board.clear_board
    end

    it 'returns false in starting position for both colors' do
      new_board.populate
      expect(new_board.in_check?(0)).to eq(false)
      expect(new_board.in_check?(1)).to eq(false)
    end

    it 'returns true for white (fools mate)' do
      new_board.populate
      # Fool's mate
      new_board.move_piece([5, 6], [5, 5])
      new_board.move_piece([6, 6], [6, 4])
      # Black
      new_board.move_piece([4, 1], [4, 3])
      new_board.move_piece([3, 0], [7, 4])
      expect(new_board.in_check?(0)).to eq(true)
    end

    it 'returns true for black mate' do
      new_board.board[4][0] = Rook.new([4, 0], 0)
      new_board.board[7][2] = King.new([7, 2], 0)
      new_board.board[7][0] = King.new([7, 0], 1)
      expect(new_board.in_check?(1)).to eq(true)
    end
  end

  describe '#get_pieces' do
    subject(:new_board) { Board.new }

    it 'returns white pieces' do
      new_board.populate
      expect(new_board.get_pieces(0).all? { |piece| piece.color == 0 }).to eq(true)
    end

    it 'returns black pieces' do
      new_board.populate
      expect(new_board.get_pieces(1).all? { |piece| piece.color == 1 }).to eq(true)
    end

    it 'returns one piece (king)' do
      new_board.board[7][0] = King.new([7, 0], 1)
      new_board.update_board_ui
      expect(new_board.get_pieces(1).all?(King)).to be true
    end
  end

  describe '#checkmate?' do
    subject(:new_board) { Board.new }

    after do
      new_board.clear_board
    end

    it 'returns true for white (fools mate)' do
      # Fool's mate
      new_board.populate
      new_board.move_piece([5, 6], [5, 5])
      new_board.move_piece([6, 6], [6, 4])
      new_board.move_piece([4, 1], [4, 3])
      new_board.move_piece([3, 0], [7, 4])
      expect(new_board.checkmate?(0)).to eq(true)
    end

    it 'returns true for black mate' do
      new_board.board[4][0] = Rook.new([4, 0], 0)
      new_board.board[7][2] = King.new([7, 2], 0)
      new_board.board[7][0] = King.new([7, 0], 1)
      expect(new_board.checkmate?(1)).to eq(true)
    end
  end

  describe '#simulate_move' do
    subject(:new_board) { Board.new }
    before do
      new_board.populate
    end

    it 'moves pawn a2 to a3' do
      expect(new_board.simulate_move(new_board.board[0][6], [0, 5]).board[0][5]).to be_a(Pawn)
    end
  end

  describe '#stalemate?' do
    subject(:new_board) { Board.new }

    it 'returns true for black stalemate' do
      new_board.board[4][0] = Rook.new([6, 2], 0)
      new_board.board[7][2] = King.new([7, 2], 0)
      new_board.board[7][0] = King.new([7, 0], 1)
      new_board.update_board_ui
      expect(new_board.stalemate?(1)).to eq(true)
    end
  end

  describe '#castle?' do
    subject(:new_board) { Board.new }

    it 'returns false when king has moved' do
      new_board.populate
      new_board.move_piece([4, 6], [4, 4]) # Move pawn forward 2 spots
      new_board.move_piece([4, 7], [4, 6]) # Move king forward
      new_board.move_piece([4, 6], [4, 7]) # Move king back to starting pos
      expect(new_board.castle?(0, 'ks')).to eq(false)
    end

    it 'returns false when rook has moved' do
      new_board.populate
      new_board.move_piece([7, 6], [7, 4]) # Move pawn forward 2 spots
      new_board.move_piece([7, 7], [7, 5]) # Move rook forward
      new_board.move_piece([7, 5], [7, 7]) # Move rook back to starting pos
      expect(new_board.castle?(0, 'ks')).to eq(false)
    end

    it 'returns false when path not clear' do
      new_board.populate
      expect(new_board.castle?(1, 'ks')).to eq(false)
    end

    it 'returns false when king in check' do
      new_board.board[4][7] = King.new([4, 7], 0)
      new_board.board[7][7] = Rook.new([7, 7], 0)
      new_board.board[6][6] = Knight.new([6, 6], 1)
      expect(new_board.castle?(0, 'ks')).to eq(false)
    end

    it 'returns false when king passes through check' do
      new_board.board[4][0] = King.new([4, 0], 1)
      new_board.board[0][0] = Rook.new([0, 0], 1)
      new_board.board[4][2] = Knight.new([4, 2], 0)
      expect(new_board.castle?(1, 'qs')).to eq(false)
    end

    it 'returns false when king ends in check' do
      new_board.board[4][0] = King.new([4, 0], 1)
      new_board.board[0][0] = Rook.new([0, 0], 1)
      new_board.board[3][2] = Knight.new([3, 2], 0)
      expect(new_board.castle?(1, 'qs')).to eq(false)
    end

    it 'returns true when QS castle is available' do
      new_board.board[4][0] = King.new([4, 0], 1)
      new_board.board[0][0] = Rook.new([0, 0], 1)
      expect(new_board.castle?(1, 'qs')).to eq(true)
    end

    it 'returns true when KS castle is available' do
      new_board.board[4][7] = King.new([4, 7], 0)
      new_board.board[7][7] = Rook.new([7, 7], 0)
      expect(new_board.castle?(0, 'ks')).to eq(true)
    end
  end

  describe '#castle_qs' do
    subject(:new_board) { Board.new }

    it 'castles QS when available' do
      new_board.board[4][0] = King.new([4, 0], 1)
      new_board.board[0][0] = Rook.new([0, 0], 1)
      new_board.castle_qs(1)
      expect(new_board.board[2][0]).to be_a(King)
      expect(new_board.board[3][0]).to be_a(Rook)
      new_board.update_board_ui
      puts new_board.board_ui
    end

    it 'castles KS when available' do
      new_board.board[4][7] = King.new([4, 7], 0)
      new_board.board[7][7] = Rook.new([7, 7], 0)
      new_board.castle_ks(0)
      expect(new_board.board[6][7]).to be_a(King)
      expect(new_board.board[5][7]).to be_a(Rook)
      new_board.update_board_ui
      puts new_board.board_ui
    end
  end
end
