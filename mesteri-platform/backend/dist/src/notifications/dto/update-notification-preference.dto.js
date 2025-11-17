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
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateNotificationPreferenceDto = exports.NotificationType = void 0;
const class_validator_1 = require("class-validator");
var NotificationType;
(function (NotificationType) {
    NotificationType["NEW_JOB"] = "NEW_JOB";
    NotificationType["OFFER_ACCEPTED"] = "OFFER_ACCEPTED";
    NotificationType["CONTRACT_SIGNED"] = "CONTRACT_SIGNED";
    NotificationType["PAYMENT_RECEIVED"] = "PAYMENT_RECEIVED";
    NotificationType["NEW_MESSAGE"] = "NEW_MESSAGE";
    NotificationType["WELCOME"] = "WELCOME";
    NotificationType["PROJECT_COMPLETED"] = "PROJECT_COMPLETED";
    NotificationType["OFFER_SUBMITTED"] = "OFFER_SUBMITTED";
})(NotificationType || (exports.NotificationType = NotificationType = {}));
class UpdateNotificationPreferenceDto {
    notificationType;
    pushEnabled;
    emailEnabled;
}
exports.UpdateNotificationPreferenceDto = UpdateNotificationPreferenceDto;
__decorate([
    (0, class_validator_1.IsEnum)(NotificationType),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], UpdateNotificationPreferenceDto.prototype, "notificationType", void 0);
__decorate([
    (0, class_validator_1.IsBoolean)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Boolean)
], UpdateNotificationPreferenceDto.prototype, "pushEnabled", void 0);
__decorate([
    (0, class_validator_1.IsBoolean)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Boolean)
], UpdateNotificationPreferenceDto.prototype, "emailEnabled", void 0);
//# sourceMappingURL=update-notification-preference.dto.js.map