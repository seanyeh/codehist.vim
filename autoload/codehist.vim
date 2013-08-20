function s:Filter(s)
    let s = strtrans(a:s)
    let s = escape(s, '!#%/\')
    let s = substitute(s,'\^@','\\n','g')
    return shellescape(s)
endfunction

function! codehist#create_diffs(dir)
    " file_type including the '.'
    let file_type = matchstr(bufname("%"), "\\.\\w\\+$")

    let patch_dir = a:dir
    " Create dir if it does not exist
    execute "!mkdir -p ".patch_dir

    let a = ''
    let b = ''
    let counter = 1

    let num_undos = undotree()["seq_last"]

    normal! gg"byG
    normal! g-
    normal! gg"ayG

    while counter < num_undos
        let a = s:Filter(@a)

        let b = s:Filter(@b)

        let cmd = "silent !diff -u <(echo ".a.") <(echo ".b.") > ".patch_dir."/patch.".counter.file_type
        " echom cmd
        execute cmd

        " FOR DEBUG
        " execute "silent !echo ".b." > ".patch_dir."/test.".counter

        normal! gg"byG
        normal! g-
        normal! gg"ayG

        let counter += 1
    endwhile

    execute "silent !echo ".a." > ".patch_dir."/START"

    " " Revert to most current
    let counter2 = 0
    while counter2 < counter
        normal! g+
        " execute "redo"
        let counter2 += 1
    endwhile

endfunction
