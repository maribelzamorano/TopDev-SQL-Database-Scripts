-- STATEMENTS FOR TESTING STORED PROCEDURES

--insert into akkradm.IO_VERANSTALTUNG(VESG_NR,VESG_NR2,VESG_KZABRUFVERANSTALTUNG,VESG_KZVORLAEUFIGERTERMIN,
--					VESG_KZFESTERTERMIN,VESG_AUFABRUFBIS,VOTE_ID,VESG_BEGINN,VESG_#BEGINN_ZEIT,VESG_ENDE,
--					VESG_#ENDE_ZEIT,VESG_THEMA,GUEB_ID,VERR_ID,VESG_TEILNEHMERBEITRAG,VESG_VERANSTALTUNGORT,
--					VESG_ANMELDESCHLUSS,VESG_LEITUNG,VESG_DOZENTEN,VESG_ZWISCHENTERMINE,VESG_ZUSATZINFORMATIONEN,
--					VEST_CODE) values(N'Test',N'Test', 1,1,1,'2009-09-29',1,'2009-09-29', 
--					N'Test','2009-09-29',N'Test',N'Test',N'Test',N'Test',
--					1,N'Test example 2','2009-09-29',N'Test example 2',N'Test example 2',N'Test example 2',N'Test example 2'
--					,N'Test example 2');

declare	@VESG_id	UDT_ID, @VESG_user UDT_USER, @VESG_xpts UDT_#PTS,
	@VESG_NR nvarchar(10),@VESG_NR2	nvarchar(25),@VESG_KZABRUFVERANSTALTUNG   UDT_BOOLEAN,@VESG_KZVORLAEUFIGERTERMIN UDT_BOOLEAN,
	@VESG_KZFESTERTERMIN UDT_BOOLEAN,@VESG_AUFABRUFBIS	datetime,@VOTE_ID	UDT_ANZAHL_I, @VESG_BEGINN	datetime,
	@VESG_#BEGINN_ZEIT	UDT_UHRZEIT,@VESG_ENDE	datetime,@VESG_#ENDE_ZEIT             UDT_UHRZEIT,
	@VESG_THEMA	nvarchar(500),@GUEB_ID						nvarchar(25),@VERR_ID nvarchar(25),@VESG_TEILNEHMERBEITRAG	UDT_BETRAG,
	@VESG_VERANSTALTUNGORT	nvarchar(255),@VESG_ANMELDESCHLUSS	datetime,@VESG_LEITUNG	nvarchar(4000),
	@VESG_DOZENTEN	nvarchar(4000),@VESG_ZWISCHENTERMINE nvarchar(255),@VESG_ZUSATZINFORMATIONEN	nvarchar(500),@VEST_CODE nvarchar(25);

set @VESG_id = 0;
set @VESG_user = null;
set	@VESG_xpts = null;

	set @VESG_NR					= N'Test';
	set @VESG_NR2					= N'Test';
	set @VESG_KZABRUFVERANSTALTUNG	= 1;
	set @VESG_KZVORLAEUFIGERTERMIN	= 1;
	set @VESG_KZFESTERTERMIN	    = 1;
	set @VESG_AUFABRUFBIS			= '2009-09-29';
	set @VOTE_ID					= 1; 
	set @VESG_BEGINN				= '2009-09-29';
	set @VESG_#BEGINN_ZEIT			= N'Test';
	set @VESG_ENDE					= '2009-09-29';
	set @VESG_#ENDE_ZEIT			= N'Test';
	set @VESG_THEMA					= N'Test';
	set @GUEB_ID					= N'Test';
	set @VERR_ID					= N'Test';
	set @VESG_TEILNEHMERBEITRAG		= 1;
	set @VESG_VERANSTALTUNGORT		= N'Test example 2';
	set @VESG_ANMELDESCHLUSS		= '2009-09-29';
	set @VESG_LEITUNG				= N'Test example 2';
	set @VESG_DOZENTEN				= N'Test example 2';
	set @VESG_ZWISCHENTERMINE		= N'Test example 2';
	set @VESG_ZUSATZINFORMATIONEN	= N'Test example 2';
	set @VEST_CODE					= N'Test example 2';
	

begin transaction
begin try

	exec akkradm.pss_VESG_IUD
		@SESSION_ID	= N'471174114712',
		@USER		= N'MZ',

		@VESG_ID	= @VESG_id output,
		@VESG_USER	= @VESG_user,
		@VESG_XPTS	= @VESG_xpts,

		@AAKT_CODE	= 10,			-- 10 = insert, 20 = update, 30 = logical delete, 90 = physical delete

	--> business columns

	
			 
			@VESG_NR					= @VESG_NR,
			@VESG_NR2					= @VESG_NR2,
			@VESG_KZABRUFVERANSTALTUNG	= @VESG_KZABRUFVERANSTALTUNG,
			@VESG_KZVORLAEUFIGERTERMIN	= @VESG_KZVORLAEUFIGERTERMIN,
			@VESG_KZFESTERTERMIN		= @VESG_KZFESTERTERMIN,
			@VESG_AUFABRUFBIS			= @VESG_AUFABRUFBIS,
			@VOTE_ID					= @VOTE_ID ,
			@VESG_BEGINN				= @VESG_BEGINN ,
			@VESG_#BEGINN_ZEIT			= @VESG_#BEGINN_ZEIT,
			@VESG_ENDE					= @VESG_ENDE,
			@VESG_#ENDE_ZEIT			= @VESG_#ENDE_ZEIT,
			@VESG_THEMA					= @VESG_THEMA,
			@GUEB_ID					= @GUEB_ID,
			@VERR_ID					= @VERR_ID ,
			@VESG_TEILNEHMERBEITRAG		= @VESG_TEILNEHMERBEITRAG,
			@VESG_VERANSTALTUNGORT		= @VESG_VERANSTALTUNGORT,
			@VESG_ANMELDESCHLUSS		= @VESG_ANMELDESCHLUSS,
			@VESG_LEITUNG				= @VESG_LEITUNG,
			@VESG_DOZENTEN			    = @VESG_DOZENTEN,
			@VESG_ZWISCHENTERMINE		= @VESG_ZWISCHENTERMINE,
			@VESG_ZUSATZINFORMATIONEN	= @VESG_ZUSATZINFORMATIONEN,
			@VEST_CODE				    = @VEST_CODE,	
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
from	akkradm.IO_VERANSTALTUNG
GO