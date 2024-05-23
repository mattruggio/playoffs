# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require 'primitive'
require 'yaml'

require_relative 'playoffs/basketball'
require_relative 'playoffs/best_of'
require_relative 'playoffs/cli'
require_relative 'playoffs/contestant'
require_relative 'playoffs/loader'
require_relative 'playoffs/random_simulator'
require_relative 'playoffs/round'
require_relative 'playoffs/series'
require_relative 'playoffs/team'
require_relative 'playoffs/tournament'

module Playoffs
  class IncorrectTeamCount < StandardError; end
  class InvalidTeamError < StandardError; end
  class InvalidTeamsError < StandardError; end
  class NotEnoughTeamsError < StandardError; end
  class RoundOverError < StandardError; end
  class SeriesOverError < StandardError; end
  class TeamsMustBeUniqueError < StandardError; end
  class TournamentOverError < StandardError; end
end
