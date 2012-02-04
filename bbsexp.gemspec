Gem::Specification.new do |s|
  s.name = 'bbsexp'
  s.version = '0.2.1'
  s.platform = Gem::Platform::RUBY
  s.authors = ['tca']
  s.summary = 'Concise BBcode Framework'
  s.description = s.summary
  s.homepage = "https://github.com/tca/bbsexp"

  s.required_ruby_version = '>=1.9.2'

  s.files = Dir["LICENSE", "README.md", "lib/**/*"]
  s.require_paths = ['lib']
end
