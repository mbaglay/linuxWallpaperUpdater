import urllib2
import json
import requests
import shutil
import os

BING_DOMAIN = "http://www.bing.com"
IMAGE_NAME = "SAVED_IMAGE.JPG~"
INSTALL_WALLPAPER_COMMAND = "gsettings set org.gnome.desktop.background picture-uri file://"

current_dir = os.getcwd()
PATH_TO_IMAGE = "{0}/{1}".format(current_dir, IMAGE_NAME)

json_url = "{0}/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=uk-UA".format(BING_DOMAIN)

response = urllib2.urlopen(json_url)
bing_json = response.read()
bing_hash = json.loads(bing_json)

image_url = "{0}{1}".format(BING_DOMAIN, bing_hash['images'][0]['url'])

req = requests.get(image_url, stream=True)

if req.status_code == 200:
    with open(PATH_TO_IMAGE, 'wb') as f:
        req.raw.decode_content = True
        shutil.copyfileobj(req.raw, f)

    os.system("{0}{1}".format(INSTALL_WALLPAPER_COMMAND, PATH_TO_IMAGE))