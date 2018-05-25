# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe YamlNormalizer::Services::Normalize do
  it 'inherits from YamlNormalizer::Services::Base' do
    expect(described_class).to be < YamlNormalizer::Services::Base
  end

  describe '.call' do
    subject { described_class.call(*args) }

    let(:path) { "#{SpecConfig.data_path}#{File::SEPARATOR}" }
    let(:args) { ["#{path}#{file}"] }

    context 'invalid args, no arg matches file' do
      let(:args) { ['lol', :foo, nil] }

      it { is_expected.to eql [] }
      it 'prints a message to stderr if no files match the given arguments' do
        expect { subject }.to output(
          "[\"lol\", :foo, nil] does not match any files\n"
        ).to_stderr
      end
    end

    context 'partially invalid args' do
      subject do
        stderr = $stderr
        $stderr = StringIO.new
        result = described_class.call(*args)
        $stderr = stderr
        result
      end
      let(:args) { ["#{path}*.1", :invalid, "#{path}1.*"] }

      it 'sanitizes list of files before processing' do
        expect(subject).to eql ["#{path}1.1", "#{path}1.2", "#{path}2.1"]
      end
    end

    context 'invalid YAML file' do
      let(:file) { 'invalid.yml' }
      it 'prints "is not a YAML file" message to STDERR' do
        expect { subject }
          .to output("#{path}invalid.yml is not a YAML file\n").to_stderr
      end
    end

    context 'using relative path' do
      it 'processes files with a relative path' do
        Tempfile.open('foo') do |yaml|
          Dir.chdir(Pathname(yaml).dirname)
          expect { described_class.call(Pathname(yaml).basename) }
            .to_not raise_error
        end
      end
    end

    context 'single-document YAML file' do
      let(:file) { 'valid.yml' }
      let(:expected) { 'valid_normalized.yml' }

      it 'normalizes and updates the given yaml file' do
        Tempfile.open(file) do |yaml|
          yaml.write(File.read(path + file))
          yaml.rewind
          expect do
            stderr = $stderr
            $stderr = StringIO.new
            described_class.call(yaml.path)
            $stderr = stderr
          end.to(
            change { File.read(yaml.path) }
            .from(File.read("#{path}#{file}"))
            .to(File.read("#{path}#{expected}"))
          )
        end
      end

      it 'prints out a success message with relative file path' do
        Tempfile.open(file) do |yaml|
          yaml.write(File.read(path + file))
          yaml.rewind
          f_abs = Pathname.new(yaml.path).realpath
          f = f_abs.relative_path_from(Pathname.new(Dir.pwd))
          expect { described_class.call(yaml.path) }
            .to output("[NORMALIZED] #{f}\n").to_stderr
        end
      end
    end

    context 'multi-document YAML file' do
      let(:file) { 'valid2.yml' }

      it 'normalizes the yaml file' do
        Tempfile.open(file) do |yaml|
          yaml.write(File.read(path + file))
          yaml.rewind
          f_abs = Pathname.new(yaml.path).realpath
          f = f_abs.relative_path_from(Pathname.new(Dir.pwd))
          expect { described_class.call(yaml.path) }
            .to output("[NORMALIZED] #{f}\n").to_stderr
        end
      end
    end

    context 'not stable' do
      let(:file) { 'valid.yml' }
      let(:other) { 'valid_normalized.yml' }
      let(:defect) { [{ error: nil }].to_yaml }

      it 'prints out an error to STDERR' do
        Tempfile.open(file) do |yaml|
          yaml.write(File.read(path + file))
          yaml.rewind
          expect_any_instance_of(described_class).to receive(:normalize_yaml)
            .and_return(defect)

          f_abs = Pathname.new(yaml.path).realpath
          f = f_abs.relative_path_from(Pathname.new(Dir.pwd))
          expect { described_class.call(yaml.path) }
            .to output("[ERROR]      Could not normalize #{f}\n")
            .to_stderr
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
