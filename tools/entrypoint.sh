#!/bin/bash

cd ~/kerkoapp
. venv/bin/activate
pm2 start ~/tools/ecosystem.config.js
exec gunicorn --workers 3 --bind '0.0.0.0:5000' wsgi:app