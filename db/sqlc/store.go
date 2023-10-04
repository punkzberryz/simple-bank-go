package db

import (
	"context"
	"database/sql"
	"fmt"
)

// Store provies all the functions to execute db queries and tx
type Store struct {
	*Queries
	db *sql.DB
}

func NewStore(db *sql.DB) *Store {
	return &Store{
		db:      db,
		Queries: New(db),
	}
}

// executes a function withthin a database transaction
func (store *Store) execTx(ctx context.Context, fn func(*Queries) error) error {
	tx, err := store.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}

	q := New(tx)
	err = fn(q)

	if err != nil {
		if rbErr := tx.Rollback(); rbErr != nil {
			return fmt.Errorf("tx err: %v, rb err: %v", err, rbErr)
		}
		return err
	}
	return tx.Commit()
}

type TransferTxParam struct {
	FromtAccountID int64 `json:"from_account_id"`
	ToAccountID    int64 `json:"to_account_id"`
	Amount         int64 `json:"amount"`
}

type TransferTxResult struct {
	Transfer     Transfer `json:"transfer"`
	FromtAccount Account  `json:"from_account"`
	ToAccount    Account  `json:"to_account"`
	Amount       int64    `json:"amount"`
}

// perform a money transfer
// it creates a transfer recoard -> add account entires -> update account balance
func (store *Store) TransferTx(ctx context.Context, arg TransferTxParam) (TransferTxResult, error) {}
