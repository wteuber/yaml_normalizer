# frozen_string_literal: true

require 'peach'

module YamlNormalizer
  module Services
    # Normalize is a service class that provides functionality to update giving
    # YAML files to a standardized (normalized) format.
    # @exmaple
    #   normalize = YamlNormalizer::Services::Normalize.new('path/to/*.yml')
    #   result = normalize.call
    class Normalize < Base
      include Helpers::Normalize

      # Normalizes all YAML files set on instantiation.
      # @param *args [Array<String>] a list of file glob patterns
      def call(*args)
        normalize = method(:process)
        files = sanitize_files(args)
        $stderr.print "#{args} does not match any files\n" if files.empty?
        files.peach(&normalize)
      end

      private

      def process(file)
        if IsYaml.call(file)
          normalize!(file)
        else
          $stderr.print "#{file} is not a YAML file\n"
        end
      end

      def normalize!(file)
        file = relative_path_for(file)
        if stable?(input = read(file), norm = normalize_yaml(input))
          File.open(file, 'w') { |f| f.write(norm) }
          $stderr.print "[NORMALIZED] #{file}\n"
        else
          $stderr.print "[ERROR]      Could not normalize #{file}\n"
        end
      end

      # Returns true if the hashes resulting from parsing both input YAML
      # strings are equal and returns false otherwise.
      def stable?(yaml_a, yaml_b)
        hash_a = Psych.parse_stream(yaml_a).to_ruby
        hash_b = Psych.parse_stream(yaml_b).to_ruby
        hash_a.eql?(hash_b)
      end
    end
  end
end
