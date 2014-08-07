require 'mail'

module Neo
  class Mail
    def initialize
      ::Mail.defaults do
        delivery_method :smtp, Neo::Config.main[:mail][:defaults]
      end
    end
  end
end