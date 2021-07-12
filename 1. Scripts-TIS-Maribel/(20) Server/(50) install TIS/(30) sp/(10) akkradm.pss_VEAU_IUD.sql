/*	
 * topdev GmbH, erstellt am 08.10.2009 10:12		--topdev GmbH, created at ...
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-10-08 10:12:54 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (010) akkradm.pss_VEAU_IUD.sql $
 *
 */

if not exists ( select * from sysobjects where id = object_id('akkradm.pss_VEAU_IUD') and OBJECTPROPERTY(id, 'IsProcedure') = 1)
begin
	exec( N'create procedure akkradm.pss_VEAU_IUD
	as begin
		print ''Procedure created.'';
	end' );
end
GO

alter procedure akkradm.pss_VEAU_IUD
	@SESSION_ID	UDT_SESSION_ID,		
	@USER		UDT_USER,		

	@VEAU_ID	UDT_ID output,		
	@VEAU_USER	nvarchar(128),		
	@VEAU_XPTS	nvarchar(23),	

	@AAKT_CODE	smallint,			



	@VESG_ID								UDT_ID			,
	@VEAU_KZ_AUSGEFALLEN					UDT_BOOLEAN		,
	@VESG_BEGINN							datetime		,
	@VESG_#BEGINN_ZEIT						nvarchar(5)		,
	@VESG_ENDE								datetime		,
	@VESG_#ENDE_ZEIT						nvarchar(5)		,
	@VESG_DAUER								UDT_BETRAG		,
	@VESG_TN_BEITRAG						UDT_BETRAG		,
	@VEAU_ANZ_TN_GESAMT						UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_LEHRKRAEFTE				UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_WEIBLICH					UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_MAENNLICH					UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_GRUNDSCHULE				UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_REGELSCHULE				UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_GYMNASIUM					UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_BERUFSBILDENDE_SCHULE		UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_GESAMTSCHULE				UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_FOERDERSCHULE				UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_KOLLEG						UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_KINDERTAGESEINRICHTUNG		UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_SSA						UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_HOCHSCHULE					UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_SONSTIGE					UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_FACHBERATER				UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_SCHULLEITER				UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_SCHULLEITUNGSMITGLIED		UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_BERATUNGSLEHRER			UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_BERATER_SCHULENTWICKLUNG	UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_BERATER_DIDAKTIK			UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_ANDERE_FUNKTIONEN			UDT_ANZAHL_I	,
	@VEAU_ANZ_TN_EIGENES_BUNDESLAND			UDT_ANZAHL_I	,
	@VEAU_KZ_DOKUMENTATION					UDT_BOOLEAN		,
	@VEAU_EVAL_FRAGEBOGEN					UDT_BOOLEAN		,
	@VEAU_EVAL_ZIELSCHEIBE					UDT_BOOLEAN		,
	@VEAU_EVAL_POSITIONIERUNG				UDT_BOOLEAN		,
	@VEAU_EVAL_MUENDLICHE_RUECKMELDUNG		UDT_BOOLEAN		,
	@VEAU_EVAL_SONSTIGES					UDT_BOOLEAN		,
	@VEAU_EVAL_INSTRUMENT					nvarchar(255)	,



	@KZ_USE_TRANSACTION	bit = 0,
	@DEBUG				bit = 0		

as begin


	set nocount on;

	declare	@rc			integer,
			@rc_text	nvarchar(1000),
			@sql_error	integer,
			@procName	nvarchar(250),
			@step		nvarchar(100),

			@id				UDT_ID,
			@tbsh_shortname	UDT_TABLENAME_SHORT,
			@uqid			UDT_UQID,
			@pts			datetime,
			@b				bit;


	set @tbsh_shortname = N'VEAU';
	set	@id = @VEAU_ID;


	set @rc = 0;
	set @rc_text = N'';
	set @sql_error = 0;
	set @procName = isNull( Object_Name( @@PROCID ), N'<<unbekannt>>' )


	set @step = 'Gültigkeit und Berechtigungen prüfen';
	if ( @DEBUG = 1 )	print @step;

	if ( @rc = 0 )
	begin
		select @b = services.pfn_isValidSession( @SESSION_ID, @USER );
		if ( @b = 0 )	set @rc = -1;
		if ( @rc <> 0 )
		begin
			set @rc_text = N'Der Benutzername oder die Sitzungsinformationen sind ungültig.';	
		end
	end

	if ( @rc = 0 )
	begin
		select @b = services.pfn_checkGrants( @SESSION_ID, @USER, @AAKT_CODE );
		if ( @b = 0 )	set @rc = -1;
		if ( @rc <> 0 )
		begin
			set @rc_text = N'Sie verfügen nicht über ausreichende Berechtigungen, um diese Aktion auszuführen.'; -- You don't have the permission for the requested action
		end
	end

	if ( @rc = 0 )
	begin
		set @step = N'Standard-Validierung durchführen.';
		if ( @DEBUG = 1 )	print @step;
	end

	if ( @rc = 0 ) and ( @AAKT_CODE not in ( 10, 20, 30, 90 ))
	begin
		set @rc = -1;
		set @rc_text = N'Der Aktionscode = ' + convert( nvarchar(10), @AAKT_CODE ) + ' ist ungültig';	
	end

	if ( @rc = 0 ) and ( @AAKT_CODE = 10 and @id > 0 )
	begin
		set @rc = -1;
		set @rc_text = N'Die VorgangsID ist > 0, aber als Aktion wurde ''Einfügen'' angegeben.'; 
	end

	if ( @rc = 0 ) and ( @AAKT_CODE in ( 20, 30, 90 ) and @id = 0 )
	begin
		set @rc = -1;
		set @rc_text = N'Die VorgangsID ist = 0, aber als Aktion wurde ''Ändern'' oder ''Löschen'' angegeben.'; 
	end




	if ( @rc = 0 )	
	begin
		set @step = N'Prüfen, ob der Vorgang noch unverändert vorhanden ist.';	
		if ( @DEBUG = 1 )	print @step;

		if ( @AAKT_CODE in ( 20, 30, 90 )) and 
		   ( not exists( select 1 from akkradm.IO_VERANSTALTUNG_AUSWERTUNG where VEAU_ID = @VEAU_ID and VEAU_USER = @VEAU_USER and VEAU_#PTS = @VEAU_XPTS ))
		begin
			set @rc = -1;
			set @rc_text = N'Der Vorgang wurde zwischenzetlich geändert. Die gewünschte Aktion kann nicht durchgeführt werden.'; -- The recordset was changed in the meantime. The requested action can not be done.
		end
	end

	if ( @rc = 0 )
	begin
		set @step = N'Fachliche Validierungen durchführen.'; 
		if ( @DEBUG = 1 )	print @step;

	
		if ( ltrim( rtrim( @VESG_#BEGINN_ZEIT )) = N'' )	set @VESG_#BEGINN_ZEIT = null;
		if ( ltrim( rtrim( @VESG_#ENDE_ZEIT )) = N'' )	    set @VESG_#ENDE_ZEIT = null;
		if ( ltrim( rtrim( @VEAU_EVAL_INSTRUMENT )) = N'' )	set @VEAU_EVAL_INSTRUMENT = null;


		if ( @VEAU_EVAL_SONSTIGES is null )					set @VEAU_EVAL_SONSTIGES = 0;
		if ( @VEAU_EVAL_MUENDLICHE_RUECKMELDUNG is null )	set @VEAU_EVAL_MUENDLICHE_RUECKMELDUNG = 0;
		if ( @VEAU_EVAL_POSITIONIERUNG is null )			set @VEAU_EVAL_POSITIONIERUNG = 0;
		if ( @VEAU_EVAL_ZIELSCHEIBE is null )				set @VEAU_EVAL_ZIELSCHEIBE = 0;
		if ( @VEAU_EVAL_FRAGEBOGEN is null )				set @VEAU_EVAL_FRAGEBOGEN = 0;
		if ( @VEAU_KZ_DOKUMENTATION is null )				set @VEAU_KZ_DOKUMENTATION = 0;
		if ( @VEAU_ANZ_TN_EIGENES_BUNDESLAND is null )		set @VEAU_ANZ_TN_EIGENES_BUNDESLAND = 0;
		if ( @VEAU_ANZ_TN_ANDERE_FUNKTIONEN is null )		set @VEAU_ANZ_TN_ANDERE_FUNKTIONEN = 0;
		if ( @VEAU_ANZ_TN_BERATER_DIDAKTIK is null )		set @VEAU_ANZ_TN_BERATER_DIDAKTIK = 0;
		if ( @VEAU_ANZ_TN_BERATER_SCHULENTWICKLUNG is null )	set @VEAU_ANZ_TN_BERATER_SCHULENTWICKLUNG = 0;
		if ( @VEAU_ANZ_TN_BERATUNGSLEHRER is null )			set @VEAU_ANZ_TN_BERATUNGSLEHRER = 0;
		if ( @VEAU_ANZ_TN_SCHULLEITUNGSMITGLIED is null )	set @VEAU_ANZ_TN_SCHULLEITUNGSMITGLIED= 0;
		if ( @VEAU_ANZ_TN_SCHULLEITER is null )				set @VEAU_ANZ_TN_SCHULLEITER= 0;
		if ( @VEAU_ANZ_TN_FACHBERATER is null )				set @VEAU_ANZ_TN_FACHBERATER = 0;
		if ( @VEAU_ANZ_TN_SONSTIGE is null )				set @VEAU_ANZ_TN_SONSTIGE = 0;
		if ( @VEAU_ANZ_TN_HOCHSCHULE is null )				set @VEAU_ANZ_TN_HOCHSCHULE = 0;
		if ( @VEAU_ANZ_TN_SSA is null )						set @VEAU_ANZ_TN_SSA = 0;
		if ( @VEAU_ANZ_TN_KINDERTAGESEINRICHTUNG is null )	set @VEAU_ANZ_TN_KINDERTAGESEINRICHTUNG = 0;		
		if ( @VEAU_ANZ_TN_KOLLEG is null )					set @VEAU_ANZ_TN_KOLLEG = 0;
		if ( @VEAU_ANZ_TN_FOERDERSCHULE is null )			set @VEAU_ANZ_TN_FOERDERSCHULE = 0;
		if ( @VEAU_ANZ_TN_GESAMTSCHULE is null )			set @VEAU_ANZ_TN_GESAMTSCHULE = 0;
		if ( @VEAU_ANZ_TN_BERUFSBILDENDE_SCHULE is null )	set @VEAU_ANZ_TN_BERUFSBILDENDE_SCHULE = 0;
		if ( @VEAU_ANZ_TN_GYMNASIUM is null )				set @VEAU_ANZ_TN_GYMNASIUM = 0;
		if ( @VEAU_ANZ_TN_REGELSCHULE is null )				set @VEAU_ANZ_TN_REGELSCHULE = 0;
		if ( @VEAU_ANZ_TN_GRUNDSCHULE is null )				set @VEAU_ANZ_TN_GRUNDSCHULE = 0;
		if ( @VEAU_ANZ_TN_MAENNLICH is null )				set @VEAU_ANZ_TN_MAENNLICH = 0;
		if ( @VEAU_ANZ_TN_WEIBLICH is null )				set @VEAU_ANZ_TN_WEIBLICH = 0;
		if ( @VEAU_ANZ_TN_LEHRKRAEFTE is null )				set @VEAU_ANZ_TN_LEHRKRAEFTE = 0;
		if ( @VEAU_ANZ_TN_GESAMT	 is null )				set @VEAU_ANZ_TN_GESAMT	 = 0;
		if ( @VESG_TN_BEITRAG is null )						set @VESG_TN_BEITRAG = 0;
		if ( @VESG_DAUER	 is null )						set @VESG_DAUER	 = 0;
		if ( @VEAU_KZ_AUSGEFALLEN is null )					set @VEAU_KZ_AUSGEFALLEN = 0;

	end
--<

	if ( @rc = 0 )
	begin
		set @step = N'Prüfungen sind abgeschlossen und die Verarbeitung wird gestartet.'; 
		if ( @DEBUG = 1 )	print @step;

		set	@pts = getdate();

		if ( @KZ_USE_TRANSACTION = 1 )
		begin
			begin transaction;
		end

		begin try
			if ( @AAKT_CODE = 10 )
			begin
				set @uqid = NewID();

--				set @id = 0;
--				exec services.psp_GetIdentity @TBSH_SHORTNAME = @tbsh_shortname, @IDEN_VALUE = @id output
--				if ( isNull( @id, 0 ) = 0 )
--				begin
--					set @rc = -1;
--					set @rc_text = N'Der Identitätswert für ' + @tbsh_shortname + N' konnte nicht ermittelt werden.';
--				end

				if ( @rc = 0 )
				begin
					set @step = N'Einfügen des Vorgangs.';
					if ( @DEBUG = 1 )	print @step;

					insert into akkradm.IO_VERANSTALTUNG_AUSWERTUNG(
						--VEAU_ID,	
						VESG_ID,VEAU_KZ_AUSGEFALLEN,VESG_BEGINN,VESG_#BEGINN_ZEIT,VESG_ENDE,VESG_#ENDE_ZEIT,
						VESG_DAUER,VESG_TN_BEITRAG,VEAU_ANZ_TN_GESAMT,VEAU_ANZ_TN_LEHRKRAEFTE,
						VEAU_ANZ_TN_WEIBLICH,VEAU_ANZ_TN_MAENNLICH,VEAU_ANZ_TN_GRUNDSCHULE,VEAU_ANZ_TN_REGELSCHULE,
						VEAU_ANZ_TN_GYMNASIUM,VEAU_ANZ_TN_BERUFSBILDENDE_SCHULE,VEAU_ANZ_TN_GESAMTSCHULE,
						VEAU_ANZ_TN_FOERDERSCHULE,VEAU_ANZ_TN_KOLLEG,
						VEAU_ANZ_TN_KINDERTAGESEINRICHTUNG,VEAU_ANZ_TN_SSA,VEAU_ANZ_TN_HOCHSCHULE,VEAU_ANZ_TN_SONSTIGE,
						VEAU_ANZ_TN_FACHBERATER,VEAU_ANZ_TN_SCHULLEITER,VEAU_ANZ_TN_SCHULLEITUNGSMITGLIED,
						VEAU_ANZ_TN_BERATUNGSLEHRER,VEAU_ANZ_TN_BERATER_SCHULENTWICKLUNG,VEAU_ANZ_TN_BERATER_DIDAKTIK,
						VEAU_ANZ_TN_ANDERE_FUNKTIONEN,VEAU_ANZ_TN_EIGENES_BUNDESLAND,VEAU_KZ_DOKUMENTATION,
						VEAU_EVAL_FRAGEBOGEN,VEAU_EVAL_ZIELSCHEIBE,VEAU_EVAL_POSITIONIERUNG,
						VEAU_EVAL_MUENDLICHE_RUECKMELDUNG,VEAU_EVAL_SONSTIGES,VEAU_EVAL_INSTRUMENT,
						VEAU_USER, VEAU_PTS, VEAU_#PTS,
						--VEAU_ID_INT,	
						VEAU_UQID )




					values(
						--@id,
						@VESG_ID,@VEAU_KZ_AUSGEFALLEN,@VESG_BEGINN,@VESG_#BEGINN_ZEIT,@VESG_ENDE,@VESG_#ENDE_ZEIT,
						@VESG_DAUER,@VESG_TN_BEITRAG,@VEAU_ANZ_TN_GESAMT,@VEAU_ANZ_TN_LEHRKRAEFTE,
						@VEAU_ANZ_TN_WEIBLICH,@VEAU_ANZ_TN_MAENNLICH,@VEAU_ANZ_TN_GRUNDSCHULE,@VEAU_ANZ_TN_REGELSCHULE,
						@VEAU_ANZ_TN_GYMNASIUM,@VEAU_ANZ_TN_BERUFSBILDENDE_SCHULE,@VEAU_ANZ_TN_GESAMTSCHULE,
						@VEAU_ANZ_TN_FOERDERSCHULE,@VEAU_ANZ_TN_KOLLEG,
						@VEAU_ANZ_TN_KINDERTAGESEINRICHTUNG,@VEAU_ANZ_TN_SSA,@VEAU_ANZ_TN_HOCHSCHULE,@VEAU_ANZ_TN_SONSTIGE,
						@VEAU_ANZ_TN_FACHBERATER,@VEAU_ANZ_TN_SCHULLEITER,@VEAU_ANZ_TN_SCHULLEITUNGSMITGLIED,
						@VEAU_ANZ_TN_BERATUNGSLEHRER,@VEAU_ANZ_TN_BERATER_SCHULENTWICKLUNG,@VEAU_ANZ_TN_BERATER_DIDAKTIK,
						@VEAU_ANZ_TN_ANDERE_FUNKTIONEN,@VEAU_ANZ_TN_EIGENES_BUNDESLAND,@VEAU_KZ_DOKUMENTATION,
						@VEAU_EVAL_FRAGEBOGEN,@VEAU_EVAL_ZIELSCHEIBE,@VEAU_EVAL_POSITIONIERUNG,
						@VEAU_EVAL_MUENDLICHE_RUECKMELDUNG,@VEAU_EVAL_SONSTIGES,@VEAU_EVAL_INSTRUMENT,
						@USER, @pts, services.pfn_getXPTS( @pts ),
						--VEAU_ID_INT,	
						@uqid );

					set @step = N'Lesen des Identitätswertes';	
					if ( @DEBUG = 1 )	print @step;

					select	@VEAU_ID = VEAU_ID
					from	akkradm.IO_VERANSTALTUNG_AUSWERTUNG
					where	VEAU_UQID = @uqid;

					if ( @@rowcount <> 1 ) or ( isnull( @VEAU_ID, 0 ) = 0 )
					begin
						set @rc = -1;
						set @rc_text = N'Der neue Vorgang wurde nicht gefunden.';	
					end
				end
			end
			else if ( @AAKT_CODE = 20 )
			begin
				set @step = N'Aktualisierung des Vorgangs.';	
				if ( @DEBUG = 1 )	print @step;

				update akkradm.IO_VERANSTALTUNG_AUSWERTUNG set

					VESG_ID								=   @VESG_ID,
					VEAU_KZ_AUSGEFALLEN					=   @VEAU_KZ_AUSGEFALLEN,
					VESG_BEGINN							=   @VESG_BEGINN,
					VESG_#BEGINN_ZEIT					=   @VESG_#BEGINN_ZEIT,
					VESG_ENDE							=   @VESG_ENDE,
					VESG_#ENDE_ZEIT						=   @VESG_#ENDE_ZEIT,
					VESG_DAUER							=   @VESG_DAUER,
					VESG_TN_BEITRAG						=   @VESG_TN_BEITRAG,
					VEAU_ANZ_TN_GESAMT					=   @VEAU_ANZ_TN_GESAMT,
					VEAU_ANZ_TN_LEHRKRAEFTE				=	@VEAU_ANZ_TN_LEHRKRAEFTE,
					VEAU_ANZ_TN_WEIBLICH				=	@VEAU_ANZ_TN_WEIBLICH,
					VEAU_ANZ_TN_MAENNLICH				=	@VEAU_ANZ_TN_MAENNLICH,
					VEAU_ANZ_TN_GRUNDSCHULE				=	@VEAU_ANZ_TN_GRUNDSCHULE,
					VEAU_ANZ_TN_REGELSCHULE				=	@VEAU_ANZ_TN_REGELSCHULE,
					VEAU_ANZ_TN_GYMNASIUM				=	@VEAU_ANZ_TN_GYMNASIUM,
					VEAU_ANZ_TN_BERUFSBILDENDE_SCHULE	=	@VEAU_ANZ_TN_BERUFSBILDENDE_SCHULE,
					VEAU_ANZ_TN_GESAMTSCHULE			=	@VEAU_ANZ_TN_GESAMTSCHULE,
					VEAU_ANZ_TN_FOERDERSCHULE			=	@VEAU_ANZ_TN_FOERDERSCHULE,
					VEAU_ANZ_TN_KOLLEG					=   @VEAU_ANZ_TN_KOLLEG,
					VEAU_ANZ_TN_KINDERTAGESEINRICHTUNG	=	@VEAU_ANZ_TN_KINDERTAGESEINRICHTUNG,
					VEAU_ANZ_TN_SSA						=	@VEAU_ANZ_TN_SSA,
					VEAU_ANZ_TN_HOCHSCHULE				=	@VEAU_ANZ_TN_HOCHSCHULE,
					VEAU_ANZ_TN_SONSTIGE				=	@VEAU_ANZ_TN_SONSTIGE,
					VEAU_ANZ_TN_FACHBERATER				=	@VEAU_ANZ_TN_FACHBERATER,
					VEAU_ANZ_TN_SCHULLEITER				=	@VEAU_ANZ_TN_SCHULLEITER,
					VEAU_ANZ_TN_SCHULLEITUNGSMITGLIED	=	@VEAU_ANZ_TN_SCHULLEITUNGSMITGLIED,
					VEAU_ANZ_TN_BERATUNGSLEHRER			=	@VEAU_ANZ_TN_BERATUNGSLEHRER,
					VEAU_ANZ_TN_BERATER_SCHULENTWICKLUNG=	@VEAU_ANZ_TN_BERATER_SCHULENTWICKLUNG,
					VEAU_ANZ_TN_BERATER_DIDAKTIK		=	@VEAU_ANZ_TN_BERATER_DIDAKTIK,
					VEAU_ANZ_TN_ANDERE_FUNKTIONEN		=	@VEAU_ANZ_TN_ANDERE_FUNKTIONEN,
					VEAU_ANZ_TN_EIGENES_BUNDESLAND		=	@VEAU_ANZ_TN_EIGENES_BUNDESLAND,
					VEAU_KZ_DOKUMENTATION				=	@VEAU_KZ_DOKUMENTATION,
					VEAU_EVAL_FRAGEBOGEN				=	@VEAU_EVAL_FRAGEBOGEN,
					VEAU_EVAL_ZIELSCHEIBE				=	@VEAU_EVAL_ZIELSCHEIBE,
					VEAU_EVAL_POSITIONIERUNG			=	@VEAU_EVAL_POSITIONIERUNG,
					VEAU_EVAL_MUENDLICHE_RUECKMELDUNG	=	@VEAU_EVAL_MUENDLICHE_RUECKMELDUNG,
					VEAU_EVAL_SONSTIGES					=	@VEAU_EVAL_SONSTIGES,
					VEAU_EVAL_INSTRUMENT				=	@VEAU_EVAL_INSTRUMENT,

					VEAU_USER			= @USER,
					VEAU_PTS			= @pts,
					VEAU_#PTS			= services.pfn_getXPTS( @pts )

				where VEAU_ID = @VEAU_ID and VEAU_USER = @VEAU_USER and VEAU_#PTS = @VEAU_XPTS;

			end
			else if ( @AAKT_CODE = 30 )
			begin
				set @step = N'Löschen des Vorgangs (logisch).';
				if ( @DEBUG = 1 )	print @step;

				update akkradm.IO_VERANSTALTUNG_AUSWERTUNG set
					VEAU_KZ_GELOESCHT = 1,

					VEAU_USER = @USER,
					VEAU_PTS = @pts,
					VEAU_#PTS = services.pfn_getXPTS( @pts )

				where VEAU_ID = @VEAU_ID and VEAU_USER = @VEAU_USER and VEAU_#PTS = @VEAU_XPTS;

			end
			else if ( @AAKT_CODE = 90 )
			begin
				set @step = N'Löschen des Vorgangs';	
				if ( @DEBUG = 1 )	print @step;

				delete from akkradm.IO_VERANSTALTUNG_AUSWERTUNG where VEAU_ID = @VEAU_ID and VEAU_USER = @VEAU_USER and VEAU_#PTS = @VEAU_XPTS;

			end

			if ( @KZ_USE_TRANSACTION = 1 )
			begin
				if ( @rc = 0 )
				begin
					commit transaction;
				end
				else
				begin
					rollback transaction;
				end
			end

		end try
		begin catch

			if ( @KZ_USE_TRANSACTION = 1 )
			begin
				rollback transaction;
			end

			set @sql_error = ERROR_NUMBER();
			set @rc_text = ERROR_MESSAGE();

		end catch;
	end

	if ( @rc <> 0 )
	begin
		if ( isNull( @rc_text, N'' ) = N'' )
			set @rc_text = N'Es ist ein Fehler aufgetreten.';	

		set @rc_text = N'(' + @step + '): ' + @rc_text;

		select	@rc_text = services.pfn_getErrorMessageEx( 
					@sql_error,	
					null,		
					null,		
					null,	
					@procName,	
					null,		
					@rc_text	
				);

		raiserror( @rc_text, 16, 1 );
	end

end;
GO
