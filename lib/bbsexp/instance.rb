module BBSexp
  class Instance
    def initialize(parser, text)
      @parser = parser
      @text = text
      @scanner = StringScanner.new(@text)
      @result = ''
      @stack = []
      @func_stack = []
      @callbacks = []
      @state = [3]
      @locks = Hash[ @parser.exps.keys.map{|k| [k, false] } ]
    end

    def build
      # compile expessions
      #@text.gsub!(@parser.regexp) {|match| gen_token(match, $1, $2) }
      
      tokens = []
      while string = @scanner.scan_until(@parser.regexp) 
       exp = @scanner.matched
       tokens << [:string, string[0..-(exp.size + 1)]] unless string == exp
       tokens << [:exp, exp[1..-2]]
      end
      tokens << [:string, @text[@scanner.pos..-1]] unless @scanner.eos?

      p tokens

      result = tokens.reduce('') do |result, token|
        type, value = token
        case type
        when :string
          puts 'string' 
          # run callbacks on string
          @func_stack.reduce(value) {|value, func| func.(value) }
        when :exp
          #register
          puts 'exp'
          case value[0] == @parser.end_exp ? :end : :start
          when :start
            register(value)  #returns start tags
          when :end
            terminate(value) #returns end tags
          end
        end
      end
      

      p result


      #tokens.each{|type, token| gen_token(type, token) }
      
      
      if false
      # close unclosed expressions
      @text << @stack.reverse.map {|token| token.end_tags }.join

      # do a second pass for functions
      # please don't beat me this is meant for use on html-sanitized input
      # i _swear_ i will do it properly when i rewrite it some time in the distant future
      return @text if @func_stack.empty?

      end
    end

    def xgen_token(match, exps, end_noparse) 
      #dont register token if in no parse zone (unless it's the "end noparse" exp)
      return match if @state.last == 0 and end_noparse.nil?

      type = exps[0] == @parser.end_exp ? :end : :start
      token = Token.new(match, exps)

      case type
      when :start then register(token)
      when :end   then terminate(token) 
      end 

    end

    def register_token(type, token) 
      case type
      when :string
        puts 'string' 
        # run callbacks on string
        # append string to result
        #result << 
      when :exp
        #register
        #puts 'exp'
        #@stack.last.stack << token
        #token = Expression.new(token)
      end

      case type
      when :start then register(token)
      when :end   then terminate(token) 
      end 

    end

    def register(token)
      # select only valid expressions
      active_exps =
      exps.uniq.select do |exp|     # remove redundant and illegal expressions 
        @locks[exp] == false and @parser.exps[exp] <= @state.last
      end.sort do |a,b|                   # sort nocode > block > inline
        @parser.exps[b] <=> @parser.exps[a]
      end.map do |exp|
        @locks[exp] = true                # lock this expression to prevent its use deeper in the stack
        @state << @parser.exps[exp].state # set parser state to current element's level
        exp                               # return to token.active_exps as a valid expression
      end
      
      token.functions = token.active_exps.map {|exp| @parser.exps[exp].block }.compact

      start_tags = token.active_exps.map {|exp| @parser.exps[exp].tags.first }.join
      token.end_tags = token.active_exps.reverse.map {|exp| @parser.exps[exp].tags.last }.join
                     
      unless token.functions.empty?
        token.id = @func_stack.size + 1
        func_marker = "<funs#{token.id}>"
        token.end_tags.prepend "</funs>"
        @func_stack << token
      end

      
      # add the processed token to the stack
      @stack << token
      # return the start tags for the token
      start_tags + (func_marker||'')
      
    end

    def terminate(end_token) 
      return end_token.string if @stack.empty? # don't do anything if the stack is empty
      end_token.exps.map do |close|
        if token = @stack.pop
          token.active_exps.each do |exp|
            @locks[exp] = false                # unlock this expression so it can be used again
            @state.pop                         # return parser state to parent scope
          end
          token.end_tags                       # return end tags
        end
      end.join
    end
  end
end
