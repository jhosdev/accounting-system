-- +goose Up
-- +goose StatementBegin

CREATE TYPE transaction_type_enum AS ENUM ('Credit', 'Debit');

CREATE TABLE "user" (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    birth_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Lookup tables
CREATE TABLE transaction_type_ext ( -- check again after use case testing to add enum column
    xact_type_code_ext CHAR(2) PRIMARY KEY,
    description VARCHAR(50) NOT NULL
);
CREATE TABLE account_type_ext (
    account_type_ext CHAR(2) PRIMARY KEY,
    description VARCHAR(100) NOT NULL,
    fee INTEGER DEFAULT 0
);
CREATE TABLE entity_type (
    entity_type CHAR(1) PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
CREATE TABLE account_type (
    account_type CHAR(2) PRIMARY KEY,
    description VARCHAR(100) NOT NULL
);

-- Core tables
CREATE TABLE ledger (
    ledger_no INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(100),
    account_type_code CHAR(2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    FOREIGN KEY (user_id) REFERENCES "user"(id),
    FOREIGN KEY (account_type_code) REFERENCES account_type(account_type)
);
CREATE INDEX idx_ledger_user_id ON ledger(user_id);

CREATE TABLE account (
    account_no INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    account_type_ext_code CHAR(2) NOT NULL,
    name VARCHAR(50),
    description VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    FOREIGN KEY (user_id) REFERENCES "user"(id),
    FOREIGN KEY (account_type_ext_code) REFERENCES account_type_ext(account_type_ext)
);
CREATE INDEX idx_account_user_id ON account(user_id);

CREATE TABLE ledger_statement (
    ledger_no INTEGER NOT NULL,
    date DATE NOT NULL,
    closing_balance BIGINT NOT NULL,
    PRIMARY KEY (ledger_no, date),
    FOREIGN KEY (ledger_no) REFERENCES ledger(ledger_no)
);
CREATE INDEX idx_ledger_statement_ledger_no ON ledger_statement(ledger_no);

CREATE TABLE account_statement (
    account_no INTEGER NOT NULL,
    date DATE NOT NULL,
    closing_balance BIGINT NOT NULL,
    total_credit BIGINT NOT NULL,
    total_debit BIGINT NOT NULL,
    PRIMARY KEY (account_no, date),
    FOREIGN KEY (account_no) REFERENCES account(account_no)
);
CREATE INDEX idx_account_statement_account_no ON account_statement(account_no);

CREATE TABLE ledger_transaction (
    ledger_transaction_id SERIAL PRIMARY KEY,
    ledger_no INTEGER NOT NULL,
    ledger_no_debit INTEGER NOT NULL,
    date_time TIMESTAMP WITH TIME ZONE NOT NULL,
    amount INTEGER NOT NULL,
    FOREIGN KEY (ledger_no) REFERENCES ledger(ledger_no),
    FOREIGN KEY (ledger_no_debit) REFERENCES ledger(ledger_no)
);
CREATE INDEX idx_ledger_transaction_ledger_no ON ledger_transaction(ledger_no);
CREATE INDEX idx_ledger_transaction_ledger_no_debit ON ledger_transaction(ledger_no_debit);

CREATE TABLE account_transaction (
    account_transaction_id SERIAL PRIMARY KEY,
    ledger_no INTEGER NOT NULL,
    date_time TIMESTAMP WITH TIME ZONE NOT NULL,
    xact_type_code transaction_type_enum NOT NULL,
    xact_type_code_ext CHAR(2) NOT NULL,
    account_no INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    FOREIGN KEY (ledger_no) REFERENCES ledger(ledger_no),
    FOREIGN KEY (account_no) REFERENCES account(account_no),
    FOREIGN KEY (xact_type_code_ext) REFERENCES transaction_type_ext(xact_type_code_ext)
);

CREATE VIEW account_current_v AS
SELECT 
    a.account_no,
    CURRENT_DATE - INTERVAL '1 day' AS date,
    ast.closing_balance,
    COALESCE((
        SELECT SUM(amount)
        FROM account_transaction att
        WHERE att.account_no = a.account_no
        AND att.xact_type_code_ext IN ('AC', 'Dp')
        AND att.date_time >= DATE_TRUNC('month', CURRENT_DATE)
    ), 0) AS total_credit,
    COALESCE((
        SELECT SUM(amount)
        FROM account_transaction att
        WHERE att.account_no = a.account_no 
        AND att.xact_type_code_ext NOT IN ('AC', 'Dp')
        AND att.date_time >= DATE_TRUNC('month', CURRENT_DATE)
    ), 0) AS total_debit,
    ast.closing_balance + 
    COALESCE((
        SELECT SUM(amount)
        FROM account_transaction att
        WHERE att.account_no = a.account_no
        AND att.xact_type_code_ext IN ('AC', 'Dp')
        AND att.date_time >= DATE_TRUNC('month', CURRENT_DATE)
    ), 0) -
    COALESCE((
        SELECT SUM(amount)
        FROM account_transaction att
        WHERE att.account_no = a.account_no 
        AND att.xact_type_code_ext NOT IN ('AC', 'Dp')
        AND att.date_time >= DATE_TRUNC('month', CURRENT_DATE)
    ), 0) AS current_balance
FROM 
    account a
JOIN 
    account_statement ast ON a.account_no = ast.account_no
WHERE 
    ast.date = DATE_TRUNC('month', CURRENT_DATE);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP VIEW IF EXISTS account_current_v;

DROP TABLE IF EXISTS account_transaction;
DROP TABLE IF EXISTS ledger_transaction;
DROP TABLE IF EXISTS account_statement;
DROP TABLE IF EXISTS ledger_statement;
DROP TABLE IF EXISTS account;
DROP TABLE IF EXISTS ledger;
DROP TABLE IF EXISTS transaction_type_ext;
DROP TABLE IF EXISTS account_type_ext;
DROP TABLE IF EXISTS account_type;
DROP TABLE IF EXISTS entity_type;
DROP TABLE IF EXISTS "user";

DROP TYPE IF EXISTS transaction_type_enum;

-- +goose StatementEnd
