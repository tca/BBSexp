module BBSexp
  class Compiler
    def initialize(parser, text)
      @parser = parser
      @text = text
      @result = ''
      @stack = []
      @func_stack = []
      @state = [3]
      @locks = Hash[ @parser.exps.keys.map{|k| [k, false] } ]
      @tokens = tokens
    end

    def build
      @result <<  @tokens.map do |type, value|
                    case type
                    when :string  then eval_string value
                    when :exp     then eval_exp value
                    end
                  end.join

      # close unclosed expressions
      @result << @stack.reverse.map {|token|
                  token.reverse.map {|exp|
                    @parser.exps[exp].tags.last }.join }.join
    end

    def tokens
      Enumerator.new do |y|
        scanner = StringScanner.new(@text)
        while string = scanner.scan_until(@parser.regexp) 
         exp = scanner.matched
         y << [:string, string[0..-(exp.size + 1)]] unless string == exp
         y << [:exp, exp[1..-2]]
        end
        y << [:string, scanner.rest] unless scanner.eos?
      end
    end

    def eval_string(string)
      # run callbacks on string
      @func_stack.reduce(string) {|memo, func| func.(memo) }
    end

    def eval_exp(exp)
      # dont parse if we are in the no parse zone
      return eval_string(@parser.brackets(exp)) if @state.last == 0 and not exp.include? @parser.no_parse
      # process expressions
      unless exp[0] == @parser.end_exp
        register(exp)  #returns start tags
      else
        terminate(exp) #returns end tags
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
      return @parser.brackets(token) if @stack.empty? # don't do anything if the stack is empty

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
