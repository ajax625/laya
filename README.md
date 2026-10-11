# Laya local Docker setup

Runs the [Laya](https://huggingface.co/convaiinnovations/laya) decision model as an HTTP server
(`laya-serve`, from the `laya` PyPI package) in a container.

## Run
```bash
docker compose up -d --build
docker compose logs -f laya        # first start downloads the model (~0.8 GB); wait for it to finish
./test_request.sh                  # sample request
```
Endpoints: `GET /health`, `POST /v1/systemone`, `POST /v1/systemone/batch` on http://localhost:8000.

## Stop / clean up
```bash
docker compose down                # keep downloaded models
docker compose down -v             # also delete the model cache volume
```

## Notes
- CPU by default. Latency figures on the model page are from a GPU (T4); expect slower on CPU.
- Give Docker Desktop at least 4 GB RAM.
- Settings are environment variables in `docker-compose.yml` (`LAYA_MODELS`, `LAYA_API_KEY`, `LAYA_THREADS`, ...).
- Base checkpoints are near chance zero-shot on the typed-decisions benchmark and ship over-confident,
  so calibrate or fine-tune on your own labeled decisions before relying on outputs.
- Laya is a text/JSON classifier. It is not a time-series or candle model.

## Deploy to Hostinger (Docker Manager + Traefik)
1. Push this repo to GitHub (`ajax625`). `.github/workflows/publish-image.yml` builds the image and
   publishes it to `ghcr.io/ajax625/laya:latest`. After the first run, open the package on GitHub
   (Your profile > Packages > laya > Package settings) and set visibility to Public so the VPS can pull it.
2. Point DNS for `laya.informatrixlabs.com` at the VPS.
3. Hostinger > VPS > Docker Manager > Compose > "Compose manually": paste `docker-compose.hostinger.yml`,
   replace `PASTE_YOUR_API_KEY_HERE` with a key from `openssl rand -hex 32`, then Deploy.
4. Test: `curl -H "Authorization: Bearer YOUR_KEY" https://laya.informatrixlabs.com/health`
