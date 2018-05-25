# frozen_string_literal: true

require 'peach'

module YamlNormalizer
  module Services
    # Check is a service class that provides functionality to check if giving
    # YAML files are already standardized (normalized).
    # @example
    #   check = YamlNormalizer::Services::Call.new('path/to/*.yml')
    #   result = check.call
    class Check < Base
      include Helpers::Normalize

      # Normalizes all YAML files defined on instantiation.
      # @param *args [Array<String>] a list of file glob patterns
      def call(*args)
        is_valid = method(:valid?)
        sanitize_files(args).pmap(&is_valid).all?
      end

      private

      def valid?(file)
        if IsYaml.call(file)
          normalized?(file)
        else
          $stderr.print "#{file} not a YAML file\n"
        end
      end

      def normalized?(file)
        file = relative_path_for(file)
        input = read(file)
        norm = normalize_yaml(input)
        check = input.eql?(norm)

        if check
          $stdout.print "[PASSED] already normalized #{file}\n"
        else
          $stdout.print "[FAILED] normalization suggested for #{file}\n"
        end

        check
      end
    end
  end
end
