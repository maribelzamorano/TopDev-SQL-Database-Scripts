/*	
 * topdev GmbH, erstellt am 01.10.2009 14:29
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-10-01 14:29:39 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (06) akkradm.create.fk_AKRS.sql $
 *
 */

if exists(	select	1
		from	sysobjects
		where	name = 'FK_AKRS_MAND'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_AKKREDITIERUNGSSTELLE')
		)

	alter table akkradm.IO_AKKREDITIERUNGSSTELLE drop constraint FK_AKRS_MAND;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_AKRS_EIGE'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_AKKREDITIERUNGSSTELLE')
		)

	alter table akkradm.IO_AKKREDITIERUNGSSTELLE drop constraint FK_AKRS_EIGE;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_AKRS_DIEN'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_AKKREDITIERUNGSSTELLE')
		)

	alter table akkradm.IO_AKKREDITIERUNGSSTELLE drop constraint FK_AKRS_DIEN;
GO


--ALTER TABLE akkradm.IO_AKKREDITIERUNGSSTELLE ADD
-- nicht verwenden	CONSTRAINT FK_AKRS_MAND FOREIGN KEY ( MAND_ID ) REFERENCES akkradm.IO_MANDANT ( MAND_ID ),
-- nicht verwenden	CONSTRAINT FK_AKRS_EIGE FOREIGN KEY ( EIGE_ID ) REFERENCES akkradm.IO_EIGENTUEMER( EIGE_ID ),
--  CONSTRAINT FK_AKRS_DIEN FOREIGN KEY ( DIEN_ID ) REFERENCES akkradm.IO_DIENSTSTELLE( DIEN_ID )

if exists(	select	1
		from	sysindexes
		where	name = 'AKRS_FK_MAND' 
		and	id = object_id('akkradm.IO_AKKREDITIERUNGSSTELLE')
		)

	drop index akkradm.IO_AKKREDITIERUNGSSTELLE.AKRS_FK_MAND;
GO

if exists(	select	1
		from	sysindexes
		where	name = 'AKRS_FK_EIGE' 
		and	id = object_id('akkradm.IO_AKKREDITIERUNGSSTELLE')
		)

	drop index akkradm.IO_AKKREDITIERUNGSSTELLE.AKRS_FK_EIGE;
GO

if exists(	select	1
		from	sysindexes
		where	name = 'AKRS_FK_DIEN' 
		and	id = object_id('akkradm.IO_AKKREDITIERUNGSSTELLE')
		)

	drop index akkradm.IO_AKKREDITIERUNGSSTELLE.AKRS_FK_DIEN;
GO


-- nicht verwenden CREATE INDEX AKRS_FK_MAND ON akkradm.IO_AKKREDITIERUNGSSTELLE( MAND_ID );
-- nicht verwenden CREATE INDEX AKRS_FK_EIGE ON akkradm.IO_AKKREDITIERUNGSSTELLE( EIGE_ID );
CREATE INDEX AKRS_FK_DIEN ON akkradm.IO_AKKREDITIERUNGSSTELLE( DIEN_ID );

GO


