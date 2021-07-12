

-- STATEMENTS FOR TESTING STORED PROCEDURES


--insert into akkradm.IO_AKKREDITEUR( AKRS_ID,TBSH_SHORTNAME,TBSH_ID ) values( 4711, N'Test',1 );

declare	@AKRT_id	UDT_ID, @AKRT_user UDT_USER, @AKRT_xpts UDT_#PTS,
	@TBSH_SHORTNAME	UDT_TABLENAME_SHORT,@TBSH_ID UDT_ANZAHL_I;

set @AKRT_id = 0;
set @AKRT_user = null;
set	@AKRT_xpts = null;

set @TBSH_SHORTNAME = N'TEST';
set @TBSH_ID        = 4;

begin transaction
begin try

	exec akkradm.pss_AKRT_IUD
		@SESSION_ID	= N'471174114711',
		@USER		= N'MZ',

		@AKRT_ID	= @AKRT_id output,
		@AKRT_USER	= @AKRT_user,
		@AKRT_XPTS	= @AKRT_xpts,

		@AAKT_CODE	= 10,			-- 10 = insert, 20 = update, 30 = logical delete, 90 = physical delete

	--> business columns
		@AKRS_ID				= 4712,

		@TBSH_SHORTNAME			= @TBSH_SHORTNAME,
		@TBSH_ID 				= @TBSH_ID ,
	-->

	--	@KZ_USE_TRANSACTION		= 0,	-- currently not used
		@DEBUG					= 1		-- only for internal usage

	commit transaction;

end try
begin catch
	rollback transaction;

end catch

select	*
from	akkradm.IO_AKKREDITEUR
GO