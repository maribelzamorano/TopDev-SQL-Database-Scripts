

--delete from akkradm.IO_ANBIETER_STATUS_HIST where ABSH_ID=1;

declare	@ABSH_id	UDT_ID, @ABSH_user UDT_USER, @ABSH_xpts UDT_#PTS,
		@ABIE_ID UDT_ID,@ABST_ID UDT_ID,@ABSH_BEGRUENDUNG nvarchar(1000);

set @ABSH_id = 3;
set @ABSH_user = 'MZ';
set	@ABSH_xpts = '2009-10-06 09:28:57.490';


set	@ABSH_BEGRUENDUNG	=N'TEST2';



begin transaction
begin try

	exec akkradm.pss_ABSH_IUD
		@SESSION_ID	= N'471174114711',
		@USER		= N'MZ',

		@ABSH_ID	= @ABSH_id output,
		@ABSH_USER	= @ABSH_user,
		@ABSH_XPTS	= @ABSH_xpts,

		@AAKT_CODE	= 30,			


		@ABIE_ID				= 4,
		@ABST_ID				= 2,
		@ABSH_BEGRUENDUNG		= @ABSH_BEGRUENDUNG,


	-->
	--	@KZ_USE_TRANSACTION		= 0,	
		@DEBUG					= 1		

	commit transaction;

end try
begin catch
	rollback transaction;

end catch

select	*
from	akkradm.IO_ANBIETER_STATUS_HIST
GO