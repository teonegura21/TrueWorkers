# Current Task - MVP Client-Side: Basic Messaging

## Goal
Implement basic one-to-one messaging functionality for clients to communicate with craftsmen on a project.

## Implementation Plan
1. **Identify/Create Messaging Screens:** Locate or create Flutter UI for displaying conversation lists and individual chat screens.
2. **Conversation List:** Display a list of ongoing conversations (e.g., per project or per craftsman).
3. **Message Fetching:** Integrate with `MesteriService.getMessages` (or `ConversationsApiService.fetchConversation`) to retrieve messages for a specific conversation/project.
4. **Message Sending:** Implement UI for composing and sending messages, integrating with `MesteriService.sendMessage` (or `ConversationsApiService.sendMessage`).
5. **Real-time Updates (Optional for MVP):** Consider basic polling or a placeholder for real-time message updates if full WebSocket integration is out of scope for MVP.
6. **Loading and Error States:** Implement UI feedback for loading messages and sending failures.
7. **Success Feedback:** Provide visual confirmation for sent messages.

## Key References
- `app_client/lib/src/core/services/comprehensive_service.dart` (for `getMessages`, `sendMessage`)
- `app_client/lib/src/core/services/conversations_api_service.dart` (for `fetchConversation`, `sendMessage`)
- `app_client/lib/src/core/models/api_models.dart` (for `Message` model)
- `app_client/lib/src/core/models/conversation_models.dart` (for `ConversationSummary`, `ConversationThread`, `ConversationMessage`)
- Relevant UI screens for messaging.

## Checklist
- [ ] Conversation list screen UI is implemented.
- [ ] Individual chat screen UI is implemented.
- [ ] Messages are fetched using API service.
- [ ] Message sending functionality is implemented and calls API service.
- [ ] Loading indicators are shown during API calls.
- [ ] Error messages are displayed for API failures.
- [ ] User receives success feedback upon sending messages.