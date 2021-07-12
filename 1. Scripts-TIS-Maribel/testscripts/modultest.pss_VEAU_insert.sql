
--
--insert into akkradm.IO_VERANSTALTUNG_AUSWERTUNG(VESG_ID,VEAU_KZ_AUSGEFALLEN,VESG_BEGINN,VESG_#BEGINN_ZEIT,VESG_ENDE,VESG_#ENDE_ZEIT,
--						VESG_DAUER,VESG_TN_BEITRAG,VEAU_ANZ_TN_GESAMT,VEAU_ANZ_TN_LEHRKRAEFTE,
--						VEAU_ANZ_TN_WEIBLICH,VEAU_ANZ_TN_MAENNLICH,VEAU_ANZ_TN_GRUNDSCHULE,VEAU_ANZ_TN_REGELSCHULE,
--						VEAU_ANZ_TN_GYMNASIUM,VEAU_ANZ_TN_BERUFSBILDENDE_SCHULE,VEAU_ANZ_TN_GESAMTSCHULE,
--						VEAU_ANZ_TN_FOERDERSCHULE,VEAU_ANZ_TN_KOLLEG,
--						VEAU_ANZ_TN_KINDERTAGESEINRICHTUNG,VEAU_ANZ_TN_SSA,VEAU_ANZ_TN_HOCHSCHULE,VEAU_ANZ_TN_SONSTIGE,
--						VEAU_ANZ_TN_FACHBERATER,VEAU_ANZ_TN_SCHULLEITER,VEAU_ANZ_TN_SCHULLEITUNGSMITGLIED,
--						VEAU_ANZ_TN_BERATUNGSLEHRER,VEAU_ANZ_TN_BERATER_SCHULENTWICKLUNG,VEAU_ANZ_TN_BERATER_DIDAKTIK,
--						VEAU_ANZ_TN_ANDERE_FUNKTIONEN,VEAU_ANZ_TN_EIGENES_BUNDESLAND,VEAU_KZ_DOKUMENTATION,
--						VEAU_EVAL_FRAGEBOGEN,VEAU_EVAL_ZIELSCHEIBE,VEAU_EVAL_POSITIONIERUNG,
--						VEAU_EVAL_MUENDLICHE_RUECKMELDUNG,VEAU_EVAL_SONSTIGES,VEAU_EVAL_INSTRUMENT ) 
--						values( 2,1,'2009-10-08', N'Test','2009-10-08', 
--						N'Test',1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, N'Test' );

declare	@VEAU_id	UDT_ID, @VEAU_user UDT_USER, @VEAU_xpts UDT_#PTS,
	@VESG_ID	UDT_ID,@VEAU_KZ_AUSGEFALLEN	UDT_BOOLEAN,
	@VESG_BEGINN	datetime,@VESG_#BEGINN_ZEIT nvarchar(5),@VESG_ENDE	datetime,@VESG_#ENDE_ZEIT	nvarchar(5),
	@VESG_DAUER	UDT_BETRAG,@VESG_TN_BEITRAG	UDT_BETRAG,@VEAU_ANZ_TN_GESAMT	UDT_ANZAHL_I,@VEAU_ANZ_TN_LEHRKRAEFTE	UDT_ANZAHL_I,@VEAU_ANZ_TN_WEIBLICH	UDT_ANZAHL_I,
	@VEAU_ANZ_TN_MAENNLICH	UDT_ANZAHL_I,@VEAU_ANZ_TN_GRUNDSCHULE	UDT_ANZAHL_I,@VEAU_ANZ_TN_REGELSCHULE	UDT_ANZAHL_I,
	@VEAU_ANZ_TN_GYMNASIUM		UDT_ANZAHL_I,@VEAU_ANZ_TN_BERUFSBILDENDE_SCHULE	UDT_ANZAHL_I,@VEAU_ANZ_TN_GESAMTSCHULE	UDT_ANZAHL_I,
	@VEAU_ANZ_TN_FOERDERSCHULE	UDT_ANZAHL_I,@VEAU_ANZ_TN_KOLLEG			UDT_ANZAHL_I,@VEAU_ANZ_TN_KINDERTAGESEINRICHTUNG	UDT_ANZAHL_I,
	@VEAU_ANZ_TN_SSA	UDT_ANZAHL_I,@VEAU_ANZ_TN_HOCHSCHULE	UDT_ANZAHL_I,@VEAU_ANZ_TN_SONSTIGE	UDT_ANZAHL_I,
	@VEAU_ANZ_TN_FACHBERATER	UDT_ANZAHL_I,@VEAU_ANZ_TN_SCHULLEITER	UDT_ANZAHL_I,@VEAU_ANZ_TN_SCHULLEITUNGSMITGLIED	UDT_ANZAHL_I,
	@VEAU_ANZ_TN_BERATUNGSLEHRER	UDT_ANZAHL_I,@VEAU_ANZ_TN_BERATER_SCHULENTWICKLUNG UDT_ANZAHL_I,@VEAU_ANZ_TN_BERATER_DIDAKTIK	UDT_ANZAHL_I,
	@VEAU_ANZ_TN_ANDERE_FUNKTIONEN	UDT_ANZAHL_I,@VEAU_ANZ_TN_EIGENES_BUNDESLAND	UDT_ANZAHL_I,@VEAU_KZ_DOKUMENTATION	UDT_BOOLEAN,
	@VEAU_EVAL_FRAGEBOGEN	UDT_BOOLEAN,@VEAU_EVAL_ZIELSCHEIBE	UDT_BOOLEAN,@VEAU_EVAL_POSITIONIERUNG	UDT_BOOLEAN,
	@VEAU_EVAL_MUENDLICHE_RUECKMELDUNG	UDT_BOOLEAN,@VEAU_EVAL_SONSTIGES	UDT_BOOLEAN,@VEAU_EVAL_INSTRUMENT	nvarchar(255);

set @VEAU_id = 0;
set @VEAU_user = null;
set	@VEAU_xpts = null;




set	@VEAU_KZ_AUSGEFALLEN                              = 1;
set	@VESG_BEGINN                                      = '2009-10-08';
set	@VESG_#BEGINN_ZEIT                                = 'Tes';
set	@VESG_ENDE                                        = '2009-10-08';
set	@VESG_#ENDE_ZEIT                                  = 'Tes';
set	@VESG_DAUER                                       = 1;
set	@VESG_TN_BEITRAG                                  = 1;
set	@VEAU_ANZ_TN_GESAMT                               = 1;
set	@VEAU_ANZ_TN_LEHRKRAEFTE                          = 1;
set	@VEAU_ANZ_TN_WEIBLICH                             = 1;
set	@VEAU_ANZ_TN_MAENNLICH                            = 1;
set	@VEAU_ANZ_TN_GRUNDSCHULE                          = 1;
set	@VEAU_ANZ_TN_REGELSCHULE                          = 1;
set	@VEAU_ANZ_TN_GYMNASIUM                            = 1;
set	@VEAU_ANZ_TN_BERUFSBILDENDE_SCHULE                = 1;
set	@VEAU_ANZ_TN_GESAMTSCHULE                         = 1;
set	@VEAU_ANZ_TN_FOERDERSCHULE                        = 1;
set	@VEAU_ANZ_TN_KOLLEG                               = 1;
set	@VEAU_ANZ_TN_KINDERTAGESEINRICHTUNG               = 1;
set	@VEAU_ANZ_TN_SSA                                  = 1;
set	@VEAU_ANZ_TN_HOCHSCHULE                           = 1;
set	@VEAU_ANZ_TN_SONSTIGE                             = 1;
set	@VEAU_ANZ_TN_FACHBERATER                          = 1;
set	@VEAU_ANZ_TN_SCHULLEITER                          = 1;
set	@VEAU_ANZ_TN_SCHULLEITUNGSMITGLIED                = 1;
set	@VEAU_ANZ_TN_BERATUNGSLEHRER                      = 1;
set	@VEAU_ANZ_TN_BERATER_SCHULENTWICKLUNG             = 1;
set	@VEAU_ANZ_TN_BERATER_DIDAKTIK                     = 1;
set	@VEAU_ANZ_TN_ANDERE_FUNKTIONEN                    = 1;
set	@VEAU_ANZ_TN_EIGENES_BUNDESLAND                   = 1;
set	@VEAU_KZ_DOKUMENTATION                            = 1;
set	@VEAU_EVAL_FRAGEBOGEN                             = 1;
set	@VEAU_EVAL_ZIELSCHEIBE                            = 1;
set	@VEAU_EVAL_POSITIONIERUNG                         = 1;
set	@VEAU_EVAL_MUENDLICHE_RUECKMELDUNG                = 1;
set	@VEAU_EVAL_SONSTIGES                              = 1;
set	@VEAU_EVAL_INSTRUMENT                             = 'Test';



begin transaction
begin try

	exec akkradm.pss_VEAU_IUD
		@SESSION_ID	= N'471174114711',
		@USER		= N'MZ',

		@VEAU_ID	= @VEAU_id output,
		@VEAU_USER	= @VEAU_user,
		@VEAU_XPTS	= @VEAU_xpts,

		@AAKT_CODE	= 10,			-- 10 = insert, 20 = update, 30 = logical delete, 90 = physical delete

	--> fachliche Felder


		

				@VESG_ID							=   2,
				@VEAU_KZ_AUSGEFALLEN				=   @VEAU_KZ_AUSGEFALLEN,
				@VESG_BEGINN						=   @VESG_BEGINN,
				@VESG_#BEGINN_ZEIT					=   @VESG_#BEGINN_ZEIT,
				@VESG_ENDE							=   @VESG_ENDE,
				@VESG_#ENDE_ZEIT					=   @VESG_#ENDE_ZEIT,
				@VESG_DAUER							=   @VESG_DAUER,
				@VESG_TN_BEITRAG					=   @VESG_TN_BEITRAG,
				@VEAU_ANZ_TN_GESAMT					=   @VEAU_ANZ_TN_GESAMT,
				@VEAU_ANZ_TN_LEHRKRAEFTE			=	@VEAU_ANZ_TN_LEHRKRAEFTE,
				@VEAU_ANZ_TN_WEIBLICH				=	@VEAU_ANZ_TN_WEIBLICH,
				@VEAU_ANZ_TN_MAENNLICH				=	@VEAU_ANZ_TN_MAENNLICH,
				@VEAU_ANZ_TN_GRUNDSCHULE			=	@VEAU_ANZ_TN_GRUNDSCHULE,
				@VEAU_ANZ_TN_REGELSCHULE			=	@VEAU_ANZ_TN_REGELSCHULE,
				@VEAU_ANZ_TN_GYMNASIUM				=	@VEAU_ANZ_TN_GYMNASIUM,
				@VEAU_ANZ_TN_BERUFSBILDENDE_SCHULE	=	@VEAU_ANZ_TN_BERUFSBILDENDE_SCHULE,
				@VEAU_ANZ_TN_GESAMTSCHULE			=	@VEAU_ANZ_TN_GESAMTSCHULE,
				@VEAU_ANZ_TN_FOERDERSCHULE			=	@VEAU_ANZ_TN_FOERDERSCHULE,
				@VEAU_ANZ_TN_KOLLEG					=   @VEAU_ANZ_TN_KOLLEG,
				@VEAU_ANZ_TN_KINDERTAGESEINRICHTUNG	=	@VEAU_ANZ_TN_KINDERTAGESEINRICHTUNG,
				@VEAU_ANZ_TN_SSA					=	@VEAU_ANZ_TN_SSA,
				@VEAU_ANZ_TN_HOCHSCHULE				=	@VEAU_ANZ_TN_HOCHSCHULE,
				@VEAU_ANZ_TN_SONSTIGE				=	@VEAU_ANZ_TN_SONSTIGE,
				@VEAU_ANZ_TN_FACHBERATER			=	@VEAU_ANZ_TN_FACHBERATER,
				@VEAU_ANZ_TN_SCHULLEITER			=	@VEAU_ANZ_TN_SCHULLEITER,
				@VEAU_ANZ_TN_SCHULLEITUNGSMITGLIED	=	@VEAU_ANZ_TN_SCHULLEITUNGSMITGLIED,
				@VEAU_ANZ_TN_BERATUNGSLEHRER		=	@VEAU_ANZ_TN_BERATUNGSLEHRER,
				@VEAU_ANZ_TN_BERATER_SCHULENTWICKLUNG =	@VEAU_ANZ_TN_BERATER_SCHULENTWICKLUNG,
				@VEAU_ANZ_TN_BERATER_DIDAKTIK		=	@VEAU_ANZ_TN_BERATER_DIDAKTIK,
				@VEAU_ANZ_TN_ANDERE_FUNKTIONEN		=	@VEAU_ANZ_TN_ANDERE_FUNKTIONEN,
				@VEAU_ANZ_TN_EIGENES_BUNDESLAND		=	@VEAU_ANZ_TN_EIGENES_BUNDESLAND,
				@VEAU_KZ_DOKUMENTATION				=	@VEAU_KZ_DOKUMENTATION,
				@VEAU_EVAL_FRAGEBOGEN				=	@VEAU_EVAL_FRAGEBOGEN,
				@VEAU_EVAL_ZIELSCHEIBE				=	@VEAU_EVAL_ZIELSCHEIBE,
				@VEAU_EVAL_POSITIONIERUNG			=	@VEAU_EVAL_POSITIONIERUNG,
				@VEAU_EVAL_MUENDLICHE_RUECKMELDUNG	=	@VEAU_EVAL_MUENDLICHE_RUECKMELDUNG,
				@VEAU_EVAL_SONSTIGES				=	@VEAU_EVAL_SONSTIGES,
				@VEAU_EVAL_INSTRUMENT				=	@VEAU_EVAL_INSTRUMENT,


	-->
	--	@KZ_USE_TRANSACTION		= 0,	-- wird derzeit nicht verwendet
		@DEBUG					= 1		-- nur f�r interne Nutzung

	commit transaction;

end try
begin catch
	rollback transaction;

end catch

select	*
from	akkradm.IO_VERANSTALTUNG_AUSWERTUNG
GO