

--insert into akkradm.IO_ANBIETER_STATUS_HIST( ABIE_ID,ABST_ID,
--						ABSH_BEGRUENDUNG ) values( 1,2,4,2, N'Test');

declare	@ABSH_id	UDT_ID, @ABSH_user UDT_USER, @ABSH_xpts UDT_#PTS,
		@ABIE_ID UDT_ID,@ABST_ID UDT_ID,@ABSH_BEGRUENDUNG nvarchar(1000);

set @ABSH_id = 0;
set @ABSH_user = null;
set	@ABSH_xpts = null;


set	@ABSH_BEGRUENDUNG	=N'TEST';



begin transaction
begin try

	exec akkradm.pss_ABSH_IUD
		@SESSION_ID	= N'471174114711',
		@USER		= N'MZ',

		@ABSH_ID	= @ABSH_id output,
		@ABSH_USER	= @ABSH_user,
		@ABSH_XPTS	= @ABSH_xpts,

		@AAKT_CODE	= 10,			


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