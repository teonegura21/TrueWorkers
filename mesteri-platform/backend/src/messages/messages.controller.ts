import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  Request,
  Patch,
} from '@nestjs/common';
import { MessagesService } from './messages.service';
import { CreateMessageDto } from './dto/create-message.dto';
import { UpdateMessageDto, MarkAsReadDto } from './dto/update-message.dto';

interface RequestWithUser extends Request {
  user: { userId: string; email: string; role: string };
}

@Controller('messages')
export class MessagesController {
  constructor(private readonly messagesService: MessagesService) {}

  @Post()
  create(
    @Body() createMessageDto: CreateMessageDto,
    @Request() req: RequestWithUser,
  ) {
    const senderId = req.user.userId;
    return this.messagesService.create(createMessageDto, senderId);
  }

  @Get('project/:projectId')
  findAllByProject(
    @Param('projectId') projectId: string,
    @Request() req: RequestWithUser,
    @Query('skip') skip?: string,
    @Query('take') take?: string,
  ) {
    const userId = req.user.userId;
    const options = {
      skip: skip ? parseInt(skip) : undefined,
      take: take ? parseInt(take) : undefined,
    };
    return this.messagesService.findAllByProject(projectId, userId, options);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @Request() req: RequestWithUser) {
    const userId = req.user.userId;
    return this.messagesService.findOne(id, userId);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateMessageDto: UpdateMessageDto,
    @Request() req: RequestWithUser,
  ) {
    const userId = req.user.userId;
    return this.messagesService.update(id, updateMessageDto, userId);
  }

  @Patch('project/:projectId/read')
  markAllAsRead(
    @Param('projectId') projectId: string,
    @Request() req: RequestWithUser,
  ) {
    const userId = req.user.userId;
    return this.messagesService.markAllAsRead(projectId, userId);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req: RequestWithUser) {
    const userId = req.user.userId;
    return this.messagesService.remove(id, userId);
  }

  @Get('project/:projectId/unread-count')
  getUnreadCount(
    @Param('projectId') projectId: string,
    @Request() req: RequestWithUser,
  ) {
    const userId = req.user.userId;
    return this.messagesService.getUnreadCount(projectId, userId);
  }

  @Get('project/:projectId/search')
  searchMessages(
    @Param('projectId') projectId: string,
    @Query('query') query: string,
    @Request() req: RequestWithUser,
    @Query('skip') skip?: string,
    @Query('take') take?: string,
  ) {
    const userId = req.user.userId;
    const options = {
      skip: skip ? parseInt(skip) : undefined,
      take: take ? parseInt(take) : undefined,
    };
    return this.messagesService.searchMessages(
      projectId,
      userId,
      query,
      options,
    );
  }

  @Get('project/:projectId/history')
  getConversationHistory(
    @Param('projectId') projectId: string,
    @Request() req: RequestWithUser,
    @Query('before') before?: string,
    @Query('after') after?: string,
    @Query('limit') limit?: string,
  ) {
    const userId = req.user.userId;
    const options = {
      before: before ? new Date(before) : undefined,
      after: after ? new Date(after) : undefined,
      limit: limit ? parseInt(limit) : undefined,
    };
    return this.messagesService.getConversationHistory(
      projectId,
      userId,
      options,
    );
  }
}
