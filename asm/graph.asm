                     .MODEL SMALL
                     .STACK 100h
                     .DATA
Spalte               DW  0
Zeile                DW  0
Farbe                DB  0
                     .CODE
                     mov  ax,@data 
                     mov  ds,ax
                     mov  ah,00h
                     mov  al,13h          ;VGA-Modus!
                     int  10h
Anfang:              mov  Zeile,00h
                     mov  Farbe,00h
                     mov  Spalte,00h
Weiter1:             mov  ah,0Ch
                     mov  cx,Spalte
                     mov  dx,Zeile
                     mov  al,Farbe
                     int  10h
                     inc  Spalte
                     cmp  Spalte,319
                     jne  Weiter1
                     inc  Zeile
                     inc  Farbe
                     mov  Spalte,0
                     cmp  Zeile,199
                     jne  Weiter1
                     mov  Spalte,0
                     mov  Farbe,0
 
Weiter2:             mov  ah,0Ch
                     mov  cx,Spalte
                     mov  dx,Zeile
                     mov  al,Farbe
                     int  10h
                     inc  Spalte
                     cmp  Spalte,319
                     jne  Weiter2
                     dec  Zeile
                     inc  Farbe
                     mov  Spalte,0
                     cmp  Zeile,1
                     jne  Weiter2
                     mov  ah,01h
                     int  16h           ;Wurde Taste gdrueckt?
                     jnz  RausHier
                     jmp  Anfang
                                      
RausHier:
                     mov  ax,0003h      ;Normalen Bilsch. wiederherstellen
                     int  10h
                     mov  ah,4Ch
                     int  21h
                     END 
