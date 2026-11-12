#!/usr/bin/env bash
# Read an X post through the FxTwitter API. Usage: read-tweet.sh <x-url>
# No login and no API key. Falls back to api.vxtwitter.com when needed.
set -euo pipefail
url="${1:-}"
if [ -z "$url" ]; then echo "usage: read-tweet.sh <x.com-or-twitter.com-post-url>" >&2; exit 2; fi
url=$(printf '%s' "$url" | sed -E 's/[?#].*$//')
api_url=$(printf '%s' "$url" | sed -E 's#^https?://(www\.)?(x|twitter)\.com/#https://api.fxtwitter.com/#')
json=$(curl -s --max-time 20 "$api_url" || true)
code=$(printf '%s' "$json" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("code",""))' 2>/dev/null || echo "")
if [ "$code" != "200" ]; then
  api_url=$(printf '%s' "$api_url" | sed 's#://api\.fxtwitter\.com/#://api.vxtwitter.com/#')
  json=$(curl -s --max-time 20 "$api_url" || true)
  code=$(printf '%s' "$json" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("code",""))' 2>/dev/null || echo "")
fi
if [ "$code" != "200" ]; then echo "FxTwitter lookup failed (code: $code) for $url" >&2; exit 1; fi
printf '%s' "$json" | python3 -c '
import sys, json
d = json.load(sys.stdin)["tweet"]
a = d.get("author", {})
ver = " [verified]" if (a.get("verification") or {}).get("verified") else ""
print("author: {} (@{}){}".format(a.get("name", ""), a.get("screen_name", ""), ver))
print("posted: {}".format(d.get("created_at", "")))
print("url: {}".format(d.get("url", "")))
print("text: {}".format(d.get("text", "")))
print("likes: {}  retweets: {}  replies: {}  bookmarks: {}  views: {}".format(d.get("likes"), d.get("retweets"), d.get("replies"), d.get("bookmarks"), d.get("views")))
art = d.get("article")
if art:
    print("article: {}".format(art.get("title", "")))
    body = "\n".join(b.get("text", "") for b in (art.get("content") or {}).get("blocks", []))
    if body:
        print("--- article body ---")
        print(body)
    ents = art.get("media_entities") or []
    if ents:
        print("article images: {} (ids: {})".format(len(ents), ", ".join(e.get("media_id", "") for e in ents)))
med = d.get("media")
if med:
    print("media: {}".format(json.dumps(med, ensure_ascii=False)))
'
