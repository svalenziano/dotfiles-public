# JSON prettifier
unjson() { jq 'walk(if type=="string" then (. as $s | try fromjson catch $s) else . end)' "$@"; }

# input = ugly JSON, output = pretty json
prettyclip() { xclip -o -sel c | unjson | xclip -selection clipboard; }

# prettify and view in fx
prettyfx() { xclip -o -sel c | unjson | fx; }

# like unjson, but also expand embedded \n in strings onto real lines
# (output is no longer valid JSON — it's for human reading)
unjsonl() { unjson "$@" | sed 's/\\n/\n/g'; }

# prettify, expand newlines, and page in less
prettyless() { xclip -o -sel c | unjsonl | less -R; }