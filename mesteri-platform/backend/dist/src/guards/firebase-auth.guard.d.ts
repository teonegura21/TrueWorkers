import { CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { FirebaseService } from '../firebase/firebase.service';
export declare class FirebaseAuthGuard implements CanActivate {
    private firebaseService;
    private reflector;
    private readonly logger;
    constructor(firebaseService: FirebaseService, reflector: Reflector);
    canActivate(context: ExecutionContext): Promise<boolean>;
    private extractTokenFromHeader;
}
