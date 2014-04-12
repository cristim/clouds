# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','clouds','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'clouds'
  s.version = Clouds::VERSION
  s.author = 'Cristian Magherusan-Stanciu'
  s.email = 'cristian.magherusan-stanciu@here.com'
  s.homepage = 'http://here.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A layer of syntax sugar around the AWS Cloudformation API that allows you to handle Cloudformation-defined infrastructure as code with a simple tool'
# Add your other files here if you make them
  s.files = %w(
bin/clouds
lib/clouds/version.rb
lib/clouds.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md','clouds.rdoc']
  s.rdoc_options << '--title' << 'clouds' << '--main' << 'README.md' << '-ri'
  s.bindir = 'bin'
  s.executables << 'clouds'

  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_development_dependency('nokogiri')

  s.add_runtime_dependency('gli')
  s.add_runtime_dependency('aws-sdk')
  s.add_runtime_dependency('inifile')
end
