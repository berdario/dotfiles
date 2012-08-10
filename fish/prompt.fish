function branch_name
	if test $PWD != $__fish_previous_pwd
		if test (hg branch ^&-)
			set -g __fish_branch_name (printf ' (%s)' (hg branch))
		else; if test (git symbolic-ref -q HEAD ^&-)
				set -g __fish_branch_name (printf ' (%s)' (git symbolic-ref -q HEAD | cut -d"/" -f 3))
			else; 
				set -g __fish_branch_name ""
			end
		end
		set -g __fish_previous_pwd $PWD
	end
	printf "%s" $__fish_branch_name
end

function fish_prompt --description 'Write out the prompt'
	
	set -l last_status $status

	# Just calculate these once, to save a few cycles when displaying the prompt
	if not set -q __fish_prompt_hostname
		set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
		set -g __fish_prompt_normal (set_color normal)
		set -g __fish_branch_name ""
		set -g __fish_previous_pwd ""
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
