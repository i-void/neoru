require 'mail'

module Neo
  class Mail
    def initialize
      ::Mail.defaults do
        delivery_method :smtp, Neo::Config.main[:mail][:defaults] unless Neo::Config.main[:mail].nil?
      end
    end
  end
end