# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe YamlNormalizer::Ext::SortByKey do
  context 'extended Hash instances with "sort_by_key"' do
    subject { hash.extend(described_class).sort_by_key(recursive) }
    let(:recursive) { true }
    let(:hash) { { b: { z: 20, x: 10, y: { b: 1, a: 2 } }, a: nil } }
    let(:expected) { { a: nil, b: { x: 10, y: { a: 2, b: 1 }, z: 20 } } }

    it 'does not modify the original object' do
      expect { subject }.to_not(change { hash })
    end

    context 'keys of different types' do
      let(:hash) { { 1 => nil, 'two': :ok, false => {} } }
      let(:expected) { { 1 => nil, false => {}, 'two': :ok } }
      it 'sorts objects by their String representation' do
        expect(subject.inspect).to eql(expected.inspect)
      end
    end

    context 'first level only' do
      let(:recursive) { false }
      let(:expected) { { a: nil, b: { z: 20, x: 10, y: { b: 1, a: 2 } } } }

      it 'sorts first level keys only' do
        expect(subject.inspect).to eql(expected.inspect)
      end
    end

    context 'recursive' do
      it 'sorts keys of all levels' do
        expect(subject.inspect).to eql(expected.inspect)
      end
    end
  end

  describe '.to_proc' do
    subject { described_class.to_proc.call(hash) }
    let(:hash) { { 'b.z' => 20, 'b.x' => 10, 'a' => nil } }
    let(:expected) { { 'a' => nil, 'b.x' => 10, 'b.z' => 20 } }

    it 'provides a function that extends a hash and calls "sort_by_key"' do
      expect(subject.inspect).to eql(expected.inspect)
    end
  end

  it 'does not modify Ruby Core class Hash' do
    expect { {}.sort_by_key }.to raise_error(NoMethodError)
  end
end
# rubocop:enable Metrics/BlockLength
