# typed: strict
# frozen_string_literal: true

module Playoffs
  # A very simple list of commands matching ARGV as input. Allows for capturing the output
  # via the passed in IO object used for construction. This class is an example of how the
  # underlying data structures, such as: BestOf, Round, Series, Team, and Tournament,
  # in this library can be used.
  class Cli
    extend T::Sig

    sig { returns(T.any(IO, StringIO)) }
    attr_reader :io

    sig { returns(String) }
    attr_reader :script

    sig { returns(Loader) }
    attr_reader :loader

    sig { returns(Simulator) }
    attr_reader :simulator

    sig do
      params(
        io: T.any(IO, StringIO),
        script: String,
        loader: Loader,
        simulator: Simulator
      ).void
    end
    def initialize(io, script: 'bin/playoffs', loader: Loader.new, simulator: RandomSimulator.new)
      @io = io
      @script = script
      @loader = loader
      @simulator = simulator
    end

    sig { params(args: T::Array[String]).returns(Cli) }
    def run(args)
      path = args[0].to_s
      action = args[1].to_s

      if path.empty? && action.empty?
        run_help(path, action, args)

        return self
      end

      action = 'bracket' if action.empty?

      method_name = "run_#{action}"

      if respond_to?(method_name, true)
        send(method_name, path, action, args)
      else
        io.puts("Unknown: #{action}")
      end

      self
    end

    private

    # rubocop:disable Metrics/AbcSize
    sig { params(_path: String, _action: String, _args: T::Array[String]).returns(Cli) }
    def run_help(_path, _action, _args)
      io.puts('Usage:')
      io.puts("  Help:                   #{script}")
      io.puts("  Generate New Playoff:   #{script} <path> new <team_ids>")
      io.puts("  View Bracket:           #{script} <path>")
      io.puts("  View All Rounds:        #{script} <path> rounds")
      io.puts("  View Next Round/Series: #{script} <path> up")
      io.puts("  Log Next Game Winner:   #{script} <path> win <team_id>")
      io.puts("  Random Simulation:      #{script} <path> sim")
      io.puts("  Winner:                 #{script} <path> winner")
      io.puts
      io.puts('Where:')
      io.puts('  <path> is a path to a YAML file.')
      io.puts('  <team_ids> is a list of 20 team IDs separated by a comma.')
      io.puts
      io.puts('Example(s):')
      io.puts("  #{script} 2024.yaml new BOS,NYK,MIL,CLE,ORL,IND,PHI,MIA,CHI,ATL,OKC,DEN,MIN,LAC,DAL,PHX,LAL,NO,SAC,GS")
      io.puts("  #{script} 2024.yaml")
      io.puts("  #{script} 2024.yaml rounds")
      io.puts("  #{script} 2024.yaml up")
      io.puts("  #{script} 2024.yaml win MIA")
      io.puts("  #{script} 2024.yaml sim")
      io.puts("  #{script} 2024.yaml winner")

      self
    end
    # rubocop:enable Metrics/AbcSize

    sig { params(path: String, _action: String, args: T::Array[String]).returns(Cli) }
    def run_new(path, _action, args)
      ids = args[2].to_s.split(',')
      teams = ids.map { |id| Team.new(id) }
      eastern_teams = teams[0..9] || []
      western_teams = teams[10..19] || []

      tournament = Basketball.tournament_for(eastern_teams:, western_teams:)

      loader.save(path, tournament)

      self
    end

    sig { params(path: String, _action: String, _args: T::Array[String]).returns(Cli) }
    def run_bracket(path, _action, _args)
      io.puts(loader.load(path).print_bracket)

      self
    end

    sig { params(path: String, _action: String, _args: T::Array[String]).returns(Cli) }
    def run_rounds(path, _action, _args)
      io.puts(loader.load(path).print_rounds)

      self
    end

    sig { params(path: String, _action: String, _args: T::Array[String]).returns(Cli) }
    def run_up(path, _action, _args)
      tournament = loader.load(path)

      series = tournament.up_next

      io.puts(tournament.up_next) if series

      self
    end

    sig { params(path: String, _action: String, args: T::Array[String]).returns(Cli) }
    def run_win(path, _action, args)
      id = args[2].to_s

      team = Team.new(id)
      tournament = loader.load(path)
      series = tournament.up_next

      T.must(series).win(team)

      io.puts(series)

      loader.save(path, tournament)

      self
    end

    sig { params(path: String, _action: String, _args: T::Array[String]).returns(Cli) }
    def run_sim(path, _action, _args)
      tournament = loader.load(path)

      total = 0
      # while not nil (and assign series)
      while (series = tournament.up_next)
        team = simulator.pick(series)

        series.win(team)

        total += 1
      end

      io.puts(total.to_s)

      io.puts(tournament.winner.to_s)

      loader.save(path, tournament)

      self
    end

    sig { params(path: String, _action: String, _args: T::Array[String]).returns(Cli) }
    def run_winner(path, _action, _args)
      tournament = loader.load(path)

      io.puts(tournament.winner) if tournament.over?

      self
    end
  end
end
