require_relative 'lib/bbsexp.rb'

# set up a new parser
parser = BBSexp::Parser.new do |p|
  p.func 'r', :func => lambda {|text| text.reverse }

  p.inline 'b', :tags => ['<strong>', '</strong>']
  p.inline 'i', :tags => ['<em>', '</em>']
  p.inline 'u', :tags => ['<u>', '</u>']
  p.inline 'c', :tags => ['<code>', '</code>']

  #change to p.attr :class => spoiler
  p.inline 's', :tags => ['<span class="spoiler">', '</span>']

  p.block 'q', :tags => ['<blockquote>', '</blockquote>']
  p.block 'p', :tags => ['<pre>','</pre>']

  p.noparse '`'

  p.brackets = '[]'
  p.end_exp = '|'
end

# give it some nasty input
text = '[bui]wtf[|] [bpc`][bic] <-- dont parse this (bold code) or this --> [|][|`]' \
       '[biqr]reversed bold italic blockquote[|] [q]quote[|]' \
       '[i][b]end two tags at once[||]no start so dont parse -> [|] [b]tag ends itself'

puts parser.parse(text)

