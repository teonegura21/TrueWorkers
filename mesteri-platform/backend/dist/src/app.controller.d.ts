import { FirebaseService } from './firebase/firebase.service';
export declare class AppController {
    private firebaseService;
    constructor(firebaseService: FirebaseService);
    getHealth(): {
        status: string;
        timestamp: string;
        service: string;
        version: string;
        firebase: string;
    };
    getFirebaseStatus(): {
        firebase: {
            status: string;
            projectId: string;
            environment: string;
            timestamp: string;
        };
    };
}
