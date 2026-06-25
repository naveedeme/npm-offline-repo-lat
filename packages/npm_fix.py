#!/usr/bin/env python3

import json
import os
import sys
import urllib.request
import urllib.error

DEPENDENCY_SECTIONS = [
    "dependencies",
    "devDependencies",
    "peerDependencies",
    "optionalDependencies"
]


def get_latest_version(package_name):
    url = f"https://registry.npmjs.org/{package_name}"

    try:
        with urllib.request.urlopen(url) as response:
            data = json.load(response)

        latest = data["dist-tags"]["latest"]
        versions = set(data["versions"].keys())

        return latest, versions

    except urllib.error.HTTPError:
        return None, None
    except Exception:
        return None, None


def process_package_json(path, verbose=False):
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception as e:
        if verbose:
            print(f"ERROR reading {path}: {e}")
        return

    changed = False
    changes = []

    for section in DEPENDENCY_SECTIONS:
        deps = data.get(section)

        if not isinstance(deps, dict):
            continue

        for package, version in list(deps.items()):

            latest, versions = get_latest_version(package)

            if latest is None:
                del deps[package]
                changed = True
                changes.append(f"Removed {package} (not found)")

                if verbose:
                    print(f"{path}: {package} does not exist")
                continue

            clean_version = version.lstrip("^~><= ")

            if clean_version not in versions:
                deps[package] = f"^{latest}"
                changed = True
                changes.append(
                    f"{package}: {version} -> ^{latest}"
                )

                if verbose:
                    print(
                        f"{path}: invalid version for {package} "
                        f"({version}) -> ^{latest}"
                    )
            else:
                if verbose:
                    print(
                        f"{path}: {package}@{version} OK"
                    )

    if changed:
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
            f.write("\n")

        print(f"\n{path}")
        for change in changes:
            print(f"  {change}")


def find_package_json_files(root):
    for dirpath, dirnames, filenames in os.walk(root):

        if "node_modules" in dirnames:
            dirnames.remove("node_modules")

        if "package.json" in filenames:
            yield os.path.join(dirpath, "package.json")


def main():
    verbose = "--verbose" in sys.argv
    root = os.getcwd()

    for package_json in find_package_json_files(root):
        process_package_json(package_json, verbose)


if __name__ == "__main__":
    main()