StrAus               MACRO String     ;Makro StrAus zur Stringausgabe mit Parameter "String"
                     push ax          ;Ein Makro mal zur Abwechslung, obwohl ich die nicht mag...
                     push dx
                     lea  dx,String
                     mov  ah,09h
                     int  21h
                     pop  dx
                     pop  ax
                     ENDM

                     .MODEL SMALL
                     .STACK 100h
                     .DATA
buffer_A             db  6 dup(' ')    ;Wird von der Prozedur benoetigt!!
AxSec                DW ?
BxClu                DW ?
CxClu                DW ?
CR_LF                DB 10,13,"$"
AktLW                DB "Aktuelles Laufwerk                : "
LW                   DB "A:$"
Speicher             DB "Speichergroesse unter 1 MB        : $"
Msg1                 DB "Anzahl der Sektoren pro Cluster   : $"
Msg2                 DB "Anzahl der noch freien CLuster    : $"
Msg3                 DB "Anzahl der Bytes pro Cluster      : $"
Msg4                 DB "Gesamtzahl der Cluster auf dem LW : $"
Msg5                 DB "Freier Speicherplatz auf akt. LW  : $"
MByt                 DB " MB$"
KByt                 DB " KB$"
                     .CODE
                     mov  ax,@data
                     mov  ds,ax
                     mov  ah,19h           ;DOS-Funktion: Get Current Drive
                     int  21h              ;Aktuelles LW in al (0 = A, 1 = B, 2 = C...)
                     add  byte ptr [LW],al ;"A" + 0 = "A" ; "A" + 1 = "B" ; "A" + 2 = "C" ...!
                     StrAus CR_LF          ;Macro StrAus wobei CR_LF ausgegebn werden soll
                     StrAus AktLW          ;Stringausgabe von "AktLW"
                     int  12h              ;Speichergroesse unter 1MByte festellen Erg in AX
                     StrAus CR_LF
                     StrAus Speicher
                     call wrint            ;Inhalt von AX nach ASCII konvertieren und ausgeben!
                     StrAus KByt            
                     StrAus CR_LF
                     mov  ah,36h           ;Freie Plattenkapazität fuer
                     xor  dl,dl            ;das aktuelle Laufwerk (dl=0)
                     int  21h              ;Ermitteln
                     mov  [AxSec],ax       ;Ergebnisse Abspeichern
                     mov  [BxClu],bx
                     mov  [CxClu],cx       ;DX bleibt eh erhalten !
                     StrAus Msg1           ;Das ganze Zeugs ausgeben...
                     call wrint            
                     StrAus CR_LF
                     mov  ax,bx
                     StrAus Msg2
                     call wrint
                     StrAus CR_LF
                     mov  ax,cx
                     StrAus Msg3
                     call wrint
                     StrAus CR_LF
                     mov  ax,dx
                     StrAus Msg4
                     call wrint            
                     StrAus CR_LF           ;... Fertig!
                     mov  ax,Word Ptr [BxClu]  ;Ex-Wert von Ax wiederherstellen
                     xor  dx,dx      ;High Teil auf null setzen 32-Bit-Div. wegen 16-Bit Divisor
                     mov  cx,1024    ;Tip: DIV und MUL nochmal nachschauen !
                     div  cx         ;bx/1024 !! Byte-->KB (bx groesster Wert!)
                     mov  bx,ax      ;Ergebnis von ax nach bx schreiben
                     push bx
                     mov  ax,Word Ptr [AxSec]
                     mov  cx,Word Ptr [CxClu]
                     mul  cx
                     xor  dx,dx      ;High Teil loeschen
                     mov  bx,1024
                     div  bx         ;Ax/1024 KB --> MB !!
                     pop  bx
                     mul  bx        
                     StrAus Msg5
                     call Wrint
                     StrAus MByt
                     StrAus CR_LF
                     
                     mov  ah,4Ch     ;Programm beenden
                     int  21h
 
;Diese Konvertierunsprozedur ist von der Franzis-CD (hab sie ganz vorne Erwaehnt)
;Wenn man die verwendet den Puffer nicht vergessen !!

WRINT                PROC  NEAR
                     push ax                    ; save registers
                     push bx
                     push cx
                     push dx
                     push di
                     mov  cx,0                  ; set digit counter to zero
                     mov  di,OFFSET buffer_A+6  ; point past end of buffer

                    ; Divide AX, convert remainder to ASCII.

                     mov  bx,10          ; divisor = 10
A1:                  mov  dx,0           ; clear dividend to zero
                     div  bx             ; divide AX by 10 
                     or   dl,30h         ; convert remainder to ASCII
                     dec  di             ; reverse through the buffer
                     mov  [di],dl        ; store ASCII digit
                     inc  cx             ; increment count
                     or   ax,ax          ; quotient = zero?
                     jnz  A1             ; no: divide again

                     ; Display the buffer, using CX as a counter.

A2:                  mov   ah,2           ; function: display character
                     mov   dl,[di]        ; get digit from buffer
                     int   21h            ; call DOS
                     inc   di             ; point to next digit
                     loop  A2    

                     pop   di             ; restore registers
                     pop   dx
                     pop   cx
                     pop   bx
                     pop   ax
                     ret
WRINT                ENDP                
                     
;So nun haben wir ein Programm, das dem Wort Rundungsfehler eine ganz neue Dimension gibt...
;(zumindest was den Freien HD-Speicher angeht) na ja ich denk brauchbar ist es trotzdem,
;vielleicht das naechste mal die "Reste" nicht ueber Bord werfen.
;Marcus Roming <15.02.99/17:57:45> 
                    
                     END  ;THE END
