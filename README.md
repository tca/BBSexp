Library for making bbcode like markup for message boards.

Look at test.rb and below for example usage.


You can define your own elements and chain them together, but they can only be 1 character:

    "[biu]bold italic underline[.]" => "<strong><em><u>bold italic underline</u></em></strong>

you can also close multiple tags at once:

    "[b][i][u]bold italic underline[...]" => "<strong><em><u>bold italic underline</u></em></strong>"

unclosed tags are automatically closed at the end of the text:

    "[b][i][u]bold italic underline" => "<strong><em><u>bold italic underline</u></em></strong>"

Redundant elements are automatically ignored:

    "[bbiiuu][b][i][u][b][i][u]text" => "<strong><em><u>text</u></em></strong>"

The compiler follows rules such as not allowing block elements to be inside of inline elements:

    "[i][q]q is blockquote" => "<em>q is blockquote</em>"

you can also define custom functions to operate on the tags:

    "[r]reversed[.]" => "desrever"
