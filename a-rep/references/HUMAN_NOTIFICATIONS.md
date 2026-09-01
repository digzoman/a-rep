# A Rep V1.4.1 human notifications

A Rep agents may need to interrupt a human asynchronously through push, Discord, SMS, email, or another delivery adapter. The delivery transport is not the identity of the producer.

V1.4.1 standardizes a small notification envelope so a human can tell, at a glance, who the message is from and how it reached them.

## Core rule

A material A Rep human-facing notification **SHOULD preserve the same four-field provenance format used for durable GitHub messages**:

`[Agent | Platform | Role | Instance]`

For transports with a visible title/subject, the title SHOULD be one exact provenance header.

For transports without a separate title, the first line of the message SHOULD be the provenance header.

Do not invent a second identity taxonomy for notifications.

## Origin and relay

Sometimes one surface originates the message but another surface delivers it.

Example:

- ChatGPT Reviewer posts an instruction;
- the GitHub watcher wakes Fred PRIMARY;
- Fred invokes a phone-push skill.

The human-relevant origin should remain visible rather than being flattened into an anonymous title such as `A Rep test`.

When a distinct upstream A Rep producer is the reason for the notification:

- use the **origin producer's provenance header as the notification title**;
- add a body line `Relayed-By: [Agent | Platform | Role | Instance]` for the execution surface that actually delivered the notification.

Example:

```text
Title:
[Fred | ChatGPT | Reviewer | A-Rep-design-chat]

Body:
Relayed-By: [Fred | Codex | PRIMARY | VM-runtime]
A Rep V1.4 messaging test
Source: Issue #11
```

When the delivering agent itself originated the notification, use its own provenance header as the title and omit `Relayed-By`.

Example:

```text
Title:
[Fred | Codex | PRIMARY | VM-runtime]

Body:
Approval needed for LinkedIn send.
Source: Issue #23
```

This is a lightweight provenance chain, not a general trace graph.

## Source

When the notification arose from durable work state, include a concise source pointer when useful:

`Source: Issue #23`

or a durable URL.

For diagnostic/test notifications, a short `Path:` line may describe the route, for example:

`Path: Reviewer comment -> GitHub watcher -> event PRIMARY -> pocket alert`

Do not require verbose routing narration in normal production alerts.

## Authority

**A notification is not approval.**

It gets human attention. The actual decision or authorization must still be recorded through the applicable trusted authority surface.

A notification carrying `[Fred | Codex | PRIMARY | VM-runtime]` does not manufacture authority merely because it uses correct provenance.

## Urgency and notification fatigue

Use immediate phone push for material attention, not routine heartbeat success or ordinary progress.

A delivery skill may define its own urgency vocabulary and transport-specific priority mapping, but it should not silently redefine A Rep authority.

Avoid repeated reminders for the same unresolved decision unless the current work explicitly authorizes a reminder cadence.

## Delivery adapters

A Rep does not mandate Pocket Alert, Discord, SMS, email, or any other vendor.

An approved agent skill may implement one or more transports. The framework requirement is the provenance/authority contract, not a vendor dependency.

A generic low-level delivery primitive may remain transport-specific. A higher-level A Rep human-notification skill SHOULD apply the provenance envelope consistently so callers do not have to remember formatting every time.

## Security

Never include credentials, private keys, auth tokens, cookies, raw secret files, or other secret material in human notifications.

Transport success is not proof the human read the notification. When consequential action depends on a human decision, recover the actual authoritative decision rather than inferring approval from delivery.

## Evidence

Useful delivery evidence may include:

- API success/transaction ID;
- a delivered Discord message;
- a confirmed phone push;
- explicit human acknowledgment when needed.

Distinguish machine-side delivery evidence from human receipt/read evidence.

## Anti-bloat

This contract does not add:

- a notification daemon;
- a central message bus;
- a notification database;
- a cross-agent routing service;
- a new persistent agent role.

Use approved skills and existing transports. Add infrastructure only when real operating evidence requires it.
