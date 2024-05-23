# typed: false
# frozen_string_literal: true

require 'spec_helper'

describe Playoffs::Team do
  subject(:chi) { described_class.new(id) }

  let(:id) { 'CHI' }

  describe '#initialize' do
    it 'sets id' do
      expect(chi.id).to eq(id)
    end
  end
end
