# Triage Labels

The engineering skills speak in terms of five canonical triage roles. This file maps those roles to the actual label strings used in this repo's issue tracker (Linear, team `SK8`).

| Label in mattpocock/skills | Label in our tracker | Meaning                                  |
| -------------------------- | -------------------- | ---------------------------------------- |
| `needs-triage`             | `needs-triage`       | Maintainer needs to evaluate this issue  |
| `needs-info`               | `needs-info`         | Waiting on reporter for more information |
| `ready-for-agent`          | `ready-for-agent`    | Fully specified, ready for an AFK agent  |
| `ready-for-human`          | `ready-for-human`    | Requires human implementation            |
| `wontfix`                  | `wontfix`            | Will not be actioned                     |

When a skill mentions a role (e.g. "apply the AFK-ready triage label"), use the corresponding label string from this table.

## Creating missing labels

Labels live on the Linear team `SK8`. Before applying a label, check it exists with `list_issue_labels`. If one of the strings above is missing, create it via the `linear` MCP server (`create_issue_label`) — or ask the user first if the label set looks deliberately different.

Edit the "Label in our tracker" column here if the Linear vocabulary changes; skills read this file, not a hardcoded list.
