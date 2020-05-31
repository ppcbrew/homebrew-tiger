#!/usr/bin/python -u

# ppctapbot.py: A script to build and upload bottles to a tigerbrew tap.
# See https://github.com/ppcbrew/homebrew-tiger/blob/master/bin/ppctapbot.py

# Copyright (c) 2020 Jason Pepas
# Released under the terms of the MIT license.
# See https://opensource.org/licenses/MIT

# This script was written to work with the version of Python which shipped
# with OS X Tiger (10.4), which is Python 2.3.5.

# See the section about ~/.ppctapbot/config to customize the behavior of this
# script.

import sys
sys.stderr.write("Error: this script isn't finished yet, see build-tap-bottle.sh instead.\n")
sys.exit(1)

import os
import pwd
import grp
import commands
import popen2
import random
import time
import tempfile
import sha

def usage(fd, show_title=True):
    """Prints the usage message to the file descriptor.  Throws on failure."""
    exe = os.path.basename(sys.argv[0])
    if show_title:
        fd.write("%s: a script to build bottles for your tigerbrew tap.\n" % exe)
    fd.write('Usage:\n')
    fd.write("  %s --help\n" % exe)
    fd.write("      Display this help message.\n")
    fd.write('\n')
    fd.write("  %s <formula>\n" % exe)
    fd.write("      Reset /usr/local using /usr/local-golden-base,\n")
    fd.write("      then build and upload a bottle of <tap>/<formula>.\n")
    fd.write("  %s --flavor <flavor> <formula>\n" % exe)
    fd.write("      Reset /usr/local using /usr/local-golden-<flavor>,\n")
    fd.write("      then build and upload a bottle of <tap>/<formula>.\n")
    # fd.write('\n')
    # fd.write("  %s --random\n" % exe)
    # fd.write("      Reset /usr/local using /usr/local-golden-base,\n")
    # fd.write("      then build and upload a bottle of a random formula.\n")
    # fd.write("  %s --random --flavor <flavor>\n" % exe)
    # fd.write("      Reset /usr/local using /usr/local-golden-<flavor>,\n")
    # fd.write("      then build and upload a bottle of a random formula.\n")
    fd.write('\n')
    fd.write("  %s --watch\n" % exe)
    fd.write("  %s --daemonize\n" % exe)
    fd.write("      Watch for files to appear in , resetting /usr/local using /usr/local-golden-base,\n")
    fd.write("      and building and uploading bottles of random formulae.\n")
    fd.write('\n')
    fd.write("  %s --reset\n" % exe)
    fd.write("      Reset /usr/local using /usr/local-golden-base.\n")
    fd.write("  %s --reset <flavor>\n" % exe)
    fd.write("      Reset /usr/local using /usr/local-golden-<flavor>.\n")
    fd.write('\n')

# Configuration defaults.
# Override these by populating ~/.ppctapbot/config with
# space-delimited options, e.g.:
# FIXME

def blind_cmd(cmd, job):
    """Runs the command, logging any failure.
    Returns True/False."""
    log(cmd + '\n', job)
    status, output = commands.getstatusoutput(cmd)
    if status != 0:
        logerr("Error: failed cmd '%s'.\n" % cmd, job)
        logerr(output + '\n', job)
        return False
    return True

def blind_cmds(cmds, job):
    """Runs the list of commands, logging any failures.
    Short-circuits on first error.
    Returns True/False."""
    for cmd in cmds:
        ok = blind_cmd(cmd, job)
        if not ok:
            return False
    return True

def run_cmd(cmd, job):
    """Runs the command, logging any failure.
    Returns (True/False, output)."""
    log(cmd + '\n', job)
    status, output = commands.getstatusoutput(cmd)
    if status != 0:
        logerr("Error: failed cmd '%s'.\n" % cmd, job)
        logerr(output + '\n', job)
        return (False, output)
    return (True, output)

def log_cmd(cmd, job):
    """Runs the command, logging all output.
    Returns True/False."""
    log(cmd + '\n', job)
    # Use Popen4 to get interactive output from the command.
    # Unfortunately, it appears the processes launched by ruby (e.g. configure)
    # will buffer their output, so we still end up getting output in large
    # chunks, rather than line-by-line.
    bufsize = 8
    # Popen4 combines stdout and stderr.
    childproc = popen2.Popen4(cmd, bufsize)
    while True:
        status = childproc.poll()
        if status != -1:
            # -1 means childproc has finished.
            break
        # os.read() is non-blocking.
        output = os.read(childproc.fromchild.fileno(), bufsize)
        if output == '':
            time.sleep(0.25)
            continue
        log(output, job)
    log('\n', job)

    if status != 0:
        logerr("Error: failed cmd '%s'.\n" % cmd, job)
        return False
    return True

def mkdir(path, job):
    """Calls mkdir -p.  Logs and asserts on failure."""
    cmd = "mkdir -p %s" % path
    ok = blind_cmd(cmd, job)
    assert ok

def touch(path, job):
    """Creates an empty file.  Logs and asserts on failure."""
    cmd = "mkdir -p '%s' && touch '%s'" % (os.path.dirname(path), path)
    ok = blind_cmd(cmd, job)
    assert ok

def mv(path_a, path_b, job):
    """Calls mv.  Logs and asserts on failure."""
    cmd = "mv '%s' '%s'" % (path_a, path_b)
    ok = blind_cmd(cmd, job)
    assert ok

def openlog(logname, job):
    """Creates or appends to a log file of the form:
    <logs_dir>/<formula>/<tstamp>.<hostname>/<logname>
    Logs and throws / asserts on failure.
    """
    if job['mode'] in ['reset', 'single', 'watch']:
        # when invoked interactively, don't log to a file.
        return
    fpath = "%s/%s/%s.%s/%s" % (
        job['logs_dir'],
        job['formula'],
        job['tstamp'],
        job['hostname'],
        logname
    )
    dirname = os.path.dirname(fpath)
    mkdir(dirname, job)
    fd = open(fpath, 'a')
    job['log_fpath'] = fpath
    job['log_fd'] = fd

def log(msg, job, err=False):
    """Logs to stdout and a file descriptor.  Throws on failure."""
    if err:
        sys.stderr.write(msg)
        sys.stderr.flush()
    else:
        if job['mode'] != 'daemon':
            sys.stdout.write(msg)
            sys.stdout.flush()
    fd = job.get('log_fd')
    if fd:
        fd.write(msg)
        fd.flush()

def logerr(msg, job):
    """Convenience wrapper for log(err=True).  Throws on failure."""
    log(msg, job, err=True)

def closelog(job):
    """Closes the job's logging file descriptor.  Throws on failure."""
    if 'log_fpath' in job:
        del job['log_fpath']
    if 'log_fd' in job:
        fd = job['log_fd']
        fd.close()
        del job['log_fd']

def is_git_repo(path):
    """Returns True if the path is in a git repo."""
    if not path.startswith('/'):
        path = "./%s" % path
    while path not in ['.', '/']:
        if os.path.isdir("%s/.git" % path):
            return True
        path = os.path.dirname(path)
        continue
    if os.path.isdir("%s/.git" % path):
        return True
    return False

def commit_logs(job):
    """If logs_dir is a git repo, commits and pushes the logs.
    Logs failure, returns True/False."""
    formula = job['formula']
    path = job['logs_dir']
    if not is_git_repo(path):
        return True
    cmds = [
        "cd '%s' && git pull" % path,
        "cd '%s' && git add ." % path,
        "cd '%s' && git commit -m 'Adding build logs for %s'" % (path, formula),
    ]
    return blind_cmds(cmds, job)

def determine_formula_version(job):
    """Determines the (stable) version of job's formula.
    Logs and returns None on failure."""
    formula = job['formula']
    cmd = "brew info %s" % formula
    ok, output = run_cmd(cmd, job)
    if not ok:
        return False
    line0 = output.splitlines()[0]
    words = line0.split()
    if words[0] != "%s:" % formula or words[1] != 'stable':
        logerr("Error: unexpected output from '%s'.\n" % cmd, job)
        logerr(output + '\n', job)
        return False
    version = words[2].rstrip(',')
    job['version'] = version
    return True

def brew_update(job):
    """Runs 'brew update'.  Returns True/False."""
    openlog('update.txt', job)
    log("Updating formulae.\n", job)
    cmd = 'nice brew update --verbose'
    ok = log_cmd(cmd, job)
    if not ok:
        if 'log_fpath' in job:
            logerr("See %s.\n" % job['log_fpath'], job)
        closelog(job)
        return False
    log("Update formulae succeeded.\n", job)
    if 'log_fpath' in job:
        log("See %s.\n" % job['log_fpath'], job)
    closelog(job)
    return True

def format_time(t):
    """Format a duration (seconds, integer) into e.g. 1d3h47m23s.""" 
    t = int(t)
    days = 0
    while t >= 60 * 60 * 24:
        days += 1
        t -= 60 * 60 * 24
    hours = 0
    while t >= 60 * 60:
        hours += 1
        t -= 60 * 60
    minutes = 0
    while t >= 60:
        minutes += 1
        t -= 60
    seconds = t
    s = ""
    if days > 0:
        s += "%dd" % days
    if hours > 0:
        s += "%dh" % hours
    if minutes > 0:
        s += "%dm" % minutes
    s += "%ds" % seconds
    return s

def tap_path(tap_name):
    """Returns the tap path for a tap name.
    e.g. 'ppcbrew/tiger' => '/usr/local/Taps/ppcbrew/homebrew-tiger'"""
    parts = tap_name.split('/')
    return "/usr/local/Library/Taps/%s/homebrew-%s" % (parts[0], parts[1])

def build_formula(job):
    """Builds the job's formula.  Returns True/False."""
    openlog('install.txt', job)
    formula = job['formula']
    tap_name = job['tap_name']
    tap_formula = "%s/%s" % (tap_name, formula)
    log("Building %s.\n" % tap_formula, job)
    then = int(time.time())
    cmd = "nice brew install --verbose --build-bottle %s" % (tap_formula)
    ok = log_cmd(cmd, job)
    if not ok:
        if 'log_fpath' in job:
            logerr("See %s.\n" % job['log_fpath'], job)
        closelog(job)
        return False
    log("Building %s succeeded.\n" % tap_formula, job)
    now = time.time()
    elapsed = now - then
    elapsed = format_time(elapsed)
    log("Elapsed: %s\n" % elapsed, job)
    if 'log_fpath' in job:
        log("See %s.\n" % job['log_fpath'], job)
    closelog(job)
    return True

def compute_sha1(fpath):
    """Compute the sha1 hash of the file."""
    hash = sha.new()
    fd = open(fpath)
    while True:
        data = fd.read(256 * 1024)
        if len(data) == 0:
            break
        hash.update(data)
    fd.close()
    return hash.hexdigest()

def bottle_formula(job):
    """Bottles the job's formula.
    Returns True/False.  Asserts on mkdir failure."""
    openlog('bottle.txt', job)
    formula = job['formula']
    tap_name = job['tap_name']
    tap_formula = "%s/%s" % (tap_name, formula)
    log("Bottling %s.\n" % tap_formula, job)

    # make a tempdir so we can easily discover the name of the bottle file.
    tmpdir = tempfile.mkdtemp()

    # build the bottle.
    cmd = "cd '%s' && nice brew bottle %s" % (tmpdir, tap_formula)
    ok = log_cmd(cmd, job)
    if not ok:
        os.rmdir(tmpdir)
        if 'log_fpath' in job:
            logerr("See %s.\n" % job['log_fpath'], job)
        closelog(job)
        return False
    
    # figure out the filename and os/arch of the bottle which was just built.
    bottle_fname = os.listdir(tmpdir)[0]
    parts = bottle_fname.split('.')
    parts.reverse()
    if parts[1] != 'tar' or parts[2] != 'bottle':
        logerr("Error: unrecognized bottle name '%s'.\n" % bottle_fname, job)
        os.unlink("%s/%s" % (tmpdir, bottle_fname))
        os.rmdir(tmpdir)
        if 'log_fpath' in job:
            logerr("See %s.\n" % job['log_fpath'], job)
        closelog(job)
        return False
    job['bottle_fname'] = bottle_fname
    bottle_arch = parts[3]  # e.g. 'tiger_g3'
    job['bottle_arch'] = bottle_arch

    # compute the sha1.
    sha1 = compute_sha1("%s/%s" % (tmpdir, bottle_fname))
    job['bottle_sha1'] = sha1

    # move bottle to the bottles dir.
    bottles_dir = job['bottles_dir']
    mkdir(bottles_dir, job)
    mv(
        "%s/%s" % (tmpdir, bottle_fname),
        "%s/%s" % (bottles_dir, bottle_fname),
        job
    )
    os.rmdir(tmpdir)

    log("Bottling %s succeeded.\n" % tap_formula, job)
    if 'log_fpath' in job:
        log("See %s.\n" % job['log_fpath'], job)
    closelog(job)
    return True

def upload_bottle(job):
    """Uploads the job's bottle.  Returns True/False."""
    openlog('upload.txt', job)
    formula = job['formula']
    tap_name = job['tap_name']
    tap_formula = "%s/%s" % (tap_name, formula)
    bottle_fname = job['bottle_fname']
    log("Uploading %s bottle %s.\n" % (tap_formula, bottle_fname), job)
    tap_name = job['tap_name']
    script = "%s/bin/upload-bottle-to-b2.py" % tap_path(tap_name)
    bottles_dir = job['bottles_dir']
    cmd = "nice %s %s/%s" % (script, bottles_dir, bottle_fname)
    ok = log_cmd(cmd, job)
    if not ok:
        if 'log_fpath' in job:
            logerr("See %s.\n" % job['log_fpath'], job)
        closelog(job)
        return False
    if job['keep_bottles'] == 'no':
        log("Deleting %s/%s.\n" % (bottles_dir, bottle_fname), job)
        os.unlink("%s/%s" % (bottles_dir, bottle_fname))
    log("Uploading %s bottle %s succeeded.\n" % (tap_formula, bottle_fname), job)
    if 'log_fpath' in job:
        log("See %s.\n" % job['log_fpath'], job)
    closelog(job)
    return True

def add_bottle_to_formula(job):
    """Add an entry to the 'bottle do' section of the formula."""
    # parse the formula.
    # remove any existing bottle entry for our arch.
    # add in an entry for the bottle we just built.
    # ensure the root_url part is ok?
    # commit changes to git.
    # push changes to origin.
    openlog('fixme.txt', job)

    formula = job['formula']
    tap_name = job['tap_name']
    formula_fpath = "%s/Formula/%s.rb" % (tap_path(tap_name), formula)
    log("Adding bottle to formula '%s'.\n" % (formula_fpath), job)
    sha1 = job['bottle_sha1']
    os_arch = job['bottle_arch']
    root_url = job['root_bottles_url']
    script = "%s/bin/add-bottle-to-formula.py" % tap_path(tap_name)
    cmd = "%s '%s' %s %s '%s'" % (script, formula_fpath, sha1, os_arch, root_url)
    ok = blind_cmd(cmd, job)
    if not ok:
        if 'log_fpath' in job:
            logerr("See %s.\n" % job['log_fpath'], job)
        closelog(job)
        return False
    log("Add bottle to formula succeeded.\n", job)

    log("Committing changes to '%s'.\n" % (formula_fpath), job)
    formula_dir = os.path.dirname(formula_fpath)
    cmds = [
        "cd %s && git add %s.rb" % (formula_dir, formula),
        "cd %s && git commit -m 'Adding %s bottle to %s.rb'" \
            % (formula_dir, os_arch, formula),
        "cd %s && git remote set-url origin git@github.com:%s/homebrew-%s" \
            % (formula_dir, tap_name.split('/')[0], tap_name.split('/')[1]),
        "cd %s && git push origin" % formula_dir,
    ]
    ok = blind_cmds(cmds, job)
    if not ok:
        if 'log_fpath' in job:
            logerr("See %s.\n" % job['log_fpath'], job)
        closelog(job)
        return False
    log("Commit changes succeeded.\n", job)

    if 'log_fpath' in job:
        log("See %s.\n" % job['log_fpath'], job)
    closelog(job)
    return True

def reset_usrlocal(flavor, job):
    """Reset /usr/local using a 'golden master' flavor.
    Exits on failure."""
    openlog('reset.txt', job)
    log("Resetting /usr/local using /usr/local-golden-%s.\n" % flavor, job)
    for path in ['/usr/local', "/usr/local-golden-%s" % flavor]:
        stat = os.stat(path)
        uid = stat.st_uid
        user = pwd.getpwuid(uid).pw_name
        gid = stat.st_gid
        group = grp.getgrgid(gid).gr_name
        if user != 'root' or group != 'admin':
            logerr("Error: bad permissions on %s.  Please run:\n" % path, job)
            logerr("  sudo chown root:admin %s\n" % path, job)
            logerr("  sudo chmod 775 %s\n" % path, job)
            closelog(job)
            sys.exit(1)
    #cmd = "rsync -a --delete /usr/local-golden-%s/ /usr/local" % flavor
    # So, the above was the original command, but it fails because setting
    # the mod time on the top-level directory (/usr/local) requires write
    # permission on /usr, which a regular user doesn't have:
    #   rsync: failed to set times on "/usr/local/.": Permission denied (13)
    # It is a shame rsync doesn't have a "sync everything but the containing
    # directory entry" option.  We will have to approximate that as best we can.
    # Thanks to:
    # https://unix.stackexchange.com/questions/42685/rsync-how-to-exclude-the-topmost-directory
    # https://superuser.com/questions/1444389/set-permissions-with-rsync-for-all-files-but-the-root-directory
    cmd = "rsync -a --delete /usr/local-golden-%s/* /usr/local-golden-%s/.[!.]* /usr/local/" \
        % (flavor, flavor)
    ok = blind_cmd(cmd, job)
    if not ok:
        if 'log_fpath' in job:
            logerr("See %s.\n" % job['log_fpath'], job)
        closelog(job)
        sys.exit(1)
    cmd = "rsync -r --delete --existing --ignore-existing /usr/local-golden-%s/ /usr/local/" \
        % flavor
    ok = blind_cmd(cmd, job)
    if not ok:
        if 'log_fpath' in job:
            logerr("See %s.\n" % job['log_fpath'], job)
        closelog(job)
        sys.exit(1)
    log('Resetting /usr/local succeeded.\n', job)
    if 'log_fpath' in job:
        log("See %s.\n" % job['log_fpath'], job)
    closelog(job)

def job_single(job):
    """Build a single, specific formula.  Returns True/False."""
    flavor = job['flavor']
    reset_usrlocal(flavor, job)
    ok = brew_update(job)
    if not ok:
        return False
    ok = build_formula(job)
    if not ok:
        return False
    ok = bottle_formula(job)
    if not ok:
        return False
    ok = upload_bottle(job)
    if not ok:
        return False
    ok = add_bottle_to_formula(job)
    if not ok:
        return False
    return True

def available_formulae(job):
    """Returns the list of available formulae.
    Logs and return None on failure."""
    cmd = "brew search"
    ok, output = run_cmd(cmd, job)
    if not ok:
        return None
    lines = output.splitlines()
    return lines

# def job_loop(job):
#     """Build random formulas in a loop, forever."""
#     while True:
#         log('\n')
#         log('Job: build random formulas.\n')
#         log('  Picking a random formula.\n')
#         formulas = available_formulas()
#         formula = random.choice(formulas)
#         flavor = job['flavor']
#         reset_disk(flavor)
#         build_formula(formula)
#         time.sleep(1)

def load_config():
    """Loads ~/.ppcbrewbot/config.  Exits on failure."""
    config_fpath = "%s/.ppcbrewbot/config" % os.environ['HOME']
    if not os.path.exists(config_fpath):
        sys.stderr.write("Error: ~/.ppcbrewbot/config doesn't exist.\n")
        sys.stderr.write('This config file is a space-delimited set of options.\n')
        sys.stderr.write('\n')
        sys.stderr.write('My config file looks like:\n')
        sys.stderr.write('tap_name ppcbrew/tiger\n')
        sys.stderr.write('logs_dir /Users/bot/github/ppcbrew/logs\n')
        sys.stderr.write('bottles_dir /Users/bot/bottles\n')
        sys.stderr.write('keep_bottles yes\n')
        sys.stderr.write('flavor_sequence base apple-gcc42\n')
        sys.stderr.write('root_bottles_url https://f002.backblazeb2.com/file/bottles\n')
        sys.stderr.write('uploader /usr/local/Library/Taps/ppcbrew/homebrew-tiger/bin/upload-bottle-to-b2.py\n')
        sys.exit(1)
    fd = open(config_fpath)
    lines = fd.readlines()
    fd.close()
    config = {}
    for line in lines:
        parts = line.strip().split(' ', 1)
        config[parts[0]] = parts[1]
    return config

def parse_cmdline():
    """Parse the command-line options.  Exits on failure."""
    opts = sys.argv[1:]
    job = {}
    job['mode'] = None
    job['flavor'] = 'base'
    while len(opts):
        if opts[0] in ['-h', '--help']:
            job['mode'] = 'help'
            opts = opts[1:]
            break
        elif opts[0] == '--reset':
            job['mode'] = 'reset'
            opts = opts[1:]
            if len(opts):
                job['flavor'] = opts[0]
                opts = opts[1:]
            break
        elif opts[0] == '--daemon':
            job['mode'] = 'daemon'
            opts = opts[1:]
            continue
        elif opts[0] == '--watch':
            job['mode'] = 'watch'
            opts = opts[1:]
            continue
        elif opts[0] == '--flavor':
            job['flavor'] = opts[1]
            opts = opts[2:]
            continue
        elif opts[0] == '--random':
            job['mode'] = 'single'
            opts = opts[1:]
            continue
        else:
            job['mode'] = 'single'
            job['formula'] = opts[0]
            opts = opts[1:]
            break
    if len(opts) != 0:
        sys.stderr.write('Error: bad command-line options.\n')
        usage(sys.stderr, show_title=False)
        sys.exit(1)
    return job

if __name__ == '__main__':
    job = parse_cmdline()
    # import pprint
    # pprint.pprint(job)
    # sys.exit(0)
    if job['mode'] == None:
        usage(sys.stderr)
        sys.exit(1)
    if job['mode'] == 'help':
        usage(sys.stdout)
        sys.exit(0)

    if os.geteuid() == 0:
        sys.stderr.write("Error: don't run this as root.\n")
        sys.exit(1)

    config = load_config()
    # job supercedes config
    config.update(job)
    job = config

    consent_fpath = "%s/.ppcbrewbot/PLEASE_CLOBBER_MY_USR_LOCAL" % os.environ['HOME']
    if not os.path.exists(consent_fpath):
        sys.stderr.write(
            "Error: this script clobbers /usr/local, but you haven't consented.\n"
        )
        sys.stderr.write("Please run:\n")
        sys.stderr.write("  mkdir -p %s\n" % os.path.dirname(consent_fpath))
        sys.stderr.write("  touch %s\n" % consent_fpath)
        sys.exit(1)

    if job['mode'] == 'single':
        ok = job_single(job)
        if not ok:
            sys.exit(1)
        sys.exit(0)
    # elif job['mode'] == 'loop':
    #     job_loop(job)
    elif job['mode'] == 'reset':
        reset_usrlocal('base', job)
        sys.exit(0)
    else:
        assert False
