require_relative 'lib/mergetrain_check/version'

Gem::Specification.new do |spec|
  spec.name = "Gitlab-mergetrain-checker"
  spec.version = MergetrainCheck::VERSION
  spec.date = %q{2020-04-29}
  spec.authors = ["Fabio Gallonetto"]
  spec.email = 'fabio.gallonetto@curve.com'
  spec.summary = %q{A command line tool to check the status of a merge train in gitlab}
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'ruby-keychain', '~> 0.3.2'
end
