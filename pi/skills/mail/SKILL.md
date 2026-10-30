---
name: mail
description: Write an email as a Markdown letter the host can send. Use whenever an email is discussed or needs writing, replying, or editing.
---

# Mail

Write the email the user asks for into a `.md` file in this format:

```markdown
---
to: Name <addr@example.com>
subject: Text
attachments:
  - file.pdf
---

Body in Markdown.
```

- `to`: one address or a list; there is no cc or bcc.
- `attachments`: optional; paths are relative to the letter.
- No other keys.

Then run `mail-draft --check <letter>` and fix the letter until it passes.
