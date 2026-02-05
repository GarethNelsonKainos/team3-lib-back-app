import dotenv from "dotenv";

dotenv.config();

type EnvConfig = {
  port: number;
  databaseUrl?: string;
  pgHost: string;
  pgPort: number;
  pgDatabase: string;
  pgUser: string;
  pgPassword: string;
};

const parseNumber = (value: string | undefined, fallback: number) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
};

export const loadEnv = (): EnvConfig => {
  return {
    port: parseNumber(process.env.PORT, 3001),
    databaseUrl: process.env.DATABASE_URL,
    pgHost: process.env.PGHOST ?? "127.0.0.1",
    pgPort: parseNumber(process.env.PGPORT, 5432),
    pgDatabase: process.env.PGDATABASE ?? "library_dev",
    pgUser: process.env.PGUSER ?? "nialloneill",
    pgPassword: process.env.PGPASSWORD ?? "postgres"
  };
};
