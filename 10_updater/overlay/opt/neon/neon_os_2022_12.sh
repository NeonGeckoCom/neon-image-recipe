#!/bin/bash
# NEON AI (TM) SOFTWARE, Software Development Kit & Application Framework
# All trademark and other rights reserved by their respective owners
# Copyright 2008-2022 Neongecko.com Inc.
# Contributors: Daniel McKnight, Guy Daniels, Elon Gasper, Richard Leeds,
# Regina Bloomstine, Casimiro Ferreira, Andrii Pernatii, Kirill Hrymailo
# BSD-3 License
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
# OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE,  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

core_ref=${1:-dev}
venv_path="/home/neon/venv"
backup_path="/home/neon/.cache/neon/venv_backup"
pip_spec="git+https://github.com/neongeckocom/neoncore@${core_ref}#egg=neon_core[core_modules,skills_required,skills_essential,skills_default,skills_extended,pi]"
timestamp=$(date +"%Y-%m-%d_%H-%M")
update_log_path="/home/neon/.local/state/neon/${timestamp}_update"

backup_venv() {
  echo "Backing up venv"
  cp -r "${venv_path}" "${backup_path}"
  chown -R neon:neon /home/neon
  echo "venv backup complete"
}

remove_backup() {
  echo "Removing venv backup"
  rm -rf "${backup_path}"
}

restore_backup() {
  if [ -d "${backup_path}" ]; then
    rm -rf "${venv_path}"
    mv "${backup_path}" "${venv_path}"
    chown -R neon:neon /home/neon
  else
    echo "No Backup to Restore!"
  fi
}

do_python_update() {
  . "${venv_path}/bin/activate"
  mkdir -p "${update_log_path}"
  pip install --upgrade pip
  pip install --report --upgrade "${pip_spec}" > "${update_log_path}/pip_report.json"
  deactivate
  chown -R neon:neon /home/neon
}

validate_module_load() {
  . "${venv_path}/bin/activate"
  status=$(python3 "${BASE_DIR}/check_neon_modules.py")
  deactivate
  if [ "${status}" == "0" ]; then
    echo "Update success"
    return 0
  else
    echo "Update failed!"
    restore_backup
    return 1
  fi
}

remove_backup
systemctl stop neon
systemctl stop gui-shell
backup_venv || exit 2
do_python_update || echo "Update Failed"
validate_module_load
systemctl start gui-shell
systemctl start neon
