function! SearchCscopeDb()
  let p = getcwd()
  let lastp = ""
  let maxdeep = 5
  while(maxdeep > 0)
    let rp = system("readlink -f " . p)
    let rp = substitute(rp, "\n", "", "g")
    if rp == lastp
      break
    endif
    let lastp = rp
    let p .= "/.."
    let maxdeep -= 1

    if filereadable(rp . "/cscope.out")
      silent execute "cscope add " . rp . "/cscope.out " . rp
      break
    endif
  endwhile
endfunction

if has("cscope")
  call SearchCscopeDb()
endif
