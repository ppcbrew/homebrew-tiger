#!/usr/bin/python

# Copyright (c) 2020 Jason Pepas
# Released under the terms of the MIT License.
# See https://opensource.org/licenses/MIT

# This script uploads a file to Backblaze's B2 object storage service.

# This script is written for the Python interpreter which shipped
# with OS X Tiger (10.4), which is Python 2.3.5.

# However, it does rely on curl from homebrew, to leverage its
# more recent TLS implementation.

# Thanks to https://gist.github.com/jonas-hagen/64f5e30af321446561a01d606128e201

import sys
import os
import commands
import re
import sha

# Each of these functions sucessively builds up a "config" object.

def curl_path(config):
    """Find the latest curl from tigerbrew."""
    versions = os.listdir('/usr/local/Cellar/curl')
    versions.sort()
    latest = versions[-1]
    curl = "/usr/local/Cellar/curl/%s/bin/curl" % latest
    config['curl'] = curl
    return config

def load_backblaze_config(config):
    """Load the ~/.backblaze.conf config file.
    Example file:
    application_key_id 123456
    application_key 123456
    bucket_id 123456
    """
    fd = open("%s/.backblaze.conf" % os.environ['HOME'])
    for line in fd.readlines():
        words = line.split()
        config[words[0]] = words[1]
    fd.close()
    return config

def compute_sha1(config):
    """Compute the sha1 hash of the file to be uploaded."""
    file = config['bottle']
    hash = sha.new()
    fd = open(file)
    while True:
        data = fd.read(256 * 1024)
        if len(data) == 0:
            break
        hash.update(data)
    fd.close()
    config['sha1'] = hash.hexdigest()
    return config

def b2_authorize_account(config):
    """Make a call to the backblaze b2_authorize_account endpoint."""
    curl = config['curl']
    api_url = 'https://api.backblaze.com/b2api/v2/b2_authorize_account'
    cmd = "%s -s --fail --show-error -u '%s:%s' %s" % (
        curl,
        config['application_key_id'],
        config['application_key'],
        api_url
    )
    status, output = commands.getstatusoutput(cmd)
    if status != 0:
        sys.stderr.write(output + '\n')
        if status > 255:
            status = 1
        sys.exit(status)

    # ugh, json wasn't introduced until Python 2.6!
    # parse out the apiUrl from the response.
    regex = re.compile('"apiUrl"\s*:\s*"(.+?)"', flags=re.MULTILINE)
    m = regex.search(output)
    if m is None:
        sys.stderr.write("Error: can't parse apiUrl from API response:\n%s" % output)
        sys.exit(1)
    api_url = m.group(1)

    # parse out the authorizationToken from the response.
    regex = re.compile('"authorizationToken"\s*:\s*"(.+?)"', flags=re.MULTILINE)
    m = regex.search(output)
    if m is None:
        sys.stderr.write("Error: can't parse authorizationToken from API response:\n%s" % output)
        sys.exit(1)
    auth_token = m.group(1)

    config['api_url'] = api_url
    config['auth_token'] = auth_token
    return config

def b2_get_upload_url(config):
    """Make a call to the backblaze b2_get_upload_url endpoint."""
    curl = config['curl']
    api_url = "%s/b2api/v2/b2_get_upload_url" % config['api_url']
    cmd = "%s -s --fail --show-error -H 'Authorization: %s' -d '{\"bucketId\": \"%s\"}' %s" % (
        curl,
        config['auth_token'],
        config['bucket_id'],
        api_url
    )
    status, output = commands.getstatusoutput(cmd)
    if status != 0:
        sys.stderr.write(output + '\n')
        if status > 255:
            status = 1
        sys.exit(status)

    # parse out the uploadUrl from the response.
    regex = re.compile('"uploadUrl"\s*:\s*"(.+?)"', flags=re.MULTILINE)
    m = regex.search(output)
    if m is None:
        sys.stderr.write("Error: can't parse uploadUrl from API response:\n%s" % output)
        sys.exit(1)
    upload_url = m.group(1)

    # parse out the authorizationToken from the response.
    regex = re.compile('"authorizationToken"\s*:\s*"(.+?)"', flags=re.MULTILINE)
    m = regex.search(output)
    if m is None:
        sys.stderr.write("Error: can't parse authorizationToken from API response:\n%s" % output)
        sys.exit(1)
    auth_token = m.group(1)

    config['upload_url'] = upload_url
    config['auth_token'] = auth_token
    return config

def b2_upload_file(config):
    """Make a call to the backblaze API to upload a file."""
    curl = config['curl']
    cmd = "%s -s --fail --show-error" % config['curl'] \
        + " -H 'Authorization: %s'" % config['auth_token'] \
        + " -H 'X-Bz-File-Name: %s'" % os.path.basename(config['bottle']) \
        + " -H 'Content-Type: application/octect-stream'" \
        + " -H 'X-Bz-Content-Sha1: %s'" % config['sha1'] \
        + " --data-binary '@%s'" % config['bottle'] \
        + " %s" % config['upload_url']
    status, output = commands.getstatusoutput(cmd)
    if status != 0:
        sys.stderr.write(output + '\n')
        if status > 255:
            status = 1
        sys.exit(status)

if __name__ == '__main__':
    if len(sys.argv) == 1:
        sys.stderr.write('Error: no bottle file specified.\n')
        sys.exit(1)
    config = {}
    config['bottle'] = sys.argv[1]
    sys.stdout.write('Uploading %s.\n' % config['bottle'])
    config = curl_path(config)
    config = load_backblaze_config(config)
    sys.stdout.write('  Computing sha1 of bottle.\n')
    config = compute_sha1(config)
    sys.stdout.write('  Logging in to backblaze.\n')
    config = b2_authorize_account(config)
    sys.stdout.write('  Requesting an upload URL.\n')
    config = b2_get_upload_url(config)
    sys.stdout.write('  Uploading file.\n')
    b2_upload_file(config)
    sys.stdout.write('Done.\n')
