import { IsString, IsNotEmpty, IsPhoneNumber, MinLength, IsOptional, IsIn } from 'class-validator';

export class RegisterDto {
  @IsPhoneNumber()
  @IsNotEmpty()
  phone_number: string;

  @IsString()
  @MinLength(6)
  password: string;

  @IsString()
  @IsNotEmpty()
  full_name: string;

  @IsString()
  @IsNotEmpty()
  village_name: string;

  @IsString()
  @IsNotEmpty()
  district_name: string;

  @IsString()
  @IsOptional()
  preferred_language?: string;

  @IsString()
  @IsNotEmpty()
  emergency_contact_name: string;

  @IsPhoneNumber()
  @IsNotEmpty()
  emergency_contact_phone: string;

  @IsString()
  @IsOptional()
  @IsIn(['patient', 'chw', 'doctor', 'admin'])
  role?: string;
}

export class LoginDto {
  @IsPhoneNumber()
  @IsNotEmpty()
  phone_number: string;

  @IsString()
  @IsNotEmpty()
  password: string;
}