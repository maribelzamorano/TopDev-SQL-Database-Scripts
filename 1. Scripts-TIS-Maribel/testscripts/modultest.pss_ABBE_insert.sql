

--insert into akkradm.IO_ANBIETER_BENUTZER( ABIE_ID,TBSH_SHORTNAME,ABBE_KZ_ZUGEORD_DURCH_ABIE,
--						TBSH_ID,TBSH_BEZEICHNUNG,TBSH_LOGINID ) values( 1,2,4,'abbe',1,1, N'Test', N'Test' );

declare	@ABBE_id	UDT_ID, @ABBE_user UDT_USER, @ABBE_xpts UDT_#PTS,
	@ABIE_ID	UDT_ID,
	@TBSH_SHORTNAME	UDT_TABLENAME_SHORT,@ABBE_KZ_ZUGEORD_DURCH_ABIE	UDT_BOOLEAN,
	@TBSH_ID	UDT_ID,@TBSH_BEZEICHNUNG	nvarchar(200),@TBSH_LOGINID	nvarchar(128);

set @ABBE_id = 0;
set @ABBE_user = null;
set	@ABBE_xpts = null;



set	@TBSH_SHORTNAME					= 'ABBE';
set	@ABBE_KZ_ZUGEORD_DURCH_ABIE		= 1;
set	@TBSH_ID						= 1;
set	@TBSH_BEZEICHNUNG				= N'Test2';
set	@TBSH_LOGINID					= N'Test2';


begin transaction
begin try

	exec akkradm.pss_ABBE_IUD
		@SESSION_ID	= N'471174114711',
		@USER		= N'ThomasStangner',

		@ABBE_ID	= @ABBE_id output,
		@ABBE_USER	= @ABBE_user,
		@ABBE_XPTS	= @ABBE_xpts,

		@AAKT_CODE	= 10,			-- 10 = insert, 20 = update, 30 = logical delete, 90 = physical delete

	--> fachliche Felder


		@ABIE_ID						= 1,

		@TBSH_SHORTNAME					= @TBSH_SHORTNAME	,
		@ABBE_KZ_ZUGEORD_DURCH_ABIE		= @ABBE_KZ_ZUGEORD_DURCH_ABIE,
		@TBSH_ID						= @TBSH_ID,
		@TBSH_BEZEICHNUNG				= @TBSH_BEZEICHNUNG,
		@TBSH_LOGINID					= @TBSH_LOGINID,

	-->
	--	@KZ_USE_TRANSACTION		= 0,	-- wird derzeit nicht verwendet
		@DEBUG					= 1		-- nur für interne Nutzung

	commit transaction;

end try
begin catch
	rollback transaction;

end catch

select	*
from	akkradm.IO_ANBIETER_BENUTZER
GO