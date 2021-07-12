-- STATEMENTS FOR TESTING STORED PROCEDURES


--insert into akkradm.IO_SCHULAMTSKREIS(@KREI_BEZEICHNUNG,@KREI_SCHLUESSEL) values( N'Test example 2', 12 );

declare	@KREI_id	UDT_ID, @KREI_user UDT_USER, @KREI_xpts UDT_#PTS,
	@KREI_BEZEICHNUNG nvarchar(50),@KREI_SCHLUESSEL SMALLINT;

set @KREI_id = 0;
set @KREI_user = null;
set	@KREI_xpts = null;

	set @KREI_BEZEICHNUNG	= N'Test example 2' + convert( nvarchar(16), getdate(), 121 );
	set @KREI_SCHLUESSEL	= 12;
	

begin transaction
begin try

	exec akkradm.pss_KREI_IUD
		@SESSION_ID	= N'471174114712',
		@USER		= N'MZ',

		@KREI_ID	= @KREI_id output,
		@KREI_USER	= @KREI_user,
		@KREI_XPTS	= @KREI_xpts,

		@AAKT_CODE	= 10,			-- 10 = insert, 20 = update, 30 = logical delete, 90 = physical delete

	--> business columns

	
			 
		@KREI_BEZEICHNUNG	= @KREI_BEZEICHNUNG,
		@KREI_SCHLUESSEL    = @KREI_SCHLUESSEL,				
	-->

	--	@KZ_USE_TRANSACTION		= 0,	-- currently not used
		@DEBUG					= 1		-- only for internal usage

	commit transaction;

end try
begin catch
	rollback transaction;
	execute psp_error 
end catch

select	*
from	akkradm.IO_SCHULAMTSKREIS
GO