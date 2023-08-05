vim9script

def ShowFileSwitchMenu(qmods: string)
  var folder: string = expand('%:p:h')
  var no_extension: string = expand('%:p:r')
  var extension: string = expand('%:e')
  var available_files: list<string> = []

  var candidates: list<string> = []
  if extension == 'html'
    candidates = ['css', 'scss', 'ts', 'spec.ts']
  elseif extension == 'css' || extension == 'scss'
    candidates = ['html', 'ts', 'spec.ts']
  elseif extension == 'ts' && fnamemodify(no_extension, ':e') == 'spec'
    no_extension = fnamemodify(no_extension, ':r')
    candidates = ['css', 'scss', 'html', 'ts']
  elseif extension == 'ts'
    candidates = ['css', 'scss', 'html', 'spec.ts']
  endif
  for candidate in candidates
    var filename = $"{no_extension}.{candidate}"
    if filereadable(filename)
      add(available_files, fnamemodify(filename, ':t'))
    endif
  endfor

  # Special case for ts-files
  if extension == 'ts' && fnamemodify(no_extension, ':e') == 'component'
    add(available_files, 'HTML template')
    add(available_files, 'Style template')
  endif

  const options: dict<any> = {
    title: 'Switch files',
    callback: (id: number, result: number) => {
      if result < 0
        return
      endif
      var file = available_files[result - 1]
      if file == 'HTML template'
        execute "normal! gg /template\<CR>"
        return
      elseif file == 'Style template'
        execute "normal! gg /styles\<CR>"
        return
      endif
      file = $"{folder}\\{file}"
      var w: list<number> = win_findbuf(bufnr(file))
      if empty(w)
        if &modified || &buftype != ''
          execute $"{qmods} split {file}"
        else
          var edit_cmd: string = 'confirm'
          if qmods != ''
            edit_cmd ..= $" {qmods} split"
          else
            edit_cmd ..= " edit"
          endif
          execute $"{edit_cmd} {file}"
        endif
      else
        win_gotoid(w[0])
      endif
    }
  }

  var popup_id = popup_menu(available_files, options)
enddef

command! SwitchFile call ShowFileSwitchMenu(<q-mods>)



