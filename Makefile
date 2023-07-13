.PHONY: drafts serve post build draft

drafts:
	bundle exec jekyll serve --drafts --incremental

serve:
	bundle exec jekyll serve --incremental

build:
	bundle exec jekyll build --incremental

post:
	@read -p "Enter post title: " title && cp _drafts/template.md "_posts/$$(date +%Y-%m-%d)-$${title}.md"

draft:
	@read -p "Enter draft title: " title && cp _drafts/template.md "_drafts/$${title}.md"