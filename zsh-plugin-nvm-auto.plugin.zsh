#!/bin/bash

__NVM_AUTO_VERSION=""

__nvm_auto_find_rc() {
	local DIR

	DIR="$(pwd)"

	if [ -f "${DIR}/.nvmrc" ] && [ -r "${DIR}/.nvmrc" ]; then
		awk '{print $1; exit 0;}' "${DIR}/.nvmrc"
		return 0
	fi
	while [ "${DIR}" != "/" ]; do
		DIR="$(dirname "${DIR}")"
		if [ -f "${DIR}/.nvmrc" ] && [ -r "${DIR}/.nvmrc" ]; then
			awk '{print $1; exit 0;}' "${DIR}/.nvmrc"
			return 0
		fi
	done
	return 1
}

__nvm_auto_load() {
	local NODE_VERSION

	if ! nvm help &>/dev/null; then
		return 0
	fi

	NODE_VERSION="$(__nvm_auto_find_rc)"
	if [ -z "${NODE_VERSION}" ]; then
		NODE_VERSION="default"
	fi

	if [ "${NODE_VERSION}" != "${__NVM_AUTO_VERSION}" ]; then
		if [ "${NODE_VERSION}" = "default" ]; then
			if [ "$(nvm version default 2>/dev/null)" != "N/A" ]; then
				nvm use default &>/dev/null
			fi
		else
			nvm use "${NODE_VERSION}" &>/dev/null
		fi
		if [ "$?" = "0" ]; then
			__NVM_AUTO_VERSION="${NODE_VERSION}"
		else
			echo "NVM: Failed to find suitable version for ${NODE_VERSION}"
		fi
	fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd __nvm_auto_load
__nvm_auto_load
