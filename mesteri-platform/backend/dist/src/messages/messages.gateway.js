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
var MessagesGateway_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.MessagesGateway = void 0;
const websockets_1 = require("@nestjs/websockets");
const socket_io_1 = require("socket.io");
const messages_service_1 = require("./messages.service");
const common_1 = require("@nestjs/common");
const firebase_service_1 = require("../firebase/firebase.service");
let MessagesGateway = MessagesGateway_1 = class MessagesGateway {
    firebaseService;
    messagesService;
    logger = new common_1.Logger(MessagesGateway_1.name);
    server;
    constructor(firebaseService, messagesService) {
        this.firebaseService = firebaseService;
        this.messagesService = messagesService;
    }
    afterInit(server) {
        this.logger.log('WebSocket Gateway initialized');
    }
    async handleConnection(client) {
        try {
            const token = client.handshake.auth?.token || client.handshake.headers.authorization;
            if (!token) {
                this.logger.error('No token provided');
                client.disconnect(true);
                return;
            }
            const firebaseToken = token.replace('Bearer ', '');
            const decodedToken = await this.firebaseService.verifyIdToken(firebaseToken);
            client.userId = decodedToken.uid;
            this.logger.log(`User ${decodedToken.uid} connected via WebSocket`);
        }
        catch (error) {
            this.logger.error('WebSocket authentication failed:', error.message);
            client.disconnect(true);
        }
    }
    handleDisconnect(client) {
        if (client.userId) {
            this.logger.log(`User ${client.userId} disconnected`);
        }
    }
    handleJoinProject(client, data) {
        if (!client.userId) {
            client.emit('error', { message: 'Authentication required' });
            return;
        }
        const { projectId } = data;
        this.messagesService
            .validateProjectAccess(projectId, client.userId)
            .then(() => {
            client.join(`project-${projectId}`);
            client.projectId = projectId;
            this.logger.log(`User ${client.userId} joined project room: project-${projectId}`);
            client.emit('joined-project', { projectId });
        })
            .catch((error) => {
            this.logger.error(`Failed to join project ${projectId} for user ${client.userId}:`, error.message);
            client.emit('error', {
                message: 'You do not have access to this project',
            });
        });
    }
    handleLeaveProject(client) {
        if (client.projectId) {
            client.leave(`project-${client.projectId}`);
            this.logger.log(`User ${client.userId} left project room: project-${client.projectId}`);
            client.projectId = undefined;
        }
    }
    async handleSendMessage(client, data) {
        if (!client.userId) {
            client.emit('error', { message: 'Authentication required' });
            return;
        }
        try {
            const { projectId, receiverId, content, messageType, attachments, metadata, } = data;
            const createMessageDto = {
                projectId,
                receiverId,
                content,
                messageType: messageType || undefined,
                attachments: attachments || [],
                metadata: metadata || undefined,
            };
            const message = await this.messagesService.create(createMessageDto, client.userId);
            this.server.to(`project-${projectId}`).emit('new-message', {
                message,
                senderId: client.userId,
            });
            client.emit('message-sent', { message });
            this.logger.log(`Message sent in project ${projectId} by user ${client.userId}`);
        }
        catch (error) {
            this.logger.error('Failed to send message:', error.message);
            client.emit('error', { message: error.message });
        }
    }
    handleTypingStart(client, data) {
        if (!client.userId || !client.projectId) {
            return;
        }
        client.to(`project-${client.projectId}`).emit('user-typing', {
            userId: client.userId,
            isTyping: true,
        });
    }
    handleTypingStop(client) {
        if (!client.userId || !client.projectId) {
            return;
        }
        client.to(`project-${client.projectId}`).emit('user-typing', {
            userId: client.userId,
            isTyping: false,
        });
    }
    async handleMarkAsRead(client, data) {
        if (!client.userId) {
            return;
        }
        try {
            const { projectId } = data;
            const markAsRead = await this.messagesService.markAllAsRead(projectId, client.userId);
            client.to(`project-${projectId}`).emit('messages-read', {
                readerId: client.userId,
                projectId,
                count: markAsRead,
            });
            this.logger.log(`User ${client.userId} marked messages as read in project ${projectId}`);
        }
        catch (error) {
            this.logger.error('Failed to mark messages as read:', error.message);
            client.emit('error', { message: error.message });
        }
    }
    async broadcastSystemMessage(projectId, systemType, extraContent) {
        try {
            const systemMessage = await this.messagesService.createSystemMessage(projectId, systemType, extraContent);
            this.server.to(`project-${projectId}`).emit('new-message', {
                message: systemMessage,
                isSystemMessage: true,
            });
            this.logger.log(`System message broadcasted in project ${projectId}: ${systemType}`);
        }
        catch (error) {
            this.logger.error('Failed to broadcast system message:', error.message);
        }
    }
};
exports.MessagesGateway = MessagesGateway;
__decorate([
    (0, websockets_1.WebSocketServer)(),
    __metadata("design:type", socket_io_1.Server)
], MessagesGateway.prototype, "server", void 0);
__decorate([
    (0, websockets_1.SubscribeMessage)('join-project'),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], MessagesGateway.prototype, "handleJoinProject", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('leave-project'),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], MessagesGateway.prototype, "handleLeaveProject", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('send-message'),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], MessagesGateway.prototype, "handleSendMessage", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('typing-start'),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], MessagesGateway.prototype, "handleTypingStart", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('typing-stop'),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], MessagesGateway.prototype, "handleTypingStop", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('mark-as-read'),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], MessagesGateway.prototype, "handleMarkAsRead", null);
exports.MessagesGateway = MessagesGateway = MessagesGateway_1 = __decorate([
    (0, websockets_1.WebSocketGateway)({
        cors: {
            origin: process.env.FRONTEND_URL || [
                'http://localhost:3000',
                'http://localhost:3001',
            ],
            credentials: true,
        },
        namespace: '/messages',
    }),
    __metadata("design:paramtypes", [firebase_service_1.FirebaseService,
        messages_service_1.MessagesService])
], MessagesGateway);
//# sourceMappingURL=messages.gateway.js.map