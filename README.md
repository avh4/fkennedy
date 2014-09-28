
# Dev mode

```bash
elm-get install
elm-reactor -p 40008 &
npm install
node app.js &
open http://localhost:40008/index.elm
```

# Production

```bash
elm --bundle-runtime --make index.elm
```
