export declare class RegisterDto {
    phone_number: string;
    password: string;
    full_name: string;
    village_name: string;
    district_name: string;
    preferred_language?: string;
    emergency_contact_name: string;
    emergency_contact_phone: string;
    role?: string;
}
export declare class LoginDto {
    phone_number: string;
    password: string;
}
