require 'mail'

module Neo
  class Mail
    def initialize
      ::Mail.defaults do
        delivery_method :smtp, Neo::Config[:mail][:defaults] unless Neo::Config[:mail].nil?
      end
    end
  end
end