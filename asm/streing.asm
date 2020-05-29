                     .MODEL SMALL
                     .STACK 100h
                     .DATA

Msg1                 DB   10,13,"Geben sie den Text ein: $"
Msg2                 DB   10,13,"$"
Puffer               STRUC                  ;Stuktur definieren
       Max           DB   50                ;Maximale Anzahl Zeichen
       Anz           DB   ?                 ;Fkt gibt hier die Anz. der eingegebenen Zeichen rein
       Txt           DB   53 DUP (?)        ;Hier der eigentliche Text
Puffer               ENDS
BufStrc              Puffer <>              ;Speicherplatz  fuer Puffer!

                     .CODE
                     mov  ax,@data
                     mov  ds,ax
                     mov  ah,09h
                     lea  dx,Msg1
                     int  21h
                     lea  dx,BufStrc               ;in dx der Puffer
                     mov  ah,0Ah         
                     int  21h                      ;Zeichen eingeben
                     mov  bx,dx
                     lea  dx,Msg2        
                     mov  ah,09h
                     int  21h                      ;CR LF
                     add  bx,2                     ;plus 2 (Max u. Anz !)
                     add  bl,BufStrc.Anz           ;Ans Ende des Textes!
                     ;adc  bh,0  Falls Ueberlauf
                     mov  word ptr ds:[bx],0D0Ah   ;CR LF anhaengen
                     mov  byte ptr ds:[bx+2],"$"   ;$ fuer Fkt. 09h anhaengen
                     lea  dx,BufStrc.Txt           ;dx auf den Text
                     mov  ah,09h
                     int  21h                      ;Text ausgeben
                     mov  ah,4Ch       
                     int  21h                      ;Beenden
                     END
