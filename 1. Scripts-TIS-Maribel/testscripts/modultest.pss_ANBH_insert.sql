

--insert into akkradm.IO_ANGEBOT_STATUS_HIST(ANBO_ID,ANST_ID,
--						ANBH_BEGRUENDUNG ) values( 1,2,4,1,N'Test');

declare	@ANBH_id	UDT_ID, @ANBH_user UDT_USER, @ANBH_xpts UDT_#PTS,
	@ANBO_ID				UDT_ID,@ANST_ID				UDT_ID,@ANBH_BEGRUENDUNG		nvarchar(1000);

set @ANBH_id = 0;
set @ANBH_user = null;
set	@ANBH_xpts = null;


set	@ANBH_BEGRUENDUNG	= N'Test';


begin transaction
begin try

	exec akkradm.pss_ANBH_IUD
		@SESSION_ID	= N'471174114711',
		@USER		= N'ThomasStangner',

		@ANBH_ID	= @ANBH_id output,
		@ANBH_USER	= @ANBH_user,
		@ANBH_XPTS	= @ANBH_xpts,

		@AAKT_CODE	= 10,			


		@ANBO_ID				= 3,
		@ANST_ID				= 2,
		@ANBH_BEGRUENDUNG		= @ANBH_BEGRUENDUNG,

	-->
	--	@KZ_USE_TRANSACTION		= 0,	
		@DEBUG					= 1		

	commit transaction;

end try
begin catch
	rollback transaction;

end catch

select	*
from	akkradm.IO_ANGEBOT_STATUS_HIST
GO