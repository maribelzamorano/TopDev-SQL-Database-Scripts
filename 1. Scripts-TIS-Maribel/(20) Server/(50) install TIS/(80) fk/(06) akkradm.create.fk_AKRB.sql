/*	
 * topdev GmbH, erstellt am 01.10.2009 14:29
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-10-01 14:29:39 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (06) akkradm.create.fk_AKRB.sql $
 *
 */

if exists(	select	1
		from	sysobjects
		where	name = 'FK_AKRB_MAND'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_AKKREDITIERUNGSBESCHEID')
		)

	alter table akkradm.IO_AKKREDITIERUNGSBESCHEID drop constraint FK_AKRB_MAND;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_AKRB_EIGE'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_AKKREDITIERUNGSBESCHEID')
		)

	alter table akkradm.IO_AKKREDITIERUNGSBESCHEID drop constraint FK_AKRB_EIGE;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_AKRB_ABIE'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_AKKREDITIERUNGSBESCHEID')
		)

	alter table akkradm.IO_AKKREDITIERUNGSBESCHEID drop constraint FK_AKRB_ABIE;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_AKRB_ANBO'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_AKKREDITIERUNGSBESCHEID')
		)

	alter table akkradm.IO_AKKREDITIERUNGSBESCHEID drop constraint FK_AKRB_ANBO;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_AKRB_AKRS'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_AKKREDITIERUNGSBESCHEID')
		)

	alter table akkradm.IO_AKKREDITIERUNGSBESCHEID drop constraint FK_AKRB_AKRS;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_AKRB_AKRA'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_AKKREDITIERUNGSBESCHEID')
		)

	alter table akkradm.IO_AKKREDITIERUNGSBESCHEID drop constraint FK_AKRB_AKRA;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_AKRB_AKRT'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_AKKREDITIERUNGSBESCHEID')
		)

	alter table akkradm.IO_AKKREDITIERUNGSBESCHEID drop constraint FK_AKRB_AKRT;
GO

--ALTER TABLE akkradm.IO_AKKREDITIERUNGSBESCHEID ADD
-- nicht verwenden	CONSTRAINT FK_AKRB_MAND FOREIGN KEY ( MAND_ID ) REFERENCES akkradm.IO_MANDANT ( MAND_ID ),
-- nicht verwenden	CONSTRAINT FK_AKRB_EIGE FOREIGN KEY ( EIGE_ID ) REFERENCES akkradm.IO_EIGENTUEMER( EIGE_ID ),
--  CONSTRAINT FK_AKRB_ABIE FOREIGN KEY ( ABIE_ID ) REFERENCES akkradm.IO_ANBIETER( ABIE_ID ),
--  CONSTRAINT FK_AKRB_ANBO FOREIGN KEY ( ANBO_ID ) REFERENCES akkradm.IO_ANGEBOT( ANBO_ID ),
--	CONSTRAINT FK_AKRB_AKRS FOREIGN KEY ( AKRS_ID ) REFERENCES akkradm.IO_AKKREDITIERUNGSSTELLE( AKRS_AKKREDITIERUNGSSTELLEID ),
--	CONSTRAINT FK_AKRB_AKRA FOREIGN KEY ( AKRA_ID ) REFERENCES akkradm.IO_AKKREDITIERUNGSBESCHEIDART( AKRA_ID ),
--	CONSTRAINT FK_AKRB_AKRT FOREIGN KEY ( AKRT_ID ) REFERENCES akkradm.IO_AKKREDITEUR( AKRT_ID )

if exists(	select	1
		from	sysindexes
		where	name = 'AKRB_FK_MAND' 
		and	id = object_id('akkradm.IO_AKKREDITIERUNGSBESCHEID')
		)

	drop index akkradm.IO_AKKREDITIERUNGSBESCHEID.AKRB_FK_MAND;
GO

if exists(	select	1
		from	sysindexes
		where	name = 'AKRB_FK_EIGE' 
		and	id = object_id('akkradm.IO_AKKREDITIERUNGSBESCHEID')
		)

	drop index akkradm.IO_AKKREDITIERUNGSBESCHEID.AKRB_FK_EIGE;
GO

if exists(	select	1
		from	sysindexes
		where	name = 'AKRB_FK_ABIE' 
		and	id = object_id('akkradm.IO_AKKREDITIERUNGSBESCHEID')
		)

	drop index akkradm.IO_AKKREDITIERUNGSBESCHEID.AKRB_FK_ABIE;
GO

if exists(	select	1
		from	sysindexes
		where	name = 'AKRB_FK_ANBO' 
		and	id = object_id('akkradm.IO_AKKREDITIERUNGSBESCHEID')
		)

	drop index akkradm.IO_AKKREDITIERUNGSBESCHEID.AKRB_FK_ANBO;
GO

if exists(	select	1
		from	sysindexes
		where	name = 'AKRB_FK_AKRS' 
		and	id = object_id('akkradm.IO_AKKREDITIERUNGSBESCHEID')
		)

	drop index akkradm.IO_AKKREDITIERUNGSBESCHEID.AKRB_FK_AKRS;
GO

if exists(	select	1
		from	sysindexes
		where	name = 'AKRB_FK_AKRA' 
		and	id = object_id('akkradm.IO_AKKREDITIERUNGSBESCHEID')
		)

	drop index akkradm.IO_AKKREDITIERUNGSBESCHEID.AKRB_FK_AKRA;
GO
if exists(	select	1
		from	sysindexes
		where	name = 'AKRB_FK_AKRT' 
		and	id = object_id('akkradm.IO_AKKREDITIERUNGSBESCHEID')
		)

	drop index akkradm.IO_AKKREDITIERUNGSBESCHEID.AKRB_FK_AKRT;
GO

-- nicht verwenden CREATE INDEX AKRB_FK_MAND ON akkradm.IO_AKKREDITIERUNGSBESCHEID( MAND_ID );
-- nicht verwenden CREATE INDEX AKRB_FK_EIGE ON akkradm.IO_AKKREDITIERUNGSBESCHEID( EIGE_ID );
CREATE INDEX AKRB_FK_ABIE ON akkradm.IO_AKKREDITIERUNGSBESCHEID( ABIE_ID );
CREATE INDEX AKRB_FK_ANBO ON akkradm.IO_AKKREDITIERUNGSBESCHEID( ANBO_ID );
CREATE INDEX AKRB_FK_AKRS ON akkradm.IO_AKKREDITIERUNGSBESCHEID( AKRS_ID );
CREATE INDEX AKRB_FK_AKRA ON akkradm.IO_AKKREDITIERUNGSBESCHEID( AKRA_ID );
CREATE INDEX AKRB_FK_AKRT ON akkradm.IO_AKKREDITIERUNGSBESCHEID( AKRT_ID );
GO


