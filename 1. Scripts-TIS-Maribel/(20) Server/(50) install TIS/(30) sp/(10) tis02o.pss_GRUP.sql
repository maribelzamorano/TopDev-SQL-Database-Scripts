/*	
 * topdev GmbH, erstellt am 01.10.2009 14:00
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-10-01 14:00:25 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (010) tis02o.pss_GRUP.sql $
 *
 */

if not exists ( select * from sysobjects where id = object_id('tis02o.pss_GRUP') and OBJECTPROPERTY(id, 'IsProcedure') = 1)
begin
	exec( N'create procedure tis02o.pss_GRUP
	as begin
		print ''Procedure created.'';
	end' );
end
GO

alter procedure tis02o.pss_GRUP
	@SESSION_ID				UDT_SESSION_ID,
	@USER					UDT_USER,

	@CURRENT_PAGE			integer = 1,
	@ROWS_PER_PAGE			integer = 20,
	@ROWS_MAX				bigint = 1000,
	@ROWS_TOTAL				bigint output,
	@KZ_USE_RESULTSET		UDT_BOOLEAN = 0,
	@RESULTSET_ID			UDT_SESSION_ID output,

	@ORDER_BY				nvarchar(1000) = null,
--> fachliche Felder

	@GRUP_NAME				nvarchar(255),	--nvarchar(255),

-->
	@DEBUG					bit = 0		-- nur für interne Nutzung

as begin

--> Standardblock: NICHT AENDERN - DO NOT CHANGE
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

			-- wird nur bei Datumsfiltern benötigt
			@minDate			datetime,
			@maxDate			datetime;

	set @minDate = convert( datetime, N'19000101', 112 );
	set @maxDate = convert( datetime, N'99991231', 112 );

--< Ende Standardblock

	declare	@datum_von	datetime,
			@datum_bis	datetime;

	set @tbsh_shortname = N'GRUP';
	set @tbsh_longname = N'GRUPPE';

--> Standardblock: NICHT AENDERN - DO NOT CHANGE
	set @rc = 0;
	set @rc_text = N'';
	set @sql_error = 0;
	set @procName = isNull( Object_Name( @@PROCID ), N'<<unbekannt>>' );
	set @aakt_code = 0;	-- Lesen
	set @permissionObject = services.pfn_getPermissionObject( @@PROCID, null );

	set	@parms = N'';
	set @where = N'';

	if ( @rc = 0 ) and ( isNull( @RESULTSET_ID, N'' ) = N'' )
	begin
		select	@RESULTSET_ID = replace( NewID(), '-', '' ),
				@KZ_USE_RESULTSET = 0;
	end

--> Sitzung und Nutzer, Berechtigungen prüfen
--> Session and user, permissions
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
--< Ende Standardblock

--> fachliche Validierung
--> business validations
	if ( @rc = 0 ) and ( @KZ_USE_RESULTSET = 0 )
	begin
		set @step = N'Fachliche Validierungen durchführen.';
		if ( @DEBUG = 1 )	print @step;

		set @parm = N'';

		-- null-Setzen von leeren Zeichenketten
		-- reset empty strings
		if ( ltrim( rtrim( @GRUP_NAME )) = N'' )	set @GRUP_NAME = null;

		

		---------------
		if ( @rc <> 0 )
		begin
			set @rc_text = N'Der Wert ' + @parm + N' wurde in einem ungültigen Format gesendet.';
		end
	end
--<

--> Standardblock: NICHT AENDERN
--> Erstellen von bzw. prüfen auf Ergebnisstabelle Standardblock
--> create or check resultset table
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
--< Ende Standardblock

--> Where-Bedingung erstellen
--> building of where conditions
	if ( @rc = 0 ) and ( @KZ_USE_RESULTSET = 0 )
	begin
		set @step = N'Filterkriterien auswerten und Where-Bedingung erstellen.';
		if ( @DEBUG = 1 )	print @step;

		-- hier werden alle möglichen Suchparameter mit ihrem Original-Typ aufgenommen, außer Datumswerte
		-- minDate und maxDate werden nur benötigt, wenn Datumsfilter verwendet werden
		if ( @parms > N'' )
				set @parms = @parms + N',';
		set @parms = N'@GRUP_name nvarchar(255)';

		if ( @GRUP_NAME is not null )	-- Zeichenkette
		begin
			if ( @where > N'' )
				set @where = @where + N' and ';

			set	@GRUP_NAME = services.pfn_prepareSearchList( services.pfn_prepareSearchItem( @GRUP_NAME, 0 ));
			set @where = @where + N'( GRUP_NAME like ''%'+@GRUP_name+'%'' ) ';

			if ( @DEBUG = 1 )
			begin
				print	N'@GRUP_NAME = ' + @GRUP_NAME;
			end
		end
		if ( @where > N'' )
			set @where = N'where ' + @where;
	end
--<
--> Sortierung bestimmen bzw. Standard verwenden
--> set sortation or using standard sortation
	if ( @rc = 0 ) and ( @KZ_USE_RESULTSET = 0 )
	begin
		set @step = N'Sortierung bestimmen.';
		if ( @DEBUG = 1 )	print @step;

		if ( isNull( @ORDER_BY, N'' ) > N'' )
			set @orderby = services.pfn_getSortation( @ORDER_BY );

		if isNull( @orderby, N'' ) = N''
			-- Order by aus den Systemeinstellungen lesen
			set @orderby = services.pfn_getSortation( N'#' + services.pfn_getObjectName( null, @procName ) + N'#' );

		if isNull( @orderby, N'' ) = N''
			set @orderby = N'tis02o.T_GRUPPE.GRUP_NAME ';

		if ( isNull( @orderby, N'' ) > N'' ) and ( left( @orderby, 8 ) <> N'order by' )
			set @orderby = N'order by ' + @orderby + N' ';
	end

	if ( @rc = 0 ) 
	begin
		if ( @KZ_USE_RESULTSET = 0 )
		begin
			set @step = N'ResultSet wird erstellt...';	-- preparing resultset
			if ( @DEBUG = 1 )	print @step;

			set	@sql = 
					-- do not change
					N'if exists( select 1 from ' + @object_name + N' ) truncate table ' + @object_name + '; ' +
					N'insert into ' + @object_name + N'( ' + @tbsh_shortname + N'_ID, ROWNUMBER ) ' +
					-- you have to change only the tablename below
					N'select GRUP_ID, ROW_NUMBER() OVER ( ' + @orderby + N' ) as ROWNUMBER from tis02o.T_GRUPPE ';

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
				-- extending parameters if necessary
				exec sp_executesql 
					-- standard parameters
					@sql,
					@parms,
					@ROWS_TOTAL = @ROWS_TOTAL output,
					--- change or extend below...
					@GRUP_NAME = @GRUP_NAME;

			END TRY
			BEGIN CATCH
				select	@rc = -1, @sql_error = ERROR_NUMBER(),
						@rc_text = N'Beim Erstellen des Ergebnisses ist ein Fehler aufgetreten. ' + ERROR_MESSAGE();

			END CATCH
		end
		else
		begin -- Standardblock, DO NOT CHANGE
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
		end -- Ende Standardblock
	end

--> blättern
--> paging, DO NOT CHANGE
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
--<

--> Erstellen Darstellungsinformationen
--> getting resultset, look for "change" to finding places for modifications
	if ( @rc = 0 )
	begin
		BEGIN TRY
			set @step = N'ResultSet wird ausgegeben...';
			if ( @DEBUG = 1 )	print @step;

			set @sql = 
				N'select top ' + convert( nvarchar(18), @ROWS_MAX ) + N' ' +
				-- change (add) your column list
				N'GRUP_ID, GRUP_NAME, GRUP_PTS, GRUP_#PTS as GRUP_XPTS, GRUP_USER ' +
				-- change tablename T_GRUPPE in ...
				N'from tis02o.T_GRUPPE ' +
				N'join ' + @object_name + N' rs on ( rs.GRUP_ID = tis02o.T_GRUPPE.GRUP_ID ) ' +
				-- do not change
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

--> Standardblock, DO NOT CHANGE
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
					@sql_error,	-- @ERRORNUMBER
					null,		-- @ERRORSEVERITY
					null,		-- @ERRORSTATE
					null,		-- @ERRORLINE
					@procName,	-- @ERRORPROCEDURE
					null,		-- @ERRORMESSAGE
					@rc_text	-- @MSG
				);

		raiserror( @rc_text, 16, 1 );
	end
--< Ende Standardblock

end
GO


