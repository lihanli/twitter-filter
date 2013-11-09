require 'rake/testtask'

def compile_coffee(name, append = false)
  `node_modules/.bin/coffee -p -c src/js/#{name}.coffee #{append ? '>>' : '>'} dist/js/#{name}.js`
end

def compile_scss(name)
  `sass -r sass-css-importer src/css/#{name}.scss dist/css/#{name}.css`
end

def build_js
  %w(background inject).each do |file|
    compile_coffee(file)
  end
  puts 'js built'
end

def build_css
  compile_scss('inject')
  puts 'css built'
end

task :build do
  build_js
  build_css
end

task watch: [:build] do
  require 'listen'

  %w(css js).each do |type|
    Listen.to("src/#{type}") do |modified, added, removed|
      send("build_#{type}")
    end.start
  end

  sleep 10 while true
end

Rake::TestTask.new('test') do |t|
  t.libs << "test"
  t.test_files = FileList['test/tests/**/*.rb']
end
