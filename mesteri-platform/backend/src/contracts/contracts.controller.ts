import {
  Controller,
  Post,
  Get,
  Param,
  Body,
  HttpCode,
  HttpStatus,
  Logger,
  ValidationPipe,
  UseGuards,
  Request,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHmac } from 'crypto';
import { ContractsService } from './contracts.service';
import { ContractResponseDto } from './dto/contract-response.dto';
import { SignRequestWebhookDto } from './dto/sign-request-webhook.dto';
import { FirebaseAuthGuard } from '../guards/firebase-auth.guard';

@Controller('contracts')
export class ContractsController {
  private readonly logger = new Logger(ContractsController.name);

  constructor(
    private readonly contractsService: ContractsService,
    private readonly configService: ConfigService,
  ) {}

  @Post('/project/:projectId')
  @UseGuards(FirebaseAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  async createContractForProject(
    @Param('projectId') projectId: string,
    @Request() req,
  ): Promise<ContractResponseDto> {
    this.logger.log(`Request to create contract for project: ${projectId}`);

    // Get initiatorId from authenticated user
    const initiatorId = req.user.uid;

    return this.contractsService.createContract(projectId, initiatorId);
  }

  @Get(':contractId')
  async getContract(
    @Param('contractId') contractId: string,
  ): Promise<ContractResponseDto> {
    this.logger.log(`Fetching details for contract: ${contractId}`);
    return this.contractsService.getContractById(contractId);
  }

  @Post('webhooks/signrequest')
  @HttpCode(HttpStatus.OK)
  async handleSignRequestWebhook(
    @Body(new ValidationPipe({ transform: true, whitelist: true }))
    webhookDto: SignRequestWebhookDto,
  ): Promise<{ success: boolean }> {
    this.logger.log(
      `SignRequest webhook received: ${webhookDto.event_type} for document ${webhookDto.document?.uuid}`,
    );

    // Verify webhook authenticity
    this.verifyWebhookSignature(webhookDto);

    if (webhookDto.event_type === 'signed') {
      await this.contractsService.handleSignedWebhook(webhookDto);
    } else if (webhookDto.event_type === 'declined') {
      await this.contractsService.handleDeclinedWebhook(webhookDto);
    } else if (webhookDto.event_type === 'cancelled') {
      await this.contractsService.handleCancelledWebhook(webhookDto);
    } else {
      this.logger.log(`Ignoring webhook event type: ${webhookDto.event_type}`);
    }

    return { success: true };
  }

  /**
   * Verify SignRequest webhook signature using HMAC-SHA256
   *
   * SignRequest generates an event_hash by concatenating event_time + event_type
   * and creating an HMAC-SHA256 hash using the API token as the secret key.
   *
   * @param webhookDto - The webhook payload from SignRequest
   * @throws UnauthorizedException if signature verification fails
   */
  private verifyWebhookSignature(webhookDto: SignRequestWebhookDto): void {
    const apiToken = this.configService.get<string>('SIGNREQUEST_API_TOKEN');

    if (!apiToken) {
      this.logger.error('SIGNREQUEST_API_TOKEN is not configured');
      throw new UnauthorizedException('Webhook verification failed: API token not configured');
    }

    // Concatenate event_time and event_type as per SignRequest documentation
    const payload = `${webhookDto.event_time}${webhookDto.event_type}`;

    // Generate HMAC-SHA256 signature
    const expectedHash = createHmac('sha256', apiToken)
      .update(payload)
      .digest('hex');

    // Compare with the hash provided by SignRequest
    if (expectedHash !== webhookDto.event_hash) {
      this.logger.warn(
        `Webhook signature verification failed. Expected: ${expectedHash}, Received: ${webhookDto.event_hash}`,
      );
      throw new UnauthorizedException('Invalid webhook signature');
    }

    this.logger.debug('Webhook signature verified successfully');
  }
}
