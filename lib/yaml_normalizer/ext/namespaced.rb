# frozen_string_literal: true

module YamlNormalizer
  module Ext
    # *YamlNormalizer::Ext::Namespaced* extends instances of *Hash* to provide
    # the additional public helper method *namespaced*.
    # The approach of extending Hash instances avoids monkey-patching a Ruby
    # Core class and using refinements.
    module Namespaced
      # Provides a *Proc* for a functional programming approach. It allows to
      # pass *Namespaced* as block argument using ampersand syntax.
      # @example
      #   hash = {a: {b: {c: 1}}, b:{x: 2, y: {ok: true}, z: 4}}
      #   YamlNormalizer::Ext::Namespaced.to_proc.call(hash)
      #   => {"a.b.c"=>1, "b.x"=>2, "b.y.ok"=>true, "b.z"=>4}
      #
      #   hashes = [{a: {b: {c: 1}}}, {b:{x: 2, y: {ok: true}, z: 4}}]
      #   hashes.map(&YamlNormalizer::Ext::Namespaced)
      #   => [{"a.b.c"=>1}, {"b.x"=>2, "b.y.ok"=>true, "b.z"=>4}]
      #
      # @return [Proc] a function to be used
      def self.to_proc
        ->(hash) { hash.extend(self).namespaced }
      end

      # Transforms a tree-shaped *Hash* into a flat key-value pair *Hash*,
      # separating tree levels with a dot.
      # *namespaced* does not modify the  instance of *Hash* it's called on.
      # @example
      #   hash = {a: {b: {c: 1}}, b:{x: 2, y: {ok: true}, z: 4}}
      #   hash.extend(YamlNormalizer::Ext::Namespaced)
      #   hash.namespaced
      #   => {"a.b.c"=>1, "b.x"=>2, "b.y.ok"=>true, "b.z"=>4}
      #
      # @param namespace [Array] the namespace cache for the current namespace,
      #   used on recursive tree traversal1
      #
      # @param tree [Hash] the accumulator object being build while recursive
      #   traversing the original tree-shaped Hash
      #
      # @return [Hash] flat key-value pair Hash
      def namespaced(namespace = [], tree = {})
        each do |key, value|
          child_ns = namespace.dup << key
          if value.instance_of?(Hash)
            value.extend(Namespaced).namespaced child_ns, tree
          else
            tree[child_ns.join('.')] = value
          end
        end
        tree
      end
    end
  end
end
