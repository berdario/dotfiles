function branch_name
	if [ -d .hg ]
		printf ' (%s)' (hg branch)
	else; if [ -d .git ]
			printf ' (%s)' (git branch | awk '{print $2}')
		end
	end
end

function fish_prompt --description 'Write out the prompt'
	
	set -l last_status $status

	# Just calculate these once, to save a few cycles when displaying the prompt
	if not set -q __fish_prompt_hostname
		set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
	end

	if not set -q __fish_prompt_normal
		set -g __fish_prompt_normal (set_color normal)
	end

	switch $USER

		case root

		if not set -q __fish_prompt_cwd
			if set -q fish_color_cwd_root
				set -g __fish_prompt_cwd (set_color $fish_color_cwd_root)
			else
				set -g __fish_prompt_cwd (set_color $fish_color_cwd)
			end
		end

		echo -n -s "$USER" @ "$__fish_prompt_hostname" ' ' "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal" '# '

		case '*'

		if not set -q __fish_prompt_cwd
			set -g __fish_prompt_cwd (set_color --bold blue)
			set -g __fish_prompt_userhost (set_color --bold green)
			set -g __fish_prompt_branch (set_color --bold red)
		end

		if [ -z $VIRTUAL_ENV ]
		   set -g __fish_prompt_venv ""
		else
		   set -g __fish_prompt_venv (set_color --bold -b blue white) (basename "$VIRTUAL_ENV") "$__fish_prompt_normal "
		end

		if [ $last_status -ne 0 ]
		   set -g __fish_prompt_exit_code (set_color --bold red) "[$last_status]"
		else
		   set -g __fish_prompt_exit_code ""
		end

		echo -n -s "$__fish_prompt_venv$__fish_prompt_userhost$USER" @ "$__fish_prompt_hostname" ' ' "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_branch" (branch_name) "$__fish_prompt_exit_code$__fish_prompt_normal" '> '

	end
end
