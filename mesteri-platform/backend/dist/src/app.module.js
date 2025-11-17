"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const core_1 = require("@nestjs/core");
const firebase_module_1 = require("./firebase/firebase.module");
const firebase_auth_guard_1 = require("./guards/firebase-auth.guard");
const auth_module_1 = require("./auth/auth.module");
const users_module_1 = require("./users/users.module");
const jobs_module_1 = require("./jobs/jobs.module");
const offers_module_1 = require("./offers/offers.module");
const projects_module_1 = require("./projects/projects.module");
const payments_module_1 = require("./payments/payments.module");
const reviews_module_1 = require("./reviews/reviews.module");
const verification_module_1 = require("./verification/verification.module");
const database_module_1 = require("./core/database/database.module");
const messages_module_1 = require("./messages/messages.module");
const notifications_module_1 = require("./notifications/notifications.module");
const conversations_module_1 = require("./conversations/conversations.module");
const storage_module_1 = require("./storage/storage.module");
const inspiration_module_1 = require("./inspiration/inspiration.module");
const analytics_module_1 = require("./analytics/analytics.module");
const media_module_1 = require("./media/media.module");
const signrequest_module_1 = require("./signrequest/signrequest.module");
const contracts_module_1 = require("./contracts/contracts.module");
const app_controller_1 = require("./app.controller");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({
                isGlobal: true,
                envFilePath: '.env',
            }),
            firebase_module_1.FirebaseModule,
            database_module_1.DatabaseModule,
            auth_module_1.AuthModule,
            users_module_1.UsersModule,
            jobs_module_1.JobsModule,
            offers_module_1.OffersModule,
            projects_module_1.ProjectsModule,
            payments_module_1.PaymentsModule,
            reviews_module_1.ReviewsModule,
            verification_module_1.VerificationModule,
            messages_module_1.MessagesModule,
            notifications_module_1.NotificationsModule,
            conversations_module_1.ConversationsModule,
            storage_module_1.StorageModule,
            inspiration_module_1.InspirationModule,
            analytics_module_1.AnalyticsModule,
            media_module_1.MediaModule,
            signrequest_module_1.SignRequestModule,
            contracts_module_1.ContractsModule,
        ],
        controllers: [app_controller_1.AppController],
        providers: [
            {
                provide: core_1.APP_GUARD,
                useClass: firebase_auth_guard_1.FirebaseAuthGuard,
            },
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map