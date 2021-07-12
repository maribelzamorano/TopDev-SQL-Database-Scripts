/*	
 * topdev GmbH, erstellt am 29.09.2009 09:44		--topdev GmbH, created at ...
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-09-29 09:44:26 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (020) akkradm.pss_VESG_IUD.sql $
 *
 */

if not exists ( select * from sysobjects where id = object_id('akkradm.pss_VESG_IUD') and OBJECTPROPERTY(id, 'IsProcedure') = 1)
begin
	exec( N'create procedure akkradm.pss_VESG_IUD
	as begin
		print ''Procedure created.'';
	end' );
end
GO

alter procedure akkradm.pss_VESG_IUD
	@SESSION_ID	UDT_SESSION_ID,		
	@USER		UDT_USER,			

	@VESG_ID	UDT_ID output,		
	@VESG_USER	nvarchar(128),		
	@VESG_XPTS	nvarchar(23),		

	@AAKT_CODE	smallint,			


	@ANBO_ID				        UDT_ID,
	@VOTE_ID						UDT_ID,	
	@GUEB_ID						UDT_ID,
	@VERR_ID						UDT_ID,	                                 

	@VESG_NR					nvarchar(10),
	@VESG_NR2				    nvarchar(25),
	@VESG_KZABRUFVERANSTALTUNG  UDT_BOOLEAN	,
	@VESG_KZVORLAEUFIGERTERMIN  UDT_BOOLEAN	,
	@VESG_KZFESTERTERMIN		UDT_BOOLEAN	,
	@VESG_AUFABRUFBIS			datetime	,
	@VESG_BEGINN				datetime	,
	@VESG_#BEGINN_ZEIT			UDT_UHRZEIT	,
	@VESG_ENDE					datetime	,
	@VESG_#ENDE_ZEIT            UDT_UHRZEIT	,
	@VESG_THEMA					nvarchar(500),
	@VESG_TEILNEHMERBEITRAG		UDT_BETRAG	,
	@VESG_VERANSTALTUNGORT		nvarchar(255),
	@VESG_ANMELDESCHLUSS		datetime	,
	@VESG_LEITUNG				nvarchar(4000),
	@VESG_DOZENTEN				nvarchar(4000),
	@VESG_ZWISCHENTERMINE		nvarchar(255),
	@VESG_ZUSATZINFORMATIONEN	nvarchar(500),

	@VEST_CODE					nvarchar(25),
	


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


	set @tbsh_shortname = N'VESG';
	set	@id = @VESG_ID;


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
		   ( not exists( select 1 from akkradm.IO_VERANSTALTUNG where VESG_ID = @VESG_ID and VESG_USER = @VESG_USER and VESG_#PTS = @VESG_XPTS ))
		begin
			set @rc = -1;
			set @rc_text = N'Der Vorgang wurde zwischenzetlich geändert. Die gewünschte Aktion kann nicht durchgeführt werden.'; 
		end
	end

	if ( @rc = 0 )
	begin
		set @step = N'Fachliche Validierungen durchführen.'; 
		if ( @DEBUG = 1 )	print @step;

		
		if ( ltrim( rtrim( @VESG_#ENDE_ZEIT )) = N'' )			set @VESG_#ENDE_ZEIT = null;
		if ( ltrim( rtrim( @VESG_THEMA )) = N'' )				set @VESG_THEMA= null;
		if ( ltrim( rtrim( @VESG_VERANSTALTUNGORT )) = N'' )	set @VESG_VERANSTALTUNGORT = null;
		if ( ltrim( rtrim( @VESG_LEITUNG)) = N'' )				set @VESG_LEITUNG = null;
		if ( ltrim( rtrim( @VESG_DOZENTEN )) = N'' )			set @VESG_DOZENTEN = null;
		if ( ltrim( rtrim( @VESG_ZWISCHENTERMINE )) = N'' )		set @VESG_ZWISCHENTERMINE = null;
		if ( ltrim( rtrim( @VESG_ZUSATZINFORMATIONEN )) = N'' )	set @VESG_ZUSATZINFORMATIONEN = null;
		if ( ltrim( rtrim( @VEST_CODE )) = N'' )				set @VEST_CODE = null;

		
		if ( @VESG_KZABRUFVERANSTALTUNG is null )	set @VESG_KZABRUFVERANSTALTUNG = 0;
		if ( @VESG_KZVORLAEUFIGERTERMIN is null )	set @VESG_KZVORLAEUFIGERTERMIN = 0;
		if ( @VESG_KZFESTERTERMIN is null )			set @VESG_KZFESTERTERMIN = 0;
		if ( @VESG_TEILNEHMERBEITRAG is null )		set @VESG_TEILNEHMERBEITRAG = 0;

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

					insert into akkradm.IO_VERANSTALTUNG(
						
						ANBO_ID,VOTE_ID,GUEB_ID,VERR_ID,VESG_NR,VESG_NR2,VESG_KZABRUFVERANSTALTUNG,VESG_KZVORLAEUFIGERTERMIN,
						VESG_KZFESTERTERMIN,VESG_AUFABRUFBIS,VESG_BEGINN,VESG_#BEGINN_ZEIT,
						VESG_ENDE,VESG_#ENDE_ZEIT,VESG_THEMA,VESG_TEILNEHMERBEITRAG,
						VESG_VERANSTALTUNGORT,VESG_ANMELDESCHLUSS,VESG_LEITUNG,VESG_DOZENTEN,VESG_ZWISCHENTERMINE,
						VESG_ZUSATZINFORMATIONEN,
						
						VEST_CODE,
						VESG_USER, VESG_PTS, VESG_#PTS,
						
						VESG_UQID )
					values(
						
						@ANBO_ID,@VOTE_ID,@GUEB_ID,@VERR_ID,@VESG_NR,@VESG_NR2,@VESG_KZABRUFVERANSTALTUNG,@VESG_KZVORLAEUFIGERTERMIN,
						@VESG_KZFESTERTERMIN,@VESG_AUFABRUFBIS,@VESG_BEGINN,@VESG_#BEGINN_ZEIT,
						@VESG_ENDE,@VESG_#ENDE_ZEIT,@VESG_THEMA,@VESG_TEILNEHMERBEITRAG,
						@VESG_VERANSTALTUNGORT,@VESG_ANMELDESCHLUSS,@VESG_LEITUNG,@VESG_DOZENTEN,@VESG_ZWISCHENTERMINE,
						@VESG_ZUSATZINFORMATIONEN,
						
						@VEST_CODE, 
						@USER, @pts, services.pfn_getXPTS( @pts ),
						
						@uqid );

					set @step = N'Lesen des Identitätswertes';	
					if ( @DEBUG = 1 )	print @step;

					select	@VESG_ID = VESG_ID
					from	akkradm.IO_VERANSTALTUNG
					where	VESG_UQID = @uqid;

					if ( @@rowcount <> 1 ) or ( isnull( @VESG_ID, 0 ) = 0 )
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

				update akkradm.IO_VERANSTALTUNG set

				
						ANBO_ID						=@ANBO_ID ,
						VOTE_ID						=@VOTE_ID,
						GUEB_ID						=@GUEB_ID,
						VERR_ID						=@VERR_ID,
						VESG_NR						=@VESG_NR,
						VESG_NR2					=@VESG_NR2,
						VESG_KZABRUFVERANSTALTUNG	=@VESG_KZABRUFVERANSTALTUNG,
						VESG_KZVORLAEUFIGERTERMIN	=@VESG_KZVORLAEUFIGERTERMIN,
						VESG_KZFESTERTERMIN			=@VESG_KZFESTERTERMIN,
						VESG_AUFABRUFBIS			=@VESG_AUFABRUFBIS,
						VESG_BEGINN					=@VESG_BEGINN,
						VESG_#BEGINN_ZEIT			=@VESG_#BEGINN_ZEIT,
						VESG_ENDE					=@VESG_ENDE,
						VESG_#ENDE_ZEIT				=@VESG_#ENDE_ZEIT,
						VESG_THEMA					=@VESG_THEMA,
						VESG_TEILNEHMERBEITRAG		=@VESG_TEILNEHMERBEITRAG,
						VESG_VERANSTALTUNGORT		=@VESG_VERANSTALTUNGORT,
						VESG_ANMELDESCHLUSS			=@VESG_ANMELDESCHLUSS,
						VESG_LEITUNG				=@VESG_LEITUNG,
						VESG_DOZENTEN				=@VESG_DOZENTEN,
						VESG_ZWISCHENTERMINE		=@VESG_ZWISCHENTERMINE,			
						VESG_ZUSATZINFORMATIONEN	=@VESG_ZUSATZINFORMATIONEN,
						VEST_CODE					=@VEST_CODE, 

						VESG_USER					= @USER,
						VESG_PTS					= @pts,
						VESG_#PTS					= services.pfn_getXPTS( @pts )

				where VESG_ID = @VESG_ID and VESG_USER = @VESG_USER and VESG_#PTS = @VESG_XPTS;

			end
			else if ( @AAKT_CODE = 30 )
			begin
				set @step = N'Löschen des Vorgangs (logisch).';	
				if ( @DEBUG = 1 )	print @step;

				update akkradm.IO_VERANSTALTUNG set
					VESG_KZ_GELOESCHT = 1,

					VESG_USER = @USER,
					VESG_PTS = @pts,
					VESG_#PTS = services.pfn_getXPTS( @pts )

				where VESG_ID = @VESG_ID and VESG_USER = @VESG_USER and VESG_#PTS = @VESG_XPTS;

			end
			else if ( @AAKT_CODE = 90 )
			begin
				set @step = N'Löschen des Vorgangs';	
				if ( @DEBUG = 1 )	print @step;

				delete from akkradm.IO_VERANSTALTUNG where VESG_ID = @VESG_ID and VESG_USER = @VESG_USER and VESG_#PTS = @VESG_XPTS;

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
