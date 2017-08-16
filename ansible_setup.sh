#!/usr/bin/env bash

#######################
#  Dependency Checks  #
#######################

# Function to check if referenced command exists
cmd_exists() {
  if [ $# -eq 0 ]; then
    echo 'WARNING: No command argument was passed to verify exists'
  fi

  #cmds=($(echo "${1}"))
  cmds=($(printf '%s' "${1}"))
  fail_counter=0
  for cmd in "${cmds[@]}"; do
    command -v "${cmd}" >&/dev/null # portable 'which'
    rc=$?
    if [ "${rc}" != "0" ]; then
      fail_counter=$((fail_counter+1))
    fi
  done

  if [ "${fail_counter}" -ge "${#cmds[@]}" ]; then
    echo "Unable to find one of the required commands [${cmds[*]}] in your PATH"
    return 1
  fi
}


DEP_PKGS="gcc PyYAML libyaml python-devel make openssl-devel libffi libffi-devel python-setuptools python-setuptools-devel git"
check_depends() {
  yum clean all
  yum list installed $DEP_PKGS > /dev/null
  if [ $? -ne 1 ]; then
    echo "At least some dependencies not found"
    echo "Installing $DEP_PKGS"
    yum clean all && yum install -y $DEP_PKGS
    if [ $? -ne 0 ]; then
      echo "Something went wrong installing. Bailing out"
      exit 1
    else
      echo "Yum dependencies installed successfully."
    fi
  else
    echo "All Yum dependencies present"
  fi
}
  
check_depends
if [ $? -ne 0 ]; then
  echo "Something went wrong installing dependencies"
  exit 1
fi

pip_cmd_list=('pip')
for cmd in "${pip_cmd_list[@]}"; do
  cmd_exists "${cmd[@]}"
  # shellcheck disable=SC2181
  if [ $? -ne 0 ]; then
    echo "Installing Python PIP via Easy_Install"
    easy_install pip
  fi
done

virtenv_cmd_list=(
  'virtualenv virtualenv-2.7 virtualenv-2.5'
)
for cmd in "${virtenv_cmd_list[@]}"; do
  cmd_exists "${cmd[@]}"
  # shellcheck disable=SC2181
  if [ $? -ne 0 ]; then
    echo "Installing Python virtualenv via PIP"
    pip install virtualenv
  fi
done

#######################
#  Library Functions  #
#######################

run() {
    "$@"
    rc=$?
    if [[ $rc -gt 0 ]]; then
        return $rc
    fi
}

if [ ! -d ./.ansible_venv ]; then
    echo "Failed to find a virtualenv, creating one."
    run virtualenv ./.ansible_venv
else
    echo "Found existing virtualenv, using that instead."
fi

. ./.ansible_venv/bin/activate
run pip install --upgrade pip
run pip install --upgrade setuptools
run pip install -r requirements/ansible.txt
run ansible-galaxy install -r ansible/requirements.yml -p ansible/galaxy_roles -f
