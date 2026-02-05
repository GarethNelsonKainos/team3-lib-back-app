import pgPromise from 'pg-promise';

const pgp = pgPromise();

const connection = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'library',
  user: process.env.DB_USER || process.env.PGUSER || process.env.USER || 'postgres',
  password: process.env.DB_PASSWORD || process.env.PGPASSWORD || '',
};

export const db = pgp(connection);
