;; extends

((code_span) @markup.raw
 (#set! priority 110))

((emphasis) @markup.italic
 (#set! priority 110))

((strong_emphasis) @markup.strong
 (#set! priority 110))

((strikethrough) @markup.strikethrough
 (#set! priority 110))

([
  (link_label)
  (link_text)
  (link_title)
  (image_description)
] @markup.link.label
 (#set! priority 110))

([
  (link_destination)
  (uri_autolink)
  (email_autolink)
] @markup.link.url
 (#set! priority 110))
