import vim
import re
import pyvlw_native
import sys,os, time, locale
import subprocess
VERSION = '1.0'
def printInfo():
  print 'Vim Latex for Windows', VERSION
  
def refreshMupdf(exepath, filename, spid):
  path = exepath+' '+filename
  spid = pyvlw_native.refreshMupdf(path,spid)
  return spid;

def killMupdf(pid):
  os.system('taskkill /pid ' + pid)

def parseTitle(title):
  p = '(.*\.pdf)\s-\s(\d+)\/(\d+)'
  m = re.search(p,title)
  if not m:
    return ('','','')
  return (m.group(1), m.group(2), m.group(3))

tmpdir = vim.eval('g:VLW_temp_dir') 
tmptexfile = tmpdir + '/preview.tex'
tmppdffile = tmpdir + '/preview.pdf'
def createTmpDir():
  if not os.path.exists(tmpdir):
    os.makedirs(tmpdir)
    f = open(tmptexfile,'wb')
    f.close()
    f = open(tmppdffile,'wb')
    f.close()

BEGIN_DOC = '\\begin{document}'
END_DOC = '\\end{document}'
def findStartPos(token, row):
    i = row -1
    retpos = (-1,-1)
    while(i>=0):
      line = vim.current.buffer[i]
      pos =  line.find(token)
      if -1 != pos:
        retpos = (i,pos)
        break
      pos =  line.find(BEGIN_DOC)
      if -1 != pos:
        retpos = (i,pos)
        break
      i = i-1  
    return retpos 

def findEndPos(token, row, noend=False):
    i = row -1
    retpos = (-1,-1)
    lc = len(vim.current.buffer)
    while(i<lc):
      line = vim.current.buffer[i]
      pos =  line.rfind(token)
      if -1 != pos:
        if noend:
          retpos = (i,pos)
        else:
          retpos = (i,pos+len(token))
        break
      pos =  line.rfind(END_DOC)
      if -1 != pos:
        retpos = (i,pos)
        break
      i = i+1  
    return retpos 

def writeBetween(writer, startp, endp):
  if startp==(-1,-1) or endp==(-1,-1):
    return
  if startp[0]==endp[0]:
    writer.write(vim.current.buffer[startp[0]][startp[1]:endp[1]]+'\n')
    return
  writer.write(vim.current.buffer[startp[0]][startp[1]:]+'\n')
  for i in xrange(startp[0]+1,endp[0]):
    writer.write(vim.current.buffer[i]+'\n')
  writer.write(vim.current.buffer[endp[0]][:endp[1]]+'\n')

def extractCurrentEnv(envtype):
  createTmpDir()
  (row, col) = vim.current.window.cursor
  tmpf = open(tmptexfile, 'wb')
  #preamble
  for x in vim.current.buffer:
    pos = x.find(BEGIN_DOC)
    if(pos!=-1):
      tmpf.write(x[:pos]+'\n')
      break
    else:
      tmpf.write(x+'\n')
  tmpf.write(BEGIN_DOC+'\n')
  BEGIN_ENV = '\\begin{'
  END_ENV = '\\end{'
  env_pair = {'\\[':('\\]',0,False),'$':('$',0, False),
      '\\section':('\\section',1, True)}
  if envtype == '$env':
    line = vim.current.buffer[row-1];
    mstart =  re.search('\\\\end\{\s*(.+?)\s*\}', line)
    if mstart:
      BEGIN_ENV = BEGIN_ENV+ mstart.group(1)+'}'
    startp = findStartPos( BEGIN_ENV, row)
    # print vim.current.buffer[startp-1]
    m = re.search('\\\\begin\{\s*(.+?)\s*\}', vim.current.buffer[startp[0]])
    if not m:
      print 'Fail to find "\\begin", syntax error?'
    else:
      END_ENV =  END_ENV+m.group(1)+'}'
      endp = findEndPos(END_ENV, row)
      writeBetween(tmpf, startp,endp)
  elif envtype.startswith('%'):
      BE = envtype[1:]
      try:
        EE = env_pair[BE]
        startp = findStartPos(BE, row)
        endp = findEndPos( EE[0], row+EE[1], EE[2])
        writeBetween(tmpf, startp,endp)
      except:
        print 'Unknown Tex env: "'+envtype+'"'
  elif envtype.startswith('#'):
      m = re.match('#(\d+):(\d+)', envtype)
      if m:
        fcb = int(m.group(1))-1
        fce = int(m.group(2))-1
        fcelen = len(vim.current.buffer[fce])
        writeBetween(tmpf, (fcb,0),(fce,fcelen))
      else:
        print 'Syntex error: ', envtype
  else:
    print 'Unknown Tex env: "'+envtype+'"'

  tmpf.write(END_DOC+'\n')
  tmpf.close()

def chooseCompiler():
  i = 0
  for line in vim.current.buffer:
    if i>5: break
    i = i+1
    if line.lower().find('xetex'):
      return 'g:VLW_CompileRule_xelatex'
  return 'g:VLW_CompileRule_pdflatex'

def convertToUTF8():
  if sys.getdefaultencoding()=='utf-8': return True
  fi = open(tmptexfile,'rb')
  src = fi.read()
  fi.close()
  src_encode = [locale.getpreferredencoding(),'ascii','utf-8', 'gb18030',
      'euc_jis_2004', 'iso2022_jp','johab']
  content = ''
  for x in src_encode:
    try:
      content = src.decode(x).encode('utf-8')
      break
    except UnicodeDecodeError:
      continue

  if not content:
    return False
  else:
    fi = open(tmptexfile, 'wb')
    fi.write(content)
    fi.close()
    return True

def compileTempTex():
  compiler = chooseCompiler()
  if compiler == 'g:VLW_CompileRule_xelatex':
    if not convertToUTF8():
      print 'Failed to convert to UTF-8 (using xelatex)'
      return 

  try:
    pdf_rule = vim.eval(compiler)
  except:
    pdf_rule = '' 
  if not pdf_rule:
    print compiler+' not set, vim-latex not installed?'
    return 
  #pdf_rule = pdf_rule.replace('$*','')
  cmd_arg = ' -include-directory=../'
  command = pdf_rule+ cmd_arg +' preview.tex'
  startupinfo = subprocess.STARTUPINFO()
  startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
  cwd = os.path.abspath(tmpdir)
  pipe = subprocess.Popen(command,startupinfo=startupinfo,cwd=cwd,bufsize=-1, shell=False)
  exitcode = pipe.wait()
  if exitcode!=0:
    print "Fail to compile preview snippet or with warnings!"
  else:
    print "Compile OK"

