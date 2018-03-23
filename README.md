# Contacto Legislativo

### Setup

Download microservices repositories:

```
  git clone git@github.com:wedevelopmx/contacto-cdn.git /service/cdn
  git clone git@github.com:wedevelopmx/contacto-portal.git /service/portal
  git clone git@github.com:wedevelopmx/contacto-api.git /service/api
```


### Deployment
#### Development

```
  docker-compose build --no-cache
  docker-compose up | start
  docker-compose stop
```

#### Production

```
  docker-compose build --no-cache
  docker-compose -f docker-compose-production.yml up | start
  docker-compose -f docker-compose-production.yml scale api=5 portal=5 cdn=5
  docker-compose logs -f --tail="all"
```
