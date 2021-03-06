
-- STATEMENTS FOR TESTING STORED PROCEDURES


--update akkradm.IO_AKKREDITIERUNGSSTELLE set AKRS_BRIEFFENSTERANSCHRIFT =N'test2' where AKRS_AKKREDITIERUNGSSTELLEID=1;

declare	@AKRS_AKKREDITIERUNGSSTELLEID	UDT_ANZAHL_I, @AKRS_user UDT_USER, @AKRS_xpts UDT_#PTS,
		@AKRS_BRIEFFENSTERANSCHRIFT	nvarchar(255),@AKRS_BRIEFKOPF1	nvarchar(100),@AKRS_BRIEFKOPF2	nvarchar(100),
		@AKRS_BRIEFKOPF3	nvarchar(100),@AKRS_ZUSTAENDIGKEITSBEREICHID	UDT_ANZAHL_I,
		@AKRS_ZUSTAENDIGKEITSBEREICHBEZEICHNUNG nvarchar(200),@AKRS_LOGOID	UDT_ANZAHL_I;

set @AKRS_AKKREDITIERUNGSSTELLEID = 2;
set @AKRS_user = 'ThomasStangner';
set	@AKRS_xpts = '2009-09-30 12:33:20.043';

set @AKRS_BRIEFFENSTERANSCHRIFT				= N'TEST2';
set	@AKRS_BRIEFKOPF1						= N'TEST';
set	@AKRS_BRIEFKOPF2						= N'TEST';
set	@AKRS_BRIEFKOPF3						= N'TEST';
set	@AKRS_ZUSTAENDIGKEITSBEREICHID			= 2;
set	@AKRS_ZUSTAENDIGKEITSBEREICHBEZEICHNUNG = N'TEST';
set	@AKRS_LOGOID							= 7;

begin transaction
begin try

	exec akkradm.pss_AKRS_IUD
		@SESSION_ID	= N'471174114711',
		@USER		= N'ThomasStangner',

		@AKRS_AKKREDITIERUNGSSTELLEID	= @AKRS_AKKREDITIERUNGSSTELLEID output,
		@AKRS_USER	= @AKRS_user,
		@AKRS_XPTS	= @AKRS_xpts,

		@AAKT_CODE	= 20,			-- 10 = insert, 20 = update, 30 = logical delete, 90 = physical delete

	--> business columns
		@DIEN_ID				= 4711,

		@AKRS_BRIEFFENSTERANSCHRIFT				= @AKRS_BRIEFFENSTERANSCHRIFT,
		@AKRS_BRIEFKOPF1						= @AKRS_BRIEFKOPF1,
		@AKRS_BRIEFKOPF2						= @AKRS_BRIEFKOPF2,
		@AKRS_BRIEFKOPF3						= @AKRS_BRIEFKOPF3,
		@AKRS_ZUSTAENDIGKEITSBEREICHID			= @AKRS_ZUSTAENDIGKEITSBEREICHID,
		@AKRS_ZUSTAENDIGKEITSBEREICHBEZEICHNUNG = @AKRS_ZUSTAENDIGKEITSBEREICHBEZEICHNUNG,
		@AKRS_LOGOID							= @AKRS_LOGOID,
			-->

	--	@KZ_USE_TRANSACTION		= 0,	-- currently not used
		@DEBUG					= 1		-- only for internal usage

	commit transaction;

end try
begin catch
	rollback transaction;

end catch

select	*
from	akkradm.IO_AKKREDITIERUNGSSTELLE
GO