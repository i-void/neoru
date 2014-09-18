require 'selenium-webdriver'
module Neo
  module Selenium
    extend self

    def init
      @driver = nil
      @wait = nil
    end

    def get(link)
      if @driver.nil?
        @driver = ::Selenium::WebDriver.for :chrome
        @wait = ::Selenium::WebDriver::Wait.new timeout: 20
      end

      @driver.get link
    end

    def find(css_directive)
      elem = nil
      @wait.until { elem = @driver.find_element :css, css_directive }
      elem
    end

    def find_all(css_directive)
      elem = nil
      @wait.until { elem = @driver.find_elements :css, css_directive }
      elem
    end

  end
end