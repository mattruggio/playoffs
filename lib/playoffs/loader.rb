# typed: strict
# frozen_string_literal: true

module Playoffs
  # Knows how to (de)serialize a tournament and read/write from/to disk.
  class Loader
    extend T::Sig

    sig { overridable.params(tournament: Tournament).returns(String) }
    def serialize(tournament)
      io = StringIO.new

      YAML.dump(tournament, io)

      io.string
    end

    sig { overridable.params(string: String).returns(Tournament) }
    def deserialize(string)
      YAML.load(
        string,
        permitted_classes: [
          BestOf,
          Round,
          Series,
          Team,
          Tournament
        ],
        aliases: true
      )
    end

    sig { overridable.params(path: String, tournament: Tournament).void }
    def save(path, tournament)
      FileUtils.mkdir_p(File.dirname(path))

      File.write(path, serialize(tournament))

      self
    end

    sig { overridable.params(path: String).returns(Tournament) }
    def load(path)
      deserialize(File.read(path))
    end
  end
end
