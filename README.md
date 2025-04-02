# accounting-system
Base implementation of a double-entry accouting system in Golang

# tools
- [ ] [pgx](https://github.com/jackc/pgx/v5)
- [ ] [gqlgen](https://github.com/99designs/gqlgen)
- [ ] [goose](https://github.com/pressly/goose)
- [ ] [chi](https://github.com/go-chi/chi)

# architecture

# database

-> we're gonna store numbers with 2 decimal places but we're gonna use integers to avoid precision issues. Ex: 100.40 -> 10040 in db

## migrations

### create new migration

```bash
goose -s -dir migrations create <name> sql
```

## schema

# api

## graphql
