# Raspberry

git clone https://github.com/crater-invoice/crater

Update content of .env, then
cp .env crater/.env

Copy docker-compose.yml
cp -i docker-compose.yml crater/docker-compose.yml

cd crater
docker-compose up -d
./docker-compose/setup.sh