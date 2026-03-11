#!/bin/env python3

import json

from urllib.request import urlopen

res = urlopen("https://api.github.com/repos/saltstack/salt/releases?per_page=10")


def split_version(ver):
    return ver.strip("v").split(".")


versions = dict()

for release in json.load(res):
    major, minor = split_version(release["tag_name"])
    if major not in versions:
        versions[major] = release["tag_name"]

matrix = dict(salt=list(versions.values()))

print("::set-output name=salt-matrix::" + json.dumps(matrix))
