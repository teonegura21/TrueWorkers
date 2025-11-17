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
exports.MessagesController = void 0;
const common_1 = require("@nestjs/common");
const messages_service_1 = require("./messages.service");
const create_message_dto_1 = require("./dto/create-message.dto");
const update_message_dto_1 = require("./dto/update-message.dto");
let MessagesController = class MessagesController {
    messagesService;
    constructor(messagesService) {
        this.messagesService = messagesService;
    }
    create(createMessageDto, req) {
        const senderId = req.user.userId;
        return this.messagesService.create(createMessageDto, senderId);
    }
    findAllByProject(projectId, req, skip, take) {
        const userId = req.user.userId;
        const options = {
            skip: skip ? parseInt(skip) : undefined,
            take: take ? parseInt(take) : undefined,
        };
        return this.messagesService.findAllByProject(projectId, userId, options);
    }
    findOne(id, req) {
        const userId = req.user.userId;
        return this.messagesService.findOne(id, userId);
    }
    update(id, updateMessageDto, req) {
        const userId = req.user.userId;
        return this.messagesService.update(id, updateMessageDto, userId);
    }
    markAllAsRead(projectId, req) {
        const userId = req.user.userId;
        return this.messagesService.markAllAsRead(projectId, userId);
    }
    remove(id, req) {
        const userId = req.user.userId;
        return this.messagesService.remove(id, userId);
    }
    getUnreadCount(projectId, req) {
        const userId = req.user.userId;
        return this.messagesService.getUnreadCount(projectId, userId);
    }
    searchMessages(projectId, query, req, skip, take) {
        const userId = req.user.userId;
        const options = {
            skip: skip ? parseInt(skip) : undefined,
            take: take ? parseInt(take) : undefined,
        };
        return this.messagesService.searchMessages(projectId, userId, query, options);
    }
    getConversationHistory(projectId, req, before, after, limit) {
        const userId = req.user.userId;
        const options = {
            before: before ? new Date(before) : undefined,
            after: after ? new Date(after) : undefined,
            limit: limit ? parseInt(limit) : undefined,
        };
        return this.messagesService.getConversationHistory(projectId, userId, options);
    }
};
exports.MessagesController = MessagesController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_message_dto_1.CreateMessageDto, Object]),
    __metadata("design:returntype", void 0)
], MessagesController.prototype, "create", null);
__decorate([
    (0, common_1.Get)('project/:projectId'),
    __param(0, (0, common_1.Param)('projectId')),
    __param(1, (0, common_1.Request)()),
    __param(2, (0, common_1.Query)('skip')),
    __param(3, (0, common_1.Query)('take')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object, String, String]),
    __metadata("design:returntype", void 0)
], MessagesController.prototype, "findAllByProject", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], MessagesController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_message_dto_1.UpdateMessageDto, Object]),
    __metadata("design:returntype", void 0)
], MessagesController.prototype, "update", null);
__decorate([
    (0, common_1.Patch)('project/:projectId/read'),
    __param(0, (0, common_1.Param)('projectId')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], MessagesController.prototype, "markAllAsRead", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], MessagesController.prototype, "remove", null);
__decorate([
    (0, common_1.Get)('project/:projectId/unread-count'),
    __param(0, (0, common_1.Param)('projectId')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], MessagesController.prototype, "getUnreadCount", null);
__decorate([
    (0, common_1.Get)('project/:projectId/search'),
    __param(0, (0, common_1.Param)('projectId')),
    __param(1, (0, common_1.Query)('query')),
    __param(2, (0, common_1.Request)()),
    __param(3, (0, common_1.Query)('skip')),
    __param(4, (0, common_1.Query)('take')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, Object, String, String]),
    __metadata("design:returntype", void 0)
], MessagesController.prototype, "searchMessages", null);
__decorate([
    (0, common_1.Get)('project/:projectId/history'),
    __param(0, (0, common_1.Param)('projectId')),
    __param(1, (0, common_1.Request)()),
    __param(2, (0, common_1.Query)('before')),
    __param(3, (0, common_1.Query)('after')),
    __param(4, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object, String, String, String]),
    __metadata("design:returntype", void 0)
], MessagesController.prototype, "getConversationHistory", null);
exports.MessagesController = MessagesController = __decorate([
    (0, common_1.Controller)('messages'),
    __metadata("design:paramtypes", [messages_service_1.MessagesService])
], MessagesController);
//# sourceMappingURL=messages.controller.js.map