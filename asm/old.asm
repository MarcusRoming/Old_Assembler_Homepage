                        .MODEL SMALL
                        .STACK 100h    
                        .DATA          

Meldung                  DB  "Hallo Welt!$"  ;Die Meldung selbst 
                                                     
                        .CODE
Entrypoint:              mov  ax,@data  ;Entrypoint ist ein label, kann somit auch anders heiﬂen.
                         mov  ds,ax     
                                      
                         mov  dx,OFFSET Meldung  
                         mov  ah,09h             
                         int  21h                
                                                 
                         mov  ah,4Ch             
                         int  21h                
                            
                         END Entrypoint ;Entrypoint festlegen analog zu COM-Dateien.