module Hypermicrodata
  class Property
    attr_reader :value, :names, :rels

    def initialize(value, names, rels = [])
      @value = value
      @names = names
      @rels = rels
    end

    def item
      @value if @value.is_a?(Item)
    end

    def item?
      !!item
    end

    def link?
      false
    end

    def submit_button?
      false
    end
  end
end
