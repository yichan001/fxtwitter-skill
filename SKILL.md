# Read X posts with FxTwitter

## When to use it

- Use this skill whenever the user shares an X or Twitter link, or asks what a specific post says.

- Prefer this skill over opening X in the browser. The browser route is slower and often blocked, while this route returns structured JSON in about two seconds.

- Use it for one post link at a time. For a timeline, a search, or a list, use the browser or a different source.

## Rewrite the link

- Keep the username and the post ID exactly as they are in the link the user gave.

- Replace only the domain with api.fxtwitter.com and keep a slash after the domain.

- Turn https://x.com/sgwer73/status/2120853798839267562 into https://api.fxtwitter.com/sgwer73/status/2120853798839267562.

- Treat twitter.com links the same way as x.com links.

## Fetch it

- Fetch the rewritten link with curl and a 20 second timeout. No login and no API key are needed.

- Run scripts/read-tweet.sh with the original link and let it do the rewrite and the fetch for you.

- Read the JSON the API returns and confirm the code field is 200 before you trust the rest.

- If api.fxtwitter.com fails or returns a code other than 200, retry the same link on api.vxtwitter.com. That service mirrors the same format and the same fields.

## Read the result

- Take the post text from tweet.text and the author name from tweet.author.name with the handle in tweet.author.screen_name.

- Take the publish time from tweet.created_at and convert it to the user's timezone before you report it.

- Take the counts from tweet.likes, tweet.retweets, tweet.replies, tweet.bookmarks and tweet.views. Say when you read them, because the counts keep growing.

- Take the article title from tweet.article.title when the post links a long article. Join the text of every block in tweet.article.content.blocks to read the full article body.

- Take image and video links from the media fields when they are present. Report the direct links instead of describing them from memory.

## Limits

- The counts you read are a snapshot. A later read of the same post can show higher numbers.

- A post the author deleted or protected returns an error instead of content. Say so plainly and do not guess at the text.

- The article body comes as blocks of text. Keep the order of the blocks when you read it.

- Do not use this skill to log in, follow, like, repost or reply. It is a read only route.

## Related

- Use `muse.skill_search` to find related skills.

- Use `muse.connector_search` to find connectors for other services.
