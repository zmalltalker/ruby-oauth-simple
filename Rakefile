require 'rake/testtask'
require 'hoe'
require 'lib/oauth-simple'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

Hoe.new('oauth-simple', OAuthSimple::VERSION) do |h|
  h.author = ['Marius Mathiesen']
  h.email = 'marius.mathiesen@gmail.com'
  h.description = 'Simple OAuth implementation'
  h.summary = h.description
  h.rubyforge_name = h.name
  h.url = 'http://oauth-simple.rubyforge.org/'
  if RUBY_VERSION < '1.9'
    h.extra_deps << [
      ['ruby-hmac', '>= 0.3.1']
    ]
  end
end

task :default => [:test]