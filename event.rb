class Neo::Event
  @events = {}
  class << self
    # registers an event named <label>
    # if you want to unregister an event later, define an <identifier>
    def register(label, identifier, &block)
      @events[label] = {} if @events[label].nil?
      @events[label][identifier] = block
    end

    # unregister an event named <label> and identified by <identifier>
    def unregister(label, identifier)
      @events[label].delete(identifier) unless @events[label].nil? && @events[label][identifier].nil?
    end

    # deletes an entire event named <label>
    def delete(label)
      @events.delete(label) unless @events[label].nil?
    end

    # trigger an event named <label>
    def trigger(label)
      @events[label] = {} if @events[label].nil?
      @events[label].each_value do |block|
        block.call
      end
    end

    # clear all events
    def clear
      @events = {}
    end
  end
end