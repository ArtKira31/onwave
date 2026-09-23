import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, Length, MaxLength } from 'class-validator';
import type { User } from '@prisma/client';

export class GuestSessionRequest {
  @ApiProperty({
    minLength: 16,
    maxLength: 128,
    description: 'Генерируется клиентом один раз и живёт в secure storage.',
  })
  @IsString()
  @Length(16, 128)
  deviceId!: string;
}

export class OAuthLoginRequest {
  @ApiProperty({ description: 'id_token от SDK провайдера.' })
  @IsString()
  @Length(16, 4096)
  idToken!: string;

  @ApiProperty({ description: 'Тот же device-id, что в гостевой сессии — по нему гость апгрейдится.' })
  @IsString()
  @Length(16, 128)
  deviceId!: string;

  @ApiProperty({
    required: false,
    nullable: true,
    description: 'Apple отдаёт имя только при первом входе. Второй раз его не будет.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  fullName?: string;
}

export class RefreshRequest {
  @ApiProperty()
  @IsString()
  @Length(16, 512)
  refreshToken!: string;
}

export class MeDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: ['user', 'organizer', 'moderator', 'admin'] }) role!: string;
  @ApiProperty({ description: 'У гостя нет аккаунта, но есть валидная сессия.' }) isGuest!: boolean;
  @ApiProperty({ nullable: true, type: String }) email!: string | null;
  @ApiProperty({ nullable: true, type: String }) displayName!: string | null;
  @ApiProperty({ nullable: true, type: String }) avatarUrl!: string | null;
  @ApiProperty({ nullable: true, type: String }) acceptedTermsVersion!: string | null;

  static from(user: User): MeDto {
    return {
      id: user.id,
      role: user.role,
      isGuest: user.isGuest,
      email: user.email,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      acceptedTermsVersion: user.acceptedTermsVersion,
    };
  }
}

export class AuthTokensDto {
  @ApiProperty() accessToken!: string;
  @ApiProperty() refreshToken!: string;
  @ApiProperty({ description: 'Время жизни access-токена в секундах.' }) expiresIn!: number;
  @ApiProperty({ type: MeDto }) user!: MeDto;
}
