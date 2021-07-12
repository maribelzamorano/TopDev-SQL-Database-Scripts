/*	
 * topdev GmbH, erstellt am 08.10.2009 11:37		--topdev GmbH, created at ...
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-10-08 11:37:45 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (010) akkradm.pss_VESH_IUD.sql $
 *
 */

if not exists ( select * from sysobjects where id = object_id('akkradm.pss_VESH_IUD') and OBJECTPROPERTY(id, 'IsProcedure') = 1)
begin
	exec( N'create procedure akkradm.pss_VESH_IUD
	as begin
		print ''Procedure created.'';
	end' );
end
GO

alter procedure akkradm.pss_VESH_IUD
	@SESSION_ID	UDT_SESSION_ID,		
	@USER		UDT_USER,			

	@VESH_ID	UDT_ID output,		
	@VESH_USER	nvarchar(128),	
	@VESH_XPTS	nvarchar(23),		

	@AAKT_CODE	smallint,		


	@VESG_ID		    	UDT_ID,
	@VEST_CODE				UDT_CODE,
	@VESH_PTS_VEST			datetime,
	@VESH_USER_VEST			UDT_USER,


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

	set @tbsh_shortname = N'VESH';
	set	@id = @VESH_ID;


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
		   ( not exists( select 1 from akkradm.IO_VERANSTALTUNG_STATUS_HIST where VESH_ID = @VESH_ID and VESH_USER = @VESH_USER and VESH_#PTS = @VESH_XPTS ))
		begin
			set @rc = -1;
			set @rc_text = N'Der Vorgang wurde zwischenzetlich geändert. Die gewünschte Aktion kann nicht durchgeführt werden.'; 
		end
	end

	if ( @rc = 0 )
	begin
		set @step = N'Fachliche Validierungen durchführen.'; 
		if ( @DEBUG = 1 )	print @step;


		if ( ltrim( rtrim( @VEST_CODE )) = N'' )	set @VEST_CODE = null;
		if ( ltrim( rtrim( @VESH_USER_VEST )) = N'' )	set @VESH_USER_VEST= null;


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

					insert into akkradm.IO_VERANSTALTUNG_STATUS_HIST(
						--VESH_ID,	
						VESG_ID,
						VEST_CODE,VESH_PTS_VEST,VESH_USER_VEST,
						VESH_USER, VESH_PTS, VESH_#PTS,
						--VESH_ID_INT,	
						VESH_UQID )
						values(
						--@id,
						@VESG_ID,
						@VEST_CODE,@VESH_PTS_VEST,@VESH_USER_VEST,
						@USER, @pts, services.pfn_getXPTS( @pts ),
						--VESH_ID_INT,	
						@uqid );

					set @step = N'Lesen des Identitätswertes';	
					if ( @DEBUG = 1 )	print @step;

					select	@VESH_ID = VESH_ID
					from	akkradm.IO_VERANSTALTUNG_STATUS_HIST
					where	VESH_UQID = @uqid;

					if ( @@rowcount <> 1 ) or ( isnull( @VESH_ID, 0 ) = 0 )
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

				update akkradm.IO_VERANSTALTUNG_STATUS_HIST set

					VESG_ID			    = @VESG_ID,
					VEST_CODE			= @VEST_CODE,
					VESH_PTS_VEST		= @VESH_PTS_VEST,
					VESH_USER_VEST		= @VESH_USER_VEST,

					VESH_USER			= @USER,
					VESH_PTS			= @pts,
					VESH_#PTS			= services.pfn_getXPTS( @pts )

				where VESH_ID = @VESH_ID and VESH_USER = @VESH_USER and VESH_#PTS = @VESH_XPTS;

			end
			else if ( @AAKT_CODE = 30 )
			begin
				set @step = N'Löschen des Vorgangs (logisch).';
				if ( @DEBUG = 1 )	print @step;

				update akkradm.IO_VERANSTALTUNG_STATUS_HIST set
					VESH_KZ_GELOESCHT = 1,

					VESH_USER = @USER,
					VESH_PTS = @pts,
					VESH_#PTS = services.pfn_getXPTS( @pts )

				where VESH_ID = @VESH_ID and VESH_USER = @VESH_USER and VESH_#PTS = @VESH_XPTS;

			end
			else if ( @AAKT_CODE = 90 )
			begin
				set @step = N'Löschen des Vorgangs';	
				if ( @DEBUG = 1 )	print @step;

				delete from akkradm.IO_VERANSTALTUNG_STATUS_HIST where VESH_ID = @VESH_ID and VESH_USER = @VESH_USER and VESH_#PTS = @VESH_XPTS;

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
