require "pry"
desc "Starts the application server on port 4567"
task :server do
  exec "ruby app.rb"
end

desc "Imports summer departures"
task :import do
  exec "./bin/import ljetni"
end

require "rake/testtask"
Rake::TestTask.new do |t|
    t.pattern = "test/*.rb"
end

task :default => :test

namespace :sass do
  desc "compile sass to css"
  task :compile do
    check_node_sass_present do
      exec "node-sass public/sass/style.scss public/style.css"
    end
  end

  desc "observe sass changes and compile on the fly"
  task :watch do
    check_node_sass_present do
      exec "node-sass public/sass/style.scss --watch public/style.css"
    end
  end
end

def check_node_sass_present
  yield
rescue => ex
  if ex.message =~ /No such file or directory - node-sass/
    puts
    puts "You don't have node-sass installed, install it with:"
    puts "    npm install -g node-sass"
    puts
  else
    raise ex
  end
end