# typed: strict
# frozen_string_literal: true

module Playoffs
  # Contains rules for how many total a series can be.
  class BestOf
    extend T::Sig

    sig { returns(Integer) }
    attr_reader :total

    sig { params(total: Integer).void }
    def initialize(total = 7)
      raise ArgumentError, 'total has to be positive' unless total.positive?
      raise ArgumentError, 'total has to be odd' unless total.odd?

      @total = total

      freeze
    end

    sig { returns(Integer) }
    def to_win
      (total / 2.0).ceil
    end

    sig { returns(String) }
    def to_s
      "#{self.class.to_s.split('::').last}::#{total}"
    end

    sig { params(other: BestOf).returns(T::Boolean) }
    def ==(other)
      total == other.total
    end
    alias eql? ==
  end
end
