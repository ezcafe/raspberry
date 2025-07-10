# ntfy

## Create user

```bash
-- List users
docker exec -it ntfy ntfy user list

-- Create admin user
docker exec -it ntfy ntfy user add --role=admin <your-user-name>
```
