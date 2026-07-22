export type LocalizationLanguage = Record<string, any>;
export type LocalizationLanguages = Record<string, LocalizationLanguage>;

export interface LocalizationOptions {
  split?: boolean;
}

export interface LocalizationManifestLanguage {
  name?: string;
  flag?: string;
  src?: string;
  [key: string]: unknown;
}

export type LocalizationManifest = Record<string, string | LocalizationManifestLanguage>;

export interface LocalizationErrorState {
  cache: Record<string, boolean>;
  throw(code: string, details?: any): void;
}

export class Localization {
  constructor(url: string, fallback?: string, options?: LocalizationOptions);

  onready?: () => void;
  onerror?: (error: string, details?: any) => void;
  onchange?: (language: string) => void;

  languages: LocalizationLanguages;
  preferred: string;
  default: string;
  ready: boolean;
  mode: "bundle" | "split";
  source: string;
  manifest: LocalizationManifest;
  loaded: Record<string, boolean>;
  pending: Promise<void>;
  err: LocalizationErrorState;

  active: string;

  render(value: unknown, data?: Record<string, unknown> | null): string;
  lookup(path: string | string[], fallback?: unknown): unknown;
  text(path: string | string[], fallback?: string, data?: Record<string, unknown> | null): string;
  table(path: string | string[]): Record<string, any>;
  use(language: string): Promise<string>;
  load(language: string): Promise<boolean>;

  [key: string]: any;
}

export const flags: Record<string, string>;

declare global {
  interface HTMLElementTagNameMap {
    "language-selector": HTMLElement;
  }
}
