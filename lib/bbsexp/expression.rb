module BBSexp
  class Expression
    include Comparable
    attr_reader :sym, :state, :tags, :block

    def initialize(sym, state, args={})
      @sym = sym
      @state = case state
               when :block   then 3
               when :inline  then 2
               when :func    then 1
               when :noparse then 0
               else state
               end
      @tags = args[:tags] || ['', '']
      @block = args[:func]
    end

    def <=>(b)
      @state <=> (b.class == Expression ? b.state : b.to_i)
    end
  end
end
