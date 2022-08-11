import json
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
        }}
    return meta


if __name__ == "__main__":
    print(json.dumps(get_project_meta()))
