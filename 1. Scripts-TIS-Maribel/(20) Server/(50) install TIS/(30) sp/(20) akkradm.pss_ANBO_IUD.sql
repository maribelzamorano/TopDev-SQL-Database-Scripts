/*	
 * topdev GmbH, erstellt am 05.10.2009 15:08		--topdev GmbH, created at ...
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-10-05 15:08:54 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (020) akkradm.pss_ANBO_IUD.sql $
 *
 */

if not exists ( select * from sysobjects where id = object_id('akkradm.pss_ANBO_IUD') and OBJECTPROPERTY(id, 'IsProcedure') = 1)
begin
	exec( N'create procedure akkradm.pss_ANBO_IUD
	as begin
		print ''Procedure created.'';
	end' );
end
GO

alter procedure akkradm.pss_ANBO_IUD
	@SESSION_ID	UDT_SESSION_ID,		
	@USER		UDT_USER,		

	@ANBO_ID	UDT_ID output,		
	@ANBO_USER	nvarchar(128),		
	@ANBO_XPTS	nvarchar(23),		

	@AAKT_CODE	smallint,			



	@ABIE_ID						UDT_ID			,
	@QUEL_ID						UDT_ID			,
	@ANBO_NUMMER					nvarchar(8)		,
	@ANBO_NUMMER_ABIE				nvarchar(25)	,
	@ANBO_AKTENZEICHEN				nvarchar(19)	,
	@ANBO_THEMA						nvarchar(500)	,
	@ANBO_BESCHREIBUNG				nvarchar(max)	,
	@ANBO_GESTALTUNG				nvarchar(500)	,
	@ANBO_ERWERB_FERTIGKEITEN		nvarchar(1000)	,
	@SCHW_ID						UDT_ID			,
	@ANBO_DAUER						UDT_BETRAG		,
	@ANBO_LEISTUNGSPUNKTE			Integer			,
	@ANBO_URL						nvarchar(255)	,
	@ANBO_TEILNEHMERHINWEIS			nvarchar(500)	,
	@ANKA_CODE						UDT_CODE		,
	@ANBO_KRITERIEN_ERFOLG_TEILNAHME	nvarchar(255),
	@ANBO_QUALIFIZIERUNG_NACHWEIS	nvarchar(255)	,
	@ANBO_KZ_VERPFLICHTENDE_ERKLAERUNG UDT_BOOLEAN	,

	@ANST_ID						UDT_ID			,
	@ANBO_GRUND_ANST				nvarchar(1000)	,
	@ANBO_PTS_ANST					UDT_PTS			,
	@ANBO_USER_ANST					UDT_USER		,


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


	set @tbsh_shortname = N'ANBO';
	set	@id = @ANBO_ID;


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
		   ( not exists( select 1 from akkradm.IO_ANGEBOT where ANBO_ID = @ANBO_ID and ANBO_USER = @ANBO_USER and ANBO_#PTS = @ANBO_XPTS ))
		begin
			set @rc = -1;
			set @rc_text = N'Der Vorgang wurde zwischenzetlich geändert. Die gewünschte Aktion kann nicht durchgeführt werden.'; 
		end
	end

	if ( @rc = 0 )
	begin
		set @step = N'Fachliche Validierungen durchführen.';
		if ( @DEBUG = 1 )	print @step;

	
		if ( ltrim( rtrim( @ANBO_NUMMER )) = N'' )						set @ANBO_NUMMER = null;
		if ( ltrim( rtrim( @ANBO_NUMMER_ABIE )) = N'' )					set @ANBO_NUMMER_ABIE = null;
		if ( ltrim( rtrim( @ANBO_AKTENZEICHEN )) = N'' )				set @ANBO_AKTENZEICHEN = null;
		if ( ltrim( rtrim( @ANBO_THEMA	 )) = N'' )						set @ANBO_THEMA	 = null;
		if ( ltrim( rtrim( @ANBO_BESCHREIBUNG )) = N'' )				set @ANBO_BESCHREIBUNG = null;
		if ( ltrim( rtrim( @ANBO_GESTALTUNG )) = N'' )					set @ANBO_GESTALTUNG = null;
		if ( ltrim( rtrim( @ANBO_ERWERB_FERTIGKEITEN )) = N'' )			set @ANBO_ERWERB_FERTIGKEITEN = null;
		if ( ltrim( rtrim( @ANBO_URL )) = N'' )							set @ANBO_URL = null;
		if ( ltrim( rtrim( @ANBO_TEILNEHMERHINWEIS )) = N'' )			set @ANBO_TEILNEHMERHINWEIS = null;
		if ( ltrim( rtrim( @ANBO_KRITERIEN_ERFOLG_TEILNAHME )) = N'' )	set @ANBO_KRITERIEN_ERFOLG_TEILNAHME = null;
		if ( ltrim( rtrim( @ANBO_QUALIFIZIERUNG_NACHWEIS )) = N'' )		set @ANBO_QUALIFIZIERUNG_NACHWEIS = null;
		if ( ltrim( rtrim( @ANBO_GRUND_ANST )) = N'' )					set @ANBO_GRUND_ANST = null;
		if ( ltrim( rtrim( @ANKA_CODE )) = N'' )						set @ANKA_CODE = null;



		if ( @ANBO_DAUER	 is null )			set @ANBO_DAUER	 = 0;
		if ( @ANBO_LEISTUNGSPUNKTE is null )	set @ANBO_LEISTUNGSPUNKTE = 0;
		if ( @ANBO_KZ_VERPFLICHTENDE_ERKLAERUNG is null )	set @ANBO_KZ_VERPFLICHTENDE_ERKLAERUNG = 0;

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

					insert into akkradm.IO_ANGEBOT(
						--ANBO_ID,
						ABIE_ID,QUEL_ID,
						ANBO_NUMMER,ANBO_NUMMER_ABIE,ANBO_AKTENZEICHEN,
						ANBO_THEMA,ANBO_BESCHREIBUNG,ANBO_GESTALTUNG,ANBO_ERWERB_FERTIGKEITEN,
						SCHW_ID,ANBO_DAUER,ANBO_LEISTUNGSPUNKTE,ANBO_URL,
						ANBO_TEILNEHMERHINWEIS,ANKA_CODE,ANBO_KRITERIEN_ERFOLG_TEILNAHME,
						ANBO_QUALIFIZIERUNG_NACHWEIS,ANBO_KZ_VERPFLICHTENDE_ERKLAERUNG,ANST_ID,
						ANBO_GRUND_ANST,ANBO_PTS_ANST,ANBO_USER_ANST,
						ANBO_USER, ANBO_PTS, ANBO_#PTS,
						--ANBO_ID_INT,	
						ANBO_UQID )
					values(
						--@id,
						@ABIE_ID,@QUEL_ID,
						@ANBO_NUMMER,@ANBO_NUMMER_ABIE,@ANBO_AKTENZEICHEN,
						@ANBO_THEMA,@ANBO_BESCHREIBUNG,@ANBO_GESTALTUNG,@ANBO_ERWERB_FERTIGKEITEN,
						@SCHW_ID,@ANBO_DAUER,@ANBO_LEISTUNGSPUNKTE,@ANBO_URL,
						@ANBO_TEILNEHMERHINWEIS,@ANKA_CODE,@ANBO_KRITERIEN_ERFOLG_TEILNAHME,
						@ANBO_QUALIFIZIERUNG_NACHWEIS,@ANBO_KZ_VERPFLICHTENDE_ERKLAERUNG,@ANST_ID,
						@ANBO_GRUND_ANST,@ANBO_PTS_ANST,@ANBO_USER_ANST,
						@USER, @pts, services.pfn_getXPTS( @pts ),
						--ANBO_ID_INT,	
						@uqid );

					set @step = N'Lesen des Identitätswertes';	
					if ( @DEBUG = 1 )	print @step;

					select	@ANBO_ID = ANBO_ID
					from	akkradm.IO_ANGEBOT
					where	ANBO_UQID = @uqid;

					if ( @@rowcount <> 1 ) or ( isnull( @ANBO_ID, 0 ) = 0 )
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

				update akkradm.IO_ANGEBOT set


					ABIE_ID								= @ABIE_ID,
					QUEL_ID								= @QUEL_ID,
					ANBO_NUMMER							= @ANBO_NUMMER,
					ANBO_NUMMER_ABIE					= @ANBO_NUMMER_ABIE,
					ANBO_AKTENZEICHEN					= @ANBO_AKTENZEICHEN,
					ANBO_THEMA							= @ANBO_THEMA,
					ANBO_BESCHREIBUNG					= @ANBO_BESCHREIBUNG,
					ANBO_GESTALTUNG						= @ANBO_GESTALTUNG,
					ANBO_ERWERB_FERTIGKEITEN			= @ANBO_ERWERB_FERTIGKEITEN,
					SCHW_ID								= @SCHW_ID,
					ANBO_DAUER							= @ANBO_DAUER,
					ANBO_LEISTUNGSPUNKTE				= @ANBO_LEISTUNGSPUNKTE,
					ANBO_URL							= @ANBO_URL,
					ANBO_TEILNEHMERHINWEIS				= @ANBO_TEILNEHMERHINWEIS,
					ANKA_CODE							= @ANKA_CODE,
					ANBO_KRITERIEN_ERFOLG_TEILNAHME		= @ANBO_KRITERIEN_ERFOLG_TEILNAHME,
					ANBO_QUALIFIZIERUNG_NACHWEIS		= @ANBO_QUALIFIZIERUNG_NACHWEIS,
					ANBO_KZ_VERPFLICHTENDE_ERKLAERUNG	= @ANBO_KZ_VERPFLICHTENDE_ERKLAERUNG,
					ANST_ID								= @ANST_ID,
					ANBO_GRUND_ANST						= @ANBO_GRUND_ANST,
					ANBO_PTS_ANST						= @ANBO_PTS_ANST,
					ANBO_USER_ANST						= @ANBO_USER_ANST,

					ANBO_USER			= @USER,
					ANBO_PTS			= @pts,
					ANBO_#PTS			= services.pfn_getXPTS( @pts )

				where ANBO_ID = @ANBO_ID and ANBO_USER = @ANBO_USER and ANBO_#PTS = @ANBO_XPTS;

			end
			else if ( @AAKT_CODE = 30 )
			begin
				set @step = N'Löschen des Vorgangs (logisch).';	
				if ( @DEBUG = 1 )	print @step;

				update akkradm.IO_ANGEBOT set
					ANBO_KZ_GELOESCHT = 1,

					ANBO_USER = @USER,
					ANBO_PTS = @pts,
					ANBO_#PTS = services.pfn_getXPTS( @pts )

				where ANBO_ID = @ANBO_ID and ANBO_USER = @ANBO_USER and ANBO_#PTS = @ANBO_XPTS;

			end
			else if ( @AAKT_CODE = 90 )
			begin
				set @step = N'Löschen des Vorgangs';	
				if ( @DEBUG = 1 )	print @step;

				delete from akkradm.IO_ANGEBOT where ANBO_ID = @ANBO_ID and ANBO_USER = @ANBO_USER and ANBO_#PTS = @ANBO_XPTS;

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
