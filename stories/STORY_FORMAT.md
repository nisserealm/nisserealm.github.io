# Story Format

For writing, use one small Markdown file per attitude.

Each tile story can have:

- `cautious.story.md`
- `kind.story.md`
- `bold.story.md`

Use this structure:

```md
# Reindeer on the Ridge

The ridge falls quiet around you. An old herder sits beneath a spruce,
and a thin reindeer watches with clever patience.

The old man studies you in silence before he nods.
$companionName lowers her head and chooses your road.
```

The file is the full successful story for that attitude.

Failure is no longer authored inside the story file. The game resolves failure in
the background and shows a short missed-encounter message or, later, a separate
detrimental story.

Supported placeholder tokens:

- `$playerName`
- `$place`
- `$companionName`
- `$attitude`
- `$fromName`

Guidelines:

- Keep each story short.
- Write one complete success story per attitude.
- Favor one strong image over too much exposition.
- Let rewards be shown by the game UI when possible.
- Use the prose to give mood, consequence, and a sense of being in a fantasy world.
