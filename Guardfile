# More info at https://github.com/guard/guard#readme

guard 'bundler' do
  watch('Gemfile')
end

guard 'rspec' do
  watch(%r{^(lib|spec)/.+\.rb$})
end

guard 'shell' do
  watch(%r{^public/javascripts/(.+\.coffee)$}) { `coffee -c public/javascripts/$1` }
  watch(%r{^public/examples/(.+\.coffee)$}) { `coffee -b -c public/examples/$1` }
end

guard 'livereload' do
  watch(%r{.+\.js})
  watch(%r{.+\.erb})
  watch(%r{public/examples/go/.+})
end

guard 'jasmine-headless-webkit', :jasmine_config => 'public/javascripts/spec/jasmine.yml' do
  #watch(%r{^public/javascripts/(.*)\..*}) { |m| newest_js_file("public/javascripts/spec/#{m[1]}_spec") }
  watch(%r{^public/javascripts/(.*)\.coffee}) { |m| "public/javascripts/spec/#{m[1]}_spec" }
end

guard 'sass', :input => 'public/examples/go'

