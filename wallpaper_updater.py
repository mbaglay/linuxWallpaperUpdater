import urllib2
import json
import requests
import shutil
import os
import time
import datetime
import re
import subprocess

BING_DOMAIN = "http://www.bing.com"
IMAGE_NAME = "SAVED_IMAGE.JPG~"
LOGGER_NAME = "WALLPAPER_LOGGER~"

INSTALL_WALLPAPER_COMMAND = ["gsettings", "set", "org.gnome.desktop.background", "picture-uri"]

SECONDS_TO_WAIT_AFTER_EXCEPTION = 60
STATUS_OK = 200

DEFAULT_LOCALE = "en-US"
LIST_OF_SOURCES_TO_GET_LOCALE = ["LC_TIME", "LC_NAME", "LC_IDENTIFICATION", "LANG"]
LOCALE_REGEXP = "[a-zA-Z]{2}[_-][a-zA-Z]{2}"

current_dir = os.getcwd()
PATH_TO_IMAGE = "{0}/{1}".format(current_dir, IMAGE_NAME)
WALLPAPER_LOGGER = "{0}/{1}".format(current_dir, LOGGER_NAME)

def log_text(text, modif='w'):
    with open(WALLPAPER_LOGGER, modif) as f:
        f.write("{0}\n".format(text))

log_text("Updating of wallpaper is started ...", 'w')

current_locale = DEFAULT_LOCALE

for source_of_locale in LIST_OF_SOURCES_TO_GET_LOCALE:
    locale = os.getenv(source_of_locale, "")
    matches = re.findall(LOCALE_REGEXP, locale)
    if len(matches) > 0:
        locale = matches[0]

    if locale:
        locale = list(locale)
        locale[2] = "-"

        current_locale = "".join(locale)
        break

log_text("LOCALE IS: {0}".format(current_locale), 'a')

json_url = "{0}/HPImageArchive.aspx?format=js&idx=0&n=1&mkt={locale}".format(BING_DOMAIN, locale = current_locale)

log_text("JSON URL IS: {0}".format(json_url), 'a')

log_text("Time now is {0}".format(datetime.datetime.now().time()), 'a')

try_to_reconnect = True
while try_to_reconnect:
    try:
        response = urllib2.urlopen(json_url)
        bing_json = response.read()

        log_text("GOT NEXT JSON: {0}".format(bing_json), 'a')

        bing_hash = json.loads(bing_json)

        image_url = "{0}{1}".format(BING_DOMAIN, bing_hash['images'][0]['url'])

        log_text("IMAGE URL IS: {0}".format(image_url), 'a')

        req = requests.get(image_url, stream=True)

        log_text("GOT NEXT response: {0}".format(req), 'a')
    except Exception as exception:
        log_text("GOT exception: {0}".format(exception), 'a')
        log_text("Will retry after {0} seconds ...".format(SECONDS_TO_WAIT_AFTER_EXCEPTION), 'a')
        time.sleep(SECONDS_TO_WAIT_AFTER_EXCEPTION)
    else:
        try_to_reconnect = False

if req.status_code == STATUS_OK:
    with open(PATH_TO_IMAGE, 'wb') as f:
        req.raw.decode_content = True
        shutil.copyfileobj(req.raw, f)

    result_command = INSTALL_WALLPAPER_COMMAND + ["file://{0}".format(PATH_TO_IMAGE)]

    command = " ".join(result_command)
    log_text("RUN COMMAND: {0}".format(command), 'a')

    p = subprocess.Popen(result_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, errors = p.communicate()
    if out:
        log_text("    RESULT: {0}".format(out), 'a')
    if errors:
        log_text("    ERRORS: {0}".format(errors), 'a')
