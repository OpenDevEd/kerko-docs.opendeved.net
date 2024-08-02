import sys

from flask import redirect, url_for
from kerko.config_helpers import config_get

from kerkoapp import create_app
from flask import (redirect, session, request)
from posthog import Posthog
import uuid

try:
    application = app = create_app()
except RuntimeError as e:
    print(e, file=sys.stderr)
    sys.exit(1)

# Initialize Posthog
posthog = Posthog(
    project_api_key=app.config.get('posthog').get("POSTHOG_API_KEY"),
    host=app.config.get('posthog').get("POSTHOG_API_HOST")
)

@app.before_request
def before_request():
    if "user_id" not in session:
        session["user_id"] = str(uuid.uuid4())

@app.get("/toggle-theme")
def toggle_theme():
    current_theme = session.get("theme")
    if current_theme == "dark":
        session["theme"] = "light"
    else:
        session["theme"] = "dark"
    # Capture the toggle-theme event
    posthog.capture(
        session["user_id"],
        "toggle-theme",
        properties={"theme": session["theme"], "$current_url": request.url},
    )
    return redirect(request.referrer)

@app.route('/')
def home():
    return redirect(url_for('kerko.search'))


try:
    proxy_fix_config = config_get(app.config, 'kerkoapp.proxy_fix')
except KeyError:
    pass
else:
    if proxy_fix_config.get('enabled'):
        from werkzeug.middleware.proxy_fix import ProxyFix
        app.wsgi_app = ProxyFix(  # type: ignore
            app.wsgi_app,
            **{
                kwarg: value
                for kwarg, value in proxy_fix_config.items() if kwarg != 'enabled'
            },
        )


@app.shell_context_processor
def make_shell_context():
    """Return context dict for a shell session, giving access to variables."""
    return dict(application=application)
