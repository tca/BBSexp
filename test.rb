require_relative 'lib/bbsexp.rb'

# set up a new parser
class TestLang
  include BBSexp::Dialect

  noparse '`'
  brackets '[]'
  end_exp '|'

  func 'r', :func => lambda {|text| text.reverse }

  inline 'b', :tags => ['<strong>', '</strong>']
  inline 'i', :tags => ['<em>', '</em>']
  inline 'u', :tags => ['<u>', '</u>']
  inline 'c', :tags => ['<code>', '</code>']

  #change to attr :class => spoiler
  inline 's', :tags => ['<span class="spoiler">', '</span>']

  block 'q', :tags => ['<blockquote>', '</blockquote>']
  block 'p', :tags => ['<pre>','</pre>']

end

# give it some nasty input
text = '[bui]wtf[|] [bpc`][bic] <-- dont parse this (bold code) or this --> [|][|`]' \
       '[biqr]reversed bold italic blockquote[|] [q]quote[|]' \
       '[i][b]end two tags at once[||]no start so dont parse -> [|] [b]tag ends itself'

puts TestLang.parse(text)

