module BBSexp
  module Dialect
    module ClassMethods
      attr_accessor :exps, :brackets, :end_exp, :no_parse
      attr_reader :regexp, :end_exp

      def self.extended(by)
        by.instance_exec do
          @exps = {}
        end
      end

      def initialize
        @brackets ||= '[]'
        @no_parse ||= '`'
        @end_exp ||= '|'
        exps = [  @brackets[0],
                  @exps.keys.join,
                  @end_exp,
                  @no_parse,
                  @brackets[1] ].map {|v| Regexp.escape(v) }

        regexp = "%s([%s]+|%s+(%s)?)%s" % exps
        @regexp = Regexp.new(regexp)
        @initialized = true
      end

      def brackets(brackets=nil)
        return  @brackets[0] + brackets + @brackets[1] if @brackets
        @brackets ||= brackets
      end

      def end_exp(exp=nil)
        @end_exp ||= exp
      end

      def method_missing(level, sym, args={})
        exp(sym, level, args)
      end

      def exp(sym, state, args={})
        sym = sym.to_s
        @no_parse = sym if state == :noparse
        @exps[sym] = Expression.new(sym, state, args)
      end
      
      def parse(text)
        initialize unless @initialized
        Compiler.new(self, text).build
      end
    end

    def self.included(by)
      by.extend ClassMethods
    end
  end
end
