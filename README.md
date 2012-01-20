library for making bbcode like markup for message boards

examples:

    "[biu]bold italic underline[|]" => "<strong><em><u>bold itealic underline</u></em></strong>

you can also close multiple tags at once:

    "[b][i][u]bold italic underline[|||]" => "<strong><em><u>bold itealic underline</u></em></strong>"

unclosed tags are automatically closed at the end of the text

    "[b][i][u]bold italic underline" => "<strong><em><u>bold itealic underline</u></em></strong>"
