                     .MODEL SMALL
                     .STACK 100h
                     .DATA
CommandTail          DB   126 DUP (0)
Puffer1              DB   ?
Datei1               DW   ?
Datei2               DW   ?
KleinUE              DB   "&uuml;"
GrossUE              DB   "&Uuml;"
KleinOE              DB   "&ouml;"
GrossOE              DB   "&Ouml;"
KleinAE              DB   "&auml;"
GrossAE              DB   "&Auml;"
CountIt              DW   ?
Message              DB   "HTML Textkonverter WIN Ver 1.00 (c) 1998 by Marcus Roming$"
Msg2                 DB   "Kein oder falscher Parameter. Syntax: Winkonv [LW:\][Path\]FileName."
                     DB   "Ext $"                 ;<-- Fortsetzung
Msg3                 DB   10,13,"Fehler beim oeffnen. Syntax: Winkonv [LW:\][Path\]FileName.Ext$"
                     .CODE
                     mov  ax,@data                ;Beim Start zeigen es u. ds aufs PSP 
                     mov  es,ax                   ;ES zeigt nun aufs Datensegment 
                     mov  cl,byte ptr ds:[0080h]  ;So lang ist der Tail (Tail = Kommandozeile)
                     xor  ch,ch                   ;Die groesse des Tails ist nun in CX
                     push cx                      ;Fuer spaeter !!                   
                     cmp  cx,04h
                     jnle KeinFehler
                     jmp  NoTail
KeinFehler:          sub  cx,1                    ;1 weniger, weil ich den Abstand nicht will
                     mov  si,82h                  ;Quelle: DS:SI, DS zeigt (noch) aufs PSP
                     mov  di,OFFSET CommandTail   ;Ziel: ES:DI DS zeigt aufs Datensegment. 
                     rep  movsb                   ;Tail ins Datensegment
                     mov  ax,@data
                     mov  ds,ax
                     lea  dx,Message
                     mov  ah,09h
                     int  21h
                     mov  ax,3D00h                ;Datei oeffnen nur lesen
                     lea  dx,CommandTail
                     int  21h
                     jnc  Ziel1
                     jmp  Ende
Ziel1:               mov  [Datei1],ax             ;Handle 1 Sichern die [] ist optional
                     mov  bx,ax
                  
                     mov  ah,3Ch                  ;Datei erstellen
                     lea  dx,CommandTail
                     pop  di
                     sub  di,6                    ;6 abziehen
                     mov  bx,dx
                     cmp  byte ptr [bx+di],'0'    ;Ist das Zeichen eine 0 ?
                     je   GehtNicht
                     mov  byte ptr [bx+di],'0'    ;Name abaendern
                     jmp  OK
GehtNicht:           mov  byte ptr [bx+di],'X'    ;Alternativzeichen
Ok:                  int  21h
                     jnc  Ziel2
                     jmp  Fertig
Ziel2:               mov  [Datei2],ax             ;Handle 2 sichern
DoLoop:                                           ;Anfang der Schleife

                     mov  bx,[Datei1]             ;Datei 1 lesen
                     mov  ah,3Fh
                     mov  cx,01h                  ;1 Byte
                     lea  dx,Puffer1
                     int  21h
                     cmp  ax,00h                  ;Wenn AX=0 dann wurde kein Zeichen 
                     jne  Ziel3                   ;gelesen --> Ende! (ganz raus aus der Schleife)
                     jmp  Fertig
Ziel3:
                     cmp  byte ptr [Puffer1],252  ;Ansi-Zahl fuer ü 
                     jne  Weiter1                 ;Wenn nicht gleich auf den naechsten Pruefen
                     mov  ah,40h                  ;Wenn gleich die Daten aus KleiUE schreiben
                     mov  cx,06h
                     lea  dx,KleinUE
                     mov  bx,[Datei2]             
                     int  21h
                     jmp  Raus                    ;Es wurde ein ü gefunden, es kann also kein 
                                                  ;anderes mehr kommen--> Sprung ans Ende der 
                                                  ;Schleife (nicht ganz raus !!))
Weiter1:
                     cmp  byte ptr [Puffer1],220  ;Ansi-Zahl fuer Ü
                     jne  Weiter2
                     mov  ah,40h
                     mov  cx,06h
                     lea  dx,GrossUE
                     mov  bx,[Datei2]
                     int  21h
                     jmp  Raus
Weiter2:
                     cmp  byte ptr [Puffer1],228
                     jne  Weiter3
                     mov  ah,40h
                     mov  cx,06h
                     lea  dx,KleinAE
                     mov  bx,[Datei2]
                     int  21h
                     jmp  Raus
Weiter3:             

                     cmp  byte ptr [Puffer1],196
                     jne  Weiter4
                     mov  ah,40h
                     mov  cx,06h
                     lea  dx,GrossAE
                     mov  bx,[Datei2]
                     int  21h
                     jmp  Raus

Weiter4:
                     cmp  byte ptr [Puffer1],246
                     jne  Weiter5
                     mov  ah,40h
                     mov  cx,06h
                     lea  dx,KleinOE
                     mov  bx,[Datei2]
                     int  21h
                     jmp  Raus

Weiter5:
                     cmp  byte ptr [Puffer1],214
                     jne  Weiter6
                     mov  ah,40h
                     mov  cx,06h
                     lea  dx,GrossOE
                     mov  bx,[Datei2]
                     int  21h
                     jmp  Raus
                     
Weiter6:                   
                     mov  bx,[Datei2]
                     mov  ah,40h
                     mov  cx,01h
                     lea  dx,Puffer1
                     int  21h
Raus:               
                     jmp  DoLoop            ;Unbedingter Sprung nach DoLoop

Fertig:
                     mov  bx,[Datei1]
                     mov  ah,3Eh
                     int  21h

                     mov  bx,[Datei2]
                     mov  ah,3Eh
                     int  21h
                     jmp  GanzFertig
NoTail:
                     mov  ax,@data           ;Noch schnell nachholen
                     mov  ds,ax
                     lea  dx,Msg2
                     mov  ah,09h
                     int  21h                ;Fehlermeldung ausgeben
                     jmp  GanzFertig

Ende:
                     lea  dx,Msg3         
                     mov  ah,09h 
                     int  21h                ;Fehlermedung ausgeben
GanzFertig:
                     mov  ah,4Ch
                     int  21h

                     END

