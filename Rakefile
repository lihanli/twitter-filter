require 'rake/testtask'

def compile_scss(name)
  `sass -r sass-css-importer src/css/#{name}.scss dist/css/#{name}.css`
end

def build_js
  `node_modules/.bin/coffee -o dist/js -c src/js`
  puts 'js built'
end

def build_css
  compile_scss('inject')
  compile_scss('options')
  puts 'css built'
end

task :build do
  build_js
  build_css
end

task :dist do
  system('rm build.zip')
  system('zip -r build.zip . -x ./src/**\* ./.sass-cache/**\* ./.git/**\* ./test/**\* ./node_modules/**\*')
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
