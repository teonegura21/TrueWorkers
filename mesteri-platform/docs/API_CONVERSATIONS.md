# Conversations & Messaging API (Phase 1)

## Routes

| Method | Path | Description |
| --- | --- | --- |
| POST | /conversations | Create a conversation (optionally tied to a project). |
| POST | /conversations/projects/:projectId/ensure | Ensure the primary project conversation exists (idempotent). |
| POST | /conversations/messages | Send a message to a conversation. |
| GET | /conversations/:id/messages | List messages with pagination (most recent first). |
| POST | /conversations/:id/read | Mark a conversation as read up to the latest (or provided) message. |
| GET | /conversations/:id/unread-count | Return unread count for the requester. |

All routes require Authorization: Bearer <token>.

## DTOs

### CreateConversationDto
`	s
{
  title?: string;
  projectId?: string;
  participantIds: string[]; // must include the authenticated user
}
`

### SendConversationMessageDto
`	s
{
  conversationId: string;
  kind?: MessageKind; // defaults to TEXT
  body?: string;      // required if no attachments
  attachmentIds?: string[]; // optional list of existing attachment IDs
}
`

### ListConversationMessagesDto
Query params: skip (default 0), 	ake (default 50)

## Behaviour Notes
- Project conversations automatically enforce inclusion of client + craftsman and use the SUPPORT_THREAD retention policy.
- Message attachments are referenced via ttachment_links and reuse the Attachment metadata created during upload.
- markRead updates conversation_participants.last_read_message_id, enabling accurate unread counts.
- ensureProjectConversation will create the conversation on first call and return the existing one subsequently.

## Next Steps
- Integrate the Signed URL API for uploading new attachments before calling sendMessage.
- Update the mobile/web clients to switch from legacy job-based messaging endpoints to the new conversation routes.
- Deprecate the old /messages endpoints once clients migrate.
