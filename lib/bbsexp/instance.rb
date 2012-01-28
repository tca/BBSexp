module BBSexp
  class Instance
    def initialize(parser, text)
      @parser = parser
      @text = text
      @stack = []
      @func_stack = {}
      @state = [3]
      @locks = Hash[ @parser.exps.keys.map{|k| [k, false] } ]
    end

    def build
      # compile expessions
      @text.gsub!(@parser.regexp) {|match| gen_token(match, $1, $2) }

      # close unclosed expressions
      @text << @stack.reverse.map {|token| token.end_tags }.join

      # do a second pass for functions
      # please don't beat me this is meant for use on html-sanitized input
      # i _swear_ i will do it properly when i rewrite it some time in the distant future
      return @text if @func_stack.empty?

      doc = Nokogiri::XML("<fakeroot>"+@text+"</fakeroot>")
      doc.xpath("//funs").each do |fun|
         fun.content = @func_stack[fun.attr(:id).to_i].(fun.content)
      end
      doc.root.to_s.gsub(/(<\/?fakeroot>)|(<\/?funs(\sid="\d*")?>)/, "")
    end

    def gen_token(match, exps, end_noparse) 
      #dont register token if in no parse zone (unless it's the "end noparse" exp)
      return match if @state.last == 0 and end_noparse.nil?

      type = exps[0] == @parser.end_exp ? :end : :start
      token = Token.new(match, exps)

      case type
      when :start then register(token)
      when :end   then terminate(token) 
      end 

    end

    def register(token)
      # select only valid expressions
      token.active_exps =
      token.exps.uniq.select do |exp|     # remove redundant and illegal expressions 
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
        func_marker = "<funs id='#{token.id}'>"
        token.end_tags.prepend "</funs>"
        @func_stack[token.id] = token
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
