;; extends
((inline) @_inline (#match? @_inline "^(import|export)")) @nospell

((fenced_code_block
  (info_string) @info
  (#match? @info "^manim"))
 @codeblock)
