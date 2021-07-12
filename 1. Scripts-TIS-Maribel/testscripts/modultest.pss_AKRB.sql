
setuser 'akkradm';

exec pss_AKRB
	@SESSION_ID = '1234567890',
	@USER = 'MZ',
	@ROWS_TOTAL = 1,
	@RESULTSET_ID = 'example',
	@GEPA_#NAME_12		= '',
	@ABIE_NUMMER		= '',
	@AKRT_ID			= NULL,
    @DEBUG=1;

setuser;
go



