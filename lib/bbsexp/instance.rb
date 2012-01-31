module BBSexp
  class Instance
    def initialize(parser, text)
      @parser = parser
      @text = text
      @scanner = StringScanner.new(@text)
      @result = ''
      @stack = []
      @func_stack = []
      @state = [3]
      @locks = Hash[ @parser.exps.keys.map{|k| [k, false] } ]
      @brackets = ->(token) { @parser.brackets[0] + token + @parser.brackets[1] }
    end

    def build
      tokens = []
      while string = @scanner.scan_until(@parser.regexp) 
       exp = @scanner.matched
       tokens << [:string, string[0..-(exp.size + 1)]] unless string == exp
       tokens << [:exp, exp[1..-2]]
      end
      tokens << [:string, @scanner.rest] unless @scanner.eos?

      # evaluate tokens
      @result = tokens.map{|token| eval_token(token) }.join
      # close unclosed expressions
      @result << @stack.reverse.map {|token|
                  token.reverse.map {|exp|
                    @parser.exps[exp].tags.last }.join }.join
      @result
    end

    def eval_token(token)
      type, value = token
      case type
      when :string
        # run callbacks on string
        @func_stack.reduce(value) {|value, func| func.(value) }
      when :exp
        # dont parse if we are in the no parse zone
        return @brackets[value] if @state.last == 0 and not value.include? @parser.no_parse
        # process expressions
        unless value[0] == @parser.end_exp
          register(value)  #returns start tags
        else
         terminate(value) #returns end tags
        end
      end
    end

    def register(token)
      @stack << active_exps =               # append valid expressions to the stack
      token.chars.to_a.uniq.select do |exp| # ignore redundant and illegal expressions 
        @locks[exp] == false and @parser.exps[exp] <= @state.last
      end.sort do |a,b|
        @parser.exps[b] <=> @parser.exps[a] # sort nocode > block > inline
      end.map do |exp|
        @locks[exp] = true                  # lock this expression to prevent its use deeper in the stack
        @state << @parser.exps[exp].state   # set parser state to current element's level
        exp                                 # return to token.active_exps as a valid expression
      end
      
      @func_stack += active_exps.map {|exp| @parser.exps[exp].block }.compact

      # return the start tags for the token
      active_exps.map {|exp| @parser.exps[exp].tags.first }.join
    end

    def terminate(token) 
      return @brackets[token] if @stack.empty? # don't do anything if the stack is empty

      token.chars.map do |close|
        if exps = @stack.pop
          exps.map do |exp|
            @locks[exp] = false                        # unlock this expression so it can be used again
            @state.pop                                 # return parser state to parent scope
            @func_stack.pop if @parser.exps[exp].block # disable function
            @parser.exps[exp].tags.last                # return end tag
          end.reverse.join
        end
      end.join
    end
  end
end
