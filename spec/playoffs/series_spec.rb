# typed: false
# frozen_string_literal: true

require 'spec_helper'

describe Playoffs::Series do
  let(:chi) { Playoffs::Team.new('CHI') }
  let(:nyk) { Playoffs::Team.new('NYK') }
  let(:mia) { Playoffs::Team.new('MIA') }

  describe '#initialize' do
    it 'sets contestants' do
      finals = described_class.new

      expect(finals.contestants).to eq([])
    end

    it 'defaults best_of to 7' do
      finals = described_class.new

      expect(finals.best_of).to eq(Playoffs::BestOf.new(7))
    end

    it 'sets best_of' do
      finals = described_class.new(best_of: Playoffs::BestOf.new(3))

      expect(finals.best_of).to eq(Playoffs::BestOf.new(3))
    end

    it 'prevents an even best_of' do
      expect { described_class.new(best_of: Playoffs::BestOf.new(2)) }.to raise_error(ArgumentError)
    end
  end

  describe '#valid?' do
    it 'is true with two team contestants' do
      finals = described_class.new.register(chi).register(nyk)

      expect(finals.valid?).to be true
    end

    it 'is false with one team contestant' do
      finals = described_class.new.register(chi)

      expect(finals.valid?).to be false
    end

    it 'is false with no contestants' do
      finals = described_class.new

      expect(finals.valid?).to be false
    end
  end

  describe '#to_s' do
    context 'with no contestants' do
      it 'is INVALID' do
        finals = described_class.new

        expect(finals.to_s).to eq('!INVALID!::BestOf::7::Series::TBD::0::TBD::0')
      end
    end

    context 'with an invalid series contestant' do
      it 'is INVALID' do
        semi_final = described_class.new.register(chi)
        finals = described_class.new.winner_of(semi_final).register(nyk)

        expect(finals.to_s).to eq('!INVALID!::BestOf::7::Series::NYK::0::TBD::0')
      end
    end

    context 'with two team contestants' do
      it 'outputs both team#to_s values' do
        finals = described_class.new.register(chi).register(nyk)

        expect(finals.to_s).to eq('BestOf::7::Series::CHI::0::NYK::0')
      end
    end

    context 'with one series and one team contestant' do
      it 'outputs TBD vs. team#to_s' do
        semi_final = described_class.new.register(chi).register(mia)
        finals = described_class.new.winner_of(semi_final).register(nyk)

        expect(finals.to_s).to eq('BestOf::7::Series::NYK::0::TBD::0')
      end
    end
  end

  context 'when building the graph' do
    describe '#register' do
      it 'adds team as a contestant' do
        finals = described_class.new.register(nyk)

        expect(finals.contestants).to include(nyk)
      end

      it 'prevents more than two contestants' do
        finals = described_class.new.register(chi).register(nyk)

        expect { finals.register(mia) }.to raise_error(ArgumentError)
      end
    end

    describe '#winner_of' do
      it 'adds series as a contestant' do
        semi_final = described_class.new
        finals = described_class.new.winner_of(semi_final)

        expect(finals.contestants).to include(semi_final)
      end

      it 'sets contestant#winner_advances_to series' do
        semi_final = described_class.new
        finals = described_class.new.winner_of(semi_final)

        expect(semi_final.winner_advances_to).to eq(finals)
      end

      it 'prevents more than two contestants' do
        east_final = described_class.new
        west_final = described_class.new
        mars_final = described_class.new
        finals = described_class.new.winner_of(east_final).winner_of(west_final)

        expect { finals.winner_of(mars_final) }.to raise_error(ArgumentError)
      end
    end

    describe '#loser_of' do
      it 'adds series as a contestant' do
        semi_final = described_class.new
        finals = described_class.new.loser_of(semi_final)

        expect(finals.contestants).to include(semi_final)
      end

      it 'sets contestant#loser_advances_to series' do
        semi_final = described_class.new
        finals = described_class.new.loser_of(semi_final)

        expect(semi_final.loser_advances_to).to eq(finals)
      end

      it 'prevents more than two contestants' do
        east_final = described_class.new
        west_final = described_class.new
        mars_final = described_class.new
        finals = described_class.new.loser_of(east_final).loser_of(west_final)

        expect { finals.loser_of(mars_final) }.to raise_error(ArgumentError)
      end
    end
  end
end
