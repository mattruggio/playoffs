# typed: false
# frozen_string_literal: true

require 'pry'
require 'securerandom'

unless ENV['DISABLE_SIMPLECOV'] == 'true'
  require 'simplecov'
  require 'simplecov-console'

  SimpleCov.formatter = SimpleCov::Formatter::Console
  SimpleCov.start do
    add_filter %r{\A/spec/}
  end
end

def fixture_path(*)
  File.join('spec', 'fixtures', *)
end

def read_fixture(*)
  read(fixture_path(*))
end

def read(path)
  File.read(path)
end

TEMP_DIR = File.join('tmp', 'spec')

RSpec.configure do |config|
  config.before(:suite) do
    FileUtils.rm_rf(TEMP_DIR)
  end

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

require 'rspec/expectations'
require 'sorbet-runtime'
require './lib/playoffs'
