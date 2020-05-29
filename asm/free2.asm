                     .MODEL TINY           ;COM-Datei erstellen: tasm free2  und tlink /t free2 !
                     .CODE
                     ORG  100h
Start:               mov  ah,19h           ;DOS-Funktion: Get Current Drive
                     int  21h              ;Aktuelles LW in al (0 = A, 1 = B, 2 = C...)
                     add  byte ptr [LW],al ;"A" + 0 = "A" ; "A" + 1 = "B" ; "A" + 2 = "C" ...!
                     mov  ah,09h
                     lea  dx,AktLW
                     int  21h
                     int  12h              ;Speichergroesse unter 1MByte festellen Erg in AX
                     push ax
                     lea  dx,Speicher
                     mov  ah,09h
                     int  21h
                     pop  ax
                     call wrint            ;Inhalt von AX nach ASCII konvertieren und ausgeben!
                     mov  ah,09h
                     lea  dx,KByt
                     int  21h
                     mov  ah,36h           ;Freie Plattenkapazität fuer
                     xor  dl,dl            ;das aktuelle Laufwerk (dl=0)
                     int  21h              ;Ermitteln
                     mov  [AxSec],ax       ;Ergebnisse Abspeichern
                     mov  [BxClu],bx
                     mov  [CxClu],cx
                     push dx
                     push ax
                     lea  dx,Msg1
                     mov  ah,09h
                     int  21h
                     pop  ax               ;ax wiederherstellen
                     call wrint
                     mov  ah,09h
                     lea  dx,Msg2
                     int  21h
                     mov  ax,bx
                     call wrint
                     mov  ah,09h
                     lea  dx,Msg3
                     int  21h
                     mov  ax,cx
                     call wrint
                     mov  ah,09h
                     lea  dx,Msg4
                     int  21h
                     pop  ax         ;Ex dx-Wert nach ax !!
                     call wrint      ;... Fertig!      
                     mov  bx,Word Ptr [BxClu]  ;Ex-Wert von Ax wiederherstellen
                     shr  bx,10      ;bx/1024 (2^10 !) siehe Anmerkung unten
                     mov  ax,Word Ptr [AxSec]
                     mov  cx,Word Ptr [CxClu]
                     mul  cx
                     shr  ax,10      ;ax/1024 (2^10 !) siehe Anmerkung unten
                     mul  bx        
                     push ax
                     mov  ah,09h
                     lea  dx,Msg5
                     int  21h
                     pop  ax
                     call Wrint
                     mov  ah,09h
                     lea  dx,MByt
                     int  21h
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

;Jetzt noch die Daten:

buffer_A             db  6 dup(' ')    ;Wird von der Prozedur benoetigt!!
AxSec                DW ?
BxClu                DW ?
CxClu                DW ?
CR_LF                DB 10,13,"$"
AktLW                DB 10,13,"Aktuelles Laufwerk                : "
LW                   DB "A:$"
Speicher             DB 10,13,"Speichergroesse unter 1 MB        : $"
Msg1                 DB 10,13,"Anzahl der Sektoren pro Cluster   : $"
Msg2                 DB 10,13,"Anzahl der noch freien CLuster    : $"
Msg3                 DB 10,13,"Anzahl der Bytes pro Cluster      : $"
Msg4                 DB 10,13,"Gesamtzahl der Cluster auf dem LW : $"
Msg5                 DB 10,13,"Freier Speicherplatz auf akt. LW  : $"
MByt                 DB " MB",10,13,"$"
KByt                 DB " KB$"


;Anmerkung: SHR kann zur Division mit zweierpotenzen verwendet werden: Verschieben um 1 
;           entspricht einer Division duch 2 (2^1), verschieben um 2 entspricht einer
;           Division durch 4 (2^2), verschieben um 3 entspricht einer Division durch 8
;           (2^3) usw. Analog dazu kann man mit SHL multiplizieren !!! ---> Warum SHR bzw.
;           SHL sind schneller !

                    
                     END START ;THE END
