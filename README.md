# LBD_SVILUPPO



Il mio contributo all'implementazione delle operazioni del corso Laboratorio di Basi di Dati (2019\2020)

OPERAZIONI:

• Classifica del tempo medio di permanenza dei veicoli: La classifica, in un determinato periodo, dei tempi medi di permanenza in ogni autorimessa
di tutti i veicoli di proprietà di ogni cliente. Escludere dalla classifica quelli per cui il tempo medio è inferiore di una soglia
(inserita da form). 

• Inserimento Tipo Turno: permette di inserire un nuovo tipo di turno specificando Nome, OraInizio, OraFine e RetribuzioneOraria. 

• Licenziamento: permette di licenziare un dipendente. Il sistema setterà Licenziamento con la data odierna. 

• Visualizza tipi turno: permette di visualizzare tutti i tipi di turno disponibili.

• Report Lavoro non svolto: Fornisce per ogni operatore i dati relativi alla somma tra le seguenti differenze: 
Turni.OraInizioTurno - TipiTurni.OraInizio per ogni Turni.Data
TipoTurni.OraFine - OrarioFineTurno per ogni Turni.Data , in un determinato periodo di tempo (giornaliero/settimanale/mensile/annuale/totale) 

• Dettagli sede con veicolo non sanzionato: trovare i dettagli delle sedi in cui, in un determinato periodo, c'è almeno un veicolo che non abbia
ricevuto sanzioni [durante una sosta] --- classifica delle sedi con meno veicoli sanzionati. Clicco sul count e mi da i dettagli di quei veicoli non sanzionati, clicco su proprietario e mi
visualizza.

• Report Dettagli Anagrafici responsabili: Dettagli anagrafici e reddito dei responsabili di operatori che guadagnano più di x euro (dove x è inserito da form),
con indicazione del reddito dell’operatore. 
