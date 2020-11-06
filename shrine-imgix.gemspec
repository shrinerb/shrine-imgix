Gem::Specification.new do |gem|
  gem.name          = "shrine-imgix"
  gem.version       = "0.5.2"

  gem.required_ruby_version = ">= 2.1"

  gem.summary      = "Provides Imgix integration for Shrine."
  gem.homepage     = "https://github.com/shrinerb/shrine-imgix"
  gem.authors      = ["Janko Marohnić"]
  gem.email        = ["janko.marohnic@gmail.com"]
  gem.license      = "MIT"

  gem.files        = Dir["README.md", "LICENSE.txt", "lib/**/*.rb", "*.gemspec"]
  gem.require_path = "lib"

  gem.add_dependency "shrine", ">= 2.0", "< 4"
  gem.add_dependency "imgix", ">= 1.2", "< 5"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "mocha"
end
