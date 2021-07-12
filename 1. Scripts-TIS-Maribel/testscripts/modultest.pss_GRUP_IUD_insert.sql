

-- STATEMENTS FOR TESTING STORED PROCEDURES


--insert into tis02o.IO_GRUPPE( GRUP_NAME ) values( N'Test' );

declare	@GRUP_id	UDT_ID, @GRUP_user UDT_USER, @GRUP_xpts UDT_#PTS,
	@GRUP_NAME nvarchar(255);

set @GRUP_id = 0;
set @GRUP_user = null;
set	@GRUP_xpts = null;

set @GRUP_NAME = N'Test example ';

begin transaction
begin try

	exec tis02o.pss_GRUP_IUD
		@SESSION_ID	= N'471174114711',
		@USER		= N'MZ',

		@GRUP_ID	= @GRUP_id output,
		@GRUP_USER	= @GRUP_user,
		@GRUP_XPTS	= @GRUP_xpts,

		@AAKT_CODE	= 10,			-- 10 = insert, 20 = update, 30 = logical delete, 90 = physical delete

	--> business columns
		@GRUP_NAME			= @GRUP_NAME,

	-->

	--	@KZ_USE_TRANSACTION		= 0,	-- currently not used
		@DEBUG					= 1		-- only for internal usage

	commit transaction;

end try
begin catch
	rollback transaction;

end catch

select	*
from	tis02o.IO_GRUPPE
GO