-- Create liquibase schema if it does not exist
CREATE SCHEMA IF NOT EXISTS liquibase;

-- Give all privileges on the new schema to user
GRANT ALL PRIVILEGES ON liquibase.* TO 'user'@'%';

