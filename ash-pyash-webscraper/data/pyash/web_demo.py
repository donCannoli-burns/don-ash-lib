# Intended for pyash-web.ash after the scraper built-ins are enabled.
# The built-in returns at most the requested number of normalized text lines.
text = scrape("https://example.com", 50)
print(text)

# Save HTML + Markdown + PDF under ~/.kolmafia/data/scraper/example-com.*
result = scrape_save("https://example.com", "all", 50, "example-com")
print(result)
