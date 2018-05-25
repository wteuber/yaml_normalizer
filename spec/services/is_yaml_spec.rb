# frozen_string_literal: true

require 'spec_helper'

RSpec.describe YamlNormalizer::Services::IsYaml do
  it 'inherits from YamlNormalizer::Services::Base' do
    expect(described_class).to be < YamlNormalizer::Services::Base
  end

  describe '#call' do
    subject { described_class.call(file) }

    let(:path) { "#{SpecConfig.data_path}#{File::SEPARATOR}" }

    context 'not a string, not a file' do
      let(:file) { :does_not_exist }
      it { is_expected.to eql false }
    end

    context 'invalid YAML file' do
      let(:file) { "#{path}invalid.yml" }
      it { is_expected.to eql false }
    end

    context 'scalar YAML file' do
      let(:file) { "#{path}scalar.yml" }
      it { is_expected.to eql false }
    end

    context 'valid YAML file' do
      let(:file) { "#{path}valid.yml" }
      it { is_expected.to eql true }
    end
  end
end
