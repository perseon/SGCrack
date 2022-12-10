FUNCTION VerPa
 LPARAMETERS pcodcd, plver, plprg, mcodn
 LOCAL mlcod, i
 mlcod = 0
 FOR i = 1 TO 6
    mlcod = mlcod+i*ASC(SUBSTR(pcodcd, i, 1))
 ENDFOR
 crc = VAL(SUBSTR(pcodcd, 7, 2))
 IF crc<>MOD(mlcod, 100)
    RETURN -1
 ENDIF
 mlcod = mlcod+mcodn*plver+ASC(plprg)
 RETURN MAX(INT(MOD(SQRT(mlcod*SQRT(mlcod)), 1)*1000000), 1)
ENDFUNC