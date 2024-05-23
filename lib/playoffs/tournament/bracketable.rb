# typed: strict
# frozen_string_literal: true

module Playoffs
  # Print out a basic, tree-based, text hierarchy of all series.
  module Bracketable
    extend T::Helpers
    extend T::Sig

    abstract!

    sig { abstract.returns(Series) }
    def championship; end

    sig { returns(String) }
    def print_bracket
      top_line =
        if championship.valid? && championship.over?
          championship.winner.to_s
        elsif championship.valid?
          'TBD'
        else
          '!INVALID!'
        end

      ([top_line] + traverse_to_s(championship)).join("\n")
    end

    private

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    sig do
      params(
        series: Series,
        next_series: T.nilable(Series),
        depth: Integer,
        draw_sibling_depths: T::Array[Integer]
      ).returns(String)
    end
    def series_line(series, next_series = nil, depth = 0, draw_sibling_depths = [])
      type =
        if next_series && next_series == series.loser_advances_to
          '::LoserAdvances'
        elsif next_series && series.loser_advances_to
          '::WinnerAdvances'
        end

      line = ''

      (0...depth).each do |d|
        line += (draw_sibling_depths.include?(d) ? '│ ' : '  ')
      end

      current_char =
        if depth.positive? && draw_sibling_depths.include?(depth)
          '├ '
        else
          '└ '
        end

      line + "#{current_char}#{series}#{type}"
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # rubocop:disable Metrics/ParameterLists
    sig do
      params(
        series: Series,
        next_series: T.nilable(Series),
        depth: Integer,
        lines: T::Array[String],
        draw_sibling_depths: T::Array[Integer]
      ).returns(T::Array[String])
    end
    def traverse_to_s(series, next_series = nil, depth = 0, lines = [], draw_sibling_depths = [])
      lines << series_line(series, next_series, depth, draw_sibling_depths)

      series.contestants.each_with_index do |contestant, index|
        new_siblings_depths =
          if index < series.contestants.length - 1
            draw_sibling_depths + [depth + 1]
          else
            draw_sibling_depths
          end

        traverse_to_s(contestant, series, depth + 1, lines, new_siblings_depths) if contestant.is_a?(Series)
      end

      lines
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
