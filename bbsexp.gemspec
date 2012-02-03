Gem::Specification.new do |s|
  s.name = 'bbsexp'
  s.version = '0.2.0'
  s.platform = Gem::Platform::RUBY
  s.authors = ['tca']
  s.summary = 'Custom BBcode Framework'
  s.description = s.summary

  s.required_ruby_version = '>=1.9.2'

  s.files = Dir["**/*"].reject {|f| File.directory?(f) }
  s.require_paths = ['lib']
end
