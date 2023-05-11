# Cal.com

## Update the calcom submodule

```
git submodule update --remote --init
```

## Build and start Cal.com via docker compose

```
docker compose up --build
```

## (First Run) Open a browser to http://localhost:5555 to look at or modify the database content.

a. Click on the User model to add a new user record.

b. Fill out the fields (remembering to encrypt your password with BCrypt) and click Save 1 Record to create your first user.

## Start Cal.com

Open a browser to http://localhost:3000 and login with your just created, first user.

## (Second Run) Comment out studio