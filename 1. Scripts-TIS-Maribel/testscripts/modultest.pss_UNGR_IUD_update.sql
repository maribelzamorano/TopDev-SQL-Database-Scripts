

-- STATEMENTS FOR TESTING STORED PROCEDURES


--update akkradm.IO_UNTERGRUPPE set UNGR_THEMA= N'Test 2' where UNGR_ID=1


declare	@UNGR_id	UDT_ID, @UNGR_user UDT_USER, @UNGR_xpts UDT_#PTS,
	@UNGR_THEMA	nvarchar(255),  @UNGR_DT_BEGINN	datetime,@UNGR_DT_ENDE	datetime,
	@UNGR_MAX_TEILNEHMER	UDT_ANZAHL_I,@UNGR_#DT_BEGINN_ZEIT	UDT_UHRZEIT,@UNGR_#DT_ENDE_ZEIT	UDT_UHRZEIT,
	@UNGR_KZ_GESPERRT	UDT_BOOLEAN,@UNGR_KZ_ANMELDUNG_ZUL	UDT_BOOLEAN,@UNGR_KZ_NICHT_UEBERBUCHBAR UDT_BOOLEAN,
	@UNGR_ANMELDEBLOCK	smallint ,@UNGR_KZ_AUTO_VERGABE	UDT_BOOLEAN_TRUE,@UNGR_TEILNEHMER_ANZAHL UDT_ANZAHL_S;

set @UNGR_id = 3;
set @UNGR_user = 'ThomasStangner';
set	@UNGR_xpts = '2009-10-02 09:45:00.773';


set	@UNGR_THEMA					= N'Test example 2';  
set	@UNGR_DT_BEGINN				= N'2009-10-02';
set	@UNGR_DT_ENDE				= N'2009-10-02';
set	@UNGR_MAX_TEILNEHMER		= 1;
set	@UNGR_#DT_BEGINN_ZEIT		= N'Test';
set	@UNGR_#DT_ENDE_ZEIT			= N'Test';
set	@UNGR_KZ_GESPERRT			= 1;
set	@UNGR_KZ_ANMELDUNG_ZUL		= 1;
set	@UNGR_KZ_NICHT_UEBERBUCHBAR = 1;
set	@UNGR_ANMELDEBLOCK			= 4;
set	@UNGR_KZ_AUTO_VERGABE		= 1;
set	@UNGR_TEILNEHMER_ANZAHL		= 5;


begin transaction
begin try

	exec akkradm.pss_UNGR_IUD
		@SESSION_ID	= N'471174114711',
		@USER		= N'ThomasStangner',

		@UNGR_ID	= @UNGR_id output,
		@UNGR_USER	= @UNGR_user,
		@UNGR_XPTS	= @UNGR_xpts,

		@AAKT_CODE	= 20,			-- 10 = insert, 20 = update, 30 = logical delete, 90 = physical delete

	--> business columns
		@VESG_ID					     = 4711,
--		@UGAR_ID						 = 12,

		@UNGR_THEMA						 = @UNGR_THEMA,
		@UNGR_DT_BEGINN					 = @UNGR_DT_BEGINN,
		@UNGR_DT_ENDE					 = @UNGR_DT_ENDE,
		@UNGR_MAX_TEILNEHMER			 = @UNGR_MAX_TEILNEHMER,
		@UNGR_#DT_BEGINN_ZEIT			 = @UNGR_#DT_BEGINN_ZEIT,
		@UNGR_#DT_ENDE_ZEIT				 = @UNGR_#DT_ENDE_ZEIT,
		@UNGR_KZ_GESPERRT				 = @UNGR_KZ_GESPERRT,
		@UNGR_KZ_ANMELDUNG_ZUL			 = @UNGR_KZ_ANMELDUNG_ZUL,
		@UNGR_KZ_NICHT_UEBERBUCHBAR		 = @UNGR_KZ_NICHT_UEBERBUCHBAR,
		@UNGR_ANMELDEBLOCK				 = @UNGR_ANMELDEBLOCK,
		@UNGR_KZ_AUTO_VERGABE			 = @UNGR_KZ_AUTO_VERGABE,
		@UNGR_TEILNEHMER_ANZAHL			 = @UNGR_TEILNEHMER_ANZAHL,
	-->

	--	@KZ_USE_TRANSACTION		= 0,	-- currently not used
		@DEBUG					= 1		-- only for internal usage

	commit transaction;

end try
begin catch
	rollback transaction;

end catch

select	*
from	akkradm.IO_UNTERGRUPPE
GO