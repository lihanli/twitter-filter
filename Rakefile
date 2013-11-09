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

  Listen.to('src') do |modified, added, removed|
    %w(modified added removed).each do |type|
      eval(type).each do |file|
        if file.match(/.scss$/)
          build_css
        else
          build_js
        end
      end
    end
  end.start

  sleep 10 while true
end

Rake::TestTask.new('test') do |t|
  t.libs << "test"
  t.test_files = FileList['test/tests/**/*.rb']
end
