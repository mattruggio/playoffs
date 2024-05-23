# typed: strict
# frozen_string_literal: true

module Playoffs
  # A contestant is an object that feeds into a series which can either be a winner/loser
  # of another series or a team.
  Contestant = T.type_alias { T.any(Series, Team) }
end
