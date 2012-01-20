Library for making bbcode like markup for message boards.

You can define your own elements and chain them together, but they can only be 1 character.
Redundant elements are automatically ignored ([bb] only registers b once) and the compilers follows
rules such as not allowing block elements (like div or p) to be inside of inline elements (strong or em).

Look at test.rb and below for example usage.


chaining elements:

    "[biu]bold italic underline[|]" => "<strong><em><u>bold italic underline</u></em></strong>

you can also close multiple tags at once:

    "[b][i][u]bold italic underline[|||]" => "<strong><em><u>bold italic underline</u></em></strong>"

unclosed tags are automatically closed at the end of the text:

    "[b][i][u]bold italic underline" => "<strong><em><u>bold italic underline</u></em></strong>"

you can also define custom functions to operate on the tags:

    "[r]reversed[|]" => "desrever"
