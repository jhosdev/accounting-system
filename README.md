# accounting-system
Base implementation of a double-entry accouting system in Golang

# tools
- [ ] [zerolog](https://github.com/rs/zerolog)
- [ ] [lumberjack](https://github.com/natefinch/lumberjack)
- [ ] [pgx](https://github.com/jackc/pgx/v5)
- [ ] [gqlgen](https://github.com/99designs/gqlgen)
- [ ] [goose](https://github.com/pressly/goose)
- [ ] [chi](https://github.com/go-chi/chi)

# logging

We're using [zerolog](https://github.com/rs/zerolog) for logging.

We're using [lumberjack](https://github.com/natefinch/lumberjack) to rotate logs.

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
