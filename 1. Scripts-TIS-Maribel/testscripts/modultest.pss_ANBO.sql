
setuser 'akkradm';

exec pss_ANBO
	@SESSION_ID = '1234567890',
	@USER = 'MZ',
	@ROWS_TOTAL = 1,
	@RESULTSET_ID = 'example',
	@GEPA_#NAME_12		= '',
	@ABIE_NUMMER		= '',
	@ANST_ID			= NULL,
	@ANBO_PTS_ANSTVON		= NULL,
	@ANBO_PTS_ANSTBIS			= NULL,
	@ANBO_NUMMER		= null,
	@ANBO_NUMMER_ABIE	= '',
	@ANBO_THEMA	= '';

setuser;
go


