##CheetahMailer
The CheetahMailer plugin is an ActionMailer adapter for sending email through Experian CheetahMail.  
Currently, this plugin does not work with Rails-3.x. Out-of-the-box, this plugin sends CheetahMail the following content paramiters: SUBJECT_LINE and CONTENT. You can easily add your own parameters if you decide to build emails through Cheetah's interface.


###Basic Usage
1. Configure your authentication information in config/cheetah_mailer.yml

2. Configure your environment to deliver mail using the CheetahMail plugin.<br/>
<code>ActionMailer::Base.delivery_method = :cheetah</code>

3. Use ActionMailer normally.



###Setting CheetahMail AID or EID*
*The CheetahMail API requires an Event ID (eid) which usually corresponds to a single CheetahMail template.

CheetahMailer allows you to set a default eid [config/cheetah_mailer.yml] that will be used if no eid is specified.  We recommend this be a blank (or branded) 'passthrough' template that allows you to pass email content to CheetahMail's <code>%%CONTENT%%</code> hook.

To trigger a specific event, by passing the eid to an ActionMailer method
<code>
	def welcome_email(user)
	   subject "Welcome to Example Dot Com"
	   from "noreply@example.com"
	   recipients user.email
	   sent_on Time.now
	   body :user => user
	   content_type "text/html"
	   eid '111111'  #<<<<<<<<<<<<<<<<<<<<<
	   aid '111111'  #<<<<<<<<<<<<<<<<<<<<<
	end
</code>



###Alternative Usage
You can also send mail using just the CheetahMail the module.<br />
<code>CheetahMail.new.send('john.doe@example.com', :eid => '103269', :aid => '9430385370', :subject => "Cheetah Test #{Time.now}"), :body => "test"</code>


###Credits
Colin Lauver: Created the initial CheetahMail module <br />
Chip Miller : Created plugin

Copyright (c) 2010 [Chip Miller], released under the MIT license
