# NEON AI (TM) SOFTWARE, Software Development Kit & Application Framework
# All trademark and other rights reserved by their respective owners
# Copyright 2008-2022 Neongecko.com Inc.
# Contributors: Daniel McKnight, Guy Daniels, Elon Gasper, Richard Leeds,
# Regina Bloomstine, Casimiro Ferreira, Andrii Pernatii, Kirill Hrymailo
# BSD-3 License
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
# OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE,  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import json
import os

import pytz
import requests
from subprocess import check_output
from datetime import datetime


def get_commit_and_time(repo, branch="master"):
    last_commit = requests.get(f"https://api.github.com/repos/neongeckocom/{repo}/commits?sha={branch}").json()[0]
    # pprint(last_commit)
    commit_sha = last_commit.get("sha")
    commit_time = datetime.strptime(last_commit.get("commit").get("committer").get("date"),
                                    '%Y-%m-%dT%H:%M:%SZ').replace(tzinfo=pytz.UTC).timestamp()
    return commit_sha, commit_time


def get_base_image_info():
    base_image_filename = os.getenv('BASE_IMAGE')
    if not base_image_filename:
        return {'name': "unknown",
                'time': "unknown"}
    try:
        name, time = base_image_filename.split('_', 1)
        timestamp = datetime.strptime(time, '%Y-%m-%d_%H_%M').replace(tzinfo=pytz.UTC).timestamp()
        return {'name': name,
                'time': timestamp}
    except Exception as e:
        print(e)
        return {'name': "unknown",
                'time': "unknown"}

def get_project_meta(core_branch="dev"):
    try:
        image_sha = check_output(["git", "rev-parse",
                                  "HEAD"]).decode("utf-8").rstrip('\n')
        image_time = datetime.utcnow().timestamp()
    except Exception as e:
        print(e)
        image_sha, image_time = get_commit_and_time("neon-image-recipe")

    core_sha, core_time = get_commit_and_time("neoncore", "dev")

    core_version = "unknown"
    core_version_file = requests.get(f"https://raw.githubusercontent.com/"
                                     f"neongeckocom/neoncore/{core_branch}/"
                                     f"version.py").content.decode('utf-8')
    for line in core_version_file.split('\n'):
        if line.startswith("__version__"):
            if '"' in line:
                core_version = line.split('"')[1]
            else:
                core_version = line.split("'")[1]

    meta = {"image": {
        "sha": image_sha,
        "time": image_time
    },
        "core": {
            "sha": core_sha,
            "time": core_time,
            "version": core_version
    },
        "base_os": get_base_image_info()
    }
    return meta


if __name__ == "__main__":
    print(json.dumps(get_project_meta()))
