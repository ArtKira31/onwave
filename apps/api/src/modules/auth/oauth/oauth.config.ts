export type OAuthProvider = 'google' | 'apple';

export interface ProviderConfig {
  issuers: string[];
  jwksUri: string;
  /** Поле env со списком допустимых audience через запятую. */
  audienceEnv: 'GOOGLE_CLIENT_IDS' | 'APPLE_CLIENT_IDS';
}

export const PROVIDERS: Record<OAuthProvider, ProviderConfig> = {
  google: {
    // Google исторически выписывает issuer и с https://, и без — принимаются оба.
    issuers: ['https://accounts.google.com', 'accounts.google.com'],
    jwksUri: 'https://www.googleapis.com/oauth2/v3/certs',
    audienceEnv: 'GOOGLE_CLIENT_IDS',
  },
  apple: {
    issuers: ['https://appleid.apple.com'],
    jwksUri: 'https://appleid.apple.com/auth/keys',
    audienceEnv: 'APPLE_CLIENT_IDS',
  },
};
