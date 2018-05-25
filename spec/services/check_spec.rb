# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe YamlNormalizer::Services::Check do
  it 'inherits from YamlNormalizer::Services::Base' do
    expect(described_class).to be < YamlNormalizer::Services::Base
  end

  describe '.call' do
    let(:path) { "#{SpecConfig.data_path}#{File::SEPARATOR}" }

    subject { described_class.call(*args) }
    let(:args) { ["#{path}#{name}"] }

    context 'only invalid globbing inputs' do
      let(:args) { ['lol', :foo, nil] }
      it { is_expected.to eql(true) }
    end

    context 'partially invalid globbing inputs' do
      let(:args) { ["#{path}*.1", :invalid, "#{path}1.*"] }
      let(:expected) { ["#{path}2.1", "#{path}1.1", "#{path}1.2"] }
      let(:match_lines) do
        lines = expected.map do |file|
          f_abs = Pathname.new(file).realpath
          f = f_abs.relative_path_from(Pathname.new(Dir.pwd))
          "[PASSED] already normalized #{f}"
        end
        all = lines.permutation.map { |perm| Regexp.quote(perm.join("\n")) }
        Regexp.new('\A(' + all.join(')|(') + ')\n\z')
      end

      it 'sanitizes list of files before processing' do
        expect { described_class.call(*args) }.to output(match_lines).to_stdout
      end
    end

    context 'invalid YAML file' do
      let(:name) { 'invalid.yml' }

      it { is_expected.to eql(false) }

      it 'prints "not a YAML file" message to STDERR' do
        expect { subject }
          .to output("#{path}#{name} not a YAML file\n").to_stderr
      end
    end

    context 'file handling' do
      let(:data) { { path: nil } }
      let(:file) { data[:path] }
      let(:args) { file.path }

      around :example do |example|
        Tempfile.open(name) do |yaml|
          yaml.write(File.read(path + name))
          yaml.rewind
          data[:path] = yaml
          example.run
        end
      end

      context 'single-document YAML file' do
        context 'denormalized YAML file' do
          let(:name) { 'valid.yml' }

          it { is_expected.to eql(false) }

          it 'prints out an error message with relative file path' do
            f_abs = Pathname.new(file.path).realpath
            f = f_abs.relative_path_from(Pathname.new(Dir.pwd))
            expect { subject }
              .to output("[FAILED] normalization suggested for #{f}\n")
              .to_stdout
          end
        end

        context 'normalized YAML file' do
          let(:name) { 'valid_normalized.yml' }

          it { is_expected.to eql(true) }

          it 'prints out a success message with relative file path' do
            f_abs = Pathname.new(file.path).realpath
            f = f_abs.relative_path_from(Pathname.new(Dir.pwd))
            expect { subject }
              .to output("[PASSED] already normalized #{f}\n").to_stdout
          end
        end
      end

      context 'multi-document YAML file' do
        let(:name) { 'valid2_normalized.yml' }

        it 'passes if YAML file is already normalized' do
          f_abs = Pathname.new(file.path).realpath
          f = f_abs.relative_path_from(Pathname.new(Dir.pwd))
          expect { subject }
            .to output("[PASSED] already normalized #{f}\n").to_stdout
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
