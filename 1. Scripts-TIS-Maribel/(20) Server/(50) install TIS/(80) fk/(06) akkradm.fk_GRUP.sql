/*	
 * topdev GmbH, erstellt am 05.10.2009 10:00
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-10-05 10:17:26 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (06) tis02o.create.fk_GRUP.sql $
 *
 */

if exists(	select	1
		from	sysobjects
		where	name = 'FK_GRUP_MAND'
		and	xtype = 'F'
		and	parent_obj = object_id('tis02o.IO_GRUPPE')
		)

	alter table tis02o.IO_GRUPPE drop constraint FK_GRUP_MAND;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_GRUP_EIGE'
		and	xtype = 'F'
		and	parent_obj = object_id('tis02o.IO_GRUPPE')
		)

	alter table tis02o.IO_GRUPPE drop constraint FK_GRUP_EIGE;
GO


--ALTER TABLE tis02o.IO_GRUPPE ADD
-- CONSTRAINT FK_GRUP_MAND FOREIGN KEY ( MAND_ID ) REFERENCES tis02o.IO_MANDANT ( MAND_ID ),
-- CONSTRAINT FK_GRUP_EIGE FOREIGN KEY ( EIGE_ID ) REFERENCES tis02o.IO_EIGENTUEMER( EIGE_ID )
GO

if exists(	select	1
		from	sysindexes
		where	name = 'GRUP_FK_MAND' 
		and	id = object_id('tis02o.IO_GRUPPE')
		)

	drop index tis02o.IO_GRUPPE.GRUP_FK_MAND;
GO

if exists(	select	1
		from	sysindexes
		where	name = 'GRUP_FK_EIGE' 
		and	id = object_id('tis02o.IO_GRUPPE')
		)

	drop index tis02o.IO_GRUPPE.GRUP_FK_EIGE;
GO


-- CREATE INDEX GRUP_FK_MAND ON tis02o.IO_GRUPPE( MAND_ID );
-- CREATE INDEX GRUP_FK_EIGE ON tis02o.IO_GRUPPE( EIGE_ID );

GO

