# frozen_string_literal: true

module YamlNormalizer
  module Ext
    # *YamlNormalizer::Ext::Nested* extends instances of *Hash* to provide the
    # additional public helper method *nested*.
    # The approach of extending Hash instances avoids monkey-patching a Ruby
    # Core class and using refinements.
    module Nested
      # Provides a *Proc* for a functional programming approach. It allows to
      # pass *Nested* as block argument using ampersand syntax.
      # @example
      #   hash = {'a.b.c' => 1, 'b.x' => 2, 'b.y.ok' => true, 'b.z' => 4}
      #   YamlNormalizer::Ext::Nested.to_proc.call(hash)
      #   => {"a"=>{"b"=>{"c"=>1}}, "b"=>{"x"=>2, "y"=>{"ok"=>true}, "z"=>4}}
      #
      #   hashes = [{'a.b.c' => 1}, {'b.x' => 2, 'b.y.ok' => true}]
      #   hashes.map(&YamlNormalizer::Ext::Nested)
      #   => [{"a"=>{"b"=>{"c"=>1}}}, {"b"=>{"x"=>2, "y"=>{"ok"=>true}}}]
      #
      # @return [Proc] a function to be used
      def self.to_proc
        ->(hash) { hash.extend(self).nested }
      end

      # Transforms a flat key-value pair *Hash* into a tree-shaped *Hash*,
      # assuming tree levels are separated by a dot.
      # *nested* does not modify the instance of *Hash* it's called on.
      # @example
      #   hash = {'a.b.c' => 1, 'b.x' => 2, 'b.y.ok' => true, 'b.z' => 4}
      #   hash.extend(YamlNormalizer::Ext::Nested)
      #   hash.nested
      #   => {"a"=>{"b"=>{"c"=>1}}, "b"=>{"x"=>2, "y"=>{"ok"=>true}, "z"=>4}}
      #
      # @return [Hash] tree-shaped Hash
      def nested
        tree = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
        each { |key, val| nest_key(tree, key.to_s, val) }
        tree.default_proc = nil
        tree
      end

      private

      def nest_key(hash, key, val)
        if key.include?('.')
          keys = key.split('.')
          hash.dig(*keys[0..-2])[keys.fetch(-1)] = val
        else
          hash[key] = val
        end
      end
    end
  end
end
