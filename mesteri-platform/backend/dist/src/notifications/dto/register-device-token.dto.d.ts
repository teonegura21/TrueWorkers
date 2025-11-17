export declare enum DevicePlatform {
    IOS = "IOS",
    ANDROID = "ANDROID",
    WEB = "WEB"
}
export declare class RegisterDeviceTokenDto {
    token: string;
    platform: DevicePlatform;
}
