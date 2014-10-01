
# Dev mode

```bash
(cd web && elm-get install)
elm-reactor -p 40008 &
npm install
node app.js &
open http://localhost:40008/index.elm
```

## Simulating answers

```bash
curl -X GET 'http://localhost:4008/api/v1/reportAnswer?Text=Aaron&From=777777'
```

# Production

```bash
(cd web && elm --bundle-runtime --make index.elm)
```
