create or replace PACKAGE GRUPPO2_TRIGILIA AS 
   
    procedure visualizzaTipiTurno( username varchar2 default 'utente', status varchar2 default '' );
    procedure FormInserimentoTipiTurno(username varchar2 default 'utente', status varchar2 default 'superuser');
    procedure inserimentoTipiTurni(username varchar2 default 'utente',status varchar2 default 'superuser', nome varchar2, orainizio char, orafine char, retribuzioneoraria float);
    procedure handler_eccezione( username varchar2 default 'utente', status varchar2 default '',text varchar2 );
    procedure ReportLavoroNonSvolto (username varchar2 default 'utente', status varchar2 default '',indirizzo_arg varchar2, operatore_pk INT ,datainizio char default '2019-10-01', dataFine char default '2019-12-01' );
    procedure Licenziamento(username varchar2 default 'utente',status varchar2 default '', codfiscale char);
    procedure FormLicenziamento3(username varchar2 default 'utente', status varchar2 default '',tipo_dipendente varchar2 default '',indirizzo_arg varchar2);
    procedure FormLicenziamento2(username varchar2 default 'utente', status varchar2 default '', tipo_dipendente char);
    procedure FormLicenziamento1(username varchar2 default 'utente', status varchar2 default 'superuser');
    procedure FormLavoroNonSvolto2(username varchar2 default 'utente',status varchar2 default '',indirizzo_arg varchar2 );
    procedure FormLavoroNonSvolto(username varchar2 default 'utente',status varchar2 default '');
    procedure DettagliOperatori(username varchar2 default 'utente', status varchar2 default '',Indirizzo_arg varchar2 , Mese int, Anno int default '2019', Euro varchar2 );
    procedure DettagliAnagrafici(username varchar2 default 'utente',status varchar2 default '', Indirizzo_arg varchar2, Mese int default 0, Anno int default '2019', Euro varchar2);
    procedure FormDettagliAnagrafici(username varchar2 default 'utente',status varchar2 default '');
    procedure VisualizzaDettagliSoste(username varchar2 default 'utente',status varchar2 default '',veicolo_pk INT, parcheggio_arg varchar2, Inizio_arg date, Fine_arg date );
    procedure ClassificaTempoMedio(username varchar2 default 'utente',status varchar2 default '',Indirizzo_arg varchar2, OreMinuti char, datainizio char default '2019-10-01', dataFine char  default '2019-12-01');
    procedure FormClassificaTempoMedio(username varchar2 default 'utente', status varchar2 default '');
    procedure DettagliVeicoli(username varchar2 default 'utente',status varchar2 default '',sede_pk INT,datainizio char default '2019-10-01', dataFine char  default '2019-12-01');
    procedure DettagliSedi(username varchar2 default 'utente', status varchar2 default '', datainizio char default '2019-10-01', dataFine char  default '2019-12-01');
    procedure FormDettagliSedi(username varchar2 default 'utente', status varchar2 default '');
    
  function diffTempo (
    t1 IN TIMESTAMP,
    t2 IN TIMESTAMP
  ) return NUMBER; 
    
END GRUPPO2_TRIGILIA;