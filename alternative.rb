# alternative.rb
# Rails application template with
# Git + Haml + Machinist + Faker + Flexmock + Rspec + Blueprint-css.

gem 'haml'
gem 'machinist'
gem 'faker'
gem 'flexmock'
rake "gems:install", :sudo => true
rake "gems:unpack"

run "haml --rails ."

plugin 'rspec',  :git => 'git://github.com/dchelimsky/rspec.git'
plugin 'rspec-rails', :git => 'git://github.com/dchelimsky/rspec-rails.git'
generate 'rspec'
run "rm -rf test/"

file ".gitignore", <<-END
.DS_Store
log/*.log
tmp/**/*
db/*.sqlite3
END

file "spec/blueprints.rb", <<-END
require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.define do
  # title { Faker::Lorem.words(5).join(' ') }
end

# Post.blueprint do
#  title  { Sham.title }
# end

END

file "app/views/layouts/application.html.haml", <<-END
!!! XML
!!! Strict
%html
  %head
    %title New application
    = stylesheet_link_tag 'application'
    = stylesheet_link_tag 'blueprint/screen.css', :media => 'screen, projection'
    = stylesheet_link_tag 'blueprint/print.css', :media => 'print'
    /[if IE]
      = stylesheet_link_tag 'blueprint/ie.css', :media => 'screen, projection'
  %body
    %div.container
      %div#main.span-24.last.showgrid
        = yield
END

spec_helper = File.read('spec/spec_helper.rb')
spec_helper.sub!('  # config.mock_with :flexmock', '  config.mock_with :flexmock')
spec_helper.sub!("require 'spec/rails'\n", 
                 "require 'spec/rails'\nrequire File.expand_path(File.dirname(__FILE__) + '/blueprints')\n")
File.open('spec/spec_helper.rb', 'w').write(spec_helper)

run "touch tmp/.gitignore log/.gitignore"

git :init
git :submodule => 'add git://github.com/joshuaclayton/blueprint-css.git blueprint-css'

inside "public/stylesheets" do
  run "ln -s ../../blueprint-css/blueprint ."
end

git :add => ".", :commit => "-m 'initial commit'"
