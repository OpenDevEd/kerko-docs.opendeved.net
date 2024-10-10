FROM python:3.9-slim

COPY . /tmp/kerkoapp

RUN --mount=type=secret,id=zotero_api_key \
    --mount=type=secret,id=zotero_library_id \
    apt-get update && apt-get install -y --no-install-recommends \
    git npm curl gcc g++ make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --system kerkoapp && \
    useradd --gid kerkoapp --shell /bin/bash --create-home --home-dir /home/kerkoapp --groups www-data kerkoapp && \
    mv /tmp/kerkoapp/tools /home/kerkoapp && \
    mv /tmp/kerkoapp /home/kerkoapp && \
    chown -R kerkoapp:kerkoapp /home/kerkoapp && \
    npm install pm2@latest -g && \
    rm -rf /root/.npm && \
    cd /home/kerkoapp/kerkoapp && \
    mv sample.secrets.toml .secrets.toml && \
    sed -i "s|MY_SECRET_KEY|$(openssl rand -base64 32)|" .secrets.toml && \
    sed -i "s|MY_ZOTERO_API_KEY|$(cat /run/secrets/zotero_api_key)|" .secrets.toml && \
    sed -i "s|9999999|$(cat /run/secrets/zotero_library_id)|" .secrets.toml

USER kerkoapp

RUN cd /home/kerkoapp/kerkoapp && \
    npm i && \
    python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --no-cache-dir -r requirements/run.txt && \
    pip install --no-cache-dir gunicorn posthog && \
    export PATH=$(pwd)/node_modules/.bin:${PATH} && \
    flask assets build

ENTRYPOINT ["/bin/sh", "/home/kerkoapp/tools/entrypoint.sh"]