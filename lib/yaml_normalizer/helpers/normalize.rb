# frozen_string_literal: true

require 'pathname'

module YamlNormalizer
  module Helpers
    # This helper holds shared functionality to normalize a YAML string.
    module Normalize
      # Transforms a given YAML string to a normalized format.
      # @example
      #   class YamlWriter
      #     include YamlNormalizer::Helpers::Normalize
      #
      #     def initialize(yaml)
      #       @yaml = normalize_yaml(yaml)
      #     end
      #
      #     def write(file)
      #       File.open(file,'w') { |f| f.write(@yaml) }
      #     end
      #   end
      # @param [String] valid YAML string
      # @return [String] normalized YAML string
      def normalize_yaml(yaml)
        hashes = parse(yaml).to_ruby
        hashes.map(&Ext::SortByKey).map(&:to_yaml).join
      end

      private

      def sanitize_files(globs)
        files = globs.each_with_object([]) { |a, o| o << Dir[a.to_s] }
        files.flatten.sort.uniq
      end

      def parse(yaml)
        Psych.parse_stream(yaml)
      end

      def read(file)
        File.read(file, mode: 'r:bom|utf-8')
      end

      def relative_path_for(file)
        realpath = Pathname.new(file).realpath
        realpath.relative_path_from(Pathname.new(Dir.pwd))
      end
    end
  end
end
