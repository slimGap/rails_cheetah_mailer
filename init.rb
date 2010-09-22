require 'cheetah_mailer'
ActionMailer::Base.send(:include, CheetahMailer)