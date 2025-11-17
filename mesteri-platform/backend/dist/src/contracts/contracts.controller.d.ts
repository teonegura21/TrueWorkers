import { ConfigService } from '@nestjs/config';
import { ContractsService } from './contracts.service';
import { ContractResponseDto } from './dto/contract-response.dto';
import { SignRequestWebhookDto } from './dto/sign-request-webhook.dto';
export declare class ContractsController {
    private readonly contractsService;
    private readonly configService;
    private readonly logger;
    constructor(contractsService: ContractsService, configService: ConfigService);
    createContractForProject(projectId: string, req: any): Promise<ContractResponseDto>;
    getContract(contractId: string): Promise<ContractResponseDto>;
    handleSignRequestWebhook(webhookDto: SignRequestWebhookDto): Promise<{
        success: boolean;
    }>;
    private verifyWebhookSignature;
}
