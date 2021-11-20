# Overview

Simple Laravel environment by Docker and Docker-compose.

Session: Redis

DB client: adminer

| Tool    | URL                    |
| ------- | ---------------------- |
| system  | http://127.0.0.1:8080/ |
| adminer | http://127.0.0.1:9001/ |

# How to start

## Create db folder

```
mkdir db
```

## Change DB name (if you want...)

If you want to change DB name, you need to change change 'docker-compose.yml'.

```
environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: lara_db # Here!!
```

## Start Dcoker

```
docker-compose up -d
```

**It must be executed at first.**
**You need to exchange /src, if you want to use own code.**

## Install laravel and predis by composer (Ver 6.\*, latest ver: remove "6.\_")

```
docker-compose exec php composer create-project --prefer-dist laravel/laravel . "6.*"
docker-compose exec php composer require predis/predis
```

~~docker run --rm -v {Current Directly}/src:/app composer create-project --prefer-dist laravel/laravel . "6.\*"~~

## composer update (If already installed)

```
docker-compose exec php composer update (or install)
```

~~docker run --rm -v {Current Directly}/src:/app composer update ( or install)~~

## Edit `src/.env` file

```
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel # Set DB name
DB_USERNAME=root
DB_PASSWORD=password

SESSION_DRIVER=redis

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379
```

Need to change files's authority in case of WSL2

```
sudo chown {user_name}:{user_name} /src -R
```

Confirm DB work correctly

```
docker-compose exec php php artisan migrate
```

## Setting for DB and Redis

```
'mysql' => [
    'driver' => 'mysql',
    'url' => env('DATABASE_URL'),
    'host' => env('DB_HOST', 'db'), // highlight-line
    'port' => env('DB_PORT', '3306'),
    'database' => env('DB_DATABASE', 'myapp'), // highlight-line
    'username' => env('DB_USERNAME', 'root'), // highlight-line
    'password' => env('DB_PASSWORD', 'root'), // highlight-line
    'unix_socket' => env('DB_SOCKET', ''),
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
    'prefix_indexes' => true,
    'strict' => true,
    'engine' => null,
    'options' => extension_loaded('pdo_mysql') ? array_filter([
        PDO::MYSQL_ATTR_SSL_CA => env('MYSQL_ATTR_SSL_CA'),
    ]) : [],
],

...

'redis' => [

    'client' => env('REDIS_CLIENT', 'predis'),

    'options' => [
        'cluster' => env('REDIS_CLUSTER', 'redis'),
        'prefix' => env('REDIS_PREFIX', Str::slug(env('APP_NAME', 'laravel'), '_').'_database_'),
    ],

    'default' => [
        'url' => env('REDIS_URL'),
        'host' => env('REDIS_HOST', 'redis'), // highlight-line
        'password' => env('REDIS_PASSWORD', null),
        'port' => env('REDIS_PORT', '6379'),
        'database' => env('REDIS_DB', '0'),
    ],

    'cache' => [
        'url' => env('REDIS_URL'),
        'host' => env('REDIS_HOST', 'redis'), // highlight-line
        'password' => env('REDIS_PASSWORD', null),
        'port' => env('REDIS_PORT', '6379'),
        'database' => env('REDIS_CACHE_DB', '1'),
    ],

],
```

## Access

| Tool    | URL                    |
| ------- | ---------------------- |
| system  | http://127.0.0.1:8080/ |
| adminer | http://127.0.0.1:9001/ |

Need to change files's authority in docker container, in case of WSL2

```
docker-compose exec php chown www-data:www-data storage -R
docker-compose exec php chown www-data:www-data bootstrap/cache -R
```

# Plugin for Laravel

## laravel/ui package

```
docker-compose exec php composer require laravel/ui
* For Laravel 6
docker-compose exec php composer require laravel/ui:^1.0 --dev

docker-compose exec php php artisan ui vue --auth

docker run --rm -v {Current Directly}/src:/usr/src/app -w /usr/src/app node npm install
docker run --rm -v {Current Directly}/src:/usr/src/app -w /usr/src/app node npm run dev
or
docker-compose exec php npm install
docker-compose exec php npm run dev
* For Laravel 8
docker-compose exec php npm install vue-loader@^15.9.5 --save-dev --legacy-peer-deps

docker-compose exec php php artisan migrate
```

~~docker run --rm -v {Current Directly}/src:/app composer require laravel/ui~~

~~docker exec -it php php artisan ui vue --auth~~

## Vue Router

```
npm install --save vue-router
```

## Confirm Redis works correctly

```
docker-compose exec redis bash
redis-server --version
# Show Redis version

redis-cli
127.0.0.1:6379> ping
PONG
# It works correctly if PONG returns
```

After login by authority func of Laravel, you can confirm session in redis-cli

```
127.0.0.1:6379> keys *
1) "laravel_database_laravel_cache:xxxxxxxxxxxxxxxxxxxx"
```

Also it can be deleted.

```
127.0.0.1:6379> del "laravel_database_laravel_cache:xxxxxxxxxxxxxxxxxxxx"
(integer) 1
127.0.0.1:6379> keys *
(empty array)
```

# Troubleshooting

## Create encryption key

```
docker-compose exec php php artisan key:generate
```

-> Write down automatically `APP_KEY` in `.env`

## Fail to download files in db

Add this code under mysql in `docker-compose.yml`.

```
depends_on:
      -  php
      -  mysql
user: "1000:50" # Here!!
```

## Too slow and ideas of sollution

It is because of WSL2. Not to use WSL2, then it was improved.
https://stackoverflow.com/questions/63036490/docker-is-extremely-slow-when-running-laravel-on-nginx-container-wsl2

-> Project moves to out of windows mount directly(/mnt).

### Other ideas to improve.

Use "redis" for cash and session.

Reduce mount files.
https://qiita.com/ProjectEuropa/items/c094cfb4aac2968a9901

Use docker-sync.
https://qiita.com/reflet/items/ee15bf6b1b90a3a90905

https://qiita.com/miyawa-tarou/items/7ffdd8af86c57ca80ed1
