module BBSexp
  class Token
    attr_accessor :active_exps,
                  :end_tags,
                  :functions,
                  :func_markers,
                  :id

    attr_reader :exps,
                :string

    def initialize(match, exps)
      @string = match
      @exps = exps.chars.to_a
      @active_exps = []
    end 
   
    def call(text)
      @functions.each {|fun| text = fun.(text) }
      text
    end
  end
end
