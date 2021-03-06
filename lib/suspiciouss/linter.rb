require 'suspiciouss/suggestions/camel_case'
require 'suspiciouss/suggestions/indentation'
require 'suspiciouss/suggestions/overqualifying'
require 'suspiciouss/suggestions/styling_ids'
require 'suspiciouss/suggestions/styling_js_prefix'
require 'suspiciouss/suggestions/underscores'
require 'suspiciouss/suggestions/zero_units'
require 'suspiciouss/result/markdown'
require 'suspiciouss/result/plain_text'

module Suspiciouss
  class Linter

    KNOWN_FILETYPES = /(css|sass|scss|less)$/
    SUGGESTIONS = Suspiciouss::Suggestions

    def initialize
      @result = Hash.new { |hash, key| hash[key] = [] }
    end

    # Process a diff file and return the result.
    # It will read the input sequentially from a string or standard input.
    def process(input = nil)
      if input.nil?
        input = STDIN
      end

      input.each_line do |line|
        detect_filename_in line
        parse line if @filename
      end

      if input.is_a? IO
        puts result_as(Suspiciouss::Result::PlainText)
      else
        result_as(Suspiciouss::Result::Markdown)
      end
    end

    private

    # Detects if the diff block references a known file type
    def detect_filename_in(full_line)
      line_might_contain_filename = full_line.scan(/^\+\+\+ b(.+)$/)

      return if line_might_contain_filename.empty?
      @filename = line_might_contain_filename.first.first

      if @filename !~ KNOWN_FILETYPES
        @filename = nil
      end
    end

    # Parses a line with each of the known suggestions and adds the result
    # to the final output.
    def parse(full_line)
      @line = strip_diff_syntax full_line

      return unless full_line =~ /^\+ /

      known_suggestions.each do |suggestion|
        if result = suggestion.parse(@line)
          @result[@filename] << "#{result}: #{@line}"
        end
      end
    end

    # Renders the result using the specified formatter
    def result_as(formatter)
      formatter.new(@result).format
    end

    # Memoizes available suggestions in an array
    def known_suggestions
      @known_suggestions ||= SUGGESTIONS.constants.map do |suggestion_class|
        SUGGESTIONS.const_get(suggestion_class).new
      end
    end

    # Returns a line without the "+ " added by diff
    def strip_diff_syntax(line)
      line[2..-1]
    end
  end
end
