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

# Cache npm requests so the same package isn't requested repeatedly
package_cache = {}


def get_latest_version(package_name):
    if package_name in package_cache:
        return package_cache[package_name]

    url = f"https://registry.npmjs.org/{package_name}"

    try:
        with urllib.request.urlopen(url, timeout=10) as response:
            data = json.load(response)

        latest = data["dist-tags"]["latest"]
        package_cache[package_name] = latest
        return latest

    except Exception:
        package_cache[package_name] = None
        return None


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

        for package in list(deps.keys()):

            current_version = deps[package]
            latest = get_latest_version(package)

            # Package not found on npm
            if latest is None:
                del deps[package]
                changed = True
                changes.append(
                    f"Removed {package} (package not found)"
                )

                if verbose:
                    print(
                        f"[REMOVE] {path} -> {package}"
                    )

                continue

            new_version = f"^{latest}"

            if current_version != new_version:
                deps[package] = new_version
                changed = True

                changes.append(
                    f"{package}: {current_version} -> {new_version}"
                )

                if verbose:
                    print(
                        f"[UPDATE] {path} -> "
                        f"{package}: "
                        f"{current_version} -> {new_version}"
                    )
            else:
                if verbose:
                    print(
                        f"[OK] {path} -> "
                        f"{package} {current_version}"
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

        # Skip node_modules
        if "node_modules" in dirnames:
            dirnames.remove("node_modules")

        # Skip .git
        if ".git" in dirnames:
            dirnames.remove(".git")

        if "package.json" in filenames:
            yield os.path.join(dirpath, "package.json")


def main():
    verbose = "--verbose" in sys.argv

    root = os.getcwd()

    if verbose:
        print(f"Scanning: {root}\n")

    count = 0

    for package_json in find_package_json_files(root):
        count += 1
        process_package_json(package_json, verbose)

    if verbose:
        print(f"\nProcessed {count} package.json file(s).")


if __name__ == "__main__":
    main()