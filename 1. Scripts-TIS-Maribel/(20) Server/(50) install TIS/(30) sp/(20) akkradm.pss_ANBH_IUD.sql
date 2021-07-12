/*	
 * topdev GmbH, erstellt am 05.10.2009 15:55		--topdev GmbH, created at ...
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-10-05 15:55:25 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (020) akkradm.pss_ANBH_IUD.sql $
 *
 */

if not exists ( select * from sysobjects where id = object_id('akkradm.pss_ANBH_IUD') and OBJECTPROPERTY(id, 'IsProcedure') = 1)
begin
	exec( N'create procedure akkradm.pss_ANBH_IUD
	as begin
		print ''Procedure created.'';
	end' );
end
GO

alter procedure akkradm.pss_ANBH_IUD
	@SESSION_ID	UDT_SESSION_ID,		
	@USER		UDT_USER,			

	@ANBH_ID	UDT_ID output,		
	@ANBH_USER	nvarchar(128),		
	@ANBH_XPTS	nvarchar(23),		

	@AAKT_CODE	smallint,			



	@ANBO_ID				UDT_ID,
	@ANST_ID				UDT_ID,
	@ANBH_BEGRUENDUNG		nvarchar(1000),


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


	set @tbsh_shortname = N'ANBH';
	set	@id = @ANBH_ID;


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
		   ( not exists( select 1 from akkradm.IO_ANGEBOT_STATUS_HIST where ANBH_ID = @ANBH_ID and ANBH_USER = @ANBH_USER and ANBH_#PTS = @ANBH_XPTS ))
		begin
			set @rc = -1;
			set @rc_text = N'Der Vorgang wurde zwischenzetlich geändert. Die gewünschte Aktion kann nicht durchgeführt werden.';
		end
	end

	if ( @rc = 0 )
	begin
		set @step = N'Fachliche Validierungen durchführen.'; 
		if ( @DEBUG = 1 )	print @step;

		
		if ( ltrim( rtrim( @ANBH_BEGRUENDUNG )) = N'' )	set @ANBH_BEGRUENDUNG = null;

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

					insert into akkradm.IO_ANGEBOT_STATUS_HIST(
						--ANBH_ID,	
						ANBO_ID,ANST_ID,
						ANBH_BEGRUENDUNG,
						ANBH_USER, ANBH_PTS, ANBH_#PTS,
						--ANBH_ID_INT,	
						ANBH_UQID )
					values(
						--@id,
						@ANBO_ID,@ANST_ID,
						@ANBH_BEGRUENDUNG,
						@USER, @pts, services.pfn_getXPTS( @pts ),
						--ANBH_ID_INT,	
						@uqid );

					set @step = N'Lesen des Identitätswertes';	
					if ( @DEBUG = 1 )	print @step;

					select	@ANBH_ID = ANBH_ID
					from	akkradm.IO_ANGEBOT_STATUS_HIST
					where	ANBH_UQID = @uqid;

					if ( @@rowcount <> 1 ) or ( isnull( @ANBH_ID, 0 ) = 0 )
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

				update akkradm.IO_ANGEBOT_STATUS_HIST set


					ANBO_ID				= @ANBO_ID,
					ANST_ID				= @ANST_ID,
					ANBH_BEGRUENDUNG	= @ANBH_BEGRUENDUNG,

					ANBH_USER			= @USER,
					ANBH_PTS			= @pts,
					ANBH_#PTS			= services.pfn_getXPTS( @pts )

				where ANBH_ID = @ANBH_ID and ANBH_USER = @ANBH_USER and ANBH_#PTS = @ANBH_XPTS;

			end
			else if ( @AAKT_CODE = 30 )
			begin
				set @step = N'Löschen des Vorgangs (logisch).';	
				if ( @DEBUG = 1 )	print @step;

				update akkradm.IO_ANGEBOT_STATUS_HIST set
					ANBH_KZ_GELOESCHT = 1,

					ANBH_USER = @USER,
					ANBH_PTS = @pts,
					ANBH_#PTS = services.pfn_getXPTS( @pts )

				where ANBH_ID = @ANBH_ID and ANBH_USER = @ANBH_USER and ANBH_#PTS = @ANBH_XPTS;

			end
			else if ( @AAKT_CODE = 90 )
			begin
				set @step = N'Löschen des Vorgangs';	
				if ( @DEBUG = 1 )	print @step;

				delete from akkradm.IO_ANGEBOT_STATUS_HIST where ANBH_ID = @ANBH_ID and ANBH_USER = @ANBH_USER and ANBH_#PTS = @ANBH_XPTS;

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
