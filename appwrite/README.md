# Appwrite

## Running the Appwrite Docker installer tool 
docker run -it --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume "$(pwd)"/appwrite:/usr/src/code/appwrite:rw \
    --entrypoint="install" \
    appwrite/appwrite

## Setup Appwrite

- HTTP Port: 19981
- HTTPS Port: 19980
- API key: any
- Appwrite hostname: example.com
- DNS A record hostname: appwrite.example.com

## Signup

Go to
http://<your-ip>:19981 
to signup