-- +goose Up
-- +goose StatementBegin
INSERT INTO transaction_type_ext (xact_type_code_ext, description) VALUES
('AC', 'Adjustment Credit'),
('AD', 'Adjustment Debit'),
('Dp', 'Deposit'),
('FB', 'Bank Fee'),
('LO', 'Loan Out'),
('LR', 'Loan Repayment'),
('Wd', 'Withdrawal'),
('WA', 'ATM Withdrawal');

INSERT INTO account_type_ext (account_type_ext, description) VALUES
('Cq', 'Cheque'),
('Sv', 'Saving'),
('LC', 'LineOfCredit');

INSERT INTO entity_type (entity_type, name) VALUES
('P', 'Person'),
('O', 'Organisation');

INSERT INTO account_type (account_type, description) VALUES
('AA', 'Asset'),
('AL', 'Liability'),
('RR', 'Revenue'),
('RE', 'Expense'),
('GG', 'Gain'),
('GL', 'Loss');
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM transaction_type_ext;
DELETE FROM account_type_ext;
DELETE FROM entity_type;
DELETE FROM account_type;
-- +goose StatementEnd
