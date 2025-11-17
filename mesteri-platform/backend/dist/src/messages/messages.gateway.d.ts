import { OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { MessagesService } from './messages.service';
import { FirebaseService } from '../firebase/firebase.service';
interface AuthenticatedSocket extends Socket {
    userId?: string;
    projectId?: string;
}
export declare class MessagesGateway implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect {
    private readonly firebaseService;
    private readonly messagesService;
    private readonly logger;
    server: Server;
    constructor(firebaseService: FirebaseService, messagesService: MessagesService);
    afterInit(server: Server): void;
    handleConnection(client: AuthenticatedSocket): Promise<void>;
    handleDisconnect(client: AuthenticatedSocket): void;
    handleJoinProject(client: AuthenticatedSocket, data: {
        projectId: string;
    }): void;
    handleLeaveProject(client: AuthenticatedSocket): void;
    handleSendMessage(client: AuthenticatedSocket, data: {
        projectId: string;
        receiverId: string;
        content: string;
        messageType?: string;
        attachments?: any[];
        metadata?: any;
    }): Promise<void>;
    handleTypingStart(client: AuthenticatedSocket, data: {
        projectId: string;
    }): void;
    handleTypingStop(client: AuthenticatedSocket): void;
    handleMarkAsRead(client: AuthenticatedSocket, data: {
        projectId: string;
    }): Promise<void>;
    broadcastSystemMessage(projectId: string, systemType: string, extraContent?: string): Promise<void>;
}
export {};
