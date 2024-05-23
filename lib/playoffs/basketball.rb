# typed: strict
# frozen_string_literal: true

module Playoffs
  # Knows how to create a tournament specific to professional basketball.
  class Basketball
    extend T::Sig

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    sig do
      params(
        eastern_teams: T::Array[Team],
        western_teams: T::Array[Team]
      ).returns(Tournament)
    end
    def self.tournament_for(eastern_teams:, western_teams:)
      eastern_teams = eastern_teams.uniq
      western_teams = western_teams.uniq

      raise IncorrectTeamCount unless eastern_teams.size == 10
      raise IncorrectTeamCount unless western_teams.size == 10

      play_in_best_of = BestOf.new(1)

      eastern_play_in78 = Series.new(best_of: play_in_best_of)
        .register(T.must(eastern_teams[6]))
        .register(T.must(eastern_teams[7]))

      eastern_play_in910 = Series
        .new(best_of: play_in_best_of)
        .register(T.must(eastern_teams[8]))
        .register(T.must(eastern_teams[9]))

      eastern_play_in_consolation = Series
        .new(best_of: play_in_best_of)
        .loser_of(eastern_play_in78)
        .winner_of(eastern_play_in910)

      western_play_in78 = Series
        .new(best_of: play_in_best_of)
        .register(T.must(western_teams[6]))
        .register(T.must(western_teams[7]))

      western_play_in910 = Series
        .new(best_of: play_in_best_of)
        .register(T.must(western_teams[8]))
        .register(T.must(western_teams[9]))

      western_play_in_consolation = Series
        .new(best_of: play_in_best_of)
        .loser_of(western_play_in78)
        .loser_of(western_play_in910)

      championship =
        Series
          .new
          .winner_of(
            Series.new
              .winner_of(
                Series.new
                  .winner_of(
                    Series.new
                      .register(T.must(eastern_teams[0]))
                      .winner_of(eastern_play_in_consolation)
                  )
                  .winner_of(
                    Series.new
                      .register(T.must(eastern_teams[3]))
                      .register(T.must(eastern_teams[4]))
                  )
              )
              .winner_of(
                Series.new
                  .winner_of(
                    Series.new
                      .register(T.must(eastern_teams[2]))
                      .register(T.must(eastern_teams[5]))
                  )
                  .winner_of(
                    Series.new
                      .register(T.must(eastern_teams[1]))
                      .winner_of(eastern_play_in78)
                  )
              )
          )
          .winner_of(
            Series.new
              .winner_of(
                Series.new
                  .winner_of(
                    Series.new
                      .register(T.must(western_teams[0]))
                      .winner_of(western_play_in_consolation)
                  )
                  .winner_of(
                    Series.new
                      .register(T.must(western_teams[3]))
                      .register(T.must(western_teams[4]))
                  )
              )
              .winner_of(
                Series.new
                  .winner_of(
                    Series.new
                      .register(T.must(western_teams[2]))
                      .register(T.must(western_teams[5]))
                  )
                  .winner_of(
                    Series.new
                      .register(T.must(western_teams[1]))
                      .winner_of(western_play_in78)
                  )
              )
          )

      Tournament.new(championship)
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
