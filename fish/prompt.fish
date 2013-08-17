set -g __dvcs git hg

set -l hgpath (which hg)
set -l gitpath (which git)

function set_branch_name
	set -g __previous_pwd $PWD
	if test $hgpath
		if test (hg branch ^&-)
			set -g __branch_name (printf ' (%s)' (hg branch))
			return
		end
	else; if test $gitpath
			if test (git symbolic-ref -q HEAD ^&-)
				set -g __branch_name (printf ' (%s)' (git symbolic-ref -q HEAD | cut -d"/" -f 3))
				return
			end
		end
	end
	set -g __branch_name ""
end


function branch_name
	if [ $PWD != $__previous_pwd ]
			set_branch_name
	else; if contains (echo $history[1] | cut -d" " -f1) $__dvcs
			set_branch_name
		end
	end
	printf "%s" $__branch_name
end


function fish_prompt --description 'Write out the prompt'
	
	set -l last_status $status

	# Just calculate these once, to save a few cycles when displaying the prompt
	if not set -q __prompt_hostname
		set -g __prompt_hostname (hostname|cut -d . -f 1)
		set -g __prompt_normal (set_color normal)
		set -g __branch_name ""
		set -g __previous_pwd ""
	end

	switch $USER

		case root

		if not set -q __prompt_cwd
			if set -q fish_color_cwd_root
				set -g __prompt_cwd (set_color $fish_color_cwd_root)
			else
				set -g __prompt_cwd (set_color $fish_color_cwd)
			end
		end

		echo -n -s "$USER" @ "$__prompt_hostname" ' ' "$__prompt_cwd" (prompt_pwd) "$__prompt_normal" '# '

		case '*'

		if not set -q __prompt_cwd
			set -g __prompt_cwd (set_color --bold blue)
			set -g __prompt_userhost (set_color --bold green)
			set -g __prompt_branch (set_color --bold red)
		end

		if [ -z $VIRTUAL_ENV ]
		   set -g __prompt_venv ""
		else
		   set -g __prompt_venv (set_color --bold -b blue white) (basename "$VIRTUAL_ENV") "$__prompt_normal "
		end

		if [ $last_status -ne 0 ]
		   set -g __prompt_exit_code (set_color --bold red) "[$last_status]"
		else
		   set -g __prompt_exit_code ""
		end

		echo -n -s "$__prompt_venv$__prompt_userhost$USER" @ "$__prompt_hostname" ' ' "$__prompt_cwd" (prompt_pwd) "$__prompt_branch" (branch_name) "$__prompt_exit_code$__prompt_normal" '> '

	end
end
