############# HOOKS ########################

# add lines numbers
hook global WinCreate .* %{addhl number_lines}

# add brackets highliting
hook global WinCreate .* %{addhl show_matching}

# use only spaces do not use tabs
hook -group TabExpander global InsertChar \t %{ exec -draft h@}

# Add autowrap to 72 characters in git-commit
hook -group GitWrapper global WinSetOption filetype=git-commit %{
    set buffer autowrap_column 72
    autowrap-enable

    hook window WinSetOption filetype=(?!git-commit).* %{ autowrap-disable }
}

hook -group PythonJediAutostart global WinSetOption filetype=python %{
    jedi-enable-autocomplete
}

hook global WinSetOption filetype=(?!python).* %{
    jedi-disable-autocomplete
}

# show all trailing whispaces red
hook -group TrailingWhitespaces global WinCreate .* %{
    addhl regex '\h+$' 0:default,red
}

# autowrap the status.txt file
hook -group StatusAutowrap global WinCreate .*status\.txt %{
    set buffer autowrap_column 35
    autowrap-enable

    hook window WinClose .*(?!status\.txt) %{ echo "test close" }
}

#################################

set global tabstop 4

map global user n ':eval %{buffernext}<ret>'
map global user b ':eval %{bufferprev}<ret>'

# yank and paste to/from external clipboard
map global user y '<a-|>xsel -b --input<ret>:echo -color Information "Yanked to clipboard"<ret>'
map global user p '<a-!>xsel -b -o<ret>:echo -color Information "Pasted from clipboard"<ret>'

# yank to system clipboard always
hook global NormalKey y|d|c %{ nop %sh{
   echo "$kak_selection" | xsel --input
}}

# write pdb to this row
map global user d '<esc>oimport pdb; pdb.set_trace()<esc>'

# select all occurrences in this buffer
map global user a '*%s<c-/><ret>'

# my personal functions
def push_kickstart -docstring "Push actual buffer to cobra02" %{
write
%sh{
    /home/jkonecny/RH/scripts/vm_scripts/push_kickstart.sh "$kak_buffile" > /dev/null

    if [ $? -eq 0 ]; then
        echo "echo -color Information KS $kak_bufname pushed successful"
    else
        echo "echo -color Error Push failed"
    fi
}}