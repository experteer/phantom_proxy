require 'rubygems'

Gem::Specification.new do |s|
  s.name        = 'phantom_proxy'
  s.version     = '1.2.16'
  s.summary     = "This is a phantomjs Proxy"
  s.description = "This is a phyntonjs Proxy it allows you to fetch webpages and execute javascript in them."
  s.authors     = ["Daniel Sudmann"]
  s.email       = 'suddani@googlemail.com'
  s.files       = `git ls-files`.split($\)
=begin
                  FileList['lib/**/*.rb',
  										'lib/**/*.js',
                      'lib/**/**/*.ru',
                      'lib/**/**/*.html',
                      'lib/**/**/*',
                      'lib/**/**/**/*',
                      'lib/phantom_proxy/install/**/*',
                      'lib/phantom_proxy/install/**/**/*',
                      'bin/*',
                      '[A-Z]*',
                      'test/**/*'].to_a
=end
  s.homepage    = 'http://experteer.com'
  s.executables = ['phantom_proxy']
  s.add_dependency('thin', '>= 1.3.1')
  s.add_dependency('ruby-hmac', '>= 0.4.0')
end
