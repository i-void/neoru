require 'selenium-webdriver'
module Neo
  module Selenium

    def init
      @driver = nil
      @wait = nil
    end

    def get(link)
      if @driver.nil?
	      caps = ::Selenium::WebDriver::Remote::Capabilities.chrome('chromeOptions' => {
			      'args' => %w(test-type disable-popup-blocking)
	      })
        @driver = ::Selenium::WebDriver.for :chrome,desired_capabilities: caps
        @wait = ::Selenium::WebDriver::Wait.new timeout: 20
      end

      @driver.get link
    end

    def maximize
	    @driver.manage.window.maximize
    end

    def find(css_directive)
      elem = nil
      @wait.until { elem = @driver.find_element :css, css_directive }
      elem
    end

    def find_all(css_directive)
      elem = nil
      @wait.until {
	      elem = @driver.find_elements :css, css_directive
	      elem.length > 0
      }
      elem
    end

    def page_contains?(text)
	    source.include? text
    end

    def save_screen(file_name)
	    @driver.save_screenshot(file_name)
    end

    def source
	    @driver.page_source
    end

    def url
	    @driver.current_url
    end

    def navigate_to(direction)
	    if direction == :back
		    @driver.navigate.back
	    elsif direction == :forward
		    @driver.navigate.forward
	    elsif direction == :refresh
		    @driver.navigate.refresh
	    else
		    @driver.navigate.to direction
	    end
    end

    def switch_to(window)
			if window == :last
				@driver.switch_to.window get_tab_list.last
			else
				@driver.switch_to.window window
			end
    end

    def handle
	    @driver.window_handle
    end

		def get_tab_list
			@driver.window_handles
		end

		def new_tab(url=nil)
			@driver.execute_script "window.open('#{url}')"
		end

		def close_tab(tab_handle)
			current_tab = handle
			if tab_handle == :last
				switch_to :last
				tab_handle = handle
			else
				switch_to tab_handle
			end
			is_self = (current_tab == tab_handle)
			@driver.close
			if is_self
				switch_to :last
			else
				switch_to current_tab
			end
		end

		def ctrl_click(clickable_element)
			@driver.action.key_down(:control).
					click(clickable_element).
					key_up(:control).
					perform
		end

	  make_modular
  end
end