create or replace PACKAGE BODY GRUPPO2_TRIGILIA AS

        C_PACKAGE constant varchar2(30) := '.GRUPPO2_TRIGILIA.';
        C_URL constant varchar2(30):= 'TEST_SQUADRA_I_1920';
        C_IP constant varchar(30) := '131.114.73.203:8080';
        C_PACKAGE_VONA constant varchar2(100):='TEST_SQUADRA_I_1920.GRUPPOCINQUE_VONA.visualizzaCliente';
        C_PACKAGE_FALLENI constant varchar2(100):='TEST_SQUADRA_I_1920.GRUPPO4_FALLENI.visualizzaSedi';
        C_PACKAGE_MAIO constant varchar2(100):='TEST_SQUADRA_I_1920.GRUPPOCINQUE_MAIO.visualizzaVeicoloRep';
        C_PACKAGE_DELLEPIANE constant varchar2(100):= 'TEST_SQUADRA_I_1920.GRUPPO4_DELLEPIANE';
        C_PACKAGE_MATALONI constant varchar2(100):= 'TEST_SQUADRA_I_1920.GRUPPO4_MATALONI.VisualizzaTutteSosteVeicolo';
        C_PACKAGE_BELLO constant varchar2(100):= 'TEST_SQUADRA_I_1920.GRUPPO4_BELLO';
        
        
procedure visualizzaTipiTurno(username varchar2 default 'utente' , status varchar2 default '' ) is        
BEGIN
    ui.htmlOpen;
	
	ui.inizioPagina(titolo => 'Tipi di Turno');

    ui.openBodyStyle;  
    ui.openBarraMenu(username,status);
    
    ui.titolo(titolo => 'Tipi di Turno');
       
    ui.openDiv(idDiv => 'header');
    ui.apriTabella;
    ui.apriRigaTabella;
	ui.intestazioneTabella(testo => 'Nome');
    ui.intestazioneTabella(testo => 'Ora Inizio');
	ui.intestazioneTabella(testo => 'Ora Fine');
    ui.intestazioneTabella(testo => 'Retribuzione');
    ui.chiudiRigaTabella;
    ui.chiudiTabella;
    ui.closeDiv;
    
    ui.openDiv(idDiv => 'tabella');
    
    ui.apriTabella;

    for TipiTurno in (select t.Nome, 
                             TO_CHAR( t.OraInizio, 'HH:MI AM' ) as OraInizio,
                             TO_CHAR( t.OraFine, 'HH:MI AM' ) as OraFine,
                             t.RetribuzioneOraria
                             from TipiTurno t)                      
	loop  
     ui.apriRigaTabella;
     ui.ElementoTabella(TipiTurno.Nome);
	 ui.ElementoTabella(TipiTurno.OraInizio);
     ui.ElementoTabella(TipiTurno.OraFine);
     ui.ElementoTabella(TipiTurno.RetribuzioneOraria||' €/h');
	 ui.chiudiRigaTabella;
     end loop;
    ui.chiudiTabella;
    
    ui.VaiACapo;
    ui.creaBottoneLink('.ui.openPage?title=Homepage&isLogged=1&username=' || username ||'&status=' || status, 'Homepage'); 
    
    ui.closeDiv;
    ui.closeBody;
    ui.htmlClose;
end visualizzaTipiTurno; 


procedure ReportLavoroNonSvolto(username varchar2 default 'utente',status varchar2 default '',indirizzo_arg varchar2, operatore_pk INT, datainizio char default '2019-10-01', dataFine char default '2019-12-01') is
 Inizio_arg date;
 Fine_arg  date;
 trovato boolean default true;
BEGIN

    Inizio_arg:=to_char(TO_DATE(datainizio, 'YYYY-MM-DD'),'DD-MON-YY');
     Fine_arg:=to_char(TO_DATE(dataFine, 'YYYY-MM-DD'),'DD-MON-YY');       
      ui.htmlOpen;
	
      ui.inizioPagina(titolo => 'Report sul Lavoro '); 
 
      ui.openBodyStyle;

      ui.openBarraMenu(username, status);
       IF operatore_pk='0' THEN 
                IF (Inizio_arg IS NULL AND Fine_arg is NOT NULL) THEN
                    ui.titolo('Report sul lavoro svolto dai dipendenti fino al ' || Fine_arg );
                ELSIF (Fine_arg IS NULL AND Inizio_arg is NOT NULL) THEN
                    ui.titolo('Report sul lavoro svolto dai dipendenti dal ' || Inizio_arg || '  fino ad oggi' );
                ELSIF(Fine_arg IS NULL AND Inizio_arg is NULL) THEN
                    ui.titolo('Report sul lavoro svolto dai dipendenti fino ad oggi' );
                ELSE 
                    ui.titolo('Report sul lavoro svolto dai dipendenti dal '||Inizio_arg|| ' al '||Fine_arg );
                END IF;
            ELSE 
                IF (Inizio_arg IS NULL AND Fine_arg is NOT NULL) THEN
                    ui.titolo('Report sul lavoro svolto dal dipendente fino al ' || Fine_arg);
                ELSIF (Fine_arg IS NULL AND Inizio_arg is NOT NULL) THEN
                    ui.titolo('Report sul lavoro svolto dal dipendente dal ' || Inizio_arg || ' fino ad oggi');
                ELSIF(Fine_arg IS NULL AND Inizio_arg is NULL) THEN
                    ui.titolo('Report sul lavoro svolto dal dipendente fino ad oggi' );
                ELSE 
                    ui.titolo('Report sul lavoro svolto dal dipendente dal '||Inizio_arg|| ' al '||Fine_arg);
                END IF;
            END IF;
      ui.openDiv(idDiv => 'header');
      ui.apriTabella;
      ui.apriRigaTabella;
      ui.intestazioneTabella(testo => 'Nome e Cognome');
      ui.intestazioneTabella(testo => 'Ore di lavoro non svolto');
      ui.intestazioneTabella(testo => 'Ore di lavoro straordinario'); 
   
     ui.chiudiRigaTabella;
     ui.chiudiTabella;
     ui.closeDiv;
      
     ui.openDiv(idDiv => 'tabella');
    
     ui.apriTabella;
     
    FOR  turno in       
               (SELECT q.Nome, q.Cognome, q.pk_persona, SUM(diffLavoro) as risultato
                FROM   
                
                    (SELECT p.Nome, p.Cognome, p.pk_persona, t.Data, ( diffTempo ( tt.OraInizio, t.Inizio) + diffTempo ( t.Fine, tt.OraFine) )  as diffLavoro
                     FROM   Persone p, Dipendenti d, Operatori o, Turni t, TipiTurno tt, ParcheggiAutomatici pa
                     WHERE  p.pk_persona=d.pk_dipendente 
                     AND    d.pk_dipendente=o.pk_operatore  
                     AND    o.fk_parcheggioautomatico=pa.pk_parcheggioautomatico
                     AND    (Indirizzo_arg='Tutti' OR pa.Indirizzo=Indirizzo_arg)
                     AND    o.pk_operatore=t.fk_operatore
                     AND    t.fk_TipoTurno=tt.pk_TipoTurno
                     AND    (operatore_pk=0 OR o.pk_operatore=operatore_pk)
                     AND    (Inizio_arg is null OR t.Data>=Inizio_arg)
                     AND    (Fine_arg is null OR t.Data<=Fine_arg)
                    GROUP BY p.Nome, p.Cognome,p.pk_persona, t.Data, ( diffTempo ( tt.OraInizio, t.Inizio) + diffTempo ( t.Fine, tt.OraFine) ) ) q  
                    
              GROUP BY q.Nome, q.Cognome , q.pk_persona
              ORDER BY q.Nome asc
                )      
                
    LOOP  
        ui.apriRigaTabella;
        ui.ElementoTabella(turno.nome|| ' ' || turno.cognome ,linkTo => C_PACKAGE_VONA||'?username='||username||'&status='||status||'&p_cliente='||turno.pk_persona);

        if(turno.risultato > 0 ) then
            ui.ElementoTabella((TO_CHAR( FLOOR (turno.risultato / 60) ) || ':' || TO_CHAR ( MOD (turno.risultato, 60) , 'FM00'))  );
            ui.ElementoTabella('Non ha svolto lavoro in più'); 
     
        else 
            ui.ElementoTabella('Non ha svolto lavoro in meno');
            ui.ElementoTabella((TO_CHAR( FLOOR (abs(turno.risultato) / 60) ) || ':' || TO_CHAR ( MOD (abs(turno.risultato), 60) , 'FM00'))  ); 
        end if; 
         ui.chiudiRigaTabella;
        trovato:=false;
    END LOOP; 
       ui.chiudiTabella;
       IF trovato THEN
            ui.apriTabella;
                ui.apriRigaTabella;
                ui.elementoTabella(testo => 'Nessun Risultato trovato');
                 ui.chiudiRigaTabella;
                ui.chiudiTabella;
               
        END IF;
   ui.VaiACapo;
     
     ui.creaBottoneBack('Indietro');
     ui.closeDiv;
    
     ui.closeBody;
    
     ui.htmlClose;

END ReportLavoroNonSvolto;

procedure FormLavoroNonSvolto2(username varchar2 default 'utente',status varchar2 default '', indirizzo_arg varchar2 ) is

BEGIN
            ui.htmlOpen;
            
            ui.openBarraMenu(username,status);
            ui.inizioPagina('Report Lavoro');
            ui.openBodyStyle;
            ui.openBody;
            ui.titolo('Report Lavoro');
            ui.openDiv(idDiv => 'header');  
             
            ui.creaForm('Seleziona un operatore e un periodo' , C_PACKAGE||'ReportLavoroNonSvolto');
            
            ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'username', inputType => 'hidden', defaultText => username);
            ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);  
            ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'indirizzo_arg', inputType => 'hidden', defaultText => indirizzo_arg);

            ui.creaComboBox( 'Scegli operatore' , 'operatore_pk' );
                     ui.aggOpzioneAComboBox('Tutti', '0');
                     FOR   operatore IN  (SELECT 
                                  p.Nome, 
                                  p.Cognome,
                                  p.pk_persona
                                  FROM Persone p, Dipendenti d, Operatori o, ParcheggiAutomatici pa
                                  WHERE p.pk_persona=d.pk_dipendente
                                  AND d.pk_dipendente=o.pk_operatore
                                  AND o.fk_ParcheggioAutomatico=pa.pk_ParcheggioAutomatico
                                  AND (Indirizzo_arg='Tutti' OR pa.Indirizzo=Indirizzo_arg) 
                                  --AND d.licenziamento is NULL 
                                  ORDER BY p.Nome asc )
                    LOOP  
                            ui.apriRigaTabella;
                            ui.aggOpzioneAComboBox(operatore.Nome || ' ' || operatore.Cognome , operatore.pk_persona );
                            ui.chiudiRigaTabella;
                    END LOOP;
            
            ui.chiudiSelectComboBox;
            ui.vaiACapo;
        
            ui.creaTextField(nomeRif => 'Dal', placeholder => 'DD-MM-YYYY', nomeParametroGet => 'datainizio'/* flag => 'required'*/, inputType => 'date');
            ui.creaTextField(nomeRif => 'Al', placeholder => 'DD-MM-YYYY', nomeParametroGet => 'dataFine'/*, flag => 'required'*/, inputType => 'date');
            ui.creaBottoneBack('Indietro');
            ui.creaBottone('Avanti');
            
            ui.chiudiForm;
            
            ui.closeDiv;
    
            ui.closeBody;
            ui.htmlClose;

END FormLavoroNonSvolto2;

procedure FormLavoroNonSvolto(username varchar2 default 'utente',status varchar2 default '' )is
BEGIN
            ui.htmlOpen;
            
            ui.openBarraMenu(username,status);
            ui.inizioPagina('Report Lavoro');
            ui.openBodyStyle;
            ui.openBody;
            ui.titolo('Report Lavoro');
            ui.openDiv(idDiv => 'header');
            
            ui.creaForm('Scegli un parcheggio ' , C_PACKAGE||'FormLavoroNonSvolto2');
            
            ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'username', inputType => 'hidden', defaultText => username);
            ui.vaiACapo;
            
            ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
            ui.vaiAcapo;
            
            ui.creaComboBox( 'Città e Via' , 'indirizzo_arg' );
            ui.aggOpzioneAComboBox('Tutti','Tutti');
            /* visualizzo tutti i parcheggi all'interno di una comboBox */
            FOR parcheggioautomatico IN  (SELECT 
                                         pa.Citta, 
                                         pa.indirizzo
                                         FROM ParcheggiAutomatici pa)
                                        -- WHERE pa.Stato= '1')
            LOOP  
                 ui.apriRigaTabella;
                 ui.aggOpzioneAComboBox(parcheggioautomatico.Indirizzo || ' ' || parcheggioautomatico.Citta , parcheggioautomatico.Indirizzo );
                 ui.chiudiRigaTabella;
            END LOOP;
            ui.chiudiSelectComboBox;
            ui.vaiACapo;
            
            ui.creaBottoneLink('.ui.openPage?title=Homepage&isLogged=1&username=' || username ||'&status=' || status, 'Homepage'); 
            ui.creaBottone('Avanti');
            
            ui.chiudiForm;
            
            ui.closeDiv;
    
            ui.closeBody;
            ui.htmlClose;

END FormLavoroNonSvolto;

procedure handler_eccezione (username varchar2 default 'utente',status varchar2 default '', text varchar2 ) is
--username_arg varchar2(45):=username;
--status_arg INT:=status;
begin 
        ui.htmlOpen;
        
        ui.inizioPagina(titolo => 'Inserimento Tipi Turno'); 	--inserire nome della pagina
    
        ui.openBodyStyle;
          
        ui.openBarraMenu(username,status);
        ui.openDiv; 
      
        ui.titolo(text);  
        
        ui.creaBottoneBack('Indietro');
        ui.closeDiv;
        ui.closeBody;   
        ui.htmlClose;
        
end handler_eccezione;

procedure Licenziamento(username varchar2 default 'utente', status varchar2 default '',codfiscale char) 
IS
p_username VARCHAR2(45):=username;
p_stato varchar2(45):=status;
nome_lic varchar(45);
cognome_lic varchar(45);
BEGIN
        ui.htmlOpen;
        
        ui.inizioPagina(titolo => 'Licenziamento'); 
    
        ui.openBodyStyle;
          
        ui.openBarraMenu(username,status);
        ui.openDiv;
        SELECT  p.Nome,
        p.Cognome
        INTO nome_lic, cognome_lic
        FROM Persone p, Dipendenti d
        WHERE p.pk_persona=d.pk_dipendente 
        AND   p.codicefiscale=codfiscale; 
        
                 --setto licenziamento alla data corrente
                  UPDATE Dipendenti d
                  SET d.licenziamento= CURRENT_DATE
                  WHERE EXISTS (SELECT NULL
                                FROM Persone p
                                WHERE p.pk_persona=d.pk_dipendente 
                                AND   p.codicefiscale=codfiscale);
                                
                  --il licenziamento prevede anche il settamento dello stato nella tabella utenti ad 0
                  UPDATE Utenti u
                  SET u.stato=0
                  WHERE EXISTS (SELECT NULL
                                FROM Persone p,Dipendenti d
                                WHERE u.fk_persona=p.pk_persona
                                AND   p.pk_persona=d.pk_dipendente 
                                AND   p.codicefiscale=codfiscale
                                AND   u.Ruolo!='5');
        
        ui.titolo('Il dipendente '||nome_lic||' '||cognome_lic||' è stato licenziato');  
        ui.creaBottoneLink('.ui.openPage?title=Homepage&isLogged=1&username=' || username ||'&status=' || status, 'Homepage'); 
        ui.closeDiv;
        ui.closeBody;
        ui.htmlClose;
        
END Licenziamento;

procedure FormLicenziamento3(username varchar2 default 'utente',status varchar2 default '', tipo_dipendente varchar2 default '', indirizzo_arg varchar2) is 
p_username VARCHAR2(45):=username;
p_stato varchar2(45):=status;
p_tipo varchar(45):=tipo_dipendente;
BEGIN

            ui.htmlOpen; 
            ui.openBarraMenu(username,status);
            ui.inizioPagina('Form Licenziamento');
            ui.openBodyStyle;
            ui.openBody;
            ui.openDiv(idDiv => 'header');
            ui.creaForm('Scegli un operatore da licenziare  ' ,C_PACKAGE||'Licenziamento');
            
            ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'username', inputType => 'hidden', defaultText => username);
            ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
            
            ui.creaComboBox('Scegli operatore' , 'codfiscale' );
                     FOR op IN   (SELECT 
                                   p.Nome,
                                   p.Cognome,
                                   p.codicefiscale
                                   FROM Persone p, Dipendenti d, Operatori o, ParcheggiAutomatici pa
                                   WHERE p.pk_persona=d.pk_dipendente 
                                   AND d.pk_dipendente=o.pk_operatore
                                   AND o.fk_parcheggioautomatico=pa.pk_parcheggioautomatico
                                   AND pa.Indirizzo=Indirizzo_arg
                                   AND d.Licenziamento is NULL 
                                   AND pa.Stato='1'
                                  )
                    LOOP  
                    ui.apriRigaTabella;
                    ui.aggOpzioneAComboBox(op.Nome||' '||op.Cognome, op.codicefiscale);
                    ui.chiudiRigaTabella;
                END LOOP;
                ui.chiudiSelectComboBox;
                ui.creaBottoneLink(C_PACKAGE ||'FormLicenziamento2?username='||p_username||'&status='||p_stato||'&tipo_dipendente='||p_tipo, 'Indietro');
                ui.creaBottone('Licenzia');   
            ui.chiudiForm;
            ui.closeDiv;
            ui.closeBody;
            ui.htmlClose;
                          
END FormLicenziamento3;

procedure FormLicenziamento2(username varchar2 default 'utente', status varchar2 default '' , tipo_dipendente char) is 
p_username VARCHAR2(45):=username;
p_stato varchar2(45):=status;

permessi_negati EXCEPTION;
BEGIN
        ui.htmlOpen;
        ui.inizioPagina(titolo => 'Form Licenziamento'); 	--inserire nome della pagina
        ui.openBodyStyle;
        ui.openBarraMenu(username, status);
        
        ui.openDiv;
        
            CASE tipo_dipendente
                --superUser
                WHEN '1' THEN 

                    ui.creaForm('Scegli Superuser' , C_PACKAGE||'Licenziamento');
            
                    ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'username', inputType => 'hidden', defaultText => username);
                    ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
            
                    ui.creaComboBox('Scegli SuperUser' , 'codfiscale' );
                    FOR sup IN   (SELECT 
                                  p.codicefiscale, 
                                  p.Nome,
                                  p.Cognome
                                  FROM Persone p, Dipendenti d, SuperUser s
                                  WHERE p.pk_persona=d.pk_dipendente 
                                  AND d.pk_dipendente=s.pk_superuser
                                  AND d.Licenziamento is NULL 
                                  )
                    LOOP  
                    ui.apriRigaTabella;
                    ui.aggOpzioneAComboBox(sup.Nome||' '||sup.Cognome||','||sup.codicefiscale , sup.codicefiscale);
                    ui.chiudiRigaTabella;
                END LOOP;
                ui.chiudiSelectComboBox;
                ui.creaBottoneLink(C_PACKAGE ||'FormLicenziamento1?username='||p_username||'&status='||p_stato, 'Indietro');
                ui.creaBottone('Licenzia');
                --amministratore
                WHEN '2' THEN 
                   
                    ui.creaForm('Scegli Amministratore da licenziare ' , C_PACKAGE||'Licenziamento');
            
                    ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'username', inputType => 'hidden', defaultText => username);
                    ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
            
                    ui.creaComboBox('Scegli Amministratore' , 'codfiscale' );
                    FOR amm IN   (SELECT 
                                  p.codicefiscale, 
                                  p.Nome,
                                  p.Cognome
                                  FROM Persone p, Dipendenti d, Amministratori am
                                  WHERE p.pk_persona=d.pk_dipendente 
                                  AND d.pk_dipendente=am.pk_amministratore
                                  AND d.Licenziamento is NULL 
                                  )
                    LOOP  
                    ui.apriRigaTabella;
                    ui.aggOpzioneAComboBox(amm.Nome||' '||amm.Cognome||', '||amm.codicefiscale , amm.codicefiscale);
                    ui.chiudiRigaTabella;
                END LOOP;
                ui.chiudiSelectComboBox;
                ui.creaBottoneLink(C_PACKAGE ||'FormLicenziamento1?username='||p_username||'&status='||p_stato, 'Indietro');
                ui.creaBottone('Licenzia');
                --responsabile
                WHEN '3' THEN 
                   
                    ui.creaForm('Scegli Responsabile da licenziare ' , C_PACKAGE||'Licenziamento');
            
                    ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'username', inputType => 'hidden', defaultText => username);
                    ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
            
                    ui.creaComboBox('Scegli il responsabile di quale sede licenziare' , 'codfiscale' );
                    FOR resp IN  (SELECT 
                                  p.codicefiscale, 
                                  p.Nome,
                                  p.Cognome,
                                  r.fk_sede,
                                  s.Citta,
                                  s.Indirizzo
                                  FROM Persone p, Dipendenti d, Responsabili r, Sedi s
                                  WHERE p.pk_persona=d.pk_dipendente 
                                  AND d.pk_dipendente=r.pk_responsabile
                                  AND r.fk_sede=s.pk_sede
                                  AND d.Licenziamento is NULL 
                                  AND s.Stato='1'
                                  )
                    LOOP  
                    ui.apriRigaTabella;
                    ui.aggOpzioneAComboBox(resp.Nome||' '||resp.Cognome||', '|| resp.Citta||', ' || resp.Indirizzo , resp.codicefiscale);
                    ui.chiudiRigaTabella;
                END LOOP;
                ui.chiudiSelectComboBox;
                IF(status='superuser') THEN
                    ui.creaBottoneLink(C_PACKAGE ||'FormLicenziamento1?username='||p_username||'&status='||p_stato, 'Indietro');
                ELSE 
                    ui.creaBottoneLink('.ui.openPage?title=Homepage&isLogged=1&username=' || username ||'&status=' || status, 'Homepage'); 
                END IF;
                ui.creaBottone('Licenzia');
                --operatore
                WHEN '4' THEN 
                 
                    ui.creaForm('Scegli il parcheggio in cui lavora l'' operatore da licenziare  ' , C_PACKAGE||'FormLicenziamento3');
            
                    ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'username', inputType => 'hidden', defaultText => username);
                    ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
                    ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'tipo_dipendente', inputType => 'hidden', defaultText => tipo_dipendente);
                    
                    ui.creaComboBox('Scegli parcheggio' , 'indirizzo_arg' );
                    --vengono visualizzati solo i parcheggi che appartengono alla sede di competenza del responsabile che sta tentando di licenziare un operatore
                    FOR parch IN   (SELECT DISTINCT
                                   pa.Citta, 
                                   pa.Indirizzo
                                   FROM Utenti u, Persone p, Dipendenti d, Responsabili r, ParcheggiAutomatici pa, Sedi s
                                   WHERE ( status='superuser' OR u.username=p_username)
                                   AND u.fk_persona=p.pk_persona
                                   AND   p.pk_persona=d.pk_dipendente
                                   AND   d.pk_dipendente=r.pk_responsabile
                                   AND   r.fk_sede=s.pk_sede
                                   AND   s.pk_sede=pa.fk_sede
                                   AND   s.stato=1
                                   AND   pa.stato=1
                                  )
                    LOOP  
                    ui.apriRigaTabella;
                    ui.aggOpzioneAComboBox(parch.Citta||', ' || parch.Indirizzo , parch.Indirizzo);
                    ui.chiudiRigaTabella;
                END LOOP;
                ui.chiudiSelectComboBox;
                IF(status='superuser') THEN
                    ui.creaBottoneLink(C_PACKAGE ||'FormLicenziamento1?username='||p_username||'&status='||p_stato, 'Indietro');
                ELSE 
                    ui.creaBottoneLink('.ui.openPage?title=Homepage&isLogged=1&username=' || username ||'&status=' || status, 'Homepage');
                END IF;
                ui.creaBottone('Avanti');   
        
            END CASE;
            
            ui.chiudiForm;
            ui.closeDiv;
    
            ui.closeBody;
    
            ui.htmlClose;
            
END FormLicenziamento2;

procedure FormLicenziamento1(username varchar2 default 'utente', status varchar2 default 'superuser' ) is 

BEGIN       
           CASE status
                 WHEN 'superuser' THEN 
                ui.htmlOpen; 
                ui.inizioPagina(titolo => 'Licenziamento'); 	--inserire nome della pagina
                ui.openBodyStyle;
                ui.openBarraMenu(username, status);
        
                ui.openDiv;              
                ui.creaForm('Scegli la categoria di dipendente da licenziare ' , C_PACKAGE||'FormLicenziamento2');
                    
                     ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'username', inputType => 'hidden', defaultText => username);
                     ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
               
                     ui.creaComboBox('Scegli dipendente' , 'tipo_dipendente' );
                        ui.aggOpzioneAComboBox('SuperUser','1');
                        ui.aggOpzioneAComboBox('Amministratore','2');
                        ui.aggOpzioneAComboBox('Responsabile','3');
                        ui.aggOpzioneAComboBox('Operatore','4');
                     ui.chiudiSelectComboBox;
                    ui.vaiACapo;
                ui.creaBottoneLink('.ui.openPage?title=Homepage&isLogged=1&username=' || username ||'&status=' || status, 'Homepage'); 
                ui.creaBottone('Avanti');
        
                    ui.chiudiForm;
                    ui.closeDiv;  
                    ui.closeBody;
                    ui.htmlClose;
                    
                WHEN 'amministratore' THEN
                      FormLicenziamento2(username,status,3); 
                      
                WHEN 'responsabile' THEN 
                      FormLicenziamento2(username,status,4); 
                    
                END CASE; 

END FormLicenziamento1;

procedure inserimentoTipiTurni(username varchar2 default 'utente',status varchar2 default 'superuser',nome varchar2, orainizio char, orafine char, retribuzioneoraria float) is
        boh exception;
       turno_lungo EXCEPTION;
       carattere EXCEPTION;
       ret EXCEPTION;
       not_unique EXCEPTION;
       nome_arg varchar2(45):=nome;
       cn integer:=0;
      
       
BEGIN
        --480: 8 ORE
        IF( (difftempo( TO_TIMESTAMP(orainizio, 'HH24:MI'), TO_TIMESTAMP( orafine, 'HH24:MI') ) ) > 480 ) THEN
          RAISE turno_lungo;
        END IF; 
        
        IF( difftempo( TO_TIMESTAMP(orainizio, 'HH24:MI'), TO_TIMESTAMP( orafine, 'HH24:MI') )  < 0 AND  
             ( difftempo( TO_TIMESTAMP( orainizio, 'HH24:MI'), TO_TIMESTAMP('23:59', 'HH24:MI') ) 
                 +extract( minute from ( TO_TIMESTAMP( orafine, 'HH24:MI')) )  
                 + extract( hour from (TO_TIMESTAMP( orafine, 'HH24:MI') ) ) * 60 ) > 480 ) THEN 
                    RAISE boh;
        END IF;
        
        IF(LENGTH(nome) > 15) THEN
            RAISE carattere;
        END IF;
        
        IF(retribuzioneoraria<=0) THEN
            RAISE ret;
        END IF;
             
        SELECT COUNT(*)
        INTO cn
        FROM TipiTurno tt
        WHERE nome_arg = tt.nome;
                
        IF cn=1 THEN
            RAISE not_unique;
        END IF;
    
        
    ui.htmlOpen;
	
	ui.inizioPagina(titolo => 'Inserimento Tipo di Turno');

    ui.openBodyStyle;  
    ui.openBarraMenu(username,status);
    
       
    ui.openDiv(idDiv => 'header');
    ui.apriTabella;
    ui.apriRigaTabella;
	ui.intestazioneTabella(testo => 'Nome');
    ui.intestazioneTabella(testo => 'Ora Inizio');
    ui.intestazioneTabella(testo => 'Ora Fine');
    ui.intestazioneTabella(testo => 'Retribuzione Oraria');
  
    ui.chiudiRigaTabella;
    ui.chiudiTabella;
    ui.closeDiv;
    
    ui.openDiv(idDiv => 'tabella');
    
    ui.apriTabella;
    
 
     ui.apriRigaTabella;
     ui.ElementoTabella(nome);
     ui.ElementoTabella(orainizio);
     ui.ElementoTabella(orafine);
     ui.ElementoTabella(retribuzioneoraria || ' €' );
	
        ui.chiudiRigaTabella;
       ui.chiudiTabella;
        INSERT INTO TipiTurno( pk_TipoTurno , Nome , OraInizio , OraFine ,RetribuzioneOraria )
        VALUES (Seq_pk_TipoTurno.nextval , nome, TO_TIMESTAMP( orainizio,'HH24:MI' ), TO_TIMESTAMP( orafine,'HH24:MI' ) , retribuzioneoraria); 
      
        ui.creaBottoneBack('Indietro');
    
        ui.closeDiv;
        ui.closeBody;
        ui.htmlClose;
        
        EXCEPTION 
        WHEN turno_lungo THEN handler_eccezione(username,status,'Turno troppo lungo: inserisci un tipo di turno minore o uguale di 8 ore!');
        WHEN boh THEN handler_eccezione(username,status,'Turno troppo lungo: inserisci un tipo di turno minore o uguale di 8 ore!');
        WHEN carattere THEN handler_eccezione(username,status,'Nome non valido: inserisci un nome con 15 o meno caratteri!');
        WHEN ret THEN handler_eccezione(username,status,'Retribuzione oraria non valida: inserisci un valore positivo!');
        WHEN not_unique THEN handler_eccezione(username,status,'Tipo Turno già presente: inserisci un altro nome!'); 
        WHEN OTHERS THEN handler_eccezione(username,status,'Errore durante l''inserimento!'); 
     
END inserimentoTipiTurni;

procedure FormInserimentoTipiTurno(username varchar2 default 'utente',status varchar2 default 'superuser') is

begin
    ui.htmlOpen;
	
	ui.inizioPagina(titolo => 'Inserimento tipo di turno');

    ui.openBodyStyle;
    
    ui.openBarraMenu(username,status);
    
    ui.openDiv;
    
    ui.creaForm('Inserimento', C_PACKAGE||'inserimentoTipiTurni');
    
    ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'username', inputType => 'hidden', defaultText => username);
    ui.vaiACapo;
            
    ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
    ui.vaiACapo;
    
    ui.creaTextField(nomeRif => 'Nome',  placeholder => 'Nome', nomeParametroGet => 'nome',flag => 'required');
    ui.vaiACapo;
    
    ui.creaTextField(nomeRif => 'Ora Inizio', placeholder => 'HH24:MM ', nomeParametroGet => 'orainizio',flag => 'required');
    ui.vaiACapo;

    ui.creaTextField(nomeRif => 'Ora Fine', placeholder => 'HH24:MM ', nomeParametroGet => 'orafine',flag => 'required');
    ui.vaiACapo;
    
    ui.creaTextField(nomeRif => 'Retribuzione Oraria', placeholder => 'Retribuzione Oraria', nomeParametroGet => 'retribuzioneoraria',flag => 'required');
    ui.vaiACapo;
    
    ui.creaBottoneLink('.ui.openPage?title=Homepage&isLogged=1&username=' || username ||'&status=' || status, 'Homepage'); 
    ui.creaBottone('Inserisci Tipo Turno');
    
    ui.chiudiForm;
    ui.closeDiv;
    
    ui.closeBody;
    
    ui.htmlClose;
    
end FormInserimentoTipiTurno;

procedure DettagliOperatori(username varchar2 default 'utente',status varchar2 default '', Indirizzo_arg varchar2, Mese int, Anno int default '2019', Euro varchar2) is
BEGIN
            ui.htmlOpen;
        
            ui.openBarraMenu(username,status);
            ui.inizioPagina('Operatori ');
            ui.openBodyStyle;
            ui.openBody;
            if Anno= '0' then
            ui.titolo('Operatori che hanno guadagnato più ' || Euro);
            else
            ui.titolo('Operatori che nel ' || Anno || ' hanno guadagnato più di '|| Euro || '€ ');
            end if;
        
            ui.openDiv(idDiv => 'header');
            
            ui.apriTabella;
            ui.apriRigaTabella;
        
            ui.intestazioneTabella(testo => 'Nome e Cognome');
            ui.intestazioneTabella(testo => 'Licenziato');
            ui.intestazioneTabella(testo => 'Reddito');
            ui.intestazioneTabella(testo => 'Presso');
            ui.chiudiRigaTabella;
            ui.chiudiTabella;
            ui.closeDiv;
      
            ui.openDiv(idDiv => 'tabella');
    
            ui.apriTabella;
      
            FOR persone IN (
                            SELECT  p.Nome, p.Cognome, p.pk_persona, d.Licenziamento, se.Importo,pa.pk_ParcheggioAutomatico, pa.indirizzo, pa.Citta
                            FROM  Persone p, Dipendenti d, StipendiErogati se, Operatori o, ParcheggiAutomatici pa, Sedi sd
                            WHERE  p.pk_persona=d.pk_dipendente
                            AND    d.pk_Dipendente=o.pk_operatore
                            AND    d.pk_dipendente=se.fk_dipendente
                            AND    o.fk_parcheggioautomatico=pa.pk_parcheggioautomatico
                            AND    sd.pk_sede=pa.fk_sede
                            AND    ( Indirizzo_arg='Tutti'  OR sd.indirizzo = Indirizzo_arg ) 
                           
                            AND   ( Mese= '0' OR ( EXTRACT( MONTH FROM se.Data) = Mese ) ) 
                            AND   ( ( EXTRACT( YEAR FROM se.Data) ) = Anno)
                            AND   (se.Importo> CAST (REPLACE(Euro,',','') AS FLOAT) ) 
                            GROUP BY  p.Nome, p.Cognome, p.pk_persona, d.Licenziamento, se.Importo, pa.pk_ParcheggioAutomatico, pa.indirizzo, pa.Citta
                            ORDER BY se.Importo desc
            )
            LOOP
                ui.apriRigaTabella;
            
               ui.elementoTabella(persone.Nome||' ' ||persone.Cognome,linkTo => C_PACKAGE_VONA||'?username='||username||'&status='||status||'&p_cliente='||persone.pk_persona);
        
                IF( persone.licenziamento IS NULL) THEN
                 ui.elementoTabella('NO');
                ELSE 
                 ui.elementoTabella('SI');
                END IF;
                ui.elementoTabella(persone.Importo|| '  €');
                ui.elementoTabella(persone.indirizzo || ' ' || persone.Citta, linkTo => C_PACKAGE_DELLEPIANE || '.visualizzaParcheggi?username=' || username || '&status=' ||status || '&parcheggio=' || persone.pk_ParcheggioAutomatico);
                ui.chiudiRigaTabella;
            END LOOP;
            ui.chiudiTabella;
            ui.vaiACapo;
            ui.vaiACapo;
            ui.creaBottoneLink(C_PACKAGE||'DettagliAnagrafici?username='||username||'&status='||status||'&Indirizzo_arg='||Indirizzo_arg||'&Mese='||Mese||'&Anno='||Anno||'&Euro='||Euro, 'Indietro');
            ui.closeDiv;
            ui.closeBody;
      
         ui.htmlClose;
END DettagliOperatori;

procedure DettagliAnagrafici(username varchar2 default 'utente',status varchar2 default '', Indirizzo_arg varchar2 , Mese int default 0, Anno int default '2019', Euro varchar2 ) is 
   permessi_negati EXCEPTION;
   trovato boolean default true;
BEGIN
            
            ui.htmlOpen;  
            ui.openBarraMenu(username,status);
            
            ui.inizioPagina('Responsabili');
            ui.openBodyStyle;
            ui.openBody;
            if Mese= '0' then
            ui.titolo('Responsabili che nel ' || Anno || ' hanno guadagnato più degli operatori che hanno guadagnato più di ' || Euro || '€ ');
            else
            ui.titolo('Responsabili che nel ' || Mese || '-' || Anno || ' hanno guadagnato più degli operatori che hanno guadagnato più di ' || Euro || '€ ');
            end if;
             
            ui.openDiv(idDiv => 'header');
            ui.apriTabella;
            ui.apriRigaTabella;
            
            ui.intestazioneTabella(testo => 'Nome e Cognome');
            ui.intestazioneTabella(testo => 'Sesso');
            ui.intestazioneTabella(testo => 'CodiceFiscale');
            ui.intestazioneTabella(testo => 'Data di Nascita');
            ui.intestazioneTabella(testo => 'Luogo di Nascita');
            ui.intestazioneTabella(testo => 'Licenziato');
            ui.intestazioneTabella(testo => 'Reddito');
            ui.chiudiRigaTabella;
            ui.chiudiTabella;
            ui.closeDiv;
      
            ui.openDiv(idDiv => 'tabella');
    
            ui.apriTabella;
      
            FOR persone IN (
                            SELECT p.CodiceFiscale, p.Nome, p.Cognome, p.Sesso, p.DataNascita, p.LuogoNascita,
                            d.Licenziamento, se.Importo
                            FROM  Persone p, Dipendenti d,Utenti u, StipendiErogati se, ParcheggiAutomatici pa, Sedi sd, Responsabili r
                            WHERE u.fk_persona=p.pk_persona
                            AND   p.pk_persona=d.pk_dipendente
                            AND   d.pk_dipendente=r.pk_responsabile 
                            AND   d.pk_dipendente=se.fk_dipendente
                            AND   r.fk_sede=sd.pk_sede
                            AND   (Indirizzo_arg= 'Tutti' OR sd.indirizzo = Indirizzo_arg )
                            AND   ( Mese= '0' OR ( EXTRACT( MONTH FROM se.Data) = Mese ) ) 
                            AND   ( Anno= '2019' OR ( EXTRACT( YEAR FROM se.Data)  = Anno) )
                            AND   se.Importo >  (
                                    SELECT MAX(se.Importo)
                                    FROM   StipendiErogati se, Operatori o , ParcheggiAutomatici pa, Sedi sd
                                    WHERE   o.pk_Operatore=se.fk_Dipendente
                                     AND     o.fk_parcheggioautomatico=pa.pk_parcheggioautomatico
                                     AND    sd.pk_sede=pa.fk_sede
                                    AND    ( Indirizzo_arg='Tutti'  OR sd.indirizzo = Indirizzo_arg ) 
                                    AND    ( Mese= '0' OR ( EXTRACT( MONTH FROM se.Data) = Mese ) )
                                    AND    ( Anno='2019' OR ( EXTRACT( YEAR FROM se.Data)  = Anno) )
                                    AND   (se.Importo> CAST (REPLACE(Euro,',','') AS FLOAT) ) 
                                 ) 
                            
                            GROUP BY p.CodiceFiscale, p.Nome, p.Cognome, p.Sesso, p.DataNascita, p.LuogoNascita,
                            d.Licenziamento, se.Importo
                            ORDER BY se.Importo desc
                            )
           LOOP
                ui.apriRigaTabella;
            
                ui.elementoTabella(persone.Nome||' ' || persone.Cognome );
                ui.elementoTabella(persone.Sesso);
                ui.elementoTabella(persone.CodiceFiscale);
                ui.elementoTabella(persone.DataNascita);
                ui.elementoTabella(persone.LuogoNascita);
               
               IF( persone.licenziamento IS NULL) THEN
                 ui.elementoTabella('NO');
                ELSE 
                 ui.elementoTabella('SI');
                END IF;
                ui.elementoTabella(persone.Importo|| '  €');
                
                 ui.chiudiRigaTabella;
                trovato:=false;
          END LOOP;
         ui.chiudiTabella;
       IF trovato THEN
            ui.apriTabella;
                ui.apriRigaTabella;
                ui.elementoTabella(testo => 'Nessun Risultato trovato');
                 ui.chiudiRigaTabella;
                ui.chiudiTabella;
                ui.VaiACapo;
                 ui.creaBottoneLink(C_PACKAGE||'FormDettagliAnagrafici?username='||username||'&status='||status, 'Indietro');
                
        ELSE 
            ui.VaiACapo;
            ui.creaBottoneLink(C_PACKAGE||'FormDettagliAnagrafici?username='||username||'&status='||status, 'Indietro');
            ui.creaBottoneLink(C_PACKAGE||'DettagliOperatori?username='||username||'&status='||status||'&Indirizzo_arg='||Indirizzo_arg||'&Mese='||Mese||'&Anno='||Anno||'&Euro='||Euro, 'Reddito Operatori più di ' || Euro);
        END IF;
        
         ui.closeDiv;
         ui.closeBody;
      
         ui.htmlClose;
END DettagliAnagrafici;


procedure FormDettagliAnagrafici(username varchar2 default 'utente',status varchar2 default '') is 
    permessi_negati EXCEPTION;
BEGIN
            ui.htmlOpen;
            
            ui.openBarraMenu(username,status);
            ui.inizioPagina('Dettagli Anagrafici');
            ui.openBodyStyle;
            ui.openBody;
            ui.openDiv(idDiv => 'header');
            
            ui.creaForm('Dettagli Anagrafici dei responsabili che guadagnano più degli operatori che guadagnano più di x' , C_PACKAGE||'DettagliAnagrafici');
            
            ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'username', inputType => 'hidden', defaultText => username);
            ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
            
            ui.creaComboBox( 'Scegli Sede' , 'Indirizzo_arg' );
            ui.aggOpzioneAComboBox( 'Tutti', 'Tutti');
            /* visualizzo tutti i parcheggi all'interno di una comboBox */
            FOR sede IN   (SELECT 
                                sd.Citta, 
                                sd.Indirizzo
                                FROM Sedi sd
                                WHERE sd.Stato= '1' )
            LOOP  
                 ui.apriRigaTabella;
                 ui.aggOpzioneAComboBox(sede.Indirizzo || ', ' || sede.Citta , sede.Indirizzo );
                 ui.chiudiRigaTabella;
            END LOOP;
            ui.chiudiSelectComboBox;
            ui.vaiACapo; 
             ui.vaiACapo;
             ui.vaiACapo;
            
             ui.creaComboBox('Scegli mese', 'Mese');
                ui.aggOpzioneAComboBox('Tutti','0');
                ui.aggOpzioneAComboBox('Gennaio','1');
                ui.aggOpzioneAComboBox('Febbraio','2');
                ui.aggOpzioneAComboBox('Marzo','3');
                ui.aggOpzioneAComboBox('Aprile', '4');
                ui.aggOpzioneAComboBox('Maggio', '5');
                ui.aggOpzioneAComboBox('Giugno', '6');
                ui.aggOpzioneAComboBox('Luglio', '7');
                ui.aggOpzioneAComboBox('Agosto', '8');
                ui.aggOpzioneAComboBox('Settembre', '9');
                ui.aggOpzioneAComboBox('Ottobre', '10');
                ui.aggOpzioneAComboBox('Novembre', '11');
                ui.aggOpzioneAComboBox('Dicembre', '12');
            ui.chiudiSelectComboBox;
            ui.vaiACapo;
            ui.vaiACapo;
           ui.creaTextField('Scegli anno ', 'YYYY', 'Anno' , flag => 'required' );
           ui.vaiACapo;
           ui.vaiACapo;
           ui.creaTextField('Guadagna più di ', '€€€€', 'Euro', flag => 'required');
           
            ui.creaBottoneLink('.ui.openPage?title=Homepage&isLogged=1&username=' || username ||'&status=' || status, 'Homepage'); 
           ui.creaBottone('Avanti');
            
           ui.chiudiForm;
        
           ui.closeDiv;
    
           ui.closeBody;
           ui.htmlClose;

END FormDettagliAnagrafici;

procedure VisualizzaDettagliSoste(username varchar2 default 'utente',status varchar2 default '',veicolo_pk INT, parcheggio_arg varchar2, Inizio_arg date, Fine_arg date ) is
BEGIN
    ui.htmlOpen;
	
	ui.inizioPagina(titolo => 'Dettagli Soste');

    ui.openBodyStyle;  
    ui.openBarraMenu(username,status);
    
    ui.titolo(titolo => 'Soste');
       
    ui.openDiv(idDiv => 'header');
    ui.apriTabella;
    ui.apriRigaTabella;
	ui.intestazioneTabella(testo => 'Targa');
    ui.intestazioneTabella(testo => 'Inizio');
	ui.intestazioneTabella(testo => 'Fine');
    ui.intestazioneTabella(testo => 'Box');
    ui.intestazioneTabella(testo => 'Parcheggio');
    ui.chiudiRigaTabella;
    ui.chiudiTabella;
    ui.closeDiv;
    
    ui.openDiv(idDiv => 'tabella');
    
    ui.apriTabella;

    for sosta in (select     bx.pk_box,
                             pa.pk_parcheggioautomatico,
                             pa.Citta,
                             pa.Indirizzo,
                             v.Targa,
                             TO_CHAR( st.Inizio, 'DD/MM/YYYY HH24:MI ' ) as OraInizio,
                             TO_CHAR( st.Fine, 'DD/MM/YYYY HH24:MI ' ) as OraFine
                             FROM Soste st,Box bx, ParcheggiAutomatici pa, Veicoli v, Colonne cn
                             WHERE st.fk_veicolo=v.pk_veicolo
                             AND   st.fk_box=bx.pk_box
                             AND   bx.fk_Colonna=cn.pk_colonna
                             AND   cn.fk_parcheggioautomatico=pa.pk_parcheggioautomatico
                             AND  (parcheggio_arg='0' OR pa.pk_parcheggioautomatico=parcheggio_arg)
                             AND  v.pk_veicolo=veicolo_pk
                             AND  st.Fine is not null
                             AND  ( Inizio_arg is null OR cast( st.Inizio as date) >= TO_DATE(Inizio_arg) )
                             AND  ( Fine_arg is null OR cast( st.Fine as date) <=  TO_DATE(Fine_arg)+1 ) )                      
	loop  
     ui.apriRigaTabella;
     ui.ElementoTabella(sosta.Targa);
	 ui.ElementoTabella(sosta.OraInizio);
     ui.ElementoTabella(sosta.OraFine);
      ui.elementoTabella(sosta.pk_Box, C_PACKAGE_BELLO || '.visualizzaBox?username=' || username || '&status=' ||status || 
                            '&v_box=' || sosta.pk_Box);
     ui.elementoTabella(sosta.indirizzo || ' ' || sosta.Citta, linkTo => C_PACKAGE_DELLEPIANE || '.visualizzaParcheggi?username=' || username || '&status=' ||status || '&parcheggio=' || sosta.pk_ParcheggioAutomatico);
	 ui.chiudiRigaTabella;
     end loop;
     ui.chiudiTabella;
    
     ui.VaiACapo;
    
     ui.creaBottoneBack('Indietro');
    ui.closeDiv;
    ui.closeBody;
    ui.htmlClose;
END VisualizzaDettagliSoste;

procedure ClassificaTempoMedio(username varchar2 default 'utente',status varchar2 default '', Indirizzo_arg varchar2, OreMinuti char, datainizio char default '2019-10-01', dataFine char default '2019-12-01') is
    n INT:=0;
    Inizio_arg DATE;
    Fine_arg   DATE;
    Ore_arg NUMBER;
    Ore_char CHAR;
    parcheggio_arg INT;
    sostaoraria BOOLEAN;
    trovato boolean default true;
BEGIN

            ui.htmlOpen;  
            ui.openBarraMenu(username,status);
            
            ui.inizioPagina('Classifica');
            ui.openBodyStyle;
            ui.openBody;
            
            IF Indirizzo_arg='Tutti' THEN parcheggio_arg:='0';
            ELSE    SELECT pa.pk_parcheggioautomatico
                    INTO parcheggio_arg
                    FROM ParcheggiAutomatici pa
                    WHERE pa.Indirizzo=Indirizzo_arg;
            END IF;
                  
            
            Inizio_arg:=to_char(TO_DATE(datainizio, 'YYYY-MM-DD'),'DD-MON-YY');
            Fine_arg:=to_char(TO_DATE(dataFine, 'YYYY-MM-DD'),'DD-MON-YY');
            
            SELECT to_number(to_char(to_date(OreMinuti,'hh24:mi'),'sssss'))/60 
            INTO Ore_arg
            FROM dual;
           
            IF Indirizzo_arg='Tutti' THEN 
                IF (Inizio_arg IS NULL AND Fine_arg is NOT NULL) THEN
                    ui.titolo('Classifica del tempo medio di permanenza dei veicoli fino al ' || Fine_arg || ' presso tutti i parcheggi' );
                ELSIF (Fine_arg IS NULL AND Inizio_arg is NOT NULL) THEN
                    ui.titolo('Classifica del tempo medio di permanenza dei veicoli dal ' || Inizio_arg || ' fino ad oggi presso tutti i parcheggi' );
                ELSIF(Fine_arg IS NULL AND Inizio_arg is  NULL) THEN
                    ui.titolo('Classifica del tempo medio di permanenza dei veicoli fino ad oggi presso tutti i parcheggi' );
                ELSE 
                    ui.titolo('Classifica del tempo medio di permanenza dei veicoli dal '||Inizio_arg||' al '||Fine_arg|| ' presso il parcheggio tutti i parcheggi');
                END IF;
            ELSE 
                IF (Inizio_arg IS NULL AND Fine_arg is NOT NULL) THEN
                    ui.titolo('Classifica del tempo medio di permanenza dei veicoli fino al ' || Fine_arg || ' presso il parcheggio ' ||Indirizzo_arg);
                ELSIF (Fine_arg IS NULL AND Inizio_arg is NOT NULL) THEN
                    ui.titolo('Classifica del tempo medio di permanenza dei veicoli dal ' || Inizio_arg || ' fino ad oggi presso il parcheggio ' ||Indirizzo_arg);
                ELSIF(Fine_arg IS NULL AND Inizio_arg is  NULL) THEN
                    ui.titolo('Classifica del tempo medio di permanenza dei veicoli fino ad oggi presso il parcheggio ' ||Indirizzo_arg);     
                ELSE  ui.titolo('Classifica del tempo medio di permanenza dei veicoli dal '||Inizio_arg||' al '||Fine_arg|| ' presso il parcheggio ' ||Indirizzo_arg);
                
                END IF;
            END IF;
            
            ui.openDiv(idDiv => 'header');
            ui.apriTabella;
            ui.apriRigaTabella;
            
            ui.intestazioneTabella(testo => 'N° ');
            ui.intestazioneTabella(testo => 'Veicolo');
            ui.intestazioneTabella(testo => 'Tempo medio di permanenza');
            ui.intestazioneTabella(testo => 'Parcheggio');
            ui.intestazioneTabella(testo => 'Dettagli Soste');
           
            ui.chiudiRigaTabella;
            ui.chiudiTabella;
            ui.closeDiv;
      
            ui.openDiv(idDiv => 'tabella');
    
            ui.apriTabella;

            FOR veicolo IN (
                            SELECT  DISTINCT v.Targa,v.pk_veicolo,p.Nome, p.Cognome,pa.Indirizzo, pa.Citta, pa.pk_parcheggioautomatico,tempoMedio --,
                            FROM  ( 
                                SELECT v.Targa, v.pk_veicolo,p.Nome, p.Cognome, pa.Indirizzo, pa.Citta, pa.pk_parcheggioautomatico,--,pa.Indirizzo, pa.Citta , 
                                round ( AVG( (cast( st.Fine as date) - cast(st.Inizio as date) ) * 24 * 60 ), 1 )  as tempoMedio 
                                FROM Soste st, Veicoli v, Clienti cl, ParcheggiAutomatici pa, Box , Colonne cn, Persone p
                                WHERE st.fk_veicolo=v.pk_veicolo
                                AND   v.fk_proprietario=cl.pk_cliente
                                AND   cl.pk_cliente=p.pk_persona
                                AND  st.fk_box=Box.pk_box
                                AND   Box.fk_colonna=cn.pk_colonna
                                AND   cn.fk_ParcheggioAutomatico=pa.pk_ParcheggioAutomatico  
                                AND  (Indirizzo_arg= 'Tutti' OR pa.indirizzo = Indirizzo_arg )
                                AND  ( Inizio_arg is null OR cast( st.Inizio as date) >= TO_DATE(Inizio_arg) )
                                AND  ( Fine_arg is null OR cast( st.Fine as date) <=  TO_DATE(Fine_arg)+1 )
                                GROUP BY v.Targa, v.pk_veicolo, p.Nome, p.Cognome, pa.Indirizzo, pa.Citta, pa.pk_parcheggioautomatico
                                HAVING round ( AVG( (cast( st.Fine as date) - cast(st.Inizio as date) ) * 24 * 60 ), 1 )  >=  Ore_arg
                            ) q
                           JOIN Veicoli v ON q.Targa = v.Targa AND q.pk_veicolo=v.pk_veicolo
                           JOIN Persone p ON q.Nome= p.Nome AND q.Cognome=p.Cognome
                           JOIN ParcheggiAutomatici pa ON q.Indirizzo=pa.Indirizzo AND q.Citta=pa.Citta AND q.pk_parcheggioautomatico=pa.pk_parcheggioautomatico
                           ORDER BY tempoMedio desc
                        )
             
           LOOP
                n:=n+1;
                ui.apriRigaTabella;
                ui.elementoTabella(n);
                IF(status='superuser') THEN
                    ui.ElementoTabella(veicolo.Targa, linkTo =>C_PACKAGE_MAIO||'?username='||username||'&status='||status||'&idVeicolo='||veicolo.pk_veicolo);
                ELSE 
                    ui.ElementoTabella(veicolo.Targa);
                END IF; 
                ui.elementoTabella((TO_CHAR( FLOOR (veicolo.tempoMedio / 60) ) || ':' || TO_CHAR ( MOD (veicolo.tempoMedio, 60) , 'FM00')) || ' h'  );   
                 ui.elementoTabella(veicolo.indirizzo || ' ' || veicolo.Citta, linkTo => C_PACKAGE_DELLEPIANE || '.visualizzaParcheggi?username=' || username || '&status=' ||status || '&parcheggio=' || veicolo.pk_ParcheggioAutomatico);
                
                ui.ApriElementoTabella;
                ui.createlinkableButton(linkTo =>C_URL||C_PACKAGE||'VisualizzaDettagliSoste?username='||username||'&status='||status||'&veicolo_pk='||veicolo.pk_veicolo||'&parcheggio_arg='||parcheggio_arg||'&Inizio_arg='||Inizio_arg||'&Fine_arg='||Fine_arg, text => 'MOSTRA');
                ui.ChiudiElementoTabella;
                ui.chiudiRigaTabella;
                trovato:=false;
          END LOOP;
         ui.chiudiTabella;
          IF trovato THEN
            ui.apriTabella;
                ui.apriRigaTabella;
                ui.elementoTabella(testo => 'Nessun Risultato trovato');
                 ui.chiudiRigaTabella;
                ui.chiudiTabella;
        END IF;
         ui.vaiACapo;
        
         ui.creaBottoneBack('Indietro');
         ui.closeDiv;
         ui.closeBody;
      
         ui.htmlClose;
END ClassificaTempoMedio;

procedure FormClassificaTempoMedio(username varchar2 default 'utente',status varchar2 default '') is
p_username varchar(45):=username;
BEGIN
            ui.htmlOpen;
            
            ui.openBarraMenu(username,status);
            ui.inizioPagina('Classifica Tempo Medio');
            ui.openBodyStyle;
            ui.openBody;
            ui.titolo('Classifica');
            ui.openDiv(idDiv => 'header');
            
            ui.creaForm('Classifica del tempo medio di permanenza dei veicoli' , C_PACKAGE||'ClassificaTempoMedio');
            
            ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'username', inputType => 'hidden', defaultText => username);
            ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
            
            ui.creaComboBox( 'Scegli Parcheggio' , 'Indirizzo_arg' );
            ui.aggOpzioneAComboBox( 'Tutti', 'Tutti');
            /* visualizzo tutti i parcheggi all'interno di una comboBox */
           FOR parcheggio IN   (SELECT 
                                pa.Citta, 
                                pa.Indirizzo
                                FROM Utenti u, Persone p, Dipendenti d, Responsabili r, ParcheggiAutomatici pa, Sedi s
                                WHERE ( status='superuser' OR status='amministratore' OR u.username=p_username)
                                AND   u.fk_persona=p.pk_persona
                                AND   p.pk_persona=d.pk_dipendente
                                AND   d.pk_dipendente=r.pk_responsabile
                                AND   r.fk_sede=s.pk_sede
                                AND   s.pk_sede=pa.fk_sede
                                AND   s.stato=1
                                AND   pa.Stato='1' )
            LOOP  
                 ui.apriRigaTabella;
                 ui.aggOpzioneAComboBox(parcheggio.Indirizzo || ', ' || parcheggio.Citta , parcheggio.Indirizzo );
                 ui.chiudiRigaTabella;
            END LOOP;
            ui.chiudiSelectComboBox;
            ui.vaiACapo; 
            ui.vaiACapo;
            ui.vaiACapo;
            ui.creaTextField(nomeRif => 'Dal', placeholder => 'DD-MM-YYYY', nomeParametroGet => 'datainizio',/* flag => 'required', */inputType => 'date');
            ui.creaTextField(nomeRif => 'Al', placeholder => 'DD-MM-YYYY', nomeParametroGet => 'dataFine', /*flag => 'required',*/ inputType => 'date');
          
            ui.vaiACapo;
            ui.vaiACapo;
            ui.creaTextField('Permanenza superiore o uguale a', 'HH24:MM', 'OreMinuti', flag => 'required');
            
            ui.creaBottoneLink('.ui.openPage?title=Homepage&isLogged=1&username=' || username ||'&status=' || status, 'Homepage'); 
            ui.creaBottone('Visualizza Classifica');
            
            ui.chiudiForm;
            
            ui.closeDiv;
    
            ui.closeBody;
            ui.htmlClose;

END FormClassificaTempoMedio;

procedure DettagliVeicoli(username varchar2 default 'utente',status varchar2 default '',sede_pk INT, datainizio char default '2019-10-01', dataFine char  default '2019-12-01' ) is

Inizio_arg date;
Fine_arg date;
BEGIN
    ui.htmlOpen;
	
    ui.inizioPagina(titolo => 'Dettagli delle soste dei veicoli non sanzionati'); 

    ui.openBodyStyle;

     ui.openBarraMenu(username, status);

    ui.openDiv(idDiv => 'header');
    ui.apriTabella;
    ui.apriRigaTabella;
	ui.intestazioneTabella(testo => 'Targa Veicolo');
    ui.intestazioneTabella(testo => 'Inizio Sosta');
    ui.intestazioneTabella(testo => 'Fine Sosta');

    ui.chiudiRigaTabella;
    ui.chiudiTabella;
    ui.closeDiv;
    Inizio_arg:=to_char(TO_DATE(datainizio, 'YYYY-MM-DD'),'DD-MON-YY');
    Fine_arg:=to_char(TO_DATE(dataFine, 'YYYY-MM-DD'),'DD-MON-YY');
    ui.openDiv(idDiv => 'tabella');
    
    ui.apriTabella;
     FOR  veicolo IN  
                   (SELECT v.Targa, v.pk_veicolo, s.pk_sosta, s.Inizio, s.Fine
                    FROM  Veicoli v, Sedi sd, ParcheggiAutomatici pa, colonne cn, box bx, Soste s
                    WHERE NOT EXISTS (SELECT NULL
                                       FROM Sanzioni sz
                                       WHERE v.pk_veicolo= sz.fk_veicolo
                                       AND  sz.Rilevamento BETWEEN Inizio_arg AND Fine_arg ) 
                    AND  sd.pk_sede=pa.fk_sede
                    AND  sd.pk_sede=sede_pk
                    AND  pa.pk_parcheggioautomatico=cn.fk_parcheggioautomatico
                    AND  cn.pk_colonna=bx.fk_colonna and s.fk_veicolo=v.pk_veicolo
                    AND  bx.pk_box=s.fk_box
                    --and s.Inizio between Inizio_arg and Fine_arg+1
                    AND  (Inizio_arg is null OR s.Inizio>=Inizio_arg)
                    AND  (Fine_arg is null OR s.Inizio<=Fine_arg) )
   
     loop  
     ui.apriRigaTabella;
     IF(status='superuser') THEN
        ui.ElementoTabella(veicolo.Targa, linkTo =>C_PACKAGE_MAIO||'?username='||username||'&status='||status||'&idVeicolo='||veicolo.pk_veicolo);
     ELSE 
         ui.ElementoTabella(veicolo.Targa);
    END IF;
     ui.ElementoTabella(to_char(veicolo.Inizio, 'DD-MON-YY, HH:MM'));
     ui.ElementoTabella(to_char(veicolo.Fine, 'DD-MON-YY, HH:MM'));
	 ui.chiudiRigaTabella;
     end loop;
     ui.chiudiTabella;  
     ui.creaBottoneBack('Indietro');
     ui.closeDiv;
    
    ui.closeBody;
    
    ui.htmlClose;
    

END DettagliVeicoli;

procedure DettagliSedi(username varchar2 default 'utente',status varchar2 default '', datainizio char default '2019-10-01', dataFine char  default '2019-12-01') is
Inizio_arg date;
Fine_arg date;
trovato boolean default true;
BEGIN
    Inizio_arg:=to_char(TO_DATE(datainizio, 'YYYY-MM-DD'),'DD-MON-YY');
    Fine_arg:=to_char(TO_DATE(dataFine, 'YYYY-MM-DD'),'DD-MON-YY');
    ui.htmlOpen;
	
     ui.inizioPagina(titolo => 'Dettagli Sedi'); 
 
     ui.openBodyStyle;

     ui.openBarraMenu(username, status);
      IF (Inizio_arg IS NULL AND Fine_arg is NOT NULL) THEN
                    ui.titolo(titolo => 'Dettagli della sede in cui è presente almeno un veicolo non sanzionato fino al ' ||  Fine_arg);
                ELSIF (Fine_arg IS NULL AND Inizio_arg is NOT NULL) THEN
                   ui.titolo(titolo => 'Dettagli della sede in cui è presente almeno un veicolo non sanzionato dal ' || Inizio_arg || '  fino ad oggi' );
                ELSIF(Fine_arg IS NOT NULL AND Inizio_arg is NOT NULL) THEN
                    ui.titolo(titolo => 'Dettagli della sede in cui è presente almeno un veicolo non sanzionato dal '||Inizio_arg||' al ' ||Fine_arg);
                ELSE 
                    ui.titolo(titolo => 'Dettagli della sede in cui è presente almeno un veicolo non sanzionato');
        END IF;     
    
    ui.openDiv(idDiv => 'header');
    ui.apriTabella;
    ui.apriRigaTabella;
	ui.intestazioneTabella(testo => 'Sede');
    ui.intestazioneTabella(testo => 'Soste effettuate da un veicolo non sanzionato');

   
    
            ui.chiudiRigaTabella;
            ui.chiudiTabella;
            ui.closeDiv;
      
            ui.openDiv(idDiv => 'tabella');
    
            ui.apriTabella;
    --tutti i veicoli che durante una sosta non sono stati sanzionati
    FOR  sede IN 
                  --tutti i veicoli cHE NON HANNO una sanzione durante un certo periodo  
                   (SELECT  Sd.Indirizzo, Sd.Citta, Sd.pk_sede, count(*) as c
                    FROM  Veicoli v, Sedi sd, ParcheggiAutomatici pa, colonne cn, box bx, Soste s
                    WHERE NOT EXISTS (SELECT NULL
                                       FROM Sanzioni sz
                                       WHERE v.pk_veicolo= sz.fk_veicolo
                                       AND  sz.Rilevamento BETWEEN Inizio_arg AND Fine_arg ) 
                    AND  sd.pk_sede=pa.fk_sede
                    AND  pa.pk_parcheggioautomatico=cn.fk_parcheggioautomatico
                    AND  cn.pk_colonna=bx.fk_colonna and s.fk_veicolo=v.pk_veicolo
                    AND  bx.pk_box=s.fk_box
                    AND  (Inizio_arg is null OR s.Inizio>=Inizio_arg)
                    AND  (Fine_arg is null OR s.Inizio<=Fine_arg)
                    --and   s.Inizio between Inizio_arg and Fine_arg+1
                    group by Sd.Indirizzo, sd.Citta, sd.pk_sede
                    HAVING count(*) >=1 )
     loop  
     ui.apriRigaTabella;
     IF(status='amministratore' OR status='superuser') THEN
        ui.elementoTabella(testo => sede.citta || ', ' || sede.indirizzo, linkTo =>C_PACKAGE_FALLENI||'?username=' || username || '&status='|| status || '&sede='|| sede.pk_sede);
     ELSE 
        ui.elementoTabella(testo => sede.citta || ', ' || sede.indirizzo);
     END IF;
     ui.ElementoTabella(sede.c, C_URL||C_PACKAGE||'DettagliVeicoli?username='||username||'&status='||status||'&sede_pk='||sede.pk_sede||'&datainizio='||datainizio||'&dataFine='||dataFine);
     
	 ui.chiudiRigaTabella;
     trovato:=false;
     end loop;
         ui.chiudiTabella;
       IF trovato THEN
            ui.apriTabella;
                ui.apriRigaTabella;
                ui.elementoTabella(testo => 'Nessun Risultato trovato');
                 ui.chiudiRigaTabella;
                ui.chiudiTabella;
        END IF;
        ui.VaiACapo;

                 
     ui.chiudiTabella;  
     
     ui.creaBottoneBack('Indietro');
     ui.closeDiv;
    
    ui.closeBody;
    
    ui.htmlClose;
    
END DettagliSedi;

procedure FormDettagliSedi(username varchar2 default 'utente',status varchar2 default '') is

BEGIN
    ui.htmlOpen;
	
    ui.inizioPagina(titolo => 'Dettagli Sedi'); 

    ui.openBodyStyle;

     ui.openBarraMenu(username, status);
    ui.titolo(titolo => 'Dettagli della sede in cui è presente almeno un veicolo non sanzionato');-- dal '||datainizio|| ' al ' ||  dataFine);
    ui.openDiv;
        
    ui.creaForm('Scegli una data', C_PACKAGE ||'DettagliSedi');		--inserire titlo da visualizzare nella pagina del form
    ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'username', inputType => 'hidden', defaultText => username);
    ui.creaTextField(nomeRif => '',  placeholder => '', nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
   
    ui.vaiACapo;
   ui.creaTextField(nomeRif => 'Dal', placeholder => 'DD-MM-YYYY', nomeParametroGet => 'datainizio'/*, flag => 'required'*/, inputType => 'date');
  ui.creaTextField(nomeRif => 'Al', placeholder => 'DD-MM-YYYY', nomeParametroGet => 'dataFine',/* flag => 'required'*/inputType => 'date');
  
    ui.creaBottoneLink('.ui.openPage?title=Homepage&isLogged=1&username=' || username ||'&status=' || status, 'Homepage'); 
    
    ui.creaBottone('Avanti');	--inserire il nome da vedere sul bottone da premere per inviare i dati

    ui.chiudiForm;

    ui.closeDiv;
    
    ui.closeBody;
    
    ui.htmlClose;

  END FormDettagliSedi;
  
  
      function diffTempo(
        t1 IN TIMESTAMP,
        t2 IN TIMESTAMP
  ) return NUMBER AS
    BEGIN
        return  ( 
                      (extract( minute from (t2) )  
                     + extract( hour from (t2) ) * 60 )  -
                      (  extract( minute from (t1) )
                     + extract( hour from (t1) )  * 60 ) )
                     ;
    END diffTempo; 
           
END GRUPPO2_TRIGILIA;