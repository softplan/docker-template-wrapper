#!/bin/bash

# Error exit codes
E_BAD_USAGE=1
E_MISSING_PARAM=2
E_REPO_NOTFOUND=3
E_MISSING_DEPENDENCY=4

# Log level enum
LOG_NONE=-1
LOG_ERROR=0
LOG_INFO=1
LOG_DEBUG=2


# Log into STDOUT or STDERR accorddingly with $1 [msg_log_level] and LOG_LEVEL
#   LOG_LEVEL = 1 is default, so ERROR and INFO.
#
# Params:
#     $1 = [msg_log_level]: error | info | debug. Any other value is ignored
#          and treated as 'info'.
#   To disable all outputs, export LOG_LEVEL=-1
#   To enable all outputs, export LOG_LEVEL=2.
function log()
{
  case $1 in
    error) shift; log_error $@;;
    info) shift; log_info $@;;
    debug) shift; log_debug $@;;
    *) log_info $@;;
  esac
}

# Log into stderr info messages when LOG_LEVEL >= 0 (ERROR)
#   LOG_LEVEL = 1 is default, so this should always print
#   into console.
#   To disable this output, and all others, export LOG_LEVEL=-1
#   before call this script.
function log_error()
{
  if [[ $LOG_LEVEL -ge $LOG_ERROR ]]; then
    (>&2 echo -e "ERROR... " $@)
  fi
}

# Log into stdout info messages when LOG_LEVEL >= 1 (INFO)
#   LOG_LEVEL = 1 is default, so this should always print
#   into console.
#   To disable this output, and all others, export LOG_LEVEL=0
#   before call this script.
function log_info()
{
  if [[ $LOG_LEVEL -ge $LOG_INFO ]]; then
    echo -e $@
  fi
}

# Log into stdout debug messages when LOG_LEVEL >= 2 (DEBUG)
#   LOG_LEVEL = 1 is default, so this should not print into
#   console by default.
#   To enable this output, and all others, export LOG_LEVEL=2
function log_debug()
{
  if [[ $LOG_LEVEL -ge $LOG_DEBUG ]]; then
    echo -e $@
  fi
}

# Exits application with bad usage message for invalid param value.
# It is meant to be used when a valueable option is given, but the value is invalid or missing (blank)
#
# Params:
#     $1 = [param_name]: Name of the param with invalid value.
#     $2 = [param_value]: The invalid value of the param.
function exit_invalid_param_value()
{
  param_name=$1
  param_value=$2

  log error "Missing or invalid param value ${param_name} = \"${param_value}\".\n"
  usage
  exit $E_MISSING_PARAM
}

# Exits application with bad usage message for invalid given option.
# It is meant to be used when a not-valid option is given,
#
# Params:
#     $1 = [option_name]: Not-valid option given.
function exit_invalid_option()
{
  option_name=$1

  log error "Option not recognized: ${option_name}.\n"
  usage
  exit $E_BAD_USAGE
}


# Prints options parsed by this script
# It is meant to be called by application's specific usage() method
function usage_general_options()
{
  echo \
"    -h | --help                                 Shows this help page
    -v | --verbose                              Prints DEBUG level output
    -q | --quiet                                Prints nothing
    [-p | --project-path]=DOCKER_PROJECT_PATH   Docker-template project root folder.
    [-u | --project-url]=DOCKER_PROJECT_URL     Docker-template project repositoy URL.
                                                Use it to updade README file with tags / alias list.
                                                (eg. https://github.com/me/my-project)"
}

# Stripes a arg name from its value, returning only the passed value.
#

# eg. --
function arg_value()
{
  arg=$1

  echo ${arg#*=}
}

################################################################################
####   main
################################################################################

# set default logging level to INFO
LOG_LEVEL=${LOG_LEVEL:-$LOG_INFO}

for arg in $@; do
  case $arg in
    --help | help | -h)
      usage
      exit 0
      ;;

    --verbose | -v)
      LOG_LEVEL=$LOG_DEBUG
      shift
      ;;

    --quiet | -q)
      LOG_LEVEL=$LOG_NONE
      shift
      ;;

    --project-path* | -p*)
      PROJECT_PATH=$(arg_value $arg)
      shift
      if [ ! -f "${PROJECT_PATH}/opts.yml" ]; then
        exit_invalid_param_value "DOCKER_PROJECT_PATH" $PROJECT_PATH
      fi
      ;;

    --project-url* | -u*)
      PROJECT_URL=$(arg_value $arg)
      shift
      if [ -z "${PROJECT_URL}" ]; then
        exit_invalid_param_value "DOCKER_PROJECT_URL" $PROJECT_URL
      fi
      ;;
  esac
done

# Set PROJECT_PATH to parent directory if not given
PROJECT_PATH=${PROJECT_PATH:-$PWD}

if [ ! -f "${PROJECT_PATH}/opts.yml" ]; then
  log error "Docker-template project not found in \"project path\": ${PROJECT_PATH}"
  exit $E_REPO_NOTFOUND
fi
