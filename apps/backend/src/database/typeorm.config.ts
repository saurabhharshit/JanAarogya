// apps/backend/src/database/typeorm.config.ts
import { DataSource, DataSourceOptions } from 'typeorm';
import * as dotenv from 'dotenv';

dotenv.config();

export const typeOrmConfig: DataSourceOptions = {
  type: 'postgres',
  host: process.env.POSTGRES_HOST || 'localhost',
  port: parseInt(process.env.POSTGRES_PORT || '5432', 10),
  username: process.env.POSTGRES_USER || 'rural_health_user',
  password: process.env.POSTGRES_PASSWORD || 'SecurePassword123!',
  database: process.env.POSTGRES_DB || 'rural_health_db',
  entities: [__dirname + '/../**/*.entity{.ts,.js}'],
  migrations: [__dirname + '/migrations/*{.ts,.js}'],
  synchronize: false, // Strict migration control for production safety
  logging: process.env.NODE_ENV === 'development',
};

const dataSource = new DataSource(typeOrmConfig);
export default dataSource;