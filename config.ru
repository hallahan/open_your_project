# $stdout.sync = true  # makes "normal" debugging statements show up in heroku's logs: https://devcenter.heroku.com/articles/ruby#logging

require ::File.expand_path('../config/environment',  __FILE__)
run OpenYourProject::Application
