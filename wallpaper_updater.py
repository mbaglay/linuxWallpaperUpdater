import codecs
import datetime
import json
import os
import re
import requests
import shutil
import subprocess
import sys
import time
import urllib2

BING_DOMAIN = "http://www.bing.com"
IMAGE_NAME = os.getenv("IMAGE_NAME", "SAVED_IMAGE.JPG")
LOGGER_NAME = os.getenv("WALLPAPER_LOGGER", "WALLPAPER_LOGGER")
FILE_TO_SAVE_WALLPAPER_NAME = os.getenv("FILE_TO_SAVE_WALLPAPER_NAME", "IMAGE_NAME")
RETRIES_COUNT_IF_INTERNET_PROBLEM = int(os.getenv("RETRIES_COUNT_IF_INTERNET_PROBLEM", 10))
SAVE_CURRENT_WALLPAPER_LOCALLY = json.loads(os.getenv("SAVE_CURRENT_WALLPAPER_LOCALLY", "True"))
DIRECTORY_TO_SAVE_WALLPAPER = os.getenv("DIRECTORY_TO_SAVE_WALLPAPER", "")
COPYRIGHT_FILE = os.getenv("COPYRIGHT_FILE", "COPYRIGHT")

INSTALL_WALLPAPER_COMMAND = ["gsettings", "set", "org.gnome.desktop.background", "picture-uri"]

SECONDS_TO_WAIT_AFTER_EXCEPTION = 60
STATUS_OK = 200

DEFAULT_LOCALE = "en-US"
LIST_OF_SOURCES_TO_GET_LOCALE = ["LC_TIME", "LC_NAME", "LC_IDENTIFICATION", "LANG"]
LOCALE_REGEXP = "[a-zA-Z]{2}[_-][a-zA-Z]{2}"

current_dir = os.getcwd()
PATH_TO_IMAGE = "{0}/{1}".format(current_dir, IMAGE_NAME)
WALLPAPER_LOGGER = "{0}/{1}".format(current_dir, LOGGER_NAME)

def log_text(text, modif='a'):
    with open(WALLPAPER_LOGGER, modif) as f:
        f.write("{0}\n".format(text))

log_text("")
log_text("===== Updating of wallpaper is started ... =====")

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

log_text("LOCALE IS: {0}".format(current_locale))

json_url = "{0}/HPImageArchive.aspx?format=js&idx=0&n=1&mkt={locale}".format(BING_DOMAIN, locale = current_locale)

log_text("JSON URL IS: {0}".format(json_url))

log_text("TIME NOW IS {0}".format(datetime.datetime.now()))

retries_count = 0
try_to_reconnect = True
while try_to_reconnect:
    try:
        response = urllib2.urlopen(json_url)
        bing_json = response.read()

        log_text("GOT NEXT JSON: {0}".format(bing_json))

        bing_hash = json.loads(bing_json)

        copyright_info = bing_hash['images'][0]['copyright']

        with codecs.open(COPYRIGHT_FILE, encoding='utf-8', mode='w') as f:
            f.write(u"{0}".format(copyright_info))
            log_text("WROTE COPYRIGHT INFO TO {0}".format(COPYRIGHT_FILE))

        image_url = "{0}{1}".format(BING_DOMAIN, bing_hash['images'][0]['url'])

        image_name = image_url.split('/')[-1]

        log_text("IMAGE NAME IS: {0}".format(image_name))

        if os.path.exists(FILE_TO_SAVE_WALLPAPER_NAME):
            wallpaper_file_with_name = open(FILE_TO_SAVE_WALLPAPER_NAME, 'r')
            current_wallpaper_name = wallpaper_file_with_name.read()
            log_text("CURRENT WALLPAPER NAME IS: {0}".format(current_wallpaper_name))
            if image_name == current_wallpaper_name:
                log_text("CURRENT WALLPAPER IS THE FRESH ONE!")
                log_text("WALLPAPER WILL NOT BE UPDATED. IT IS UNNECESSARY.")
                sys.exit(0)

        log_text("IMAGE URL IS: {0}".format(image_url))

        req = requests.get(image_url, stream=True)

        log_text("GOT NEXT RESPONSE: {0}".format(req))

        if req.status_code == STATUS_OK:
            with open(PATH_TO_IMAGE, 'wb') as f:
                req.raw.decode_content = True
                shutil.copyfileobj(req.raw, f)

            result_command = INSTALL_WALLPAPER_COMMAND + ["file://{0}".format(PATH_TO_IMAGE)]

            command = " ".join(result_command)
            log_text("RUN COMMAND: {0}".format(command))

            p = subprocess.Popen(result_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            out, errors = p.communicate()
            if out:
                log_text("    RESULT: {0}".format(out))
            if errors:
                log_text("    ERRORS: {0}".format(errors))
            else:
                image_to_save = "{0}/{1}_{2}".format(DIRECTORY_TO_SAVE_WALLPAPER, datetime.datetime.now().date(), image_name)

                if not os.path.exists(DIRECTORY_TO_SAVE_WALLPAPER):
                    os.makedirs(DIRECTORY_TO_SAVE_WALLPAPER)
                    log_text("CREATED DIRECTORY {0} AS IT DID NOT EXIST".format(DIRECTORY_TO_SAVE_WALLPAPER))

                if not os.path.exists(image_to_save):
                    shutil.copy(PATH_TO_IMAGE, image_to_save)
                    log_text("SAVED IMAGE {0}".format(image_to_save))

                log_text("WROTE {0} TO {1}".format(image_name, FILE_TO_SAVE_WALLPAPER_NAME))
                with open(FILE_TO_SAVE_WALLPAPER_NAME, 'w') as f:
                    f.write("{0}".format(image_name))

    except Exception as exception:
        log_text("-----------")
        log_text("GOT EXCEPTION: {0}".format(exception))
        log_text("TIME NOW IS {0}".format(datetime.datetime.now()))
        log_text("ALREADY TRIED TO RECONNECT {0} TIMES".format(retries_count))
        log_text("WILL RETRY AFTER {0} SECONDS ...".format(SECONDS_TO_WAIT_AFTER_EXCEPTION))

        if retries_count >= RETRIES_COUNT_IF_INTERNET_PROBLEM:
            try_to_reconnect = False

        retries_count = retries_count + 1
        time.sleep(SECONDS_TO_WAIT_AFTER_EXCEPTION)
    else:
        try_to_reconnect = False
