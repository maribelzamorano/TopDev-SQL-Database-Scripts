

-- STATEMENTS FOR TESTING STORED PROCEDURES


--update akkradm.IO_AKKREDITIERUNGSBESCHEID set AKRA_ID=5 where AKRB_ID=1;

declare	@AKRB_id	UDT_ID, @AKRB_user UDT_USER, @AKRB_xpts UDT_#PTS,
	@ABIE_ID UDT_ID,@ANBO_ID UDT_ID,@AKRS_ID UDT_ID,@AKRA_ID UDT_ID,@AKRT_ID UDT_ID;

set @AKRB_id = 2;
set @AKRB_user = 'MZ';
set	@AKRB_xpts = '2009-10-06 14:33:18.300';



begin transaction
begin try

	exec akkradm.pss_AKRB_IUD
		@SESSION_ID	= N'471174114711',
		@USER		= N'MZ',

		@AKRB_ID	= @AKRB_id output,
		@AKRB_USER	= @AKRB_user,
		@AKRB_XPTS	= @AKRB_xpts,

		@AAKT_CODE	= 20,			-- 10 = insert, 20 = update, 30 = logical delete, 90 = physical delete

	--> business columns
		@ABIE_ID = 2,
		@ANBO_ID = 2,
		@AKRS_ID = 2,
		@AKRA_ID = 2,
		@AKRT_ID = 2,
	-->

	--	@KZ_USE_TRANSACTION		= 0,	-- currently not used
		@DEBUG					= 1		-- only for internal usage

	commit transaction;

end try
begin catch
	rollback transaction;

end catch

select	*
from	akkradm.IO_AKKREDITIERUNGSBESCHEID
GO