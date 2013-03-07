ALL :press.exe

press.exe : press.asm press.res
           ml /Zi /coff press.asm /link press.res
press.res : press.rc 
          rc press.rc 