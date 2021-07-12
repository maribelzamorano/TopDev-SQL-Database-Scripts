/*	
 * topdev GmbH, erstellt am 30.09.2009 12:05		--topdev GmbH, created at ...
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-09-30 12:05:25 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (020) akkradm.pss_AKRS_IUD.sql $
 *
 */

if not exists ( select * from sysobjects where id = object_id('akkradm.pss_AKRS_IUD') and OBJECTPROPERTY(id, 'IsProcedure') = 1)
begin
	exec( N'create procedure akkradm.pss_AKRS_IUD
	as begin
		print ''Procedure created.'';
	end' );
end
GO

alter procedure akkradm.pss_AKRS_IUD
	@SESSION_ID	UDT_SESSION_ID,		
	@USER		UDT_USER,			

	@AKRS_AKKREDITIERUNGSSTELLEID	UDT_ID output,		
	@AKRS_USER	nvarchar(128),		
	@AKRS_XPTS	nvarchar(23),		

	@AAKT_CODE	smallint,			


	@DIEN_ID				UDT_ID = 0,
	
	@AKRS_NAMEVOLL					nvarchar(202),
	@AKRS_STRASSE					nvarchar(60),
	@AKRS_HAUSNUMMER				UDT_ANZAHL_I,
	@AKRS_HAUSNUMMERNZUSATZ			nvarchar(30),
	@AKRS_POSTLEITZAHL				nvarchar(20),
	@AKRS_ORT						nvarchar(40),
	@AKRS_EMAIL						nvarchar(255),
	@AKRS_TELEFON					nvarchar(255),
	@AKRS_MOBILTELEFON				nvarchar(255),
	@AKRS_FAX						nvarchar(255),
	@AKRS_BRIEFFENSTERANSCHRIFT		nvarchar(255),
	@AKRS_BRIEFKOPF1				nvarchar(100),
	@AKRS_BRIEFKOPF2				nvarchar(100),
	@AKRS_BRIEFKOPF3				nvarchar(100),

	@AKRS_ZUSTAENDIGKEITSBEREICHID				UDT_ANZAHL_I,
	@AKRS_ZUSTAENDIGKEITSBEREICHBEZEICHNUNG 	nvarchar(200),
	@AKRS_LOGOID								UDT_ANZAHL_I,


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


	set @tbsh_shortname = N'AKRS';
	set	@id = @AKRS_AKKREDITIERUNGSSTELLEID;


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
		   ( not exists( select 1 from akkradm.IO_AKKREDITIERUNGSSTELLE where AKRS_AKKREDITIERUNGSSTELLEID = @AKRS_AKKREDITIERUNGSSTELLEID and AKRS_USER = @AKRS_USER and AKRS_#PTS = @AKRS_XPTS ))
		begin
			set @rc = -1;
			set @rc_text = N'Der Vorgang wurde zwischenzetlich geändert. Die gewünschte Aktion kann nicht durchgeführt werden.'; 
		end
	end

	if ( @rc = 0 )
	begin
		set @step = N'Fachliche Validierungen durchführen.'; 
		if ( @DEBUG = 1 )	print @step;

	
		if ( ltrim( rtrim( @AKRS_BRIEFFENSTERANSCHRIFT )) = N'' )	set @AKRS_BRIEFFENSTERANSCHRIFT = null;
		if ( ltrim( rtrim( @AKRS_BRIEFKOPF1 )) = N'' )			set @AKRS_BRIEFKOPF1 = null;
		if ( ltrim( rtrim( @AKRS_BRIEFKOPF2 )) = N'' )			set @AKRS_BRIEFKOPF2 = null;
		if ( ltrim( rtrim( @AKRS_BRIEFKOPF3 )) = N'' )			set @AKRS_BRIEFKOPF3 = null;
		if ( ltrim( rtrim( @AKRS_ZUSTAENDIGKEITSBEREICHBEZEICHNUNG )) = N'' )	set @AKRS_ZUSTAENDIGKEITSBEREICHBEZEICHNUNG = null;
		if ( ltrim( rtrim( @AKRS_NAMEVOLL )) = N'' )			set @AKRS_NAMEVOLL = null;
		if ( ltrim( rtrim( @AKRS_STRASSE )) = N'' )				set @AKRS_STRASSE = null;
		if ( ltrim( rtrim( @AKRS_HAUSNUMMERNZUSATZ )) = N'' )	set @AKRS_BRIEFKOPF3 = null;
		if ( ltrim( rtrim( @AKRS_POSTLEITZAHL )) = N'' )		set @AKRS_POSTLEITZAHL = null;
		if ( ltrim( rtrim( @AKRS_ORT)) = N'' )					set @AKRS_ORT = null;
		if ( ltrim( rtrim( @AKRS_EMAIL	 )) = N'' )				set @AKRS_EMAIL	 = null;
		if ( ltrim( rtrim( @AKRS_TELEFON )) = N'' )				set @AKRS_TELEFON = null;
		if ( ltrim( rtrim( @AKRS_MOBILTELEFON	 )) = N'' )		set @AKRS_MOBILTELEFON	 = null;
		if ( ltrim( rtrim( @AKRS_FAX	 )) = N'' )				set @AKRS_FAX	 = null;	
			

	
		if ( @AKRS_ZUSTAENDIGKEITSBEREICHID is null )	set @AKRS_ZUSTAENDIGKEITSBEREICHID = 0;
		if ( @AKRS_LOGOID is null )	set @AKRS_LOGOID = 0;
		if ( @AKRS_HAUSNUMMER is null )	set @AKRS_HAUSNUMMER = 0;

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



				if ( @rc = 0 )
				begin
					set @step = N'Einfügen des Vorgangs.';	
					if ( @DEBUG = 1 )	print @step;

					insert into akkradm.IO_AKKREDITIERUNGSSTELLE(
					
						DIEN_ID,
						AKRS_NAMEVOLL,AKRS_STRASSE,AKRS_HAUSNUMMER,AKRS_HAUSNUMMERNZUSATZ,AKRS_POSTLEITZAHL,
						AKRS_ORT,AKRS_EMAIL,AKRS_TELEFON,AKRS_MOBILTELEFON,AKRS_FAX,
						AKRS_BRIEFFENSTERANSCHRIFT,AKRS_BRIEFKOPF1,AKRS_BRIEFKOPF2,AKRS_BRIEFKOPF3,
						AKRS_ZUSTAENDIGKEITSBEREICHID,AKRS_ZUSTAENDIGKEITSBEREICHBEZEICHNUNG,AKRS_LOGOID,
						AKRS_USER, AKRS_PTS, AKRS_#PTS,
						
						AKRS_UQID )
					values(
					
						@DIEN_ID,
						@AKRS_NAMEVOLL,@AKRS_STRASSE,@AKRS_HAUSNUMMER,@AKRS_HAUSNUMMERNZUSATZ,@AKRS_POSTLEITZAHL,
						@AKRS_ORT,@AKRS_EMAIL,@AKRS_TELEFON,@AKRS_MOBILTELEFON,@AKRS_FAX,
						@AKRS_BRIEFFENSTERANSCHRIFT,@AKRS_BRIEFKOPF1,@AKRS_BRIEFKOPF2,@AKRS_BRIEFKOPF3,
						@AKRS_ZUSTAENDIGKEITSBEREICHID,@AKRS_ZUSTAENDIGKEITSBEREICHBEZEICHNUNG,@AKRS_LOGOID,
						@USER, @pts, services.pfn_getXPTS( @pts ),
					
						@uqid );

					set @step = N'Lesen des Identitätswertes';
					if ( @DEBUG = 1 )	print @step;

					select	@AKRS_AKKREDITIERUNGSSTELLEID = AKRS_AKKREDITIERUNGSSTELLEID
					from	akkradm.IO_AKKREDITIERUNGSSTELLE
					where	AKRS_UQID = @uqid;

					if ( @@rowcount <> 1 ) or ( isnull( @AKRS_AKKREDITIERUNGSSTELLEID, 0 ) = 0 )
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

				update akkradm.IO_AKKREDITIERUNGSSTELLE set

					DIEN_ID									= @DIEN_ID ,

					AKRS_NAMEVOLL						    = @AKRS_NAMEVOLL ,
					AKRS_STRASSE							= @AKRS_STRASSE,
					AKRS_HAUSNUMMER							= @AKRS_HAUSNUMMER,
					AKRS_HAUSNUMMERNZUSATZ					= @AKRS_HAUSNUMMERNZUSATZ,
					AKRS_POSTLEITZAHL						= @AKRS_POSTLEITZAHL,		
					AKRS_ORT								= @AKRS_ORT,
					AKRS_EMAIL								= @AKRS_EMAIL,
					AKRS_TELEFON							= @AKRS_TELEFON,
					AKRS_MOBILTELEFON						= @AKRS_MOBILTELEFON,
					AKRS_FAX								= @AKRS_FAX,
					AKRS_BRIEFFENSTERANSCHRIFT				= @AKRS_BRIEFFENSTERANSCHRIFT,
					AKRS_BRIEFKOPF1							= @AKRS_BRIEFKOPF1,
					AKRS_BRIEFKOPF2							= @AKRS_BRIEFKOPF2,
					AKRS_BRIEFKOPF3							= @AKRS_BRIEFKOPF3,
					AKRS_ZUSTAENDIGKEITSBEREICHID			= @AKRS_ZUSTAENDIGKEITSBEREICHID,
					AKRS_ZUSTAENDIGKEITSBEREICHBEZEICHNUNG  = @AKRS_ZUSTAENDIGKEITSBEREICHBEZEICHNUNG,
					AKRS_LOGOID								= @AKRS_LOGOID,

					AKRS_USER								= @USER,
					AKRS_PTS								= @pts,
					AKRS_#PTS								= services.pfn_getXPTS( @pts )

				where AKRS_AKKREDITIERUNGSSTELLEID = @AKRS_AKKREDITIERUNGSSTELLEID and AKRS_USER = @AKRS_USER and AKRS_#PTS = @AKRS_XPTS;

			end
			else if ( @AAKT_CODE = 30 )
			begin
				set @step = N'Löschen des Vorgangs (logisch).';	
				if ( @DEBUG = 1 )	print @step;

				update akkradm.IO_AKKREDITIERUNGSSTELLE set
					AKRS_KZ_GELOESCHT = 1,

					AKRS_USER = @USER,
					AKRS_PTS = @pts,
					AKRS_#PTS = services.pfn_getXPTS( @pts )

				where AKRS_AKKREDITIERUNGSSTELLEID = @AKRS_AKKREDITIERUNGSSTELLEID and AKRS_USER = @AKRS_USER and AKRS_#PTS = @AKRS_XPTS;

			end
			else if ( @AAKT_CODE = 90 )
			begin
				set @step = N'Löschen des Vorgangs';	
				if ( @DEBUG = 1 )	print @step;

				delete from akkradm.IO_AKKREDITIERUNGSSTELLE where AKRS_AKKREDITIERUNGSSTELLEID = @AKRS_AKKREDITIERUNGSSTELLEID and AKRS_USER = @AKRS_USER and AKRS_#PTS = @AKRS_XPTS;

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
