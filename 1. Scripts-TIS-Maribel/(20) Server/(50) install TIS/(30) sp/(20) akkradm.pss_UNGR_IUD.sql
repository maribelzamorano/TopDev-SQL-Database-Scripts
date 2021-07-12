/*	
 * topdev GmbH, erstellt am 02.10.2009 08:45   --topdev GmbH, created at ...
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-10-02 08:45:22 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (020) akkradm.pss_UNGR_IUD.sql $
 *
 */

if not exists ( select * from sysobjects where id = object_id('akkradm.pss_UNGR_IUD') and OBJECTPROPERTY(id, 'IsProcedure') = 1)
begin
	exec( N'create procedure akkradm.pss_UNGR_IUD
	as begin
		print ''Procedure created.'';
	end' );
end
GO

alter procedure akkradm.pss_UNGR_IUD
	@SESSION_ID	UDT_SESSION_ID,		
	@USER		UDT_USER,			

	@UNGR_ID	UDT_ID output,		
	@UNGR_USER	nvarchar(128),		
	@UNGR_XPTS	nvarchar(23),		

	@AAKT_CODE	smallint,			


	@VESG_ID					UDT_ID,
--  @UGAR_ID					UDT_ID,

	@UNGR_THEMA					nvarchar(255),  
	@UNGR_DT_BEGINN				datetime,
	@UNGR_DT_ENDE				datetime,
	@UNGR_MAX_TEILNEHMER		UDT_ANZAHL_I,
	@UNGR_#DT_BEGINN_ZEIT		UDT_UHRZEIT,
	@UNGR_#DT_ENDE_ZEIT			UDT_UHRZEIT,
	@UNGR_KZ_GESPERRT			UDT_BOOLEAN,
	@UNGR_KZ_ANMELDUNG_ZUL		UDT_BOOLEAN,
	@UNGR_KZ_NICHT_UEBERBUCHBAR UDT_BOOLEAN,
	@UNGR_ANMELDEBLOCK			smallint ,
	@UNGR_KZ_AUTO_VERGABE		UDT_BOOLEAN_TRUE,
	@UNGR_TEILNEHMER_ANZAHL		UDT_ANZAHL_S,
-->

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


	set @tbsh_shortname = N'UNGR';
	set	@id = @UNGR_ID;


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
		   ( not exists( select 1 from akkradm.IO_UNTERGRUPPE where UNGR_ID = @UNGR_ID and UNGR_USER = @UNGR_USER and UNGR_#PTS = @UNGR_XPTS ))
		begin
			set @rc = -1;
			set @rc_text = N'Der Vorgang wurde zwischenzetlich geändert. Die gewünschte Aktion kann nicht durchgeführt werden.'; 
		end
	end

	if ( @rc = 0 )
	begin
		set @step = N'Fachliche Validierungen durchführen.'; 
		if ( @DEBUG = 1 )	print @step;

		
		if ( ltrim( rtrim( @UNGR_THEMA	 )) = N'' )	set @UNGR_THEMA	 = null;
		if ( ltrim( rtrim( @UNGR_#DT_BEGINN_ZEIT )) = N'' )	set @UNGR_#DT_BEGINN_ZEIT = null;
		if ( ltrim( rtrim( @UNGR_#DT_ENDE_ZEIT )) = N'' )	set @UNGR_#DT_ENDE_ZEIT = null;

	
		if ( @UNGR_MAX_TEILNEHMER is null )			set @UNGR_MAX_TEILNEHMER = 0;
		if ( @UNGR_KZ_GESPERRT is null )			set @UNGR_KZ_GESPERRT = 0;
		if ( @UNGR_KZ_ANMELDUNG_ZUL is null )		set @UNGR_KZ_ANMELDUNG_ZUL = 0;
		if ( @UNGR_KZ_NICHT_UEBERBUCHBAR is null )	set @UNGR_KZ_NICHT_UEBERBUCHBAR = 0;
		if ( @UNGR_ANMELDEBLOCK is null )			set @UNGR_ANMELDEBLOCK = 0;
		if ( @UNGR_KZ_AUTO_VERGABE is null )		set @UNGR_KZ_AUTO_VERGABE = 0;
		if ( @UNGR_TEILNEHMER_ANZAHL	 is null )	set @UNGR_TEILNEHMER_ANZAHL	 = 0;
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

					insert into akkradm.IO_UNTERGRUPPE(
						--UNGR_ID,	
						VESG_ID,--UGAR_ID,
						UNGR_THEMA,UNGR_DT_BEGINN,UNGR_DT_ENDE,UNGR_MAX_TEILNEHMER,
						UNGR_#DT_BEGINN_ZEIT,UNGR_#DT_ENDE_ZEIT,UNGR_KZ_GESPERRT,UNGR_KZ_ANMELDUNG_ZUL,
						UNGR_KZ_NICHT_UEBERBUCHBAR,UNGR_ANMELDEBLOCK,UNGR_KZ_AUTO_VERGABE,UNGR_TEILNEHMER_ANZAHL,
						UNGR_USER, UNGR_PTS, UNGR_#PTS,
						--UNGR_ID_INT,	
						UNGR_UQID )
					values(
						--@id,
						@VESG_ID,--@UGAR_ID,
						@UNGR_THEMA,@UNGR_DT_BEGINN,@UNGR_DT_ENDE,@UNGR_MAX_TEILNEHMER,
						@UNGR_#DT_BEGINN_ZEIT,@UNGR_#DT_ENDE_ZEIT,@UNGR_KZ_GESPERRT,@UNGR_KZ_ANMELDUNG_ZUL,
						@UNGR_KZ_NICHT_UEBERBUCHBAR,@UNGR_ANMELDEBLOCK,@UNGR_KZ_AUTO_VERGABE,@UNGR_TEILNEHMER_ANZAHL,
						@USER, @pts, services.pfn_getXPTS( @pts ),
						--UNGR_ID_INT,	
						@uqid );

					set @step = N'Lesen des Identitätswertes';	
					if ( @DEBUG = 1 )	print @step;

					select	@UNGR_ID = UNGR_ID
					from	akkradm.IO_UNTERGRUPPE
					where	UNGR_UQID = @uqid;

					if ( @@rowcount <> 1 ) or ( isnull( @UNGR_ID, 0 ) = 0 )
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

				update akkradm.IO_UNTERGRUPPE set

					VESG_ID							 = @VESG_ID,
				  --UGAR_ID							 = @UGAR_ID,
					UNGR_THEMA						 = @UNGR_THEMA,
					UNGR_DT_BEGINN					 = @UNGR_DT_BEGINN,
					UNGR_DT_ENDE					 = @UNGR_DT_ENDE,
					UNGR_MAX_TEILNEHMER				 = @UNGR_MAX_TEILNEHMER,
					UNGR_#DT_BEGINN_ZEIT			 = @UNGR_#DT_BEGINN_ZEIT,
					UNGR_#DT_ENDE_ZEIT				 = @UNGR_#DT_ENDE_ZEIT,
					UNGR_KZ_GESPERRT				 = @UNGR_KZ_GESPERRT,
					UNGR_KZ_ANMELDUNG_ZUL			 = @UNGR_KZ_ANMELDUNG_ZUL,
					UNGR_KZ_NICHT_UEBERBUCHBAR		 = @UNGR_KZ_NICHT_UEBERBUCHBAR,
					UNGR_ANMELDEBLOCK				 = @UNGR_ANMELDEBLOCK,
					UNGR_KZ_AUTO_VERGABE			 = @UNGR_KZ_AUTO_VERGABE,
					UNGR_TEILNEHMER_ANZAHL			 = @UNGR_TEILNEHMER_ANZAHL,

					UNGR_USER			= @USER,
					UNGR_PTS			= @pts,
					UNGR_#PTS			= services.pfn_getXPTS( @pts )

				where UNGR_ID = @UNGR_ID and UNGR_USER = @UNGR_USER and UNGR_#PTS = @UNGR_XPTS;

			end
			else if ( @AAKT_CODE = 30 )
			begin
				set @step = N'Löschen des Vorgangs (logisch).';	
				if ( @DEBUG = 1 )	print @step;

				update akkradm.IO_UNTERGRUPPE set
					UNGR_KZ_GELOESCHT = 1,

					UNGR_USER = @USER,
					UNGR_PTS = @pts,
					UNGR_#PTS = services.pfn_getXPTS( @pts )

				where UNGR_ID = @UNGR_ID and UNGR_USER = @UNGR_USER and UNGR_#PTS = @UNGR_XPTS;

			end
			else if ( @AAKT_CODE = 90 )
			begin
				set @step = N'Löschen des Vorgangs';	
				if ( @DEBUG = 1 )	print @step;

				delete from akkradm.IO_UNTERGRUPPE where UNGR_ID = @UNGR_ID and UNGR_USER = @UNGR_USER and UNGR_#PTS = @UNGR_XPTS;

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
