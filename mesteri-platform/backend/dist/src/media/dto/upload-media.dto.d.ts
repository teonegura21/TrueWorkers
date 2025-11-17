export declare enum MediaCategory {
    PORTFOLIO = "PORTFOLIO",
    PROFILE = "PROFILE",
    JOB = "JOB",
    BEFORE_AFTER = "BEFORE_AFTER",
    INSPIRATION = "INSPIRATION"
}
export declare class UploadMediaDto {
    category: MediaCategory;
    entityId?: string;
}
