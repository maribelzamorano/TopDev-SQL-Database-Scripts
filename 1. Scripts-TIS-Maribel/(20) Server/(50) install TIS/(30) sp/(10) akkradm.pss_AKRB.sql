/*	
 * topdev GmbH, erstellt am 06.10.2009 10:25
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-10-06 10:25:26 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (010) akkradm.pss_AKRB.sql $
 *
 */

if not exists ( select * from sysobjects where id = object_id('akkradm.pss_AKRB') and OBJECTPROPERTY(id, 'IsProcedure') = 1)
begin
	exec( N'create procedure akkradm.pss_AKRB
	as begin
		print ''Procedure created.'';
	end' );
end
GO

alter procedure akkradm.pss_AKRB
	@SESSION_ID				UDT_SESSION_ID,
	@USER					UDT_USER,

	@CURRENT_PAGE			integer = 1,
	@ROWS_PER_PAGE			integer = 20,
	@ROWS_MAX				bigint = 1000,
	@ROWS_TOTAL				bigint output,
	@KZ_USE_RESULTSET		UDT_BOOLEAN = 0,
	@RESULTSET_ID			UDT_SESSION_ID output,

	@ORDER_BY				nvarchar(1000) = null,


	@GEPA_#NAME_12			nvarchar(200)= null,
	@ABIE_NUMMER			nvarchar(25) = null,
	@AKRT_ID				nvarchar(23) = null,


	@DEBUG					bit = 0		

as begin


	set nocount on;

	declare	@rc			integer,
			@rc_text	nvarchar(1000),
			@sql_error	integer,
			@procName	nvarchar(250),
			@step		nvarchar(100),

			@id				UDT_ID,
			@tbsh_shortname	UDT_TABLENAME_SHORT,
			@tbsh_longname	nvarchar(255),
			@uqid			UDT_UQID,
			@pts			datetime,
			@b				bit,
			@parm			nvarchar(255),
			@aakt_code		smallint;

	declare	@object_name		nvarchar(1000),
			@permissionObject	nvarchar(255),
			@table_name			nvarchar(500),
			@table_schema		nvarchar(500),
			@start				bigint, 
			@stop				bigint,
			@sql				nvarchar(max),
			@where				nvarchar(max),
			@orderby			nvarchar(max),
			@parms				nvarchar(max),
			@subselect			nvarchar(max),
			@top				integer,
			@max				integer,


			@minDate			datetime,
			@maxDate			datetime;

	set @minDate = convert( datetime, N'19000101', 112 );
	set @maxDate = convert( datetime, N'99991231', 112 );

	declare	@datum_von	datetime,
			@datum_bis	datetime;

	set @tbsh_shortname = N'AKRB';
	set @tbsh_longname = N'AKKREDITIERUNGSBESCHEID';


	set @rc = 0;
	set @rc_text = N'';
	set @sql_error = 0;
	set @procName = isNull( Object_Name( @@PROCID ), N'<<unbekannt>>' );
	set @aakt_code = 0;	
	set @permissionObject = services.pfn_getPermissionObject( @@PROCID, null );

	set	@parms = N'';
	set @where = N'';

	if ( @rc = 0 ) and ( isNull( @RESULTSET_ID, N'' ) = N'' )
	begin
		select	@RESULTSET_ID = replace( NewID(), '-', '' ),
				@KZ_USE_RESULTSET = 0;
	end


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
		select @b = services.pfn_checkGrants( @SESSION_ID, @USER, @aakt_code );
		if ( @b = 0 )	set @rc = -1;
		if ( @rc <> 0 )
		begin
			set @rc_text = N'Sie verfügen nicht über ausreichende Berechtigungen, um diese Aktion auszuführen.';
		end
	end

	if ( @rc = 0 ) and ( @KZ_USE_RESULTSET = 0 )
	begin
		set @step = N'Fachliche Validierungen durchführen.';
		if ( @DEBUG = 1 )	print @step;

		set @parm = N'';

	
		if ( ltrim( rtrim( @GEPA_#NAME_12 )) = N'' )	set @GEPA_#NAME_12 = null;
		if ( ltrim( rtrim( @ABIE_NUMMER )) = N'' )		set @ABIE_NUMMER = null;
	

		if ( @rc = 0 ) and ( @AKRT_ID is not null ) and ( isnumeric( @AKRT_ID ) = 0 )
		begin
			set @rc = -1;
			set @parm = N'@AKRT_ID';
		end
		
		if ( @rc <> 0 )
		begin
			set @rc_text = N'Der Wert ' + @parm + N' wurde in einem ungültigen Format gesendet.';
		end
	end

	BEGIN TRANSACTION;

	if ( @rc = 0 )
	begin
		set @step = N'Ergebnistabelle wird erstellt.';
		if ( @DEBUG = 1 )	print @step;

		select	@table_name = 'T#RESULT2_GET' + @tbsh_longname + N'_' + @RESULTSET_ID, 
				@table_schema = 'resultsets'

		select	@object_name = @table_schema + N'.' + @table_name

		select	@sql =
			N'if not exists( select 1 from INFORMATION_SCHEMA.TABLES where table_schema = ''' + @table_schema + N''' and table_name = ''' + @table_name + N''' )' +
			N'begin ' +
			N' CREATE TABLE ' + @object_name + N'( ' +
			N'	' + @tbsh_shortname + N'_ID 	bigint	NOT NULL, ' +
			N'	ROWNUMBER 	bigint	NOT NULL  ' +
			N' ); ' +
			N' create unique index T#R' + @tbsh_shortname + N'_IX_01_U on ' + @object_name + N'( ' + @tbsh_shortname + N'_ID ); ' + 
			N' create unique index T#R' + @tbsh_shortname + N'_IX_02_U on ' + @object_name + N'( ROWNUMBER ); ' + 
			N'end'

		BEGIN TRY
			exec @SQL_ERROR = sp_executesql @sql

		END TRY
		BEGIN CATCH
			select	@rc = -1, 
					@rc_text = N'Die Ergebnistabelle "' + @object_name + N'" konnte nicht erstellt werden. ' + ERROR_MESSAGE(),
					@sql_error = ERROR_NUMBER();

		END CATCH
	end

	if ( @rc = 0 ) and ( @KZ_USE_RESULTSET = 0 )
	begin
		set @step = N'Filterkriterien auswerten und Where-Bedingung erstellen.';
		if ( @DEBUG = 1 )	print @step;

		
		if ( @parms > N'' )
				set @parms = @parms + N',';
		set @parms = N'@GEPA_#NAME_12 nvarchar(200), @ABIE_NUMMER nvarchar(25)';

		if ( @GEPA_#NAME_12 is not null )	
		begin
			if ( @where > N'' )
				set @where = @where + N' and ';

			set	@GEPA_#NAME_12 = services.pfn_prepareSearchList( services.pfn_prepareSearchItem( @GEPA_#NAME_12, 0 ));
			set @where = @where + N'( GEPA_#NAME_12 like @GEPA_#NAME_12 ) ';

			if ( @DEBUG = 1 )
			begin
				print	N'@GEPA_#NAME_12 = ' + @GEPA_#NAME_12;
			end
		end

		if ( @ABIE_NUMMER is not null )	
		begin
			if ( @where > N'' )
				set @where = @where + N' and ';

			set	@ABIE_NUMMER = services.pfn_prepareSearchList( services.pfn_prepareSearchItem( @ABIE_NUMMER, 0 ));
			set @where = @where + N'( ABIE_NUMMER like @ABIE_NUMMER) ';

			if ( @DEBUG = 1 )
			begin
				print	N'@ABIE_NUMMER = ' + @ABIE_NUMMER;
			end
		end
		
	
		

		if ( @where > N'' )
			set @where = N'where ' + @where;
	end

	if ( @rc = 0 ) and ( @KZ_USE_RESULTSET = 0 )
	begin
		set @step = N'Sortierung bestimmen.';
		if ( @DEBUG = 1 )	print @step;

		if ( isNull( @ORDER_BY, N'' ) > N'' )
			set @orderby = services.pfn_getSortation( @ORDER_BY );

		if isNull( @orderby, N'' ) = N''

			set @orderby = services.pfn_getSortation( N'#' + services.pfn_getObjectName( null, @procName ) + N'#' );

		if isNull( @orderby, N'' ) = N''
			set @orderby = N' akkradm.T_AKKREDITIERUNGSBESCHEID.AKRB_PTS DESC';	

		if ( isNull( @orderby, N'' ) > N'' ) and ( left( @orderby, 8 ) <> N' order by ' )
			set @orderby = N' order by ' + @orderby + N' ';
	end

	if ( @rc = 0 ) 
	begin
		if ( @KZ_USE_RESULTSET = 0 )
		begin
			set @step = N'ResultSet wird erstellt...';	
			if ( @DEBUG = 1 )	print @step;

			set	@sql = 
				
					N'if exists( select 1 from ' + @object_name + N' ) truncate table ' + @object_name + '; ' +
					N'insert into ' + @object_name + N'( ' + @tbsh_shortname + N'_ID, ROWNUMBER ) ' +
				
					N'select AKRB_ID, ROW_NUMBER() OVER ( ' + @orderby + N' ) as ROWNUMBER from akkradm.T_AKKREDITIERUNGSBESCHEID 
					  join T_AKKREDITEUR on T_AKKREDITIERUNGSBESCHEID.AKRT_ID = T_AKKREDITEUR.AKRT_ID 
					  join V_GESCHAEFTSPARTNER on T_AKKREDITEUR.TBSH_ID=V_GESCHAEFTSPARTNER.GEPA_ID
					  join T_ANBIETER on T_AKKREDITIERUNGSBESCHEID.ABIE_ID=T_ANBIETER.ABIE_ID ';

			set	@sql = @sql + @where + @orderby + N'; select @ROWS_TOTAL = @@rowcount;';

			if ( @parms > N'' )
				set @parms = @parms + N',';

			set @parms = @parms + N'@ROWS_TOTAL bigint output';

			if ( @DEBUG = 1 )
			begin
				print N'Parms = ' + @parms;
				print N'SQL = ' + @sql;
			end
		
			BEGIN TRY
			
				exec sp_executesql 
				
					@sql,
					@parms,
					@ROWS_TOTAL = @ROWS_TOTAL output,
				
					@GEPA_#NAME_12  = @GEPA_#NAME_12,
					@ABIE_NUMMER	= @ABIE_NUMMER;

			END TRY
			BEGIN CATCH
				select	@rc = -1, @sql_error = ERROR_NUMBER(),
						@rc_text = N'Beim Erstellen des Ergebnisses ist ein Fehler aufgetreten. ' + ERROR_MESSAGE();

			END CATCH
		end
		else
		begin
			set @step = N'Das bestehende ResultSet wird verwendet. ROWS_TOTAL wird ermittelt.'
			if ( @DEBUG = 1 )	print @step;

			set	@sql = N'if exists( select 1 from ' + @object_name + N' ) select @ROWS_TOTAL = count(*) from ' + @object_name;
			set @parms = N'@ROWS_TOTAL bigint output';

			BEGIN TRY
				exec sp_executesql @sql,
					@parms,
					@ROWS_TOTAL = @ROWS_TOTAL output

			END TRY
			BEGIN CATCH
				select	@rc = -1, @sql_error = ERROR_NUMBER(),
						@rc_text = N'Beim Erstellen des Ergebnisses ist ein Fehler aufgetreten. ' + ERROR_MESSAGE();
			END CATCH
		end 
	end


	if ( @rc = 0 )
	begin
		set @ROWS_TOTAL = isnull( @ROWS_TOTAL, 0 );

		if ( @KZ_USE_RESULTSET = 0 )
		begin
			select	@start = ( @ROWS_PER_PAGE * ( @CURRENT_PAGE - 1 )) + 1,
					@stop = ( @ROWS_PER_PAGE * @CURRENT_PAGE )
		end
		else
		begin
			select	@start = 1, @stop = @ROWS_TOTAL
		end
	end

	if ( @rc = 0 )
	begin
		BEGIN TRY
			set @step = N'ResultSet wird ausgegeben...';
			if ( @DEBUG = 1 )	print @step;

			set @sql = 
				N'select top ' + convert( nvarchar(18), @ROWS_MAX ) + N' ' +
				
				N'T_AKKREDITIERUNGSBESCHEID.AKRB_ID as id,AKRA_BEZEICHNUNG as AkkreditierungsbescheidartDecode,AKRB_PTS as Zeitpunkt,
					ABIE_NUMMER as AnbieterNummer,GEPA_#NAME_12 as AnbieterNameVoll,GEPA_NAME_1 as AkkrediteurNachname, GEPA_NAME_2 as AkkrediteurVorname,ANBO_NUMMER as AngebotNummer,ANBO_THEMA as Thema,
					ANST_BEZEICHNUNG as AngebotsstatusDecode,ANBO_PTS_ANST as AngebotsstatusZeitpunkt ' +
				
				N'from akkradm.T_AKKREDITIERUNGSBESCHEID ' +
				N'join ' + @object_name + N' rs on ( rs.AKRB_ID = akkradm.T_AKKREDITIERUNGSBESCHEID.AKRB_ID ) 
				  join T_AKKREDITIERUNGSBESCHEIDART on T_AKKREDITIERUNGSBESCHEID.AKRA_ID=T_AKKREDITIERUNGSBESCHEIDART.AKRA_ID
				  join T_ANGEBOT on T_AKKREDITIERUNGSBESCHEID.ANBO_ID=T_ANGEBOT.ANBO_ID
				  join T_ANGEBOTSSTATUS on T_ANGEBOT.ANST_ID=T_ANGEBOTSSTATUS.ANST_ID
				  join T_AKKREDITEUR on T_AKKREDITIERUNGSBESCHEID.AKRT_ID=T_AKKREDITEUR.AKRT_ID
				  join V_GESCHAEFTSPARTNER on T_AKKREDITEUR.TBSH_ID=V_GESCHAEFTSPARTNER.GEPA_ID 
				  join T_ANBIETER on T_AKKREDITIERUNGSBESCHEID.ABIE_ID=T_ANBIETER.ABIE_ID ' +
			
				N'where ( rs.ROWNUMBER between @start and @stop ) ' +
				N';';

			set @parms = N'@start bigint, @stop bigint';
		
			if right( @sql, 1 ) <> ';'
			begin
				set @rc = -1;
				set @rc_text = N'Die generierte Abfrage ist zu lang (aktuell=' + convert( nvarchar(18), len( @sql )) + ') ==> "...' + right( @sql, 200 ) + '". Bitte informieren Sie Ihren Systemadministrator.';
			end

			if ( @rc = 0 )
			begin
				exec sp_executesql 
					@sql,
					@parms,
					@start = @start,
					@stop = @stop
			end

		END TRY
		BEGIN CATCH
			select	@rc = -1, @sql_error = ERROR_NUMBER(),
					@rc_text = N'Beim Bereitstellen des Ergebnisses ist ein Fehler aufgetreten. ' + ERROR_MESSAGE();

		END CATCH
	end


	if ( @rc = 0 )
	begin
		commit transaction
	end
	else
	begin
		rollback transaction

		if ( @DEBUG = 1 )
		begin
			print	@sql;
		end
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


end
GO
