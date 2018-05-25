# frozen_string_literal: true

module YamlNormalizer
  module Services
    # The Base Service provides a convenience class method *call* to initialize
    # the Service and call the method *call* with the given arguments as Array
    # on that instance.
    # @example
    #   class Reverse < Base
    #     def call(input)
    #       input.reverse
    #     end
    #   end
    class Base
      # A convenience class method to initialize a Service and call the method
      # *call* with the given arguments as array on that instance.
      # @param *args [Array] arguments to be passed to instance method *call*
      def self.call(*args)
        new.call(*args)
      end

      # When inheriting from Base, do not create an instance of a Service
      # object directly. *new* is a private method.
      private_class_method :new

      # Inherit from Base and implement the method *call*.
      # @example
      #   class IsFile < Base
      #     def call(file)
      #       File.file? file
      #     end
      #   end
      # @param *args [Array<Object>] arguments
      # @raise [NotImplementedError] if *call* is not implemented
      def call(*args)
        raise NotImplementedError, args
      end
    end
  end
end
