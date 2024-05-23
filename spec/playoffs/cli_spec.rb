# typed: false
# frozen_string_literal: true

require 'spec_helper'
require './spec/first_picker'

# These tests can be viewed as snapshot-based integration/end-to-end tests since it acts like an application built
# on top of the core classes supplied by this library. Testing most likely will start here for quick
# coverage and then broken down iteratively into finer-grained unit tests as required.
#
# This is also fairly brittle in that any changes to Psych's YAML serialization could end up producing different
# results but still semantically equal.
describe Playoffs::Cli do
  subject(:cli) { described_class.new(io, simulator: FirstPicker.new) }

  let(:io) { StringIO.new }
  let(:eastern_team_ids) { %w[BOS NYK MIL CLE ORL IND PHI MIA CHI ATL] }
  let(:western_team_ids) { %w[OKC DEN MIN LAC DAL PHX LAL NO SAC GS] }
  let(:team_ids) { eastern_team_ids + western_team_ids }

  describe 'new' do
    let(:path) { File.join('tmp', 'spec', "#{SecureRandom.uuid}.yaml") }

    before do
      args = [path, 'new', team_ids.join(',')]
      cli.run(args)
    end

    it 'generates YAML file' do
      actual = read(path)
      expected = read_fixture('cli', 'initial', 'tournament.yaml')

      expect(actual).to eq(expected)
    end
  end

  describe 'bracket' do
    let(:path) { fixture_path('cli', 'initial', 'tournament.yaml') }

    before do
      args = [path, 'bracket']
      cli.run(args)
    end

    it 'outputs bracket' do
      expected = read_fixture('cli', 'initial', 'bracket.txt')
      actual = read_io

      expect(actual).to eq(expected)
    end
  end

  describe 'rounds' do
    let(:path) { fixture_path('cli', 'initial', 'tournament.yaml') }

    before do
      args = [path, 'rounds']
      cli.run(args)
    end

    it 'outputs all rounds' do
      expected = read_fixture('cli', 'initial', 'rounds.txt')
      actual = read_io

      expect(actual).to eq(expected)
    end
  end

  describe 'up' do
    let(:path) { fixture_path('cli', 'initial', 'tournament.yaml') }

    before do
      args = [path, 'up']
      cli.run(args)
    end

    it 'outputs next series and current round' do
      expected = read_fixture('cli', 'initial', 'up_next.txt')
      actual = read_io

      expect(actual).to eq(expected)
    end
  end

  describe 'win' do
    let(:input_path) { fixture_path('cli', 'initial', 'tournament.yaml') }
    let(:path) { File.join(TEMP_DIR, "#{SecureRandom.uuid}.yaml") }

    before do
      FileUtils.mkdir_p(File.dirname(path))
      FileUtils.cp(input_path, path)

      args = [path, 'win', 'MIA']

      cli.run(args)
    end

    it 'saves updated bracket' do
      expected = read_fixture('cli', 'one_game_in', 'tournament.yaml')
      actual = read(path)

      expect(actual).to eq(expected)
    end

    it 'outputs series' do
      expected = read_fixture('cli', 'initial', 'win.txt')
      actual = read_io

      expect(actual).to eq(expected)
    end
  end

  describe 'sim' do
    let(:input_path) { fixture_path('cli', 'initial', 'tournament.yaml') }
    let(:path) { File.join(TEMP_DIR, "#{SecureRandom.uuid}.yaml") }

    before do
      FileUtils.mkdir_p(File.dirname(path))
      FileUtils.cp(input_path, path)

      args = [path, 'sim']

      cli.run(args)
    end

    it 'saves updated bracket' do
      expected = read_fixture('cli', 'over', 'tournament.yaml')
      actual = read(path)

      expect(actual).to eq(expected)
    end

    it 'outputs number of simulated games and winner' do
      expected = read_fixture('cli', 'initial', 'sim.txt')
      actual = read_io

      expect(actual).to eq(expected)
    end
  end

  private

  def read_io
    io.rewind
    io.read
  end
end
