require_relative '../lib/pieces/knight'

describe Knight do
  subject(:test_knight) { Knight.new([1, 7], 0) }

  describe '#legal_move' do
    it 'returns false when move ilegal' do
      expect(test_knight.legal_move?(4, 4)).to eq(false)
    end

    it 'returns true when move legal' do
      expect(test_knight.legal_move?(2, 5)).to eq(true)
    end
  end

  describe '#move' do
    it 'updates position when move legal' do
      expect { test_knight.move(2, 5) }.to change { test_knight.position }.from([1, 7]).to([2, 5])
    end

    it 'does not update position when move ilegal' do
      expect(test_knight.move(4, 4)).to be_nil
    end

    it 'does not update when out of bounds' do
      expect(test_knight.move(0, 9)).to be_nil
    end
  end
end
