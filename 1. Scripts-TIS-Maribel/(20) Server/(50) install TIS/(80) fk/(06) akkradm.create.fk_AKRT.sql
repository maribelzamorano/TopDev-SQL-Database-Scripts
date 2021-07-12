/*	
 * topdev GmbH, erstellt am 01.10.2009 14:29
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-10-01 14:29:39 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (06) akkradm.create.fk_AKRT.sql $
 *
 */

if exists(	select	1
		from	sysobjects
		where	name = 'FK_AKRT_MAND'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_AKKREDITEUR')
		)

	alter table akkradm.IO_AKKREDITEUR drop constraint FK_AKRT_MAND;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_AKRT_EIGE'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_AKKREDITEUR')
		)

	alter table akkradm.IO_AKKREDITEUR drop constraint FK_AKRT_EIGE;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_AKRT_AKRS'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_AKKREDITEUR')
		)

	alter table akkradm.IO_AKKREDITEUR drop constraint FK_AKRT_AKRS;
GO


--ALTER TABLE akkradm.IO_AKKREDITEUR ADD
-- nicht verwenden	CONSTRAINT FK_AKRT_MAND FOREIGN KEY ( MAND_ID ) REFERENCES akkradm.IO_MANDANT ( MAND_ID ),
-- nicht verwenden	CONSTRAINT FK_AKRT_EIGE FOREIGN KEY ( EIGE_ID ) REFERENCES akkradm.IO_EIGENTUEMER( EIGE_ID ),
--  CONSTRAINT FK_AKRT_AKRS FOREIGN KEY ( AKRS_ID ) REFERENCES akkradm.IO_AKKREDITIERUNGSSTELLE( AKRS_ID )

if exists(	select	1
		from	sysindexes
		where	name = 'AKRT_FK_MAND' 
		and	id = object_id('akkradm.IO_AKKREDITEUR')
		)

	drop index akkradm.IO_AKKREDITEUR.AKRT_FK_MAND;
GO

if exists(	select	1
		from	sysindexes
		where	name = 'AKRT_FK_EIGE' 
		and	id = object_id('akkradm.IO_AKKREDITEUR')
		)

	drop index akkradm.IO_AKKREDITEUR.AKRT_FK_EIGE;
GO

if exists(	select	1
		from	sysindexes
		where	name = 'AKRT_FK_AKRS' 
		and	id = object_id('akkradm.IO_AKKREDITEUR')
		)

	drop index akkradm.IO_AKKREDITEUR.AKRT_FK_AKRS;
GO



-- nicht verwenden CREATE INDEX AKRT_FK_MAND ON akkradm.IO_AKKREDITEUR( MAND_ID );
-- nicht verwenden CREATE INDEX AKRT_FK_EIGE ON akkradm.IO_AKKREDITEUR( EIGE_ID );
CREATE INDEX AKRT_FK_AKRS ON akkradm.IO_AKKREDITEUR( AKRS_ID );

GO


