FUNCTION getcodfromsite
 LPARAMETERS username, parola, pltipcomanda
 LOCAL ctargetfile, mnrf, mdenp
 mnrf = 0
 username = LOWER(ALLTRIM(username))
 parola = ALLTRIM(parola)
 IF  .NOT. internetstatus()
    IF pltipcomanda=1
       MESSAGEBOX("Preluarea automata a codurilor de activare functioneaza numai daca exista o conexiune activa la internet!", 64, "Atentie")
    ENDIF
    RETURN .F
 ENDIF
  lcerrormsg = ""
  TRY
     SELECT cod_fiscal FROM FIRME GROUP BY cod_fiscal INTO ARRAY agetnrf
     IF _TALLY>0
        mnrf = _TALLY
     ENDIF
     mlastversion = this.getlatestversion(pdenp)
     IF mlastversion<>mversionp
        MESSAGEBOX("Preluarea automata a codurilor de activare functioneaza numai daca aveti instalata ultima versiune (3.0."+ALLTRIM(STR(mlastversion))+")!", 64, "Atentie")
        lcerrormsg = "XXX"
     ELSE
        mdenp = "C"
        DO CASE
           CASE pdenp="SAGA C"
              mdenp = "C"
           CASE pdenp="SAGA B"
              mdenp = "B"
           CASE pdenp="SAGA PS"
              mdenp = "P"
        ENDCASE
        mmldata = ""
        IF FILE("MarketLine.txt")
           mmldata = LEFT(FILETOSTR("MarketLine.txt"), 10)
           IF EMPTY(CTOD(mmldata))
              mmldata = ""
           ENDIF
        ENDIF
        mpldata = ""
        IF FILE("PubLine.txt")
           mpldata = LEFT(FILETOSTR("PubLine.txt"), 10)
           IF EMPTY(CTOD(mpldata))
              mpldata = ""
           ENDIF
        ENDIF
        IF "5.01"$OS(1)
           crequest = "http://www.sagasoft.ro/get_contracte_active.php?usr="+username+"&"+"pwd="+parola+"&"+"GUID="+ALLTRIM(STR(mnrf))+"&"+"codi="+this.txtcodcd.value+"&"+"mdenp="+mdenp+IIF( .NOT. EMPTY(mpldata), "&"+"datap="+mpldata, "")+IIF( .NOT. EMPTY(mmldata), "&"+"datam="+mmldata, "")+"&"+"dt="+TTOC(DATETIME())
        ELSE
           crequest = "https://www.sagasoft.ro/get_contracte_active.php?usr="+username+"&"+"pwd="+parola+"&"+"GUID="+ALLTRIM(STR(mnrf))+"&"+"codi="+this.txtcodcd.value+"&"+"mdenp="+mdenp+IIF( .NOT. EMPTY(mpldata), "&"+"datap="+mpldata, "")+IIF( .NOT. EMPTY(mmldata), "&"+"datam="+mmldata, "")+"&"+"dt="+TTOC(DATETIME())
        ENDIF
        ctargetfile = REPLICATE(CHR(0), 260)
        = deleteurlcacheentry(ctargetfile)
        nresult = urldownloadtocachefile(0, crequest, @ctargetfile, LEN(ctargetfile), 0, 0)
        ctargetfile = STRTRAN(m.ctargetfile, CHR(0), "")
        cresponse = FILETOSTR(m.ctargetfile)
     ENDIF
  CATCH TO loexception
     lcerrormsg = "Eroare "+TRANSFORM(loexception.errorno)+" - "+loexception.message
     MESSAGEBOX("Codul de activare nu s-a putut prelua automat."+CHR(13)+"Incercati din nou sau accesati contul de utilizator.", 16, "Eroare")
  ENDTRY
  IF EMPTY(lcerrormsg)
     mmb = getpbaza()
     mlan = getpretea()
     mcpu = getcpu()
     mhdd = gethdd()
     DO CASE
        CASE pdenp="SAGA C"
           mindicepr = "C"
           mmodulconta = "c"
           mmodulstocuri = "cs"
        CASE pdenp="SAGA B"
           mindicepr = "B"
           mmodulconta = "b"
           mmodulstocuri = "bs"
        CASE pdenp="SAGA PS"
           mindicepr = "P"
           mmodulconta = "pc"
           mmodulstocuri = "ps"
     ENDCASE
     IF XMLTOCURSOR(cresponse, "cursorContracte", 2048)>0
        SELECT cursorcontracte
        REPLACE cod_identificare WITH "" FOR ISNULL(cod_identificare) .OR. LEN(ALLTRIM(cod_identificare))<6
        LOCATE FOR ALLTRIM(cod_identificare)==this.txtcodcd.value
        IF FOUND()
           SCAN FOR ALLTRIM(cod_identificare)==this.txtcodcd.value
              IF (&mmodulconta OR &mmodulstocuri)
                 REPLACE data_c WITH cursorcontracte.data IN uspa
              ENDIF
              IF &mmodulconta
                 this.txtpaswc.value = verpa(thisform.txtcodcd.value, mversionp, mindicepr, 7)
                 this.putcodonsite(cursorcontracte.nr_contract, cursorcontracte.data, cursorcontracte.comenzi_id, username, this.txtcodcd.value, verpa(thisform.txtcodcd.value, mversionp, mindicepr, 7), mhdd, mmb, mlan, mcpu, .F.)
              ENDIF
              IF &mmo
**
FUNCTION Click
 LOCAL mpathsoc
 IF DATE()>uspa.data_c
    REPLACE data_c WITH {} IN uspa
 ENDIF
 IF thisform.txtpaswc.value=0 .AND. thisform.txtpasws.value=0
    MESSAGEBOX("Completati codul de activare.", 64, "Atentie
")
    RETURN .F
 ENDIF
  mtp = 0
  IF thisform.txtpaswc.value<>0
     IF thisform.txtpaswc.value<>verpa(thisform.txtcodcd.value, mversionp, IIF(pdenp="SAGA PS", "P", IIF(pdenp="SAGA B", "B", "C")), 7)
        IF EMPTY(this.parent.tpasw.value) .AND. thisform.txtpaswc.value=verpa(thisform.txtcodcd.value, mversionp, IIF(pdenp="SAGA PS", "P", IIF(pdenp="SAGA B", "B", "C")), 6)
           pcodna = 3
           DELETE FILE "U.TXT"
           mtp = 1
        ELSE
           MESSAGEBOX("Cod de activare incorect pentru contabilitate.", 64, "Atentie
 ")
           thisform.txtpaswc.value = 0
           thisform.txtpaswc.setfocus()
           RETURN .F
       ENDIF
           ELSE
              = reg.setregkey(mprg, ALLTRIM(STR(verpa(thisform.txtcodcd.value, mversionp, IIF(pdenp="SAGA PS", "P", IIF(pdenp="SAGA B", "B", "C")), 7))), "Software\ZipDll", -2147483647)
              DELETE FILE "U.TXT"
              mtp = 1
           ENDIF
        ENDIF
        IF thisform.txtpasws.value<>0
           IF thisform.txtpasws.value<>verpa(thisform.txtcodcd.value, mversionp, "S", 7)
              IF thisform.txtpasws.value=verpa(thisform.txtcodcd.value, mversionp, "S", 6)
                 DELETE FILE "U.TXT"
                 IF mtp=1
                    mtp = 3
                 ELSE
                    mtp = 2
                 ENDIF
              ELSE
                 MESSAGEBOX("Cod de activare incorect pentru stocuri.", 64, "Atentie
       ")
                 thisform.txtpasws.value = 0
                 thisform.txtpasws.setfocus()
                 RETURN .F
       ENDIF
           ELSE
              = reg.setregkey(mprg, ALLTRIM(STR(verpa(thisform.txtcodcd.value, mversionp, IIF(pdenp="SAGA PS", "P", IIF(pdenp="SAGA B", "B", "C")), 7))), "Software\ZipDll", -2147483647)
              DELETE FILE "U.TXT"
              IF mtp=1
                 mtp = 3
              ELSE
                 mtp = 2
              ENDIF
           ENDIF
        ENDIF
        IF FILE("freetab\cf.txt")
           mgettipp = FILETOSTR("freetab\cf.txt")
        ELSE
           mgettipp = "0"
        ENDIF
        DO CASE
           CASE mtp=2 .AND. (mgettipp="1" .OR. mgettipp="3")
              IF MESSAGEBOX("Atentie! Atentie! Atentie!"+CHR(13)+"Daca activati numai partea de stocuri, accesul la partea de contabilitate NU VA MAI FI PERMIS."+CHR(13)+CHR(13)+"Doriti sa continuati?", 0276, "Atentie!")=7
                 RETURN .F
       ENDIF
           CASE mtp=1 .AND. (mgettipp="2" .OR. mgettipp="3")
              IF MESSAGEBOX("Atentie! Atentie! Atentie!"+CHR(13)+"Daca activati numai partea de contabiltate, accesul la partea de stocuri NU VA MAI FI PERMIS."+CHR(13)+CHR(13)+"Doriti sa continuati?", 0276, "Atentie!")=7
                 RETURN .F
       ENDIF
        ENDCASE
        UPDATE FREETAB\TIPDOC SET tp = mtp WHERE cod="BP"
        RELEASE reg, mprg
        ptippr = mtp
        IF ptippr<>1
           isi = .T
 ELSE
     isi = .F
 ENDIF
  STRTOFILE(ALLTRIM(STR(ptippr)), "freetab\cf.txt")
  STRTOFILE(ALLTRIM(STR(thisform.txtpaswc.value)), pcaletemp+ALLTRIM(STR(mversionp))+"C.txt")
  STRTOFILE(ALLTRIM(STR(thisform.txtpasws.value)), pcaletemp+ALLTRIM(STR(mversionp))+"S.txt")
  SET PROCEDURE TO C:\COMMONVFP\PRG\TRANSFER_BD ADDITIVE
  SELECT cod, nume, isfb, cs FROM FIRME WHERE isfb<>2 INTO ARRAY afirme
  mspatiu = 0
  LOCAL i, mtally
  mtally = _TALLY
  FOR i = 1 TO mtally
     IF afirme(i, 3)<>0
        pisfb = .T
       gnconnhandle = newhandle(afirme(i, 1), afirme(i, 3), afirme(i, 4), .T.)
           ELSE
              pisfb = .F
    ENDIF
        moldversion = getdbver(afirme(i, 1))
        IF mversion=moldversion .AND.  .NOT. FILE("UU.TXT")
           LOOP
        ENDIF
        IF  .NOT. DIRECTORY("CLONA")
           MESSAGEBOX("Directorul CLONA nu exista."+CHR(13)+"Reinstalati programul.", 16, "Eroare
           ")
           RETURN .F
    ELSE
           IF getdbver("CLONA")<>mversion
              MESSAGEBOX("Programul a fost instalat incorect."+CHR(13)+"Reinstalati programul.", 16, "Eroare
              ")
              RETURN .F
       ENDIF
           ENDIF
           mpathsoc = afirme(i, 1)
           mboolcpath = .T
    DO CASE
           CASE afirme(i, 3)=0
              mb
**
PROCEDURE Valid
 QUIT
 ENDPROC
**

**
PROCEDURE LostFocus
 SELECT uspa
 IF  .NOT. EMPTY(user) .AND.  .NOT. EMPTY(pasw)
    thisform.getcodfromsite(uspa.user, uspa.pasw, 1)
 ENDIF
 IF thisform.isquit
    QUIT
 ENDIF
 ENDPROC
**

**
PROCEDURE LostFocus
 SELECT uspa
 IF  .NOT. EMPTY(user) .AND.  .NOT. EMPTY(pasw)
    thisform.getcodfromsite(uspa.user, uspa.pasw, 1)
 ENDIF
 IF thisform.isquit
    QUIT
 ENDIF
 ENDPROC
**

**
PROCEDURE Click
 thisform.ohyperlink.navigateto("https://www.sagasoft.ro", "", "")
 ENDPROC
**

