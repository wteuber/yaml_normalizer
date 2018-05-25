# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe YamlNormalizer::Services::Base do
  let(:child) { Class.new(described_class) { define_method(:call) { |*_| } } }
  let(:dummy) { double('Child', call: nil) }
  let(:args) { [:foo, 'bar', 842, [], {}].sample(rand(1..5)) }

  describe '.new' do
    subject { child.new }
    it { expect { subject }.to raise_error(NoMethodError) }
  end

  describe '.call' do
    subject { child.call(*args) }

    context 'when #call is not implemented' do
      subject { described_class.call(*args) }

      it 'accepts arbitrary parameters' do
        expect { subject }.to raise_error(NotImplementedError)
          .with_message(args.inspect)
      end

      it 'calls instance method "call" with args' do
        expect_any_instance_of(described_class).to receive(:call).with(*args)
        subject
      end
    end

    it 'instantiates child class without arguments' do
      expect(child).to receive(:new).with(no_args).and_return(dummy)
      subject
    end

    it 'calls instance method "call" with args' do
      expect_any_instance_of(child).to receive(:call).with(*args)
      subject
    end
  end
end
# rubocop:enable Metrics/BlockLength
