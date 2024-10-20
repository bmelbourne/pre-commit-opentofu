#!/usr/bin/env bash
set -eo pipefail

# globals variables
# shellcheck disable=SC2155 # No way to assign to readonly variable in separate lines
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_common.sh
. "$SCRIPT_DIR/_common.sh"

# set up default insertion markers.  These will be changed to the markers used by
# terraform-docs if the hook config contains `--use-standard-markers=true`
insertion_marker_begin="<!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->"
insertion_marker_end="<!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->"

# these are the standard insertion markers used by terraform-docs
readonly standard_insertion_marker_begin="<!-- BEGIN_TF_DOCS -->"
readonly standard_insertion_marker_end="<!-- END_TF_DOCS -->"

function main {
  common::initialize "$SCRIPT_DIR"
  common::parse_cmdline "$@"
  common::export_provided_env_vars "${ENV_VARS[@]}"
  common::parse_and_export_env_vars
  # Support for setting relative PATH to .terraform-docs.yml config.
  for i in "${!ARGS[@]}"; do
    ARGS[i]=${ARGS[i]/--config=/--config=$(pwd)\/}
  done
  # shellcheck disable=SC2153 # False positive
  tofu_check_ "${HOOK_CONFIG[*]}" "${ARGS[*]}" "${FILES[@]}"
}

#######################################################################
# TODO Function which checks `terraform-docs` exists
# Arguments:
#   hook_config (string with array) arguments that configure hook behavior
#   args (string with array) arguments that configure wrapped tool behavior
#   files (array) filenames to check
#######################################################################
function tofu_check_ {
  local -r hook_config="$1"
  local -r args="$2"
  shift 2
  local -a -r files=("$@")

  # Get hook settings
  IFS=";" read -r -a configs <<< "$hook_config"

  if [[ ! $(command -v terraform-docs) ]]; then
    echo "ERROR: terraform-docs is required by tofu_docs pre-commit hook but is not installed or in the system's PATH."
    exit 1
  fi

  tofu_docs "${configs[*]}" "${args[*]}" "${files[@]}"
}

#######################################################################
# Wrapper around `terraform-docs` tool that check and change/create
# (depends on provided hook_config) OpenTofu documentation in
# markdown format
# Arguments:
#   hook_config (string with array) arguments that configure hook behavior
#   args (string with array) arguments that configure wrapped tool behavior
#   files (array) filenames to check
#######################################################################
function tofu_docs {
  local -r hook_config="$1"
  local -r args="$2"
  shift 2
  local -a -r files=("$@")

  local -a paths

  local index=0
  local file_with_path
  for file_with_path in "${files[@]}"; do
    file_with_path="${file_with_path// /__REPLACED__SPACE__}"

    paths[index]=$(dirname "$file_with_path")

    ((index += 1))
  done

  local -r tmp_file=$(mktemp)

  #
  # Get hook settings
  #
  local text_file="README.md"
  local add_to_existing=false
  local create_if_not_exist=false
  local use_standard_markers=false

  read -r -a configs <<< "$hook_config"

  for c in "${configs[@]}"; do

    IFS="=" read -r -a config <<< "$c"
    key=${config[0]}
    value=${config[1]}

    case $key in
      --path-to-file)
        text_file=$value
        ;;
      --add-to-existing-file)
        add_to_existing=$value
        ;;
      --create-file-if-not-exist)
        create_if_not_exist=$value
        ;;
      --use-standard-markers)
        use_standard_markers=$value
        ;;
    esac
  done

  if [ "$use_standard_markers" = true ]; then
    # update the insertion markers to those used by terraform-docs
    insertion_marker_begin="$standard_insertion_marker_begin"
    insertion_marker_end="$standard_insertion_marker_end"
  fi

  # Override formatter if no config file set
  if [[ "$args" != *"--config"* ]]; then
    local tf_docs_formatter="md"

  # Suppress terraform_docs color
  else

    local config_file=${args#*--config}
    config_file=${config_file#*=}
    config_file=${config_file% *}

    local config_file_no_color
    config_file_no_color="$config_file$(date +%s).yml"

    if [ "$PRE_COMMIT_COLOR" = "never" ] &&
      [[ $(grep -e '^formatter:' "$config_file") == *"pretty"* ]] &&
      [[ $(grep '  color: ' "$config_file") != *"false"* ]]; then

      cp "$config_file" "$config_file_no_color"
      echo -e "settings:\n  color: false" >> "$config_file_no_color"
      args=${args/$config_file/$config_file_no_color}
    fi
  fi

  local dir_path
  for dir_path in $(echo "${paths[*]}" | tr ' ' '\n' | sort -u); do
    dir_path="${dir_path//__REPLACED__SPACE__/ }"

    pushd "$dir_path" > /dev/null || continue

    #
    # Create file if it not exist and `--create-if-not-exist=true` provided
    #
    if $create_if_not_exist && [[ ! -f "$text_file" ]]; then
      dir_have_tf_files="$(
        find . -maxdepth 1 -type f | sed 's|.*\.||' | sort -u | grep -oE '^tofu|^tf$|^tfvars$' ||
          exit 0
      )"

      # if no TF files - skip dir
      [ ! "$dir_have_tf_files" ] && popd > /dev/null && continue

      dir="$(dirname "$text_file")"

      mkdir -p "$dir"

      # Use of insertion markers, where there is no existing README file
      {
        echo -e "# ${PWD##*/}\n"
        echo "$insertion_marker_begin"
        echo "$insertion_marker_end"
      } >> "$text_file"
    fi

    # If file still not exist - skip dir
    [[ ! -f "$text_file" ]] && popd > /dev/null && continue

    #
    # If `--add-to-existing-file=true` set, check is in file exist "hook markers",
    # and if not - append "hook markers" to the end of file.
    #
    if $add_to_existing; then
      HAVE_MARKER=$(grep -o "$insertion_marker_begin" "$text_file" || exit 0)

      if [ ! "$HAVE_MARKER" ]; then
        # Use of insertion markers, where addToExisting=true, with no markers in the existing file
        echo "$insertion_marker_begin" >> "$text_file"
        echo "$insertion_marker_end" >> "$text_file"
      fi
    fi

    # shellcheck disable=SC2086
    terraform-docs $tf_docs_formatter $args ./ > "$tmp_file"

    # Use of insertion markers to insert the terraform-docs output between the markers
    # Replace content between markers with the placeholder - https://stackoverflow.com/questions/1212799/how-do-i-extract-lines-between-two-line-delimiters-in-perl#1212834
    perl_expression="if (/$insertion_marker_begin/../$insertion_marker_end/) { print \$_ if /$insertion_marker_begin/; print \"I_WANT_TO_BE_REPLACED\\n\$_\" if /$insertion_marker_end/;} else { print \$_ }"
    perl -i -ne "$perl_expression" "$text_file"

    # Replace placeholder with the content of the file
    perl -i -e 'open(F, "'"$tmp_file"'"); $f = join "", <F>; while(<>){if (/I_WANT_TO_BE_REPLACED/) {print $f} else {print $_};}' "$text_file"

    rm -f "$tmp_file"

    popd > /dev/null
  done

  # Cleanup
  rm -f "$config_file_no_color"
}

[ "${BASH_SOURCE[0]}" != "$0" ] || main "$@"
