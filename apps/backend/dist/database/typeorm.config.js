"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.typeOrmConfig = void 0;
const typeorm_1 = require("typeorm");
const dotenv = require("dotenv");
dotenv.config();
exports.typeOrmConfig = {
    type: 'postgres',
    host: process.env.POSTGRES_HOST || 'localhost',
    port: parseInt(process.env.POSTGRES_PORT || '5432', 10),
    username: process.env.POSTGRES_USER || 'rural_health_user',
    password: process.env.POSTGRES_PASSWORD || 'SecurePassword123!',
    database: process.env.POSTGRES_DB || 'rural_health_db',
    entities: [__dirname + '/../**/*.entity{.ts,.js}'],
    migrations: [__dirname + '/migrations/*{.ts,.js}'],
    synchronize: false,
    logging: process.env.NODE_ENV === 'development',
};
const dataSource = new typeorm_1.DataSource(exports.typeOrmConfig);
exports.default = dataSource;
//# sourceMappingURL=typeorm.config.js.map