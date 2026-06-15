Jekyll::Hooks.register :documents, :post_convert do |doc|
  # only code blocks with line numbers and marked lines cause extra newline
  # problem
  if doc.content.include?('<span class="hll">')
    doc.content = doc.content.gsub(
      %r{\n\n</pre>},
      "\n</pre>"
    )
  end
end
