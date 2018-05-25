# frozen_string_literal: true

module YamlNormalizer
  module Ext
    # *YamlNormalizer::Ext::SortByKey* extends an instance of *Hash* to provide
    # the additional public helper methods *sort_by_key*.
    # The approach of extending Hash instances avoids monkey-patching a Ruby
    # Core class and using refinements.
    module SortByKey
      # Provides a *Proc* for a functional programming approach. It allows to
      # pass *SortByKey* as block argument using ampersand syntax.
      # @example
      #   hash = { b: { z: 20, x: 10, y: { b: 1, a: 2 } }, a: nil }
      #   YamlNormalizer::Ext::SortByKey.to_proc.call(hash)
      #   => {:a=>nil, :b=>{:x=>10, :y=>{:a=>2, :b=>1}, :z=>20}}
      #
      #   hashes = [{ b: { z: 20, x: 10 } }, {y: { b: 1, a: 2 }, a: nil }]
      #   hashes.map(&YamlNormalizer::Ext::SortByKey)
      #   => [{:b=>{:x=>10, :z=>20}}, {:a=>nil, :y=>{:a=>2, :b=>1}}]
      #
      # @return [Proc] a function to be used
      def self.to_proc
        ->(hash) { hash.extend(self).sort_by_key }
      end

      # Sorts entries alphabetically by key and returns a new *Hash*.
      # *sort_by_key* does not modify the instance of *Hash* it's called on.
      # @example
      #   hash = { b: { z: 20, x: 10, y: { b: 1, a: 2 } }, a: nil }
      #   hash.extend(YamlNormalizer::Ext::SortByKey)
      #   hash.sort_by_key
      #   => {:a=>nil, :b=>{:x=>10, :y=>{:a=>2, :b=>1}, :z=>20}}
      # @param recursive [Boolean] defines if sort_by_key is called on child
      #   nodes, defaults to true
      def sort_by_key(recursive = true)
        keys.sort_by(&:to_s).each_with_object({}) do |key, seed|
          value = seed[key] = fetch(key)
          if recursive && value.instance_of?(Hash)
            seed[key] = value.extend(SortByKey).sort_by_key
          end
        end
      end
    end
  end
end
