

--update akkradm.IO_VERANSTALTUNG_STATUS_HIST set VESH_USER_VEST='M' where VESH_ID=2;

declare	@VESH_id	UDT_ID, @VESH_user UDT_USER, @VESH_xpts UDT_#PTS,
	@VESG_ID		    	UDT_ID,
	@VEST_CODE				UDT_CODE,
	@VESH_PTS_VEST			datetime,
	@VESH_USER_VEST			UDT_USER;

set @VESH_id = 4;
set @VESH_user = 'ThomasStangner';
set	@VESH_xpts = '2009-10-08 11:55:21.147';


set	@VEST_CODE				= '24646345';
set	@VESH_PTS_VEST			= '2009-10-08';
set	@VESH_USER_VEST			= 'MZ2';


begin transaction
begin try

	exec akkradm.pss_VESH_IUD
		@SESSION_ID	= N'471174114711',
		@USER		= N'ThomasStangner',

		@VESH_ID	= @VESH_id output,
		@VESH_USER	= @VESH_user,
		@VESH_XPTS	= @VESH_xpts,

		@AAKT_CODE	= 20,			-- 10 = insert, 20 = update, 30 = logical delete, 90 = physical delete

	--> fachliche Felder


		@VESG_ID		    	= 1,
		@VEST_CODE				= @VEST_CODE,
		@VESH_PTS_VEST			= @VESH_PTS_VEST,
		@VESH_USER_VEST			= @VESH_USER_VEST,

	-->
	--	@KZ_USE_TRANSACTION		= 0,	-- wird derzeit nicht verwendet
		@DEBUG					= 1		-- nur für interne Nutzung

	commit transaction;

end try
begin catch
	rollback transaction;

end catch

select	*
from	akkradm.IO_VERANSTALTUNG_STATUS_HIST
GO