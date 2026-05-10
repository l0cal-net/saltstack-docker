#!/bin/env python3

import json
import os
import uuid

from urllib.request import urlopen

res = urlopen("https://api.github.com/repos/saltstack/salt/releases?per_page=10")


def set_output(name, value):
    fname = os.getenv("GITHUB_OUTPUT", None)
    if fname:
        delimiter = f"ghadelimiter_{uuid.uuid4().hex}"
        with open(fname, "a") as fp:
            fp.write(f"{name}<<{delimiter}\n{value}\n{delimiter}")
        return
    print(f"::set-output name={name}::{json.dumps(matrix)}")


def split_version(ver):
    return ver.strip("v").split(".")


versions = dict()

for release in json.load(res):
    major, minor = split_version(release["tag_name"])
    if "rc" in minor:
        continue
    if major not in versions:
        versions[major] = f"{major}.{minor}"

matrix = dict(salt=list(versions.values()))

set_output("salt-matrix", json.dumps(matrix))
