module Utils
  class Fifo
    attr_accessor :len, :dup, :container

    def initialize(container, options={})
      @len = options[:len] || 10    # max length of container
      @dup = options[:dup]          # has duplicated element in container
      @container = container || []
    end

    def push(ele)
      @container.delete(ele) unless @dup
      @container << ele
      if @container.length > @len
        @container = @container[@container.length - @len, @len]
      end
      @container
    end

    def to_a
      @container
    end

  end
end