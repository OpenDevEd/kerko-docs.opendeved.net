module.exports = {
  apps: [
    {
      "name": "odelib_sync",
      "script": "/home/kerkoapp/kerkoapp/venv/bin/flask kerko sync",
      "cwd": "/home/kerkoapp/kerkoapp",
      "cron_restart": "15 * * * *",
      "env": {
        "PYTHONUNBUFFERED": 1
      },
      "log_file": "/home/kerkoapp/kerkoapp/kerko_sync.log",
      "error_file": "/home/kerkoapp/kerkoapp/kerko_sync.err",
      "autorestart": false,
    }
  ]
}