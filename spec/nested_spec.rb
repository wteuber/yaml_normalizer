# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe YamlNormalizer::Ext::Nested do
  context 'extended Hash instances with "nested"' do
    subject { hash.extend(described_class).nested }
    let(:hash) do
      { 'a.b.c' => 1, 'b.x' => 2,
        'b.y.one' => true,
        'b.y.two' => nil,
        'no_dot' => 'ok',
        3 => String,
        sym: 'ok' }
    end

    it 'does not modify the original object' do
      expect { subject }.to_not(change { hash })
    end

    it 'converts a Hash from a flat key-value pairs to a tree structure' do
      expect(subject).to eql('a' => { 'b' => { 'c' => 1 } },
                             'b' => { 'x' => 2,
                                      'y' => { 'one' => true, 'two' => nil } },
                             'no_dot' => 'ok',
                             '3' => String,
                             'sym' => 'ok')
    end

    it 'resets the default_proc' do
      expect(subject[:unknown]).to be_nil
    end
  end

  describe '.to_proc' do
    subject { described_class.to_proc.call(hash) }
    let(:hash) { { 'a.b.c' => 1, 'b.x' => 2, 'b.y.ok' => true, 'b.z' => 4 } }
    let(:expected) do
      { 'a' => { 'b' => { 'c' => 1 } },
        'b' => { 'x' => 2,
                 'y' => { 'ok' => true },
                 'z' => 4 } }
    end

    it 'provides a function that extends a hash and calls "nested"' do
      expect(subject.inspect).to eql(expected.inspect)
    end
  end

  it 'does not modify Ruby Core class Hash' do
    expect { {}.nested }.to raise_error(NoMethodError)
  end
end
# rubocop:enable Metrics/BlockLength
