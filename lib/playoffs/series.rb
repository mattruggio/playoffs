# typed: strict
# frozen_string_literal: true

module Playoffs
  # A node in a directed acyclic graph which represents a current or future series between two teams.
  # The teams are able to be resolved later in the graph by connecting series together:
  # a contestestant does not have to be a team, it can be the promise of a team via
  # another series (as the winner or loser).
  class Series
    extend T::Sig

    sig { returns(T::Array[Contestant]) }
    attr_reader :contestants

    sig { returns(T.nilable(Series)) }
    attr_accessor :winner_advances_to

    sig { returns(T.nilable(Series)) }
    attr_accessor :loser_advances_to

    sig { returns(BestOf) }
    attr_reader :best_of

    sig { returns(T::Array[Team]) }
    attr_reader :winners_by_game

    sig { returns(T.nilable(Team)) }
    attr_reader :winner

    sig { params(best_of: BestOf).void }
    def initialize(best_of: BestOf.new)
      @contestants = T.let([], T::Array[Contestant])
      @best_of = best_of
      @winners_by_game = T.let([], T::Array[Team])
    end

    sig { returns(T::Array[Team]) }
    def teams
      contestants.map do |contestant|
        case contestant
        when Team
          contestant
        when Series
          contestant.winner_advances_to == self ? contestant.winner : contestant.loser
        else
          T.absurd(contestant)
        end
      end.compact
    end

    sig { returns(T.nilable(Team)) }
    def loser
      return unless winner

      (teams - [winner]).first
    end

    sig { params(team: Team).returns(Series) }
    def win(team)
      raise NotEnoughTeamsError unless teams.length == 2

      saved_team = teams.find { |t| t == team }

      raise InvalidTeamError unless saved_team
      raise SeriesOverError if over?

      winners_by_game << saved_team

      @winner = T.let(saved_team, T.nilable(Team)) if winner?(saved_team)

      self
    end

    sig { returns(Integer) }
    def games_played
      winners_by_game.length
    end

    sig { returns(T::Boolean) }
    def over?
      !not_over?
    end

    sig { returns(T::Boolean) }
    def not_over?
      winner.nil?
    end

    sig { returns(T::Boolean) }
    def valid?
      return false if contestants.length != 2

      contestants.each do |contestant|
        case contestant
        when Team
          # Teams are always valid
        when Series
          # short-circuit because we cant be valid if the previous series (children) aren't.
          return false unless contestant.valid?
        else
          T.absurd(contestant)
        end
      end

      true
    end

    sig { params(team: Team).returns(Integer) }
    def win_count_for(team)
      winners_by_game.select { |winner| winner == team }.length
    end

    # rubocop:disable Metrics/AbcSize
    sig { returns(String) }
    def to_s
      team_lines = teams.map do |contestant|
        [contestant.to_s, win_count_for(contestant)]
      end

      team_lines += [['TBD', 0]] * (2 - team_lines.length)

      [
        valid? ? nil : '!INVALID!',
        best_of.to_s,
        self.class.to_s.split('::').last,
        team_lines,
        over? ? 'Done' : nil
      ].compact.flatten.join('::')
    end
    # rubocop:enable Metrics/AbcSize

    sig { params(series: Series).returns(Series) }
    def winner_of(series)
      series.winner_advances_to = self

      add(series)
    end

    sig { params(series: Series).returns(Series) }
    def loser_of(series)
      series.loser_advances_to = self

      add(series)
    end

    sig { params(team: Team).returns(Series) }
    def register(team)
      add(team)
    end

    private

    sig { params(team: Team).returns(T::Boolean) }
    def winner?(team)
      winners_by_game.select { |w| w == team }.length == best_of.to_win
    end

    sig { params(contestant: Contestant).returns(Series) }
    def add(contestant)
      raise ArgumentError, 'No more than two contestants allowed.' if contestants.length >= 2

      contestants << contestant

      self
    end
  end
end
