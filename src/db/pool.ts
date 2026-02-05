import { Pool } from "pg";
import { loadEnv } from "../config/env.js";

const env = loadEnv();

export const pool = new Pool(
  env.databaseUrl
    ? { connectionString: env.databaseUrl }
    : {
        host: env.pgHost,
        port: env.pgPort,
        database: env.pgDatabase,
        user: env.pgUser,
        password: env.pgPassword
      }
);
