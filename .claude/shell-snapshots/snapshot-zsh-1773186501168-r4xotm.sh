# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
___sdkman_check_candidates_cache () {
	local candidates_cache="$1" 
	if [[ -f "$candidates_cache" && -z "$(< "$candidates_cache")" ]]
	then
		__sdkman_echo_red 'WARNING: Cache is corrupt. SDKMAN cannot be used until updated.'
		echo ''
		__sdkman_echo_no_colour '  $ sdk update'
		echo ''
		return 1
	else
		__sdkman_echo_debug "Using existing cache: $SDKMAN_CANDIDATES_CSV"
		return 0
	fi
}
___sdkman_help () {
	if [[ -f "$SDKMAN_DIR/libexec/help" ]]
	then
		"$SDKMAN_DIR/libexec/help"
	else
		__sdk_help
	fi
}
__arguments () {
	# undefined
	builtin autoload -XUz
}
__bun_dynamic_comp () {
	local comp="" 
	for arg in scripts
	do
		local line
		while read -r line
		do
			local name="$line" 
			local desc="$line" 
			name="${name%$'\t'*}" 
			desc="${desc/*$'\t'/}" 
			echo
		done <<< "$arg"
	done
	return $comp
}
__kubectl_debug () {
	local file="$BASH_COMP_DEBUG_FILE" 
	if [[ -n ${file} ]]
	then
		echo "$*" >> "${file}"
	fi
}
__sdk_config () {
	local -r editor=(${EDITOR:=vi}) 
	if ! command -v "${editor[@]}" > /dev/null
	then
		__sdkman_echo_red "No default editor configured."
		__sdkman_echo_yellow "Please set the default editor with the EDITOR environment variable."
		return 1
	fi
	"${editor[@]}" "${SDKMAN_DIR}/etc/config"
}
__sdk_current () {
	local candidate="$1" 
	echo ""
	if [ -n "$candidate" ]
	then
		__sdkman_determine_current_version "$candidate"
		if [ -n "$CURRENT" ]
		then
			__sdkman_echo_no_colour "Using ${candidate} version ${CURRENT}"
		else
			__sdkman_echo_red "Not using any version of ${candidate}"
		fi
	else
		local installed_count=0 
		for ((i = 0; i <= ${#SDKMAN_CANDIDATES[*]}; i++)) do
			if [[ -n ${SDKMAN_CANDIDATES[${i}]} ]]
			then
				__sdkman_determine_current_version "${SDKMAN_CANDIDATES[${i}]}"
				if [ -n "$CURRENT" ]
				then
					if [ ${installed_count} -eq 0 ]
					then
						__sdkman_echo_no_colour 'Using:'
						echo ""
					fi
					__sdkman_echo_no_colour "${SDKMAN_CANDIDATES[${i}]}: ${CURRENT}"
					((installed_count += 1))
				fi
			fi
		done
		if [ ${installed_count} -eq 0 ]
		then
			__sdkman_echo_no_colour 'No candidates are in use'
		fi
	fi
}
__sdk_default () {
	__sdkman_deprecation_notice "default"
	local candidate version
	candidate="$1" 
	version="$2" 
	__sdkman_check_candidate_present "$candidate" || return 1
	__sdkman_determine_version "$candidate" "$version" || return 1
	if [ ! -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${VERSION}" ]
	then
		echo ""
		__sdkman_echo_red "Stop! Candidate version is not installed."
		echo ""
		__sdkman_echo_yellow "Tip: Run the following to install this version"
		echo ""
		__sdkman_echo_yellow "$ sdk install ${candidate} ${VERSION}"
		return 1
	fi
	__sdkman_link_candidate_version "$candidate" "$VERSION"
	echo ""
	__sdkman_echo_green "Default ${candidate} version set to ${VERSION}"
}
__sdk_env () {
	local -r sdkmanrc=".sdkmanrc" 
	local -r subcommand="$1" 
	case $subcommand in
		("") __sdkman_load_env "$sdkmanrc" ;;
		(init) __sdkman_create_env_file "$sdkmanrc" ;;
		(install) __sdkman_setup_env "$sdkmanrc" ;;
		(clear) __sdkman_clear_env "$sdkmanrc" ;;
	esac
}
__sdk_flush () {
	local qualifier="$1" 
	case "$qualifier" in
		(version) if [[ -f "${SDKMAN_DIR}/var/version" ]]
			then
				rm -f "${SDKMAN_DIR}/var/version"
				__sdkman_echo_green "Version file has been flushed."
			fi ;;
		(temp) __sdkman_cleanup_folder "tmp" ;;
		(tmp) __sdkman_cleanup_folder "tmp" ;;
		(metadata) __sdkman_cleanup_folder "var/metadata" ;;
		(*) __sdkman_cleanup_folder "tmp"
			__sdkman_cleanup_folder "var/metadata" ;;
	esac
}
__sdk_help () {
	__sdkman_deprecation_notice "help"
	__sdkman_echo_no_colour ""
	__sdkman_echo_no_colour "Usage: sdk <command> [candidate] [version]"
	__sdkman_echo_no_colour "       sdk offline <enable|disable>"
	__sdkman_echo_no_colour ""
	__sdkman_echo_no_colour "   commands:"
	__sdkman_echo_no_colour "       install   or i    <candidate> [version] [local-path]"
	__sdkman_echo_no_colour "       uninstall or rm   <candidate> <version>"
	__sdkman_echo_no_colour "       list      or ls   [candidate]"
	__sdkman_echo_no_colour "       use       or u    <candidate> <version>"
	__sdkman_echo_no_colour "       config"
	__sdkman_echo_no_colour "       default   or d    <candidate> [version]"
	__sdkman_echo_no_colour "       home      or h    <candidate> <version>"
	__sdkman_echo_no_colour "       env       or e    [init|install|clear]"
	__sdkman_echo_no_colour "       current   or c    [candidate]"
	__sdkman_echo_no_colour "       upgrade   or ug   [candidate]"
	__sdkman_echo_no_colour "       version   or v"
	__sdkman_echo_no_colour "       help"
	__sdkman_echo_no_colour "       offline           [enable|disable]"
	if [[ "$sdkman_selfupdate_feature" == "true" ]]
	then
		__sdkman_echo_no_colour "       selfupdate        [force]"
	fi
	__sdkman_echo_no_colour "       update"
	__sdkman_echo_no_colour "       flush             [tmp|metadata|version]"
	__sdkman_echo_no_colour ""
	__sdkman_echo_no_colour "   candidate  :  the SDK to install: groovy, scala, grails, gradle, kotlin, etc."
	__sdkman_echo_no_colour "                 use list command for comprehensive list of candidates"
	__sdkman_echo_no_colour "                 eg: \$ sdk list"
	__sdkman_echo_no_colour "   version    :  where optional, defaults to latest stable if not provided"
	__sdkman_echo_no_colour "                 eg: \$ sdk install groovy"
	__sdkman_echo_no_colour "   local-path :  optional path to an existing local installation"
	__sdkman_echo_no_colour "                 eg: \$ sdk install groovy 2.4.13-local /opt/groovy-2.4.13"
	__sdkman_echo_no_colour ""
}
__sdk_home () {
	__sdkman_deprecation_notice "home"
	local candidate version
	candidate="$1" 
	version="$2" 
	__sdkman_check_version_present "$version" || return 1
	__sdkman_check_candidate_present "$candidate" || return 1
	__sdkman_determine_version "$candidate" "$version" || return 1
	if [[ ! -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]
	then
		echo ""
		__sdkman_echo_red "Stop! Candidate version is not installed."
		echo ""
		__sdkman_echo_yellow "Tip: Run the following to install this version"
		echo ""
		__sdkman_echo_yellow "$ sdk install ${candidate} ${version}"
		return 1
	fi
	echo -n "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}"
}
__sdk_install () {
	local candidate version folder
	candidate="$1" 
	version="$2" 
	folder="$3" 
	__sdkman_check_candidate_present "$candidate" || return 1
	__sdkman_determine_version "$candidate" "$version" "$folder" || return 1
	if [[ -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${VERSION}" || -L "${SDKMAN_CANDIDATES_DIR}/${candidate}/${VERSION}" ]]
	then
		echo ""
		__sdkman_echo_yellow "${candidate} ${VERSION} is already installed."
		return 0
	fi
	if [[ ${VERSION_VALID} == 'valid' ]]
	then
		__sdkman_determine_current_version "$candidate"
		__sdkman_install_candidate_version "$candidate" "$VERSION" || return 1
		if [[ "$sdkman_auto_answer" != 'true' && "$auto_answer_upgrade" != 'true' && -n "$CURRENT" ]]
		then
			__sdkman_echo_confirm "Do you want ${candidate} ${VERSION} to be set as default? (Y/n): "
			read USE
		fi
		if [[ -z "$USE" || "$USE" == "y" || "$USE" == "Y" ]]
		then
			echo ""
			__sdkman_echo_green "Setting ${candidate} ${VERSION} as default."
			__sdkman_link_candidate_version "$candidate" "$VERSION"
			__sdkman_add_to_path "$candidate"
		fi
		return 0
	elif [[ "$VERSION_VALID" == 'invalid' && -n "$folder" ]]
	then
		__sdkman_install_local_version "$candidate" "$VERSION" "$folder" || return 1
	else
		echo ""
		__sdkman_echo_red "Stop! $1 is not a valid ${candidate} version."
		return 1
	fi
}
__sdk_list () {
	local candidate="$1" 
	if [[ -z "$candidate" ]]
	then
		__sdkman_list_candidates
	else
		__sdkman_list_versions "$candidate"
	fi
}
__sdk_offline () {
	local mode="$1" 
	if [[ -z "$mode" || "$mode" == "enable" ]]
	then
		SDKMAN_OFFLINE_MODE="true" 
		__sdkman_echo_green "Offline mode enabled."
	fi
	if [[ "$mode" == "disable" ]]
	then
		SDKMAN_OFFLINE_MODE="false" 
		__sdkman_echo_green "Online mode re-enabled!"
	fi
}
__sdk_selfupdate () {
	local force_selfupdate
	local sdkman_script_version_api
	local sdkman_native_version_api
	if [[ "$SDKMAN_AVAILABLE" == "false" ]]
	then
		echo "This command is not available while offline."
		return 1
	fi
	if [[ "$sdkman_beta_channel" == "true" ]]
	then
		sdkman_script_version_api="${SDKMAN_CANDIDATES_API}/broker/version/sdkman/script/beta" 
		sdkman_native_version_api="${SDKMAN_CANDIDATES_API}/broker/version/sdkman/native/beta" 
	else
		sdkman_script_version_api="${SDKMAN_CANDIDATES_API}/broker/version/sdkman/script/stable" 
		sdkman_native_version_api="${SDKMAN_CANDIDATES_API}/broker/version/sdkman/native/stable" 
	fi
	sdkman_remote_script_version=$(__sdkman_secure_curl "$sdkman_script_version_api") 
	sdkman_remote_native_version=$(__sdkman_secure_curl "$sdkman_native_version_api") 
	sdkman_local_script_version=$(< "$SDKMAN_DIR/var/version") 
	sdkman_local_native_version=$(< "$SDKMAN_DIR/var/version_native") 
	__sdkman_echo_debug "Script: local version: $sdkman_local_script_version; remote version: $sdkman_remote_script_version"
	__sdkman_echo_debug "Native: local version: $sdkman_local_native_version; remote version: $sdkman_remote_native_version"
	force_selfupdate="$1" 
	export sdkman_debug_mode
	if [[ "$sdkman_local_script_version" == "$sdkman_remote_script_version" && "$sdkman_local_native_version" == "$sdkman_remote_native_version" && "$force_selfupdate" != "force" ]]
	then
		echo "No update available at this time."
	elif [[ "$sdkman_beta_channel" == "true" ]]
	then
		__sdkman_secure_curl "${SDKMAN_CANDIDATES_API}/selfupdate/beta/${SDKMAN_PLATFORM}" | bash
	else
		__sdkman_secure_curl "${SDKMAN_CANDIDATES_API}/selfupdate/stable/${SDKMAN_PLATFORM}" | bash
	fi
}
__sdk_uninstall () {
	__sdkman_deprecation_notice "uninstall"
	local candidate version current
	candidate="$1" 
	version="$2" 
	__sdkman_check_candidate_present "$candidate" || return 1
	__sdkman_check_version_present "$version" || return 1
	current=$(readlink "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" | sed "s!${SDKMAN_CANDIDATES_DIR}/${candidate}/!!g") 
	if [[ -L "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" && "$version" == "$current" ]]
	then
		echo ""
		__sdkman_echo_green "Deselecting ${candidate} ${version}..."
		unlink "${SDKMAN_CANDIDATES_DIR}/${candidate}/current"
	fi
	echo ""
	if [ -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}" ]
	then
		__sdkman_echo_green "Uninstalling ${candidate} ${version}..."
		rm -rf "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}"
	else
		__sdkman_echo_red "${candidate} ${version} is not installed."
	fi
}
__sdk_update () {
	local candidates_uri="${SDKMAN_CANDIDATES_API}/candidates/all" 
	__sdkman_echo_debug "Using candidates endpoint: $candidates_uri"
	local fresh_candidates_csv=$(__sdkman_secure_curl_with_timeouts "$candidates_uri") 
	__sdkman_echo_debug "Local candidates: $SDKMAN_CANDIDATES_CSV"
	__sdkman_echo_debug "Fetched candidates: $fresh_candidates_csv"
	if [[ -n "${fresh_candidates_csv}" ]] && ! grep -iq 'html' <<< "${fresh_candidates_csv}"
	then
		__sdkman_echo_debug "Fresh and cached candidate lengths: ${#fresh_candidates_csv} ${#SDKMAN_CANDIDATES_CSV}"
		local fresh_candidates combined_candidates diff_candidates
		if [[ "${zsh_shell}" == 'true' ]]
		then
			fresh_candidates=(${(s:,:)fresh_candidates_csv}) 
		else
			IFS=',' read -a fresh_candidates <<< "${fresh_candidates_csv}"
		fi
		combined_candidates=("${fresh_candidates[@]}" "${SDKMAN_CANDIDATES[@]}") 
		diff_candidates=($(printf $'%s\n' "${combined_candidates[@]}" | sort | uniq -u)) 
		if ((${#diff_candidates[@]}))
		then
			local delta
			delta=("${fresh_candidates[@]}" "${diff_candidates[@]}") 
			delta=($(printf $'%s\n' "${delta[@]}" | sort | uniq -d)) 
			if ((${#delta[@]}))
			then
				__sdkman_echo_green "\nAdding new candidates(s): ${delta[*]}"
			fi
			delta=("${SDKMAN_CANDIDATES[@]}" "${diff_candidates[@]}") 
			delta=($(printf $'%s\n' "${delta[@]}" | sort | uniq -d)) 
			if ((${#delta[@]}))
			then
				__sdkman_echo_green "\nRemoving obsolete candidates(s): ${delta[*]}"
			fi
			echo "${fresh_candidates_csv}" >| "${SDKMAN_CANDIDATES_CACHE}"
			__sdkman_echo_yellow $'\nPlease open a new terminal now...'
		else
			touch "${SDKMAN_CANDIDATES_CACHE}"
			__sdkman_echo_green $'\nNo new candidates found at this time.'
		fi
	fi
}
__sdk_upgrade () {
	local all candidates candidate upgradable installed_count upgradable_count upgradable_candidates
	if [ -n "$1" ]
	then
		all=false 
		candidates=$1 
	else
		all=true 
		if [[ "$zsh_shell" == 'true' ]]
		then
			candidates=(${SDKMAN_CANDIDATES[@]}) 
		else
			candidates=${SDKMAN_CANDIDATES[@]} 
		fi
	fi
	installed_count=0 
	upgradable_count=0 
	echo ""
	for candidate in ${candidates}
	do
		upgradable="$(__sdkman_determine_upgradable_version "$candidate")" 
		case $? in
			(1) $all || __sdkman_echo_red "Not using any version of ${candidate}" ;;
			(2) echo ""
				__sdkman_echo_red "Stop! Could not get remote version of ${candidate}"
				return 1 ;;
			(*) if [ -n "$upgradable" ]
				then
					[ ${upgradable_count} -eq 0 ] && __sdkman_echo_no_colour "Available defaults:"
					__sdkman_echo_no_colour "$upgradable"
					((upgradable_count += 1))
					upgradable_candidates=(${upgradable_candidates[@]} $candidate) 
				fi
				((installed_count += 1)) ;;
		esac
	done
	if $all
	then
		if [ ${installed_count} -eq 0 ]
		then
			__sdkman_echo_no_colour 'No candidates are in use'
		elif [ ${upgradable_count} -eq 0 ]
		then
			__sdkman_echo_no_colour "All candidates are up-to-date"
		fi
	elif [ ${upgradable_count} -eq 0 ]
	then
		__sdkman_echo_no_colour "${candidate} is up-to-date"
	fi
	if [ ${upgradable_count} -gt 0 ]
	then
		echo ""
		if [[ "$sdkman_auto_answer" != 'true' ]]
		then
			__sdkman_echo_confirm "Use prescribed default version(s)? (Y/n): "
			read UPGRADE_ALL
		fi
		export auto_answer_upgrade='true' 
		if [[ -z "$UPGRADE_ALL" || "$UPGRADE_ALL" == "y" || "$UPGRADE_ALL" == "Y" ]]
		then
			for ((i = 0; i <= ${#upgradable_candidates[*]}; i++)) do
				upgradable_candidate="${upgradable_candidates[${i}]}" 
				if [[ -n "$upgradable_candidate" ]]
				then
					__sdk_install $upgradable_candidate
				fi
			done
		fi
		unset auto_answer_upgrade
	fi
}
__sdk_use () {
	local candidate version install
	candidate="$1" 
	version="$2" 
	__sdkman_check_version_present "$version" || return 1
	__sdkman_check_candidate_present "$candidate" || return 1
	if [[ ! -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]
	then
		echo ""
		__sdkman_echo_red "Stop! Candidate version is not installed."
		echo ""
		__sdkman_echo_yellow "Tip: Run the following to install this version"
		echo ""
		__sdkman_echo_yellow "$ sdk install ${candidate} ${version}"
		return 1
	fi
	__sdkman_set_candidate_home "$candidate" "$version"
	if [[ $PATH =~ ${SDKMAN_CANDIDATES_DIR}/${candidate}/([^/]+) ]]
	then
		local matched_version
		if [[ "$zsh_shell" == "true" ]]
		then
			matched_version=${match[1]} 
		else
			matched_version=${BASH_REMATCH[1]} 
		fi
		export PATH=${PATH//${SDKMAN_CANDIDATES_DIR}\/${candidate}\/${matched_version}/${SDKMAN_CANDIDATES_DIR}\/${candidate}\/${version}} 
	fi
	if [[ ! ( -L "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" || -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" ) ]]
	then
		__sdkman_echo_green "Setting ${candidate} version ${version} as default."
		__sdkman_link_candidate_version "$candidate" "$version"
	fi
	echo ""
	__sdkman_echo_green "Using ${candidate} version ${version} in this shell."
}
__sdk_version () {
	__sdkman_deprecation_notice "version"
	local version=$(cat $SDKMAN_DIR/var/version) 
	echo ""
	__sdkman_echo_yellow "SDKMAN $version"
}
__sdkman_add_to_path () {
	local candidate present
	candidate="$1" 
	present=$(__sdkman_path_contains "$candidate") 
	if [[ "$present" == 'false' ]]
	then
		PATH="$SDKMAN_CANDIDATES_DIR/$candidate/current/bin:$PATH" 
	fi
}
__sdkman_build_version_csv () {
	local candidate versions_csv
	candidate="$1" 
	versions_csv="" 
	if [[ -d "${SDKMAN_CANDIDATES_DIR}/${candidate}" ]]
	then
		for version in $(find "${SDKMAN_CANDIDATES_DIR}/${candidate}" -maxdepth 1 -mindepth 1 \( -type l -o -type d \) -exec basename '{}' \; | sort -r)
		do
			if [[ "$version" != 'current' ]]
			then
				versions_csv="${version},${versions_csv}" 
			fi
		done
		versions_csv=${versions_csv%?} 
	fi
	echo "$versions_csv"
}
__sdkman_check_and_use () {
	local -r candidate=$1 
	local -r version=$2 
	if [[ ! -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]
	then
		__sdkman_echo_red "Stop! $candidate $version is not installed."
		echo ""
		__sdkman_echo_yellow "Run 'sdk env install' to install it."
		return 1
	fi
	__sdk_use "$candidate" "$version"
}
__sdkman_check_candidate_present () {
	local candidate="$1" 
	if [ -z "$candidate" ]
	then
		echo ""
		__sdkman_echo_red "No candidate provided."
		__sdk_help
		return 1
	fi
}
__sdkman_check_version_present () {
	local version="$1" 
	if [ -z "$version" ]
	then
		echo ""
		__sdkman_echo_red "No candidate version provided."
		__sdk_help
		return 1
	fi
}
__sdkman_checksum_zip () {
	local -r zip_archive="$1" 
	local -r headers_file="$2" 
	local algorithm checksum cmd
	local shasum_avail=false 
	local md5sum_avail=false 
	if [ -z "${headers_file}" ]
	then
		echo ""
		__sdkman_echo_debug "Skipping checksum for cached artifact"
		return
	elif [ ! -f "${headers_file}" ]
	then
		echo ""
		__sdkman_echo_yellow "Metadata file not found at '${headers_file}', skipping checksum..."
		return
	fi
	if [[ "$sdkman_checksum_enable" != "true" ]]
	then
		echo ""
		__sdkman_echo_yellow "Checksums are disabled, skipping verification..."
		return
	fi
	if command -v shasum > /dev/null 2>&1
	then
		shasum_avail=true 
	fi
	if command -v md5sum > /dev/null 2>&1
	then
		md5sum_avail=true 
	fi
	while IFS= read -r line
	do
		algorithm=$(echo $line | sed -n 's/^X-Sdkman-Checksum-\(.*\):.*$/\1/p' | tr '[:lower:]' '[:upper:]') 
		checksum=$(echo $line | sed -n 's/^X-Sdkman-Checksum-.*:\(.*\)$/\1/p' | tr -cd '[:alnum:]') 
		if [[ -n ${algorithm} && -n ${checksum} ]]
		then
			if [[ "$algorithm" =~ 'SHA' && "$shasum_avail" == 'true' ]]
			then
				cmd="echo \"${checksum} *${zip_archive}\" | shasum --check --quiet" 
			elif [[ "$algorithm" =~ 'MD5' && "$md5sum_avail" == 'true' ]]
			then
				cmd="echo \"${checksum} ${zip_archive}\" | md5sum --check --quiet" 
			fi
			if [[ -n $cmd ]]
			then
				__sdkman_echo_no_colour "Verifying artifact: ${zip_archive} (${algorithm}:${checksum})"
				if ! eval "$cmd"
				then
					rm -f "$zip_archive"
					echo ""
					__sdkman_echo_red "Stop! An invalid checksum was detected and the archive removed! Please try re-installing."
					return 1
				fi
			else
				__sdkman_echo_no_colour "Not able to perform checksum verification at this time."
			fi
		fi
	done < "${headers_file}"
}
__sdkman_cleanup_folder () {
	local folder="$1" 
	local sdkman_cleanup_dir
	local sdkman_cleanup_disk_usage
	local sdkman_cleanup_count
	sdkman_cleanup_dir="${SDKMAN_DIR}/${folder}" 
	sdkman_cleanup_disk_usage=$(du -sh "$sdkman_cleanup_dir") 
	sdkman_cleanup_count=$(ls -1 "$sdkman_cleanup_dir" | wc -l) 
	rm -rf "$sdkman_cleanup_dir"
	mkdir "$sdkman_cleanup_dir"
	__sdkman_echo_green "${sdkman_cleanup_count} archive(s) flushed, freeing ${sdkman_cleanup_disk_usage}."
}
__sdkman_clear_env () {
	local sdkmanrc="$1" 
	if [[ -z $SDKMAN_ENV ]]
	then
		__sdkman_echo_red "No environment currently set!"
		return 1
	fi
	if [[ ! -f ${SDKMAN_ENV}/${sdkmanrc} ]]
	then
		__sdkman_echo_red "Could not find ${SDKMAN_ENV}/${sdkmanrc}."
		return 1
	fi
	__sdkman_env_each_candidate "${SDKMAN_ENV}/${sdkmanrc}" "__sdkman_env_restore_default_version"
	unset SDKMAN_ENV
}
__sdkman_complete_candidate_version () {
	local -r command=$1 
	local -r candidate=$2 
	local -r candidate_version=$3 
	local -a candidates
	case $command in
		(default | d | home | h | uninstall | rm | use | u) local -r version_paths=("${SDKMAN_CANDIDATES_DIR}/${candidate}"/*) 
			for version_path in "${version_paths[@]}"
			do
				[[ $version_path = *current ]] && continue
				candidates+=("${version_path##*/}") 
			done ;;
		(install | i) while IFS= read -r -d, version || [[ -n "$version" ]]
			do
				candidates+=("$version") 
			done <<< "$(curl --silent "${SDKMAN_CANDIDATES_API}/candidates/$candidate/${SDKMAN_PLATFORM}/versions/all")" ;;
	esac
	COMPREPLY=($(compgen -W "${candidates[*]}" -- "$candidate_version")) 
}
__sdkman_complete_command () {
	local -r command=$1 
	local -r current_word=$2 
	local -a candidates
	case $command in
		(sdk) candidates=("install" "uninstall" "list" "use" "config" "default" "home" "env" "current" "upgrade" "version" "help" "offline" "selfupdate" "update" "flush")  ;;
		(current | c | default | d | home | h | uninstall | rm | upgrade | ug | use | u) local -r candidate_paths=("${SDKMAN_CANDIDATES_DIR}"/*) 
			for candidate_path in "${candidate_paths[@]}"
			do
				candidates+=("${candidate_path##*/}") 
			done ;;
		(install | i | list | ls) candidates=${SDKMAN_CANDIDATES[@]}  ;;
		(env | e) candidates=("init" "install" "clear")  ;;
		(offline) candidates=("enable" "disable")  ;;
		(selfupdate) candidates=("force")  ;;
		(flush) candidates=("temp" "version")  ;;
	esac
	COMPREPLY=($(compgen -W "${candidates[*]}" -- "$current_word")) 
}
__sdkman_create_env_file () {
	local sdkmanrc="$1" 
	if [[ -f "$sdkmanrc" ]]
	then
		__sdkman_echo_red "$sdkmanrc already exists!"
		return 1
	fi
	__sdkman_determine_current_version "java"
	local version
	[[ -n "$CURRENT" ]] && version="$CURRENT"  || version="$(__sdkman_secure_curl "${SDKMAN_CANDIDATES_API}/candidates/default/java")" 
	bat <<eof >| "$sdkmanrc"
# Enable auto-env through the sdkman_auto_env config
# Add key=value pairs of SDKs to use below
java=$version
eof
	__sdkman_echo_green "$sdkmanrc created."
}
__sdkman_deprecation_notice () {
	local message="
[Deprecation Notice]:
This legacy '$1' command is replaced by a native implementation
and it will be removed in a future release.
Please follow the discussion here:
https://github.com/sdkman/sdkman-cli/discussions/1332" 
	if [[ "$sdkman_colour_enable" == 'false' ]]
	then
		__sdkman_echo_no_colour "$message"
	else
		__sdkman_echo_yellow "$message"
	fi
}
__sdkman_determine_candidate_bin_dir () {
	local candidate_dir="$1" 
	if [[ -d "${candidate_dir}/bin" ]]
	then
		echo "${candidate_dir}/bin"
	else
		echo "$candidate_dir"
	fi
}
__sdkman_determine_current_version () {
	local candidate present
	candidate="$1" 
	present=$(__sdkman_path_contains "${SDKMAN_CANDIDATES_DIR}/${candidate}") 
	if [[ "$present" == 'true' ]]
	then
		if [[ $PATH =~ ${SDKMAN_CANDIDATES_DIR}/${candidate}/([^/]+)/bin ]]
		then
			if [[ "$zsh_shell" == "true" ]]
			then
				CURRENT=${match[1]} 
			else
				CURRENT=${BASH_REMATCH[1]} 
			fi
		fi
		if [[ "$CURRENT" == "current" ]]
		then
			CURRENT=$(readlink "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" | sed "s!${SDKMAN_CANDIDATES_DIR}/${candidate}/!!g") 
		fi
	else
		CURRENT="" 
	fi
}
__sdkman_determine_healthcheck_status () {
	if [[ "$SDKMAN_OFFLINE_MODE" == "true" || ( "$COMMAND" == "offline" && "$QUALIFIER" == "enable" ) ]]
	then
		echo ""
	else
		echo $(__sdkman_secure_curl_with_timeouts "${SDKMAN_CANDIDATES_API}/healthcheck")
	fi
}
__sdkman_determine_upgradable_version () {
	local candidate local_versions remote_default_version
	candidate="$1" 
	local_versions="$(echo $(find "${SDKMAN_CANDIDATES_DIR}/${candidate}" -maxdepth 1 -mindepth 1 -type d -exec basename '{}' \; 2> /dev/null) | sed -e "s/ /, /g")" 
	if [ ${#local_versions} -eq 0 ]
	then
		return 1
	fi
	remote_default_version="$(__sdkman_secure_curl "${SDKMAN_CANDIDATES_API}/candidates/default/${candidate}")" 
	if [ -z "$remote_default_version" ]
	then
		return 2
	fi
	if [ ! -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${remote_default_version}" ]
	then
		__sdkman_echo_yellow "${candidate} (local: ${local_versions}; default: ${remote_default_version})"
	fi
}
__sdkman_determine_version () {
	local candidate version folder
	candidate="$1" 
	version="$2" 
	folder="$3" 
	if [[ "$SDKMAN_AVAILABLE" == "false" && -n "$version" && -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]
	then
		VERSION="$version" 
	elif [[ "$SDKMAN_AVAILABLE" == "false" && -z "$version" && -L "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" ]]
	then
		VERSION=$(readlink "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" | sed "s!${SDKMAN_CANDIDATES_DIR}/${candidate}/!!g") 
	elif [[ "$SDKMAN_AVAILABLE" == "false" && -n "$version" ]]
	then
		__sdkman_echo_red "Stop! ${candidate} ${version} is not available while offline."
		return 1
	elif [[ "$SDKMAN_AVAILABLE" == "false" && -z "$version" ]]
	then
		__sdkman_echo_red "This command is not available while offline."
		return 1
	else
		if [[ -z "$version" ]]
		then
			version=$(__sdkman_secure_curl "${SDKMAN_CANDIDATES_API}/candidates/default/${candidate}") 
		fi
		local validation_url="${SDKMAN_CANDIDATES_API}/candidates/validate/${candidate}/${version}/${SDKMAN_PLATFORM}" 
		VERSION_VALID=$(__sdkman_secure_curl "$validation_url") 
		__sdkman_echo_debug "Validate $candidate $version for $SDKMAN_PLATFORM: $VERSION_VALID"
		__sdkman_echo_debug "Validation URL: $validation_url"
		if [[ "$VERSION_VALID" == 'valid' || ( "$VERSION_VALID" == 'invalid' && -n "$folder" ) ]]
		then
			VERSION="$version" 
		elif [[ "$VERSION_VALID" == 'invalid' && -L "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]
		then
			VERSION="$version" 
		elif [[ "$VERSION_VALID" == 'invalid' && -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]
		then
			VERSION="$version" 
		else
			if [[ -z "$version" ]]
			then
				version="\b" 
			fi
			echo ""
			__sdkman_echo_red "Stop! $candidate $version is not available. Possible causes:"
			__sdkman_echo_red " * $version is an invalid version"
			__sdkman_echo_red " * $candidate binaries are incompatible with your platform"
			__sdkman_echo_red " * $candidate has not been released yet"
			echo ""
			__sdkman_echo_yellow "Tip: see all available versions for your platform:"
			echo ""
			__sdkman_echo_yellow "  $ sdk list $candidate"
			return 1
		fi
	fi
}
__sdkman_display_offline_warning () {
	local healthcheck_status="$1" 
	if [[ -z "$healthcheck_status" && "$COMMAND" != "offline" && "$SDKMAN_OFFLINE_MODE" != "true" ]]
	then
		__sdkman_echo_red "==== INTERNET NOT REACHABLE! ==================================================="
		__sdkman_echo_red ""
		__sdkman_echo_red " Some functionality is disabled or only partially available."
		__sdkman_echo_red " If this persists, please enable the offline mode:"
		__sdkman_echo_red ""
		__sdkman_echo_red "   $ sdk offline"
		__sdkman_echo_red ""
		__sdkman_echo_red "================================================================================"
		echo ""
	fi
}
__sdkman_display_proxy_warning () {
	__sdkman_echo_red "==== PROXY DETECTED! ==========================================================="
	__sdkman_echo_red "Please ensure you have open internet access to continue."
	__sdkman_echo_red "================================================================================"
	echo ""
}
__sdkman_download () {
	local candidate version
	candidate="$1" 
	version="$2" 
	metadata_folder="${SDKMAN_DIR}/var/metadata" 
	mkdir -p "${metadata_folder}"
	local platform_parameter="$SDKMAN_PLATFORM" 
	local download_url="${SDKMAN_BROKER_API}/download/${candidate}/${version}/${platform_parameter}" 
	local base_name="${candidate}-${version}" 
	local tmp_headers_file="${SDKMAN_DIR}/tmp/${base_name}.headers.tmp" 
	local headers_file="${metadata_folder}/${base_name}.headers" 
	export local binary_input="${SDKMAN_DIR}/tmp/${base_name}.bin" 
	export local zip_output="${SDKMAN_DIR}/tmp/${base_name}.zip" 
	echo ""
	__sdkman_echo_no_colour "Downloading: ${candidate} ${version}"
	echo ""
	__sdkman_echo_no_colour "In progress..."
	echo ""
	__sdkman_secure_curl_download "${download_url}" --output "${binary_input}" --dump-header "${tmp_headers_file}"
	grep '^X-Sdkman' "${tmp_headers_file}" > "${headers_file}"
	__sdkman_echo_debug "Downloaded binary to: ${binary_input} (HTTP headers written to: ${headers_file})"
	local post_installation_hook="${SDKMAN_DIR}/tmp/hook_post_${candidate}_${version}.sh" 
	__sdkman_echo_debug "Get post-installation hook: ${SDKMAN_CANDIDATES_API}/hooks/post/${candidate}/${version}/${platform_parameter}"
	__sdkman_secure_curl "${SDKMAN_CANDIDATES_API}/hooks/post/${candidate}/${version}/${platform_parameter}" >| "$post_installation_hook"
	__sdkman_echo_debug "Copy remote post-installation hook: ${post_installation_hook}"
	source "$post_installation_hook"
	__sdkman_post_installation_hook || return 1
	__sdkman_echo_debug "Processed binary as: $zip_output"
	__sdkman_echo_debug "Completed post-installation hook..."
	__sdkman_validate_zip "${zip_output}" || return 1
	__sdkman_checksum_zip "${zip_output}" "${headers_file}" || return 1
	echo ""
}
__sdkman_echo () {
	if [[ "$sdkman_colour_enable" == 'false' ]]
	then
		echo -e "$2"
	else
		echo -e "\033[1;$1$2\033[0m"
	fi
}
__sdkman_echo_confirm () {
	if [[ "$sdkman_colour_enable" == 'false' ]]
	then
		echo -n "$1"
	else
		echo -e -n "\033[1;33m$1\033[0m"
	fi
}
__sdkman_echo_cyan () {
	__sdkman_echo "36m" "$1"
}
__sdkman_echo_debug () {
	if [[ "$sdkman_debug_mode" == 'true' ]]
	then
		echo "$1"
	fi
}
__sdkman_echo_green () {
	__sdkman_echo "32m" "$1"
}
__sdkman_echo_no_colour () {
	echo "$1"
}
__sdkman_echo_paged () {
	if [[ -n "$PAGER" ]]
	then
		echo "$@" | eval "$PAGER"
	elif command -v less >&/dev/null
	then
		echo "$@" | less
	else
		echo "$@"
	fi
}
__sdkman_echo_red () {
	__sdkman_echo "31m" "$1"
}
__sdkman_echo_yellow () {
	__sdkman_echo "33m" "$1"
}
__sdkman_env_each_candidate () {
	local -r filepath=$1 
	local -r func=$2 
	local normalised_line
	while IFS= read -r line || [[ -n "$line" ]]
	do
		normalised_line="$(__sdkman_normalise "$line")" 
		__sdkman_is_blank_line "$normalised_line" && continue
		if ! __sdkman_matches_candidate_format "$normalised_line"
		then
			__sdkman_echo_red "Invalid candidate format!"
			echo ""
			__sdkman_echo_yellow "Expected 'candidate=version' but found '$normalised_line'"
			return 1
		fi
		$func "${normalised_line%=*}" "${normalised_line#*=}" || return
	done < "$filepath"
}
__sdkman_env_restore_default_version () {
	local -r candidate="$1" 
	local candidate_dir default_version
	candidate_dir="${SDKMAN_CANDIDATES_DIR}/${candidate}/current" 
	if __sdkman_is_symlink $candidate_dir
	then
		default_version=$(basename $(readlink ${candidate_dir})) 
		__sdk_use "$candidate" "$default_version" > /dev/null && __sdkman_echo_yellow "Restored $candidate version to $default_version (default)"
	else
		__sdkman_echo_yellow "No default version of $candidate was found"
	fi
}
__sdkman_export_candidate_home () {
	local candidate_name="$1" 
	local candidate_dir="$2" 
	local candidate_home_var="$(echo ${candidate_name} | tr '[:lower:]' '[:upper:]')_HOME" 
	export $(echo "$candidate_home_var")="$candidate_dir"
}
__sdkman_install_candidate_version () {
	local candidate version
	candidate="$1" 
	version="$2" 
	__sdkman_download "$candidate" "$version" || return 1
	__sdkman_echo_green "Installing: ${candidate} ${version}"
	mkdir -p "${SDKMAN_CANDIDATES_DIR}/${candidate}"
	rm -rf "${SDKMAN_DIR}/tmp/out"
	unzip -oq "${SDKMAN_DIR}/tmp/${candidate}-${version}.zip" -d "${SDKMAN_DIR}/tmp/out"
	mv -f "$SDKMAN_DIR"/tmp/out/* "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}"
	__sdkman_echo_green "Done installing!"
	echo ""
}
__sdkman_install_local_version () {
	local candidate version folder version_length version_length_max
	version_length_max=15 
	candidate="$1" 
	version="$2" 
	folder="$3" 
	version_length=${#version} 
	__sdkman_echo_debug "Validating that actual version length ($version_length) does not exceed max ($version_length_max)"
	if [[ $version_length -gt $version_length_max ]]
	then
		__sdkman_echo_red "Invalid version! ${version} with length ${version_length} exceeds max of ${version_length_max}!"
		return 1
	fi
	mkdir -p "${SDKMAN_CANDIDATES_DIR}/${candidate}"
	if [[ "$folder" != /* ]]
	then
		folder="$(pwd)/$folder" 
	fi
	if [[ -d "$folder" ]]
	then
		__sdkman_echo_green "Linking ${candidate} ${version} to ${folder}"
		ln -s "$folder" "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}"
		__sdkman_echo_green "Done installing!"
	else
		__sdkman_echo_red "Invalid path! Refusing to link ${candidate} ${version} to ${folder}."
		return 1
	fi
	echo ""
}
__sdkman_is_blank_line () {
	[[ -z "$1" ]]
}
__sdkman_is_symlink () {
	[[ -h "$1" ]]
}
__sdkman_link_candidate_version () {
	local candidate version
	candidate="$1" 
	version="$2" 
	if [[ -L "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" || -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" ]]
	then
		rm -rf "${SDKMAN_CANDIDATES_DIR}/${candidate}/current"
	fi
	ln -s "${version}" "${SDKMAN_CANDIDATES_DIR}/${candidate}/current"
}
__sdkman_list_candidates () {
	if [[ "$SDKMAN_AVAILABLE" == "false" ]]
	then
		__sdkman_echo_red "This command is not available while offline."
	else
		__sdkman_echo_paged "$(__sdkman_secure_curl "${SDKMAN_CANDIDATES_API}/candidates/list")"
	fi
}
__sdkman_list_versions () {
	local candidate versions_csv
	candidate="$1" 
	versions_csv="$(__sdkman_build_version_csv "$candidate")" 
	__sdkman_determine_current_version "$candidate"
	if [[ "$SDKMAN_AVAILABLE" == "false" ]]
	then
		__sdkman_offline_list "$candidate" "$versions_csv"
	else
		__sdkman_echo_paged "$(__sdkman_secure_curl "${SDKMAN_CANDIDATES_API}/candidates/${candidate}/${SDKMAN_PLATFORM}/versions/list?current=${CURRENT}&installed=${versions_csv}")"
	fi
}
__sdkman_load_env () {
	local sdkmanrc="$1" 
	if [[ ! -f "$sdkmanrc" ]]
	then
		__sdkman_echo_red "Could not find $sdkmanrc in the current directory."
		echo ""
		__sdkman_echo_yellow "Run 'sdk env init' to create it."
		return 1
	fi
	__sdkman_env_each_candidate "$sdkmanrc" "__sdkman_check_and_use" && SDKMAN_ENV=$PWD 
}
__sdkman_matches_candidate_format () {
	[[ "$1" =~ ^[[:lower:]]+\=.+$ ]]
}
__sdkman_normalise () {
	local -r line_without_comments="${1/\#*/}" 
	echo "${line_without_comments//[[:space:]]/}"
}
__sdkman_offline_list () {
	local candidate versions_csv
	candidate="$1" 
	versions_csv="$2" 
	__sdkman_echo_no_colour "--------------------------------------------------------------------------------"
	__sdkman_echo_yellow "Offline: only showing installed ${candidate} versions"
	__sdkman_echo_no_colour "--------------------------------------------------------------------------------"
	local versions=($(echo ${versions_csv//,/ })) 
	for ((i = ${#versions} - 1; i >= 0; i--)) do
		if [[ -n "${versions[${i}]}" ]]
		then
			if [[ "${versions[${i}]}" == "$CURRENT" ]]
			then
				__sdkman_echo_no_colour " > ${versions[${i}]}"
			else
				__sdkman_echo_no_colour " * ${versions[${i}]}"
			fi
		fi
	done
	if [[ -z "${versions[@]}" ]]
	then
		__sdkman_echo_yellow "   None installed!"
	fi
	__sdkman_echo_no_colour "--------------------------------------------------------------------------------"
	__sdkman_echo_no_colour "* - installed                                                                   "
	__sdkman_echo_no_colour "> - currently in use                                                            "
	__sdkman_echo_no_colour "--------------------------------------------------------------------------------"
}
__sdkman_path_contains () {
	local candidate exists
	candidate="$1" 
	exists="$(echo "$PATH" | grep "$candidate")" 
	if [[ -n "$exists" ]]
	then
		echo 'true'
	else
		echo 'false'
	fi
}
__sdkman_prepend_candidate_to_path () {
	local candidate_dir candidate_bin_dir
	candidate_dir="$1" 
	candidate_bin_dir=$(__sdkman_determine_candidate_bin_dir "$candidate_dir") 
	echo "$PATH" | grep -q "$candidate_dir" || PATH="${candidate_bin_dir}:${PATH}" 
	unset CANDIDATE_BIN_DIR
}
__sdkman_secure_curl () {
	if [[ "${sdkman_insecure_ssl}" == 'true' ]]
	then
		curl --insecure --silent --location "$1"
	else
		curl --silent --location "$1"
	fi
}
__sdkman_secure_curl_download () {
	local curl_params
	curl_params=('--progress-bar' '--location') 
	if [[ "${sdkman_debug_mode}" == 'true' ]]
	then
		curl_params+=('--verbose') 
	fi
	if [[ "${sdkman_curl_continue}" == 'true' ]]
	then
		curl_params+=('-C' '-') 
	fi
	if [[ -n "${sdkman_curl_retry_max_time}" ]]
	then
		curl_params+=('--retry-max-time' "${sdkman_curl_retry_max_time}") 
	fi
	if [[ -n "${sdkman_curl_retry}" ]]
	then
		curl_params+=('--retry' "${sdkman_curl_retry}") 
	fi
	if [[ "${sdkman_insecure_ssl}" == 'true' ]]
	then
		curl_params+=('--insecure') 
	fi
	curl "${curl_params[@]}" "${@}"
}
__sdkman_secure_curl_with_timeouts () {
	if [[ "${sdkman_insecure_ssl}" == 'true' ]]
	then
		curl --insecure --silent --location --connect-timeout ${sdkman_curl_connect_timeout} --max-time ${sdkman_curl_max_time} "$1"
	else
		curl --silent --location --connect-timeout ${sdkman_curl_connect_timeout} --max-time ${sdkman_curl_max_time} "$1"
	fi
}
__sdkman_set_availability () {
	local healthcheck_status="$1" 
	local detect_html="$(echo "$healthcheck_status" | tr '[:upper:]' '[:lower:]' | grep 'html')" 
	if [[ -z "$healthcheck_status" ]]
	then
		SDKMAN_AVAILABLE="false" 
		__sdkman_display_offline_warning "$healthcheck_status"
	elif [[ -n "$detect_html" ]]
	then
		SDKMAN_AVAILABLE="false" 
		__sdkman_display_proxy_warning
	else
		SDKMAN_AVAILABLE="true" 
	fi
}
__sdkman_set_candidate_home () {
	local candidate version upper_candidate
	candidate="$1" 
	version="$2" 
	upper_candidate=$(echo "$candidate" | tr '[:lower:]' '[:upper:]') 
	export "${upper_candidate}_HOME"="${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}"
}
__sdkman_setup_env () {
	local sdkmanrc="$1" 
	if [[ ! -f "$sdkmanrc" ]]
	then
		__sdkman_echo_red "Could not find $sdkmanrc in the current directory."
		echo ""
		__sdkman_echo_yellow "Run 'sdk env init' to create it."
		return 1
	fi
	sdkman_auto_answer="true" USE="n" __sdkman_env_each_candidate "$sdkmanrc" "__sdk_install"
	__sdkman_load_env "$sdkmanrc"
}
__sdkman_update_service_availability () {
	local healthcheck_status=$(__sdkman_determine_healthcheck_status) 
	__sdkman_set_availability "$healthcheck_status"
}
__sdkman_validate_zip () {
	local zip_archive zip_ok
	zip_archive="$1" 
	zip_ok=$(unzip -t "$zip_archive" | grep 'No errors detected in compressed data') 
	if [ -z "$zip_ok" ]
	then
		rm -f "$zip_archive"
		echo ""
		__sdkman_echo_red "Stop! The archive was corrupt and has been removed! Please try installing again."
		return 1
	fi
}
__starship_get_time () {
	(( STARSHIP_CAPTURED_TIME = int(rint(EPOCHREALTIME * 1000)) ))
}
__zoxide_cd () {
	\builtin cd -- "$@"
}
__zoxide_doctor () {
	[[ ${_ZO_DOCTOR:-1} -ne 0 ]] || return 0
	[[ ${chpwd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]] || return 0
	_ZO_DOCTOR=0 
	\builtin printf '%s\n' 'zoxide: detected a possible configuration issue.' 'Please ensure that zoxide is initialized right at the end of your shell configuration file (usually ~/.zshrc).' '' 'If the issue persists, consider filing an issue at:' 'https://github.com/ajeetdsouza/zoxide/issues' '' 'Disable this message by setting _ZO_DOCTOR=0.' '' >&2
}
__zoxide_hook () {
	\command zoxide add -- "$(__zoxide_pwd)"
}
__zoxide_pwd () {
	\builtin pwd -L
}
__zoxide_z () {
	__zoxide_doctor
	if [[ "$#" -eq 0 ]]
	then
		__zoxide_cd ~
	elif [[ "$#" -eq 1 ]] && {
			[[ -d "$1" ]] || [[ "$1" = '-' ]] || [[ "$1" =~ ^[-+][0-9]+$ ]]
		}
	then
		__zoxide_cd "$1"
	elif [[ "$#" -eq 2 ]] && [[ "$1" = "--" ]]
	then
		__zoxide_cd "$2"
	else
		\builtin local result
		result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")"  && __zoxide_cd "${result}"
	fi
}
__zoxide_zi () {
	__zoxide_doctor
	\builtin local result
	result="$(\command zoxide query --interactive -- "$@")"  && __zoxide_cd "${result}"
}
add-zsh-hook () {
	emulate -L zsh
	local -a hooktypes
	hooktypes=(chpwd precmd preexec periodic zshaddhistory zshexit zsh_directory_name) 
	local usage="Usage: add-zsh-hook hook function\nValid hooks are:\n  $hooktypes" 
	local opt
	local -a autoopts
	integer del list help
	while getopts "dDhLUzk" opt
	do
		case $opt in
			(d) del=1  ;;
			(D) del=2  ;;
			(h) help=1  ;;
			(L) list=1  ;;
			([Uzk]) autoopts+=(-$opt)  ;;
			(*) return 1 ;;
		esac
	done
	shift $(( OPTIND - 1 ))
	if (( list ))
	then
		typeset -mp "(${1:-${(@j:|:)hooktypes}})_functions"
		return $?
	elif (( help || $# != 2 || ${hooktypes[(I)$1]} == 0 ))
	then
		print -u$(( 2 - help )) $usage
		return $(( 1 - help ))
	fi
	local hook="${1}_functions" 
	local fn="$2" 
	if (( del ))
	then
		if (( ${(P)+hook} ))
		then
			if (( del == 2 ))
			then
				set -A $hook ${(P)hook:#${~fn}}
			else
				set -A $hook ${(P)hook:#$fn}
			fi
			if (( ! ${(P)#hook} ))
			then
				unset $hook
			fi
		fi
	else
		if (( ${(P)+hook} ))
		then
			if (( ${${(P)hook}[(I)$fn]} == 0 ))
			then
				typeset -ga $hook
				set -A $hook ${(P)hook} $fn
			fi
		else
			typeset -ga $hook
			set -A $hook $fn
		fi
		autoload $autoopts -- $fn
	fi
}
bashcompinit () {
	# undefined
	builtin autoload -XUz
}
compaudit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compdef () {
	local opt autol type func delete eval new i ret=0 cmd svc 
	local -a match mbegin mend
	emulate -L zsh
	setopt extendedglob
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	while getopts "anpPkKde" opt
	do
		case "$opt" in
			(a) autol=yes  ;;
			(n) new=yes  ;;
			([pPkK]) if [[ -n "$type" ]]
				then
					print -u2 "$0: type already set to $type"
					return 1
				fi
				if [[ "$opt" = p ]]
				then
					type=pattern 
				elif [[ "$opt" = P ]]
				then
					type=postpattern 
				elif [[ "$opt" = K ]]
				then
					type=widgetkey 
				else
					type=key 
				fi ;;
			(d) delete=yes  ;;
			(e) eval=yes  ;;
		esac
	done
	shift OPTIND-1
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	if [[ -z "$delete" ]]
	then
		if [[ -z "$eval" ]] && [[ "$1" = *\=* ]]
		then
			while (( $# ))
			do
				if [[ "$1" = *\=* ]]
				then
					cmd="${1%%\=*}" 
					svc="${1#*\=}" 
					func="$_comps[${_services[(r)$svc]:-$svc}]" 
					[[ -n ${_services[$svc]} ]] && svc=${_services[$svc]} 
					[[ -z "$func" ]] && func="${${_patcomps[(K)$svc][1]}:-${_postpatcomps[(K)$svc][1]}}" 
					if [[ -n "$func" ]]
					then
						_comps[$cmd]="$func" 
						_services[$cmd]="$svc" 
					else
						print -u2 "$0: unknown command or service: $svc"
						ret=1 
					fi
				else
					print -u2 "$0: invalid argument: $1"
					ret=1 
				fi
				shift
			done
			return ret
		fi
		func="$1" 
		[[ -n "$autol" ]] && autoload -rUz "$func"
		shift
		case "$type" in
			(widgetkey) while [[ -n $1 ]]
				do
					if [[ $# -lt 3 ]]
					then
						print -u2 "$0: compdef -K requires <widget> <comp-widget> <key>"
						return 1
					fi
					[[ $1 = _* ]] || 1="_$1" 
					[[ $2 = .* ]] || 2=".$2" 
					[[ $2 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$1" "$2" "$func"
					if [[ -n $new ]]
					then
						bindkey "$3" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] && bindkey "$3" "$1"
					else
						bindkey "$3" "$1"
					fi
					shift 3
				done ;;
			(key) if [[ $# -lt 2 ]]
				then
					print -u2 "$0: missing keys"
					return 1
				fi
				if [[ $1 = .* ]]
				then
					[[ $1 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" "$1" "$func"
				else
					[[ $1 = menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" ".$1" "$func"
				fi
				shift
				for i
				do
					if [[ -n $new ]]
					then
						bindkey "$i" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] || continue
					fi
					bindkey "$i" "$func"
				done ;;
			(*) while (( $# ))
				do
					if [[ "$1" = -N ]]
					then
						type=normal 
					elif [[ "$1" = -p ]]
					then
						type=pattern 
					elif [[ "$1" = -P ]]
					then
						type=postpattern 
					else
						case "$type" in
							(pattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_patcomps[$match[1]]="=$match[2]=$func" 
								else
									_patcomps[$1]="$func" 
								fi ;;
							(postpattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_postpatcomps[$match[1]]="=$match[2]=$func" 
								else
									_postpatcomps[$1]="$func" 
								fi ;;
							(*) if [[ "$1" = *\=* ]]
								then
									cmd="${1%%\=*}" 
									svc=yes 
								else
									cmd="$1" 
									svc= 
								fi
								if [[ -z "$new" || -z "${_comps[$1]}" ]]
								then
									_comps[$cmd]="$func" 
									[[ -n "$svc" ]] && _services[$cmd]="${1#*\=}" 
								fi ;;
						esac
					fi
					shift
				done ;;
		esac
	else
		case "$type" in
			(pattern) unset "_patcomps[$^@]" ;;
			(postpattern) unset "_postpatcomps[$^@]" ;;
			(key) print -u2 "$0: cannot restore key bindings"
				return 1 ;;
			(*) unset "_comps[$^@]" ;;
		esac
	fi
}
compdump () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compgen () {
	local opts prefix suffix job OPTARG OPTIND ret=1 
	local -a name res results jids
	local -A shortopts
	emulate -L sh
	setopt kshglob noshglob braceexpand nokshautoload
	shortopts=(a alias b builtin c command d directory e export f file g group j job k keyword u user v variable) 
	while getopts "o:A:G:C:F:P:S:W:X:abcdefgjkuv" name
	do
		case $name in
			([abcdefgjkuv]) OPTARG="${shortopts[$name]}"  ;&
			(A) case $OPTARG in
					(alias) results+=("${(k)aliases[@]}")  ;;
					(arrayvar) results+=("${(k@)parameters[(R)array*]}")  ;;
					(binding) results+=("${(k)widgets[@]}")  ;;
					(builtin) results+=("${(k)builtins[@]}" "${(k)dis_builtins[@]}")  ;;
					(command) results+=("${(k)commands[@]}" "${(k)aliases[@]}" "${(k)builtins[@]}" "${(k)functions[@]}" "${(k)reswords[@]}")  ;;
					(directory) setopt bareglobqual
						results+=(${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N-/)) 
						setopt nobareglobqual ;;
					(disabled) results+=("${(k)dis_builtins[@]}")  ;;
					(enabled) results+=("${(k)builtins[@]}")  ;;
					(export) results+=("${(k)parameters[(R)*export*]}")  ;;
					(file) setopt bareglobqual
						results+=(${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N)) 
						setopt nobareglobqual ;;
					(function) results+=("${(k)functions[@]}")  ;;
					(group) emulate zsh
						_groups -U -O res
						emulate sh
						setopt kshglob noshglob braceexpand
						results+=("${res[@]}")  ;;
					(hostname) emulate zsh
						_hosts -U -O res
						emulate sh
						setopt kshglob noshglob braceexpand
						results+=("${res[@]}")  ;;
					(job) results+=("${savejobtexts[@]%% *}")  ;;
					(keyword) results+=("${(k)reswords[@]}")  ;;
					(running) jids=("${(@k)savejobstates[(R)running*]}") 
						for job in "${jids[@]}"
						do
							results+=(${savejobtexts[$job]%% *}) 
						done ;;
					(stopped) jids=("${(@k)savejobstates[(R)suspended*]}") 
						for job in "${jids[@]}"
						do
							results+=(${savejobtexts[$job]%% *}) 
						done ;;
					(setopt | shopt) results+=("${(k)options[@]}")  ;;
					(signal) results+=("SIG${^signals[@]}")  ;;
					(user) results+=("${(k)userdirs[@]}")  ;;
					(variable) results+=("${(k)parameters[@]}")  ;;
					(helptopic)  ;;
				esac ;;
			(F) COMPREPLY=() 
				local -a args
				args=("${words[0]}" "${@[-1]}" "${words[CURRENT-2]}") 
				() {
					typeset -h words
					$OPTARG "${args[@]}"
				}
				results+=("${COMPREPLY[@]}")  ;;
			(G) setopt nullglob
				results+=(${~OPTARG}) 
				unsetopt nullglob ;;
			(W) results+=(${(Q)~=OPTARG})  ;;
			(C) results+=($(eval $OPTARG))  ;;
			(P) prefix="$OPTARG"  ;;
			(S) suffix="$OPTARG"  ;;
			(X) if [[ ${OPTARG[0]} = '!' ]]
				then
					results=("${(M)results[@]:#${OPTARG#?}}") 
				else
					results=("${results[@]:#$OPTARG}") 
				fi ;;
		esac
	done
	print -l -r -- "$prefix${^results[@]}$suffix"
}
compinit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compinstall () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
complete () {
	emulate -L zsh
	local args void cmd print remove
	args=("$@") 
	zparseopts -D -a void o: A: G: W: C: F: P: S: X: a b c d e f g j k u v p=print r=remove
	if [[ -n $print ]]
	then
		printf 'complete %2$s %1$s\n' "${(@kv)_comps[(R)_bash*]#* }"
	elif [[ -n $remove ]]
	then
		for cmd
		do
			unset "_comps[$cmd]"
		done
	else
		compdef _bash_complete\ ${(j. .)${(q)args[1,-1-$#]}} "$@"
	fi
}
getent () {
	if [[ $1 = hosts ]]
	then
		sed 's/#.*//' /etc/$1 | grep -w $2
	elif [[ $2 = <-> ]]
	then
		grep ":$2:[^:]*$" /etc/$1
	else
		grep "^$2:" /etc/$1
	fi
}
prompt_starship_precmd () {
	STARSHIP_CMD_STATUS=$? STARSHIP_PIPE_STATUS=(${pipestatus[@]}) 
	if (( ${+STARSHIP_START_TIME} ))
	then
		__starship_get_time && STARSHIP_DURATION=$(( STARSHIP_CAPTURED_TIME - STARSHIP_START_TIME )) 
		unset STARSHIP_START_TIME
	else
		unset STARSHIP_DURATION STARSHIP_CMD_STATUS STARSHIP_PIPE_STATUS
	fi
	STARSHIP_JOBS_COUNT="${#jobstates[*]}" 
}
prompt_starship_preexec () {
	__starship_get_time && STARSHIP_START_TIME=$STARSHIP_CAPTURED_TIME 
}
sdk () {
	COMMAND="$1" 
	QUALIFIER="$2" 
	case "$COMMAND" in
		(l) COMMAND="list"  ;;
		(ls) COMMAND="list"  ;;
		(v) COMMAND="version"  ;;
		(u) COMMAND="use"  ;;
		(i) COMMAND="install"  ;;
		(rm) COMMAND="uninstall"  ;;
		(c) COMMAND="current"  ;;
		(ug) COMMAND="upgrade"  ;;
		(d) COMMAND="default"  ;;
		(h) COMMAND="home"  ;;
		(e) COMMAND="env"  ;;
	esac
	if [[ "$COMMAND" != "update" ]]
	then
		___sdkman_check_candidates_cache "$SDKMAN_CANDIDATES_CACHE" || return 1
	fi
	SDKMAN_AVAILABLE="true" 
	if [ -z "$SDKMAN_OFFLINE_MODE" ]
	then
		SDKMAN_OFFLINE_MODE="false" 
	fi
	__sdkman_update_service_availability
	if [ -f "${SDKMAN_DIR}/etc/config" ]
	then
		source "${SDKMAN_DIR}/etc/config"
	fi
	if [[ -z "$COMMAND" ]]
	then
		___sdkman_help
		return 1
	fi
	CMD_FOUND="" 
	if [[ "$COMMAND" != "selfupdate" || "$sdkman_selfupdate_feature" == "true" ]]
	then
		CMD_TARGET="${SDKMAN_DIR}/src/sdkman-${COMMAND}.sh" 
		if [[ -f "$CMD_TARGET" ]]
		then
			CMD_FOUND="$CMD_TARGET" 
		fi
	fi
	CMD_TARGET="${SDKMAN_DIR}/ext/sdkman-${COMMAND}.sh" 
	if [[ -f "$CMD_TARGET" ]]
	then
		CMD_FOUND="$CMD_TARGET" 
	fi
	if [[ -z "$CMD_FOUND" ]]
	then
		echo ""
		__sdkman_echo_red "Invalid command: $COMMAND"
		echo ""
		___sdkman_help
	fi
	if [[ "$COMMAND" == "offline" && -n "$QUALIFIER" && -z $(echo "enable disable" | grep -w "$QUALIFIER") ]]
	then
		echo ""
		__sdkman_echo_red "Stop! $QUALIFIER is not a valid offline mode."
	fi
	local final_rc=0 
	local native_command="${SDKMAN_DIR}/libexec/${COMMAND}" 
	if [[ "$sdkman_native_enable" == 'true' && -f "$native_command" ]]
	then
		"$native_command" "${@:2}"
	elif [ -n "$CMD_FOUND" ]
	then
		if [[ -n "$QUALIFIER" && "$COMMAND" != "help" && "$COMMAND" != "offline" && "$COMMAND" != "flush" && "$COMMAND" != "selfupdate" && "$COMMAND" != "env" && "$COMMAND" != "completion" && "$COMMAND" != "edit" && "$COMMAND" != "home" && -z $(echo ${SDKMAN_CANDIDATES[@]} | grep -w "$QUALIFIER") ]]
		then
			echo ""
			__sdkman_echo_red "Stop! $QUALIFIER is not a valid candidate."
			return 1
		fi
		local converted_command_name=$(echo "$COMMAND" | tr '-' '_') 
		__sdk_"$converted_command_name" "${@:2}"
	fi
	final_rc=$? 
	return $final_rc
}
starship_zle-keymap-select () {
	zle reset-prompt
}
z () {
	__zoxide_z "$@"
}
zi () {
	__zoxide_zi "$@"
}
# Shell Options
setopt nohashdirs
setopt login
setopt promptsubst
# Aliases
alias -- cat=bat
alias -- cl=claude
alias -- d=docker
alias -- dc='docker compose'
alias -- g=git
alias -- k=kubectl
alias -- ll='eza -l --icons'
alias -- ls='eza --icons'
alias -- lzd=lazydocker
alias -- run-help=man
alias -- which-command=whence
# Check for rg availability
if ! (unalias rg 2>/dev/null; command -v rg) >/dev/null 2>&1; then
  function rg {
  if [[ -n $ZSH_VERSION ]]; then
    ARGV0=rg /Users/masanao/.vscode/extensions/anthropic.claude-code-2.1.72-darwin-arm64/resources/native-binary/claude "$@"
  elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    ARGV0=rg /Users/masanao/.vscode/extensions/anthropic.claude-code-2.1.72-darwin-arm64/resources/native-binary/claude "$@"
  elif [[ $BASHPID != $$ ]]; then
    exec -a rg /Users/masanao/.vscode/extensions/anthropic.claude-code-2.1.72-darwin-arm64/resources/native-binary/claude "$@"
  else
    (exec -a rg /Users/masanao/.vscode/extensions/anthropic.claude-code-2.1.72-darwin-arm64/resources/native-binary/claude "$@")
  fi
}
fi
export PATH=/Users/masanao/.sdkman/candidates/sbt/current/bin\:/Users/masanao/.sdkman/candidates/java/current/bin\:/Users/masanao/.local/bin\:/Users/masanao/.bun/bin\:/Users/masanao/.local/state/fnm_multishells/40466_1773185068425/bin\:/usr/local/opt/mysql/bin\:/opt/homebrew/bin\:/opt/homebrew/sbin\:/usr/local/bin\:/System/Cryptexes/App/usr/bin\:/usr/bin\:/bin\:/usr/sbin\:/sbin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin\:/opt/pmk/env/global/bin\:/Library/Apple/usr/bin\:/Users/masanao/.orbstack/bin\:/opt/homebrew/opt/fzf/bin
