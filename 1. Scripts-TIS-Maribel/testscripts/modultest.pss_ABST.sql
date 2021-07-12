
setuser 'akkradm';

exec pss_ABST
	@SESSION_ID = '1234567890',
	@USER = 'MZ',
	@ROWS_TOTAL = 1,
	@RESULTSET_ID = 'example',
	@ABST_ID            = NULL,
	@GEPA_#NAME_12		= '',
	@ABIE_NUMMER		= '',
    @DEBUG=1;

setuser;
go



