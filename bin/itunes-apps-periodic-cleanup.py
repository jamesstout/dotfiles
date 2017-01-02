#!/usr/bin/env python3

"""Periodically clean up "Previous Mobile Applications" of iTunes."""

import arrow
import humanize
import datetime
import json
import os
import sys
import logging

OFFENDING_DIR = os.path.expanduser("~/Music/iTunes/iTunes Media/Mobile Applications/Previous Mobile Applications")
STORAGE_DIR = os.path.expanduser("~/.local/share/itunes")
STORAGE_FILE = os.path.join(STORAGE_DIR, "previous-mobile-applications.json")
DELETED_FILE = os.path.join(STORAGE_DIR, "deleted-previous-mobile-applications.json")

DELETE_AFTER = datetime.timedelta(days=7)

LOG_FILENAME = os.path.join(STORAGE_DIR, "app_cleanup.log")
FORMAT = "%(asctime)s - %(levelname)s - %(message)s"
logging.basicConfig(filename=LOG_FILENAME,level=logging.DEBUG, format=FORMAT)

logging.debug('Starting cleanup')

def convert_bytes(num):
    """
    this function will convert bytes to MB.... GB... etc
    """
    for x in ['bytes', 'KB', 'MB', 'GB', 'TB']:
        if num < 1024.0:
            return "%3.1f %s" % (num, x)
        num /= 1024.0


def file_size(file_path):
    """
    this function will return the file size
    """
    if os.path.isfile(file_path):
        file_info = os.stat(file_path)
        # return humanize.naturalsize(file_info.st_size)
        return file_info.st_size

def load_storage():
    """Load stored dictionary of seen apps from STORAGE_FILE.

    Returns
    -------
    seen_app_dict : dict
        Dictionary of (app_filename, first_seen_date) key-value pairs,
        where app_filename is str, and last_seen_date is datetime.date.

    """
    os.makedirs(STORAGE_DIR, mode=0o700, exist_ok=True)
    try:
        with open(STORAGE_FILE, encoding="utf-8") as fp:
            serializable_seen_app_dict = json.load(fp)
            return {app_filename: arrow.get(serialized_first_seen_date).date()
                    for app_filename, serialized_first_seen_date in serializable_seen_app_dict.items()}
    except OSError:
        return {}

def load_deleted():
    """Load stored dictionary of seen apps from STORAGE_FILE.

    Returns
    -------
    deleted_app_dict : dict
        Dictionary of (app_filename, deleted_date) key-value pairs,
        where app_filename is str, and deleted_date is datetime.date.

    """
    os.makedirs(STORAGE_DIR, mode=0o700, exist_ok=True)
    try:
        with open(DELETED_FILE, encoding="utf-8") as fp:
            serializable_deleted_app_dict = json.load(fp)
            return {app_filename: arrow.get(serialized_deleted_date).date()
                    for app_filename, serialized_deleted_date in serializable_deleted_app_dict.items()}
    except OSError:
        return {}


def write_storage(seen_app_dict):
    """Write the dictionary of seen apps to STORAGE_FILE.

    Parameters
    ----------
    seen_app_dict : dict
        See the return format of load_storage().

    Returns
    -------
    0 or 1
        Return code indicating success or failure.

    """
    # convert datetime.time to str (ISO 8601)
    serializable_seen_app_dict = {app_filename: first_seen_date.isoformat()
                                  for app_filename, first_seen_date in seen_app_dict.items()}
    os.makedirs(STORAGE_DIR, mode=0o700, exist_ok=True)
    try:
        with open(STORAGE_FILE, mode="w", encoding="utf-8") as fp:
            json.dump(serializable_seen_app_dict, fp, indent=2, sort_keys=True)
        return 0
    except OSError as err:
        sys.stderr.write("error: failed to write to '%s': %s" % (STORAGE_FILE, str(err)))
        logging.error("failed to write to '%s': %s" % (STORAGE_FILE, str(err)))
        return 1

def write_deleted(deleted_app_dict):
    """Write the dictionary of deleted apps to DELETED_FILE.

    Parameters
    ----------
    deleted_app_dict : dict
        See the return format of load_deleted().

    Returns
    -------
    0 or 1
        Return code indicating success or failure.

    """
    # convert datetime.time to str (ISO 8601)
    serializable_deleted_app_dict = {app_filename: deleted_date.isoformat()
                                  for app_filename, deleted_date in deleted_app_dict.items()}
    os.makedirs(STORAGE_DIR, mode=0o700, exist_ok=True)
    try:
        with open(DELETED_FILE, mode="w", encoding="utf-8") as fp:
            json.dump(serializable_deleted_app_dict, fp, indent=2, sort_keys=True)
        return 0
    except OSError as err:
        sys.stderr.write("error: failed to write to '%s': %s" % (DELETED_FILE, str(err)))
        logging.error("failed to write to '%s': %s" % (DELETED_FILE, str(err)))
        return 1


def main():
    """Main.

    Returns
    -------
    0 or 1
        Return code indicating success or failure.

    """
    if not os.path.isdir(OFFENDING_DIR):
        # good, you don't have that junk
        return 0

    today = datetime.date.today()
    seen_app_dict = load_storage()
    deleted_app_dict = load_deleted()
    current_app_list = os.listdir(OFFENDING_DIR)

    # boot already disappeared apps
    for app in [app for app in seen_app_dict if app not in current_app_list]:
        seen_app_dict.pop(app)

    # add newly appeared apps
    for app in [app for app in current_app_list if app not in seen_app_dict]:
        seen_app_dict[app] = today

    # delete expired apps
    returncode = 0
    total_deleted_bytes = 0
    newly_deleted_apps = []
    for app in seen_app_dict:
        if today >= seen_app_dict[app] + DELETE_AFTER:
            app_path = os.path.join(OFFENDING_DIR, app)
            try:
                size = file_size(app_path)
                total_deleted_bytes += size
                # sys.stdout.write("Deleted: '%s' : %s\n" % (app, humanize.naturalsize(size)))
                logging.info("Deleted: '%s' : %s" % (app, humanize.naturalsize(size)))
                os.remove(app_path)
                newly_deleted_apps.append(app)
            except OSError as err:
                sys.stderr.write("error: failed to remove '%s': %s" % (app_path, str(err)))
                logging.error("failed to remove '%s': %s" % (app_path, str(err)))
                returncode = 1

    for app in newly_deleted_apps:
        seen_app_dict.pop(app)
        deleted_app_dict[app] = today

    # sys.stdout.write("Total deleted: %s\n" % (humanize.naturalsize(total_deleted_bytes)))
    logging.info("Total deleted: %s" % (humanize.naturalsize(total_deleted_bytes)))
    # write data to disk
    returncode |= write_storage(seen_app_dict)
    returncode |= write_deleted(deleted_app_dict)

    logging.debug("Cleanup completed\n")
    logging.shutdown()
    return returncode

if __name__ == "__main__":
    exit(main())
