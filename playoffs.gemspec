# frozen_string_literal: true

require './lib/playoffs/version'

Gem::Specification.new do |s|
  s.name        = 'playoffs'
  s.version     = Playoffs::VERSION
  s.summary     = 'Underlying data structures to power a bracket-style tournament of teams/competitors.'

  s.description = <<~DESC
    I was looking to create a turn-based sports game which, inevitably, would include a playoffs simulator.
    This library provides a few, easy-to-use APIs to create, simulate, and complete a team & series-based tournament with one clear winner.
  DESC

  s.authors     = ['Matthew Ruggio']
  s.email       = ['mattruggio@icloud.com']
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir      = 'exe'
  s.executables = %w[playoffs]
  s.homepage    = 'https://github.com/mattruggio/playoffs'
  s.license     = 'MIT'
  s.metadata    = {
    'bug_tracker_uri' => 'https://github.com/mattruggio/playoffs/issues',
    'changelog_uri' => 'https://github.com/mattruggio/playoffs/blob/main/CHANGELOG.md',
    'documentation_uri' => 'https://www.rubydoc.info/gems/playoffs',
    'homepage_uri' => s.homepage,
    'source_code_uri' => s.homepage,
    'rubygems_mfa_required' => 'true'
  }

  s.required_ruby_version = '>= 2.7.6'

  s.add_runtime_dependency('primitive')
  s.add_runtime_dependency('sorbet-runtime')

  s.add_development_dependency('bundler-audit')
  s.add_development_dependency('guard-rspec')
  s.add_development_dependency('pry')
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rubocop')
  s.add_development_dependency('rubocop-rake')
  s.add_development_dependency('rubocop-rspec')
  s.add_development_dependency('rubocop-sorbet')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('simplecov-console')
  s.add_development_dependency('sorbet')
  s.add_development_dependency('tapioca')
end
