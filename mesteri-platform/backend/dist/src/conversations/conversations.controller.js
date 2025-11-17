"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ConversationsController = void 0;
const common_1 = require("@nestjs/common");
const conversations_service_1 = require("./conversations.service");
const create_conversation_dto_1 = require("./dto/create-conversation.dto");
const send_conversation_message_dto_1 = require("./dto/send-conversation-message.dto");
const list_conversation_messages_dto_1 = require("./dto/list-conversation-messages.dto");
let ConversationsController = class ConversationsController {
    conversations;
    constructor(conversations) {
        this.conversations = conversations;
    }
    async list(req) {
        return this.conversations.listForUser(req.user.userId);
    }
    async create(dto, req) {
        return this.conversations.createConversation(dto, req.user.userId);
    }
    async ensureProjectConversation(projectId, req) {
        return this.conversations.ensureProjectConversation(projectId, req.user.userId);
    }
    async sendMessage(dto, req) {
        return this.conversations.sendMessage(req.user.userId, dto);
    }
    async listMessages(conversationId, query, req) {
        const payload = {
            conversationId,
            skip: query.skip !== undefined ? Number(query.skip) : undefined,
            take: query.take !== undefined ? Number(query.take) : undefined,
        };
        return this.conversations.listMessages(req.user.userId, payload);
    }
    async markRead(conversationId, messageId, req) {
        await this.conversations.markConversationRead(conversationId, req.user.userId, messageId);
        return { status: 'ok' };
    }
    async getUnreadCount(conversationId, req) {
        const count = await this.conversations.getUnreadCount(conversationId, req.user.userId);
        return { count };
    }
};
exports.ConversationsController = ConversationsController;
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], ConversationsController.prototype, "list", null);
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_conversation_dto_1.CreateConversationDto, Object]),
    __metadata("design:returntype", Promise)
], ConversationsController.prototype, "create", null);
__decorate([
    (0, common_1.Post)('projects/:projectId/ensure'),
    __param(0, (0, common_1.Param)('projectId')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ConversationsController.prototype, "ensureProjectConversation", null);
__decorate([
    (0, common_1.Post)('messages'),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [send_conversation_message_dto_1.SendConversationMessageDto, Object]),
    __metadata("design:returntype", Promise)
], ConversationsController.prototype, "sendMessage", null);
__decorate([
    (0, common_1.Get)(':conversationId/messages'),
    __param(0, (0, common_1.Param)('conversationId')),
    __param(1, (0, common_1.Query)()),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, list_conversation_messages_dto_1.ListConversationMessagesDto, Object]),
    __metadata("design:returntype", Promise)
], ConversationsController.prototype, "listMessages", null);
__decorate([
    (0, common_1.Post)(':conversationId/read'),
    __param(0, (0, common_1.Param)('conversationId')),
    __param(1, (0, common_1.Body)('messageId')),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, Object]),
    __metadata("design:returntype", Promise)
], ConversationsController.prototype, "markRead", null);
__decorate([
    (0, common_1.Get)(':conversationId/unread-count'),
    __param(0, (0, common_1.Param)('conversationId')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ConversationsController.prototype, "getUnreadCount", null);
exports.ConversationsController = ConversationsController = __decorate([
    (0, common_1.Controller)('conversations'),
    __metadata("design:paramtypes", [conversations_service_1.ConversationsService])
], ConversationsController);
//# sourceMappingURL=conversations.controller.js.map