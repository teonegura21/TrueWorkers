import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  Request,
} from '@nestjs/common';
import { ConversationsService } from './conversations.service';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { SendConversationMessageDto } from './dto/send-conversation-message.dto';
import { ListConversationMessagesDto } from './dto/list-conversation-messages.dto';

interface RequestUser {
  user: { userId: string };
}

@Controller('conversations')
export class ConversationsController {
  constructor(private readonly conversations: ConversationsService) {}

  @Get()
  async list(@Request() req: RequestUser) {
    return this.conversations.listForUser(req.user.userId);
  }

  @Post()
  async create(
    @Body() dto: CreateConversationDto,
    @Request() req: RequestUser,
  ) {
    return this.conversations.createConversation(dto, req.user.userId);
  }

  @Post('projects/:projectId/ensure')
  async ensureProjectConversation(
    @Param('projectId') projectId: string,
    @Request() req: RequestUser,
  ) {
    return this.conversations.ensureProjectConversation(
      projectId,
      req.user.userId,
    );
  }

  @Post('messages')
  async sendMessage(
    @Body() dto: SendConversationMessageDto,
    @Request() req: RequestUser,
  ) {
    return this.conversations.sendMessage(req.user.userId, dto);
  }

  @Get(':conversationId/messages')
  async listMessages(
    @Param('conversationId') conversationId: string,
    @Query() query: ListConversationMessagesDto,
    @Request() req: RequestUser,
  ) {
    const payload: ListConversationMessagesDto = {
      conversationId,
      skip: query.skip !== undefined ? Number(query.skip) : undefined,
      take: query.take !== undefined ? Number(query.take) : undefined,
    };
    return this.conversations.listMessages(req.user.userId, payload);
  }

  @Post(':conversationId/read')
  async markRead(
    @Param('conversationId') conversationId: string,
    @Body('messageId') messageId: string | undefined,
    @Request() req: RequestUser,
  ) {
    await this.conversations.markConversationRead(
      conversationId,
      req.user.userId,
      messageId,
    );
    return { status: 'ok' };
  }

  @Get(':conversationId/unread-count')
  async getUnreadCount(
    @Param('conversationId') conversationId: string,
    @Request() req: RequestUser,
  ) {
    const count = await this.conversations.getUnreadCount(
      conversationId,
      req.user.userId,
    );
    return { count };
  }
}
