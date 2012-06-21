require 'rubygems'
require 'rake'

Gem::Specification.new do |s|
  s.name        = 'phantom_proxy'
  s.version     = '1.2.3'
  s.summary     = "This is a phantomjs Proxy"
  s.description = "This is a phyntonjs Proxy it allows you to fetch webpages and execute javascript in them."
  s.authors     = ["Daniel Sudmann"]
  s.email       = 'suddani@googlemail.com'
  s.files       = FileList['lib/**/*.rb',
  										'lib/**/*.js',
                      'lib/**/**/*.ru',
                      'lib/**/**/*.html',
                      'lib/**/**/*',
                      'lib/**/**/**/*',
                      'bin/*',
                      '[A-Z]*',
                      'test/**/*'].to_a
  s.homepage    = 'http://experteer.com'
  s.executables = ['phantom_proxy']
  s.add_dependency('thin', '>= 1.3.1')
  s.add_dependency('ruby-hmac', '>= 0.4.0')
end
