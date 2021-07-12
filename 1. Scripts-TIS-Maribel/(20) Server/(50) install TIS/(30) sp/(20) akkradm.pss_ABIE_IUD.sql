/*	
 * topdev GmbH, erstellt am 05.10.2009 12:00
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-10-05 12:01:57 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (020) akkradm.pss_ABIE_IUD.sql $
 *
 */

if not exists ( select * from sysobjects where id = object_id('akkradm.pss_ABIE_IUD') and OBJECTPROPERTY(id, 'IsProcedure') = 1)
begin
	exec( N'create procedure akkradm.pss_ABIE_IUD
	as begin
		print ''Procedure created.'';
	end' );
end
GO

alter procedure akkradm.pss_ABIE_IUD
	@SESSION_ID	UDT_SESSION_ID,
	@USER		UDT_USER,

	@ABIE_ID	UDT_ID output,		
	@ABIE_USER	nvarchar(128),		
	@ABIE_XPTS	nvarchar(23),		

	@AAKT_CODE	smallint,			



	@GEPA_ID							UDT_ID		,
	@QUEL_ID							UDT_ID		,

	@ABIE_NUMMER					nvarchar(25)	,
	@ABIE_STEUERNUMMER				nvarchar(50)	,
	@ABIE_SCHWERPUNKTE				nvarchar(1000)	,
	@ABIE_EINRICHTUNG				nvarchar(1000)	,
	@ABIE_AUSBILDUNG_LEITUNG		nvarchar(1000)	,
	@ABIE_AUSBILDUNG_PERSONAL		nvarchar(1000)	,
	@ABIE_ERFAHRUNG_LEITUNG			nvarchar(1000)	,
	@ABIE_ERFAHRUNG_PERSONAL		nvarchar(1000)	,
	@ABIE_QUALIFIKATION_LEITUNG		nvarchar(1000)	,
	@ABIE_QUALIFIKATION_PERSONAL	nvarchar(1000)	,
	@ABIE_ERWBILDUNG_LEITUNG		nvarchar(1000)	,
	@ABIE_ERWBILDUNG_PERSONAL		nvarchar(1000)	,
	@ABIE_WEITERBILDUNG_LEITUNG		nvarchar(1000)	,
	@ABIE_WEITERBILDUNG_PERSONAL	nvarchar(1000)	,

	@ABIE_KZ_ZERTIFIZIERT			UDT_BOOLEAN		,
	@ZERT_ID						UDT_ID			,
	@ABIE_ZERTIFIKAT_DATUM			datetime		,
	@ABIE_ZERTIFIKAT_STELLE			nvarchar(255)	,

	@ABIE_QS_LEITBILD				nvarchar(500)	,
	@ABIE_QS_NEUE_ENTWICKLUNGEN		nvarchar(500)	,
	@ABIE_QS_FESTLEGUNG_LERNZIELE	nvarchar(500)	,
	@ABIE_QS_BESTIMMUNG_METHODEN	nvarchar(500)	,
	@ABIE_QS_MESSUNG_ZIELERREICHUNG	nvarchar(500)	,
	@ABIE_QS_STEUERUNG_OPTIMIERUNG	nvarchar(500)	,

	@ABST_ID						UDT_ID			,
	@ABIE_GRUND_ABST				nvarchar(1000)	,
	@ABIE_PTS_ABST					UDT_PTS			,
	@ABIE_USER_ABST					UDT_USER		,

	@ABIE_AKKREDITIERUNG_DATUM		datetime		,
	@ABIE_KZ_AKKREDITIERT_ANTRAG	UDT_BOOLEAN		,
	@ABIE_KZ_AKKREDITIERT_VERORDNUNG UDT_BOOLEAN	,


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


	set @tbsh_shortname = N'ABIE';
	set	@id = @ABIE_ID;


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
			set @rc_text = N'Sie verfügen nicht über ausreichende Berechtigungen, um diese Aktion auszuführen.';
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
		   ( not exists( select 1 from akkradm.IO_ANBIETER where ABIE_ID = @ABIE_ID and ABIE_USER = @ABIE_USER and ABIE_#PTS = @ABIE_XPTS ))
		begin
			set @rc = -1;
			set @rc_text = N'Der Vorgang wurde zwischenzetlich geändert. Die gewünschte Aktion kann nicht durchgeführt werden.';
		end
	end

	if ( @rc = 0 )
	begin
		set @step = N'Fachliche Validierungen durchführen.';
		if ( @DEBUG = 1 )	print @step;


		if ( ltrim( rtrim( @ABIE_NUMMER )) = N'' )					set @ABIE_NUMMER = null;
		if ( ltrim( rtrim( @ABIE_STEUERNUMMER )) = N'' )			set @ABIE_STEUERNUMMER = null;
		if ( ltrim( rtrim( @ABIE_SCHWERPUNKTE )) = N'' )			set @ABIE_SCHWERPUNKTE = null;
		if ( ltrim( rtrim( @ABIE_EINRICHTUNG )) = N'' )				set @ABIE_EINRICHTUNG = null;
		if ( ltrim( rtrim( @ABIE_AUSBILDUNG_LEITUNG )) = N'' )		set @ABIE_AUSBILDUNG_LEITUNG = null;
		if ( ltrim( rtrim( @ABIE_AUSBILDUNG_PERSONAL )) = N'' )		set @ABIE_AUSBILDUNG_PERSONAL = null;
		if ( ltrim( rtrim( @ABIE_ERFAHRUNG_LEITUNG	 )) = N'' )		set @ABIE_ERFAHRUNG_LEITUNG	 = null;
		if ( ltrim( rtrim( @ABIE_ERFAHRUNG_PERSONAL )) = N'' )		set @ABIE_ERFAHRUNG_PERSONAL = null;
		if ( ltrim( rtrim( @ABIE_QUALIFIKATION_LEITUNG )) = N'' )	set @ABIE_QUALIFIKATION_LEITUNG = null;
		if ( ltrim( rtrim( @ABIE_QUALIFIKATION_PERSONAL )) = N'' )	set @ABIE_QUALIFIKATION_PERSONAL = null;
		if ( ltrim( rtrim( @ABIE_ERWBILDUNG_LEITUNG )) = N'' )		set @ABIE_ERWBILDUNG_LEITUNG= null;
		if ( ltrim( rtrim( @ABIE_ERWBILDUNG_PERSONAL )) = N'' )		set @ABIE_ERWBILDUNG_PERSONAL = null;
		if ( ltrim( rtrim( @ABIE_WEITERBILDUNG_LEITUNG )) = N'' )	set @ABIE_WEITERBILDUNG_LEITUNG = null;
		if ( ltrim( rtrim( @ABIE_WEITERBILDUNG_PERSONAL )) = N'' )	set @ABIE_WEITERBILDUNG_PERSONAL = null;
		if ( ltrim( rtrim( @ABIE_ZERTIFIKAT_STELLE )) = N'' )		set @ABIE_ZERTIFIKAT_STELLE = null;
		if ( ltrim( rtrim( @ABIE_QS_NEUE_ENTWICKLUNGEN	 )) = N'' )	set @ABIE_QS_NEUE_ENTWICKLUNGEN	 = null;
		if ( ltrim( rtrim( @ABIE_QS_FESTLEGUNG_LERNZIELE )) = N'' )	set @ABIE_QS_FESTLEGUNG_LERNZIELE = null;
		if ( ltrim( rtrim( @ABIE_QS_BESTIMMUNG_METHODEN )) = N'' )	set @ABIE_QS_BESTIMMUNG_METHODEN = null;
		if ( ltrim( rtrim( @ABIE_QS_MESSUNG_ZIELERREICHUNG )) = N'' )	set @ABIE_QS_MESSUNG_ZIELERREICHUNG = null;
		if ( ltrim( rtrim( @ABIE_QS_STEUERUNG_OPTIMIERUNG )) = N'' )	set @ABIE_QS_STEUERUNG_OPTIMIERUNG = null;
		if ( ltrim( rtrim( @ABIE_GRUND_ABST )) = N'' )				set @ABIE_GRUND_ABST = null;

	

		if ( @ABIE_KZ_ZERTIFIZIERT is null )	set @ABIE_KZ_ZERTIFIZIERT = 0;
		if ( @ABIE_KZ_AKKREDITIERT_ANTRAG is null )	set @ABIE_KZ_AKKREDITIERT_ANTRAG = 0;
		if ( @ABIE_KZ_AKKREDITIERT_VERORDNUNG is null )	set @ABIE_KZ_AKKREDITIERT_VERORDNUNG = 0;
	end


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

					insert into akkradm.IO_ANBIETER(
						--ABIE_ID,	
						GEPA_ID,QUEL_ID,
						ABIE_NUMMER,ABIE_STEUERNUMMER,ABIE_SCHWERPUNKTE,ABIE_EINRICHTUNG,ABIE_AUSBILDUNG_LEITUNG,
						ABIE_AUSBILDUNG_PERSONAL,ABIE_ERFAHRUNG_LEITUNG,ABIE_ERFAHRUNG_PERSONAL,
						ABIE_QUALIFIKATION_LEITUNG,ABIE_QUALIFIKATION_PERSONAL,ABIE_ERWBILDUNG_LEITUNG,
						ABIE_ERWBILDUNG_PERSONAL,ABIE_WEITERBILDUNG_LEITUNG,ABIE_WEITERBILDUNG_PERSONAL,
						ABIE_KZ_ZERTIFIZIERT,ZERT_ID,ABIE_ZERTIFIKAT_DATUM,ABIE_ZERTIFIKAT_STELLE,
						ABIE_QS_LEITBILD,ABIE_QS_NEUE_ENTWICKLUNGEN,ABIE_QS_FESTLEGUNG_LERNZIELE,
						ABIE_QS_BESTIMMUNG_METHODEN,ABIE_QS_MESSUNG_ZIELERREICHUNG,ABIE_QS_STEUERUNG_OPTIMIERUNG,
						ABST_ID,ABIE_GRUND_ABST,ABIE_PTS_ABST,ABIE_USER_ABST,
						ABIE_AKKREDITIERUNG_DATUM,ABIE_KZ_AKKREDITIERT_ANTRAG,ABIE_KZ_AKKREDITIERT_VERORDNUNG, 
						ABIE_USER, ABIE_PTS, ABIE_#PTS,
						--ABIE_ID_INT,	
						ABIE_KZ_FREIGABE, ABIE_UQID )
					values(
						--@id,
						@GEPA_ID,@QUEL_ID,
						@ABIE_NUMMER,@ABIE_STEUERNUMMER,@ABIE_SCHWERPUNKTE,@ABIE_EINRICHTUNG,@ABIE_AUSBILDUNG_LEITUNG,
						@ABIE_AUSBILDUNG_PERSONAL,@ABIE_ERFAHRUNG_LEITUNG,@ABIE_ERFAHRUNG_PERSONAL,
						@ABIE_QUALIFIKATION_LEITUNG,@ABIE_QUALIFIKATION_PERSONAL,@ABIE_ERWBILDUNG_LEITUNG,
						@ABIE_ERWBILDUNG_PERSONAL,@ABIE_WEITERBILDUNG_LEITUNG,@ABIE_WEITERBILDUNG_PERSONAL,
						@ABIE_KZ_ZERTIFIZIERT,@ZERT_ID,@ABIE_ZERTIFIKAT_DATUM,@ABIE_ZERTIFIKAT_STELLE,
						@ABIE_QS_LEITBILD,@ABIE_QS_NEUE_ENTWICKLUNGEN,@ABIE_QS_FESTLEGUNG_LERNZIELE,
						@ABIE_QS_BESTIMMUNG_METHODEN,@ABIE_QS_MESSUNG_ZIELERREICHUNG,@ABIE_QS_STEUERUNG_OPTIMIERUNG,
						@ABST_ID,@ABIE_GRUND_ABST,@ABIE_PTS_ABST,@ABIE_USER_ABST,
						@ABIE_AKKREDITIERUNG_DATUM,@ABIE_KZ_AKKREDITIERT_ANTRAG,@ABIE_KZ_AKKREDITIERT_VERORDNUNG,
						@USER, @pts, services.pfn_getXPTS( @pts ),
						--ABIE_ID_INT,	
						1, @uqid );

					set @step = N'Lesen des Identitätswertes';
					if ( @DEBUG = 1 )	print @step;

					select	@ABIE_ID = ABIE_ID
					from	akkradm.IO_ANBIETER
					where	ABIE_UQID = @uqid;

					if ( @@rowcount <> 1 ) or ( isnull( @ABIE_ID, 0 ) = 0 )
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

				update akkradm.IO_ANBIETER set


					GEPA_ID							= @GEPA_ID,
					QUEL_ID							= @QUEL_ID,
					ABIE_NUMMER						= @ABIE_NUMMER,
					ABIE_STEUERNUMMER				= @ABIE_STEUERNUMMER	,
					ABIE_SCHWERPUNKTE				= @ABIE_SCHWERPUNKTE,
					ABIE_EINRICHTUNG				= @ABIE_EINRICHTUNG,
					ABIE_AUSBILDUNG_LEITUNG			= @ABIE_AUSBILDUNG_LEITUNG,
					ABIE_AUSBILDUNG_PERSONAL		= @ABIE_AUSBILDUNG_PERSONAL,
					ABIE_ERFAHRUNG_LEITUNG			= @ABIE_ERFAHRUNG_LEITUNG,
					ABIE_ERFAHRUNG_PERSONAL			= @ABIE_ERFAHRUNG_PERSONAL,
					ABIE_QUALIFIKATION_LEITUNG		= @ABIE_QUALIFIKATION_LEITUNG,
					ABIE_QUALIFIKATION_PERSONAL		= @ABIE_QUALIFIKATION_PERSONAL,
					ABIE_ERWBILDUNG_LEITUNG			= @ABIE_ERWBILDUNG_LEITUNG,
					ABIE_ERWBILDUNG_PERSONAL		= @ABIE_ERWBILDUNG_PERSONAL,
					ABIE_WEITERBILDUNG_LEITUNG		= @ABIE_WEITERBILDUNG_LEITUNG,
					ABIE_WEITERBILDUNG_PERSONAL		= @ABIE_WEITERBILDUNG_PERSONAL,
					ABIE_KZ_ZERTIFIZIERT			= @ABIE_KZ_ZERTIFIZIERT,
					ZERT_ID							= @ZERT_ID,
					ABIE_ZERTIFIKAT_DATUM			= @ABIE_ZERTIFIKAT_DATUM,
					ABIE_ZERTIFIKAT_STELLE			= @ABIE_ZERTIFIKAT_STELLE,
					ABIE_QS_LEITBILD				= @ABIE_QS_LEITBILD,
					ABIE_QS_NEUE_ENTWICKLUNGEN		= @ABIE_QS_NEUE_ENTWICKLUNGEN,
					ABIE_QS_FESTLEGUNG_LERNZIELE	= @ABIE_QS_FESTLEGUNG_LERNZIELE,
					ABIE_QS_BESTIMMUNG_METHODEN		= @ABIE_QS_BESTIMMUNG_METHODEN,
					ABIE_QS_MESSUNG_ZIELERREICHUNG  = @ABIE_QS_MESSUNG_ZIELERREICHUNG,
					ABIE_QS_STEUERUNG_OPTIMIERUNG	= @ABIE_QS_STEUERUNG_OPTIMIERUNG,
					ABST_ID							= @ABST_ID,
					ABIE_GRUND_ABST					= @ABIE_GRUND_ABST,
					ABIE_PTS_ABST 					= @ABIE_PTS_ABST,
					ABIE_USER_ABST					= @ABIE_USER_ABST,
					ABIE_AKKREDITIERUNG_DATUM		= @ABIE_AKKREDITIERUNG_DATUM,
					ABIE_KZ_AKKREDITIERT_ANTRAG		= @ABIE_KZ_AKKREDITIERT_ANTRAG,
					ABIE_KZ_AKKREDITIERT_VERORDNUNG = @ABIE_KZ_AKKREDITIERT_VERORDNUNG,

					ABIE_USER			= @USER,
					ABIE_PTS			= @pts,
					ABIE_#PTS			= services.pfn_getXPTS( @pts )

				where ABIE_ID = @ABIE_ID and ABIE_USER = @ABIE_USER and ABIE_#PTS = @ABIE_XPTS;

			end
			else if ( @AAKT_CODE = 30 )
			begin
				set @step = N'Löschen des Vorgangs (logisch).';
				if ( @DEBUG = 1 )	print @step;

				update akkradm.IO_ANBIETER set
					ABIE_KZ_GELOESCHT = 1,

					ABIE_USER = @USER,
					ABIE_PTS = @pts,
					ABIE_#PTS = services.pfn_getXPTS( @pts )

				where ABIE_ID = @ABIE_ID and ABIE_USER = @ABIE_USER and ABIE_#PTS = @ABIE_XPTS;

			end
			else if ( @AAKT_CODE = 90 )
			begin
				set @step = N'Löschen des Vorgangs';
				if ( @DEBUG = 1 )	print @step;

				delete from akkradm.IO_ANBIETER where ABIE_ID = @ABIE_ID and ABIE_USER = @ABIE_USER and ABIE_#PTS = @ABIE_XPTS;

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
