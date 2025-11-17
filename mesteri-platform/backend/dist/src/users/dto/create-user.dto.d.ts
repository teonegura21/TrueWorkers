export declare class CreateUserDto {
    email: string;
    password: string;
    firstName?: string;
    lastName?: string;
    name?: string;
    phone?: string;
    location?: string;
    role: 'client' | 'master';
    specialty?: string;
    experience?: string;
}
