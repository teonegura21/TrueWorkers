import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayInit,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { MessagesService } from './messages.service';
import { Message } from '@prisma/client';
import { Logger } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';

interface AuthenticatedSocket extends Socket {
  userId?: string;
  projectId?: string;
}

@WebSocketGateway({
  cors: {
    origin: process.env.FRONTEND_URL || [
      'http://localhost:3000',
      'http://localhost:3001',
    ],
    credentials: true,
  },
  namespace: '/messages',
})
export class MessagesGateway
  implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect
{
  private readonly logger = new Logger(MessagesGateway.name);

  @WebSocketServer()
  server: Server;

  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly messagesService: MessagesService,
  ) {}

  afterInit(server: Server) {
    this.logger.log('WebSocket Gateway initialized');
  }

  async handleConnection(client: AuthenticatedSocket) {
    try {
      const token =
        client.handshake.auth?.token || client.handshake.headers.authorization;

      if (!token) {
        this.logger.error('No token provided');
        client.disconnect(true);
        return;
      }

      // Remove 'Bearer ' prefix if present
      const firebaseToken = token.replace('Bearer ', '');

      const decodedToken = await this.firebaseService.verifyIdToken(firebaseToken);
      
      client.userId = decodedToken.uid;
      this.logger.log(`User ${decodedToken.uid} connected via WebSocket`);
    } catch (error) {
      this.logger.error('WebSocket authentication failed:', error.message);
      client.disconnect(true);
    }
  }

  handleDisconnect(client: AuthenticatedSocket) {
    if (client.userId) {
      this.logger.log(`User ${client.userId} disconnected`);
    }
  }

  @SubscribeMessage('join-project')
  handleJoinProject(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() data: { projectId: string },
  ) {
    if (!client.userId) {
      client.emit('error', { message: 'Authentication required' });
      return;
    }

    const { projectId } = data;

    // Validate if user has access to this project
    this.messagesService
      .validateProjectAccess(projectId, client.userId)
      .then(() => {
        client.join(`project-${projectId}`);
        client.projectId = projectId;
        this.logger.log(
          `User ${client.userId} joined project room: project-${projectId}`,
        );
        client.emit('joined-project', { projectId });
      })
      .catch((error) => {
        this.logger.error(
          `Failed to join project ${projectId} for user ${client.userId}:`,
          error.message,
        );
        client.emit('error', {
          message: 'You do not have access to this project',
        });
      });
  }

  @SubscribeMessage('leave-project')
  handleLeaveProject(@ConnectedSocket() client: AuthenticatedSocket) {
    if (client.projectId) {
      client.leave(`project-${client.projectId}`);
      this.logger.log(
        `User ${client.userId} left project room: project-${client.projectId}`,
      );
      client.projectId = undefined;
    }
  }

  @SubscribeMessage('send-message')
  async handleSendMessage(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody()
    data: {
      projectId: string;
      receiverId: string;
      content: string;
      messageType?: string;
      attachments?: any[];
      metadata?: any;
    },
  ) {
    if (!client.userId) {
      client.emit('error', { message: 'Authentication required' });
      return;
    }

    try {
      const {
        projectId,
        receiverId,
        content,
        messageType,
        attachments,
        metadata,
      } = data;

      const createMessageDto = {
        projectId,
        receiverId,
        content,
        messageType: (messageType as any) || undefined,
        attachments: attachments || [],
        metadata: metadata || undefined,
      };

      const message = await this.messagesService.create(
        createMessageDto,
        client.userId,
      );

      // Broadcast the message to all clients in the project room
      this.server.to(`project-${projectId}`).emit('new-message', {
        message,
        senderId: client.userId,
      });

      // Send confirmation back to sender
      client.emit('message-sent', { message });

      this.logger.log(
        `Message sent in project ${projectId} by user ${client.userId}`,
      );
    } catch (error) {
      this.logger.error('Failed to send message:', error.message);
      client.emit('error', { message: error.message });
    }
  }

  @SubscribeMessage('typing-start')
  handleTypingStart(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() data: { projectId: string },
  ) {
    if (!client.userId || !client.projectId) {
      return;
    }

    // Broadcast typing indicator to other clients in the project room
    client.to(`project-${client.projectId}`).emit('user-typing', {
      userId: client.userId,
      isTyping: true,
    });
  }

  @SubscribeMessage('typing-stop')
  handleTypingStop(@ConnectedSocket() client: AuthenticatedSocket) {
    if (!client.userId || !client.projectId) {
      return;
    }

    // Broadcast typing indicator to other clients in the project room
    client.to(`project-${client.projectId}`).emit('user-typing', {
      userId: client.userId,
      isTyping: false,
    });
  }

  @SubscribeMessage('mark-as-read')
  async handleMarkAsRead(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() data: { projectId: string },
  ) {
    if (!client.userId) {
      return;
    }

    try {
      const { projectId } = data;
      const markAsRead = await this.messagesService.markAllAsRead(
        projectId,
        client.userId,
      );

      // Notify other clients in the project room
      client.to(`project-${projectId}`).emit('messages-read', {
        readerId: client.userId,
        projectId,
        count: markAsRead,
      });

      this.logger.log(
        `User ${client.userId} marked messages as read in project ${projectId}`,
      );
    } catch (error) {
      this.logger.error('Failed to mark messages as read:', error.message);
      client.emit('error', { message: error.message });
    }
  }

  // Method to broadcast system messages
  async broadcastSystemMessage(
    projectId: string,
    systemType: string,
    extraContent?: string,
  ) {
    try {
      const systemMessage = await this.messagesService.createSystemMessage(
        projectId,
        systemType as any,
        extraContent,
      );

      // Broadcast system message to all clients in the project room
      this.server.to(`project-${projectId}`).emit('new-message', {
        message: systemMessage,
        isSystemMessage: true,
      });

      this.logger.log(
        `System message broadcasted in project ${projectId}: ${systemType}`,
      );
    } catch (error) {
      this.logger.error('Failed to broadcast system message:', error.message);
    }
  }
}
