require_relative '../lib/pieces/pawn'

describe Pawn do
  subject(:test_pawn) { Pawn.new([2, 6], 0) }

  describe '#legal_move' do
    it 'returns false when move ilegal' do
      expect(test_pawn.legal_move?(4, 4)).to eq(false)
    end

    it 'returns true when jumping two squares on first move' do
      expect(test_pawn.legal_move?(2, 4)).to eq(true)
    end

    before do
      test_pawn.move(2, 5)
    end

    it 'returns false when jumping two squares on second move' do
      expect(test_pawn.legal_move?(2, 3)).to eq(false)
    end
  end

  describe '#move' do
    it 'updates position when move legal' do
      expect { test_pawn.move(2, 5) }.to change { test_pawn.position }.from([2, 6]).to([2, 5])
    end

    it 'does not update position when move ilegal' do
      expect(test_pawn.move(4, 4)).to be_nil
    end

    it 'does not update when out of bounds' do
      expect(test_pawn.move(0, 9)).to be_nil
    end
  end
end
