# DeleteDups

> delete all duplicated files in paths provided.
 
# To add this app to another app dependencies:

```elixir
defp deps do
    [
        #some other deps...
        {:delete_dups, "~> 0.0.0"},
    ]
```

# Up and Running

- check mongodb installation then run mongo instance:
```bash
mongod --port 5000
```

- run app by:
```bash
export DATA_BASE='choose_name'
iex -S mix
```

# Modules in this App:

- **DeleteDups**:

      main function to run: will receive paths you want to scan and options

- **DB**:

      Define all needed functions to interact with the database: find, update, insert and delete.

- **Utils**:

      Define all needed functions used by main module, the hash function used to generate unique hash depending on it's content, surfer of folders and handling db insert or update.

- **Delete**:

      deleted matches between files
