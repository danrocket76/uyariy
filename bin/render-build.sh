#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate
bundle exec rake db:seed # <--- TO ANYONE DONT FORGET TO UNCOMMENT THIS ONLY FOR THE FIRST DEPLOY to create the admin user