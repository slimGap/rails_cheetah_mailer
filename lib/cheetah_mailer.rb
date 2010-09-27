require 'curb'
require 'cgi'
module CheetahMailer
  
    #####################################################################################
    # ActionMailer Hook
    #####################################################################################
    def self.included( base )
      base.__send__( :adv_attr_accessor, :eid )
      base.__send__( :adv_attr_accessor, :aid )
    end

    def perform_delivery_cheetah(mail)
      options = {:subject => mail.subject, :body => mail.body}
      options[:eid]= @eid if @eid
      options[:aid]= @aid if @aid
    
      CheetahMail.new.send( mail.destinations, options)
      logger.info( "Mail Sent with CheetahMail EID: #{@eid || 'default'}" ) if logger
    end
    alias_method :perform_delivery_cheetahmail, :perform_delivery_cheetah
  


  class CheetahMail

    #####################################################################################
    # Create API Connection
    #####################################################################################    
    @@config = YAML::load(File.open("#{RAILS_ROOT}/config/cheetah_mailer.yml"))

    attr_accessor :connection
  
    # Establishes an API connection [authentication, session-cookie]
    def initialize
      login_url = "https://trig.em.visa.com/api/login1?name=#{@@config[:login][:username]}&cleartext=#{@@config[:login][:password]}"
      @connection = Curl::Easy.new(login_url)
      @connection.enable_cookies = true
      @connection.connect_timeout = 10 #seconds to connect with CheetahMail
      @connection.perform
      raise "CheetahMail Authentication Error -- Responce: #{@connection.body_str}"   unless @connection.body_str.match(/\s*OK\s*/)
      raise "CheetahMail Server Error -- Responce Code #{@connection.response_code}"  unless @connection.response_code==200 
    end


    #####################################################################################
    # Send API Request
    #####################################################################################  

    # Builds and sends the request via POST
    def send(email, options={})
      options = {
        :subject => '',
        :body    => '',
        :html    => 1,
        :eid     => @@config[:defaults][:eid], 
        :aid     => @@config[:defaults][:aid],
        :test    => @@config[:defaults][:test]
      }.merge(options)
      # Check APIebmtrigger documentation for full list of optional paramiters
      
      params = [
      Curl::PostField.content('email', email),
      Curl::PostField.content('eid', options.delete(:eid)),
      Curl::PostField.content('SUBJECT_LINE', options.delete(:subject)),
      Curl::PostField.content('CONTENT', CGI.escape(options.delete(:body))),
      Curl::PostField.content("HTML", options.delete(:html).to_s ) ]
      options.each { |k, v| params << Curl::PostField.content(k.to_s, v) }
      
      # connection.verbose = true # for debugging
      connection.url = "https://trig.em.visa.com/ebm/ebmtrigger1"
      connection.http_post("https://trig.em.visa.com/ebm/ebmtrigger1", params )
      
      # return    
      connection.body_str.match(/\s*OK\s*/) ? true : #or
              connection.response_code==200 ? raise( "API Error - #{connection.body_str}") : #or
                                              raise( "Server Error - Responce Code #{@connection.response_code}" )
    end

  end # class
end # module
