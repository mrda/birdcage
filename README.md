# Birdcage

_Birdcage_ is a place where you'll find lots of canaries to do various interesting things.

---

## git-canary.sh

Checks to see if a local git checkout has been modified.

```shell
[mrda@laptop birdcage]$ ./git-canary.sh -h
git-canary.sh: See if there's any local modifications to a git checkout
Usage: git-canary.sh [options]
  -g  --git-dir      <dir>     The git repository directory (optional).  Uses CANARY_GIT_DIR environment variable otherwise
  -h  --help                   Display this help information
  -v  --verbose                Be verbose about what we're doing
  -w  --work-dir     <dir>     The git checkout directory.  Uses CANARY_WORK_DIR environment variable otherwise

If you want this to run automatically, add the following line to your crontab:
    0 3 * * * /directory/to/git-canary.sh
git-canary.sh: You need to define the git checkout directory in CANARY_WORK_DIR or specify it via the -w <dir> parameter
```

## sql-canary.sh

Checks to see if there's any SQL dumps (compressed or otherwise) in a DOCROOT for a web browser.


```shell
[mrda@laptop birdcage]$ ./sql-canary.sh -h
sql-canary.sh: Look for SQL dumps that shouldn't be there.
Usage: sql-canary.sh [options]
  -a  --add-suffix   <suffix>  Add <suffix> to list to search for
  -d  --docroot      <dir>     Search in directory <dir>, otherwise use the environment variable CANARY_DOCROOT
  -h  --help                   Display this help information
  -o  --output                 Always print the output of the search
  -v  --verbose                Be verbose about what we're doing

If you want this to run automatically, add the following line to your crontab:
    0 3 * * * /directory/to/sql-canary.sh
```

## Help

You can try contacting Michael Davies <michael-birdcage@the-davies.net>

