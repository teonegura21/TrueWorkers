import { FirebaseService } from '../firebase/firebase.service';
import { UserSyncService } from '../firebase/user-sync.service';
export interface SetRoleDto {
    uid: string;
    role: 'client' | 'craftsman';
    email?: string;
    name?: string;
}
export declare class FirebaseAuthController {
    private readonly firebaseService;
    private readonly userSyncService;
    constructor(firebaseService: FirebaseService, userSyncService: UserSyncService);
    setUserRole(setRoleDto: SetRoleDto): Promise<{
        success: boolean;
        message: string;
        uid: string;
        role: "client" | "craftsman";
        roleValue: number;
    }>;
    getUserClaims({ uid }: {
        uid: string;
    }): Promise<{
        uid: string;
        email: string;
        customClaims: {
            [key: string]: any;
        };
        disabled: boolean;
        emailVerified: boolean;
    }>;
    verifyToken({ idToken }: {
        idToken: string;
    }): Promise<{
        uid: string;
        email: string;
        role: any;
        roleValue: any;
        emailVerified: boolean;
    }>;
    syncUser(userData: {
        uid: string;
        email: string;
        name?: string;
        role: 'client' | 'craftsman';
        phoneNumber?: string;
    }): Promise<{
        success: boolean;
        user: {
            id: string;
            firebaseUid: string;
            email: string;
            fullName: string;
            role: import("@prisma/client").$Enums.UserRole;
            isVerified: boolean;
        };
    }>;
    getProfile({ uid }: {
        uid: string;
    }): Promise<{
        success: boolean;
        profile: {
            local: {
                id: string;
                createdAt: Date;
                updatedAt: Date;
                email: string;
                firebaseUid: string | null;
                passwordHash: string | null;
                fullName: string;
                role: import("@prisma/client").$Enums.UserRole;
                userType: import("@prisma/client").$Enums.UserType | null;
                city: string;
                county: string;
                address: string | null;
                latitude: number | null;
                longitude: number | null;
                specialties: string[];
                isVerified: boolean;
                averageRating: number;
                totalReviews: number;
                phone: string | null;
                profileImage: string | null;
                bio: string | null;
                rating: number | null;
                reviewCount: number | null;
                profilePicture: string | null;
                portfolioPhotos: string[];
                yearsExperience: number | null;
                skillsTags: string[];
                certifications: string[];
                insuranceVerified: boolean;
                availability: string | null;
            };
            firebase: {
                uid: string;
                email: string;
                displayName: string;
                emailVerified: boolean;
                phoneNumber: string;
                customClaims: {
                    [key: string]: any;
                };
            };
            firestore: any;
        };
    }>;
}
