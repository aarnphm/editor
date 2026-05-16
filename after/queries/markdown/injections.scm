;; extends

((minus_metadata) @injection.content
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.language "yaml"))

(((inline) @_inline (#match? @_inline "^(import|export)")) @injection.content
  (#set! injection.language "tsx"))
