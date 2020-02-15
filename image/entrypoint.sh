#!/bin/sh
# Copyright Stryd, Inc. February 2020 - All rights reserved.

# Disallow unset variables.
set -o nounset

echo "RAINIER-BUILD"

# Handle reporting reasons when we exit
report_reason() {
  REASON=${1:-Unspecified}
  echo :set-output name=reason::${REASON}
  exit 1
}

report_success() {
  REASON=${1:-Success}
  echo :set-output name=reason::${REASON}
  exit 0
}

DEFAULT_EXEC=make
EXEC=

# Handle argument processing

# Set when we want to consume a specific type of positional argument
POS_NEEDED=

# Set to true/false/init/multi.  
# true  - we asked for an arg this step
# false - we asked for an arg, and then didn't provide one.
# init  - a special case to handle the first unspecified positional.
# multi - we can take a sequence of arguments
POS_FRESH=init

# Use the remaining argument list verbatim
POS_USE_ALL=

# Process positional arguments one at a time
POS_IMPLICIT_OK=true

# Run the code when we're ready
DO_RUN=true

# Print lots of extra information
VERBOSE_LEVEL=1
ARGS_LIST="$*"

while [ -n "${1:-}" ] ; do
  arg="${1}"
  shift 1

  case $arg in
    ## --       pass the remaining arguments directly to the exec
    -- )
    POS_USE_ALL=true
    break
    ;;

    ## --help   print usage info
    --help | -h )
    echo "Usage: $0 [options]"
    sed -n -e "s/^[ \t]*##[ \t]*\(.*\)$/\1/p" $0
    report_success "--help" 
    ;;

    ## --exec   set the executable (make)
    --exec | -x )
    POS_NEEDED=exec
    POS_FRESH=true
    ;;

    ## --target set the target to be run
    --target | -t )
    POS_NEEDED=target
    POS_FRESH=true
    ;;

    ## --no-target (the default behavior)
    --no-target | -T )
    TARGET=
    ;;

    ## --no-implicit-args require args to be set explicitly
    --no-implicit-args | -A )
    POS_IMPLICIT_OK=false
    ;;

    ## --dryrun Print what we would run and stop
    --dryrun | --dry-run )
    DO_RUN=false
    ;;

    ## --verbose Increase the verbosity
    -v | --verbose )
    VERBOSE_LEVEL=$((VERBOSE_LEVEL+1))
    ;;

    ## --quiet Decrease the verbosity
    -q | --quiet )
    VERBOSE_LEVEL=$((VERBOSE_LEVEL-1))
    ;;

    # Perform positional argument handling here
    * )
    case "${POS_NEEDED}" in
      exec )
        EXEC="${arg}"
        ;;

      target )
        TARGET="${arg}"
        ;;

      * )
        # Read in positional arguments if they haven't been provided yet.
        if [ "${POS_IMPLICIT_OK}" != "true" ] ; then
          report_reason "Unexpected positional argument - implicits disabled"
        elif [ -z "${EXEC:-}" ] ; then
          EXEC="${arg}"
        elif [ -z "${TARGET:-}" ] ; then
          TARGET="${arg}"
        else
          report_reason "Unexpected positional argument"
        fi
        ;;
    esac
    if [ "${POS_FRESH}" != "multi" ] ; then
      POS_NEEDED=
    fi
    ;;
esac

if [ "${POS_FRESH}" = "false" ] && [ -n "${POS_NEEDED}" ] ; then
  report_reason "Missing positional argument"
fi
if [ "${POS_FRESH}" = "true" ] ; then
  POS_FRESH=false
fi
done

if [ "${VERBOSE_LEVEL}" -gt 0 ] ; then
  echo "ARGS LIST: ${ARGS_LIST}"
fi

RETVAL=0
if [ "${DO_RUN}" = "true" ] ; then
  # Perform the actual build
  echo :set-output name=time_start::$(date -u)
  REASON=Success
  (
    # Echo the following lines, and terminate on an error
    set -x -e 
    "${EXEC:-${DEFAULT_EXEC}}" ${TARGET:+"${TARGET}"} ${POS_USE_ALL:+"$@"}
  ) ; RETVAL=$?
  echo :set-output name=time_end::$(date -u)
else
  echo "Dryrun Mode.  Would have run:"
  echo "${EXEC:-${DEFAULT_EXEC}}" ${TARGET:+"${TARGET}"} ${POS_USE_ALL:+"$@"}
fi

# Handle cleanup
if [ "${RETVAL}" -eq "0" ] ; then
  report_success
else
  report_reason "Application exited with code: ${RETVAL}"
fi

