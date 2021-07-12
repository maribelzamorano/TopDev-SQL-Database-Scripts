/*	
 * topdev GmbH, erstellt am 01.10.2009 14:29
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-10-01 14:29:39 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (06) akkradm.create.fk_VESG.sql $
 *
 */

if exists(	select	1
		from	sysobjects
		where	name = 'FK_VESG_MAND'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_VERANSTALTUNG')
		)

	alter table akkradm.IO_VERANSTALTUNG drop constraint FK_VESG_MAND;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_VESG_EIGE'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_VERANSTALTUNG')
		)

	alter table akkradm.IO_VERANSTALTUNG drop constraint FK_VESG_EIGE;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_VESG_VOTE'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_VERANSTALTUNG')
		)

	alter table akkradm.IO_VERANSTALTUNG drop constraint FK_VESG_VOTE;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_VESG_ANBO'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_VERANSTALTUNG')
		)

	alter table akkradm.IO_VERANSTALTUNG drop constraint FK_VESG_ANBO;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_VESG_GUEB'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_VERANSTALTUNG')
		)

	alter table akkradm.IO_VERANSTALTUNG drop constraint FK_VESG_GUEB;
GO

if exists(	select	1
		from	sysobjects
		where	name = 'FK_VESG_VERR'
		and	xtype = 'F'
		and	parent_obj = object_id('akkradm.IO_VERANSTALTUNG')
		)

	alter table akkradm.IO_VERANSTALTUNG drop constraint FK_VESG_VERR;
GO


--ALTER TABLE akkradm.IO_VERANSTALTUNG ADD
-- nicht verwenden	CONSTRAINT FK_VESG_MAND FOREIGN KEY ( MAND_ID ) REFERENCES akkradm.IO_MANDANT ( MAND_ID ),
-- nicht verwenden	CONSTRAINT FK_VESG_EIGE FOREIGN KEY ( EIGE_ID ) REFERENCES akkradm.IO_EIGENTUEMER( EIGE_ID ),
--  CONSTRAINT FK_VESG_VOTE FOREIGN KEY ( VOTE_ID ) REFERENCES akkradm.IO_VORLAEUFIGER_TERMIN( VOTE_ID ),
--  CONSTRAINT FK_VESG_ANBO FOREIGN KEY ( ANBO_ID ) REFERENCES akkradm.IO_ANGEBOT( ANBO_ID ),
--	CONSTRAINT FK_VESG_GUEB FOREIGN KEY ( GUEB_ID ) REFERENCES akkradm.IO_GUELTIGKEITSBEREICH( GUEB_ID ),
--	CONSTRAINT FK_VESG_VERR FOREIGN KEY ( VERR_ID ) REFERENCES akkradm.IO_VERANSTALTUNGSART( VERR_ID )

if exists(	select	1
		from	sysindexes
		where	name = 'VESG_FK_MAND' 
		and	id = object_id('akkradm.IO_VERANSTALTUNG')
		)

	drop index akkradm.IO_VERANSTALTUNG.VESG_FK_MAND;
GO

if exists(	select	1
		from	sysindexes
		where	name = 'VESG_FK_EIGE' 
		and	id = object_id('akkradm.IO_VERANSTALTUNG')
		)

	drop index akkradm.IO_VERANSTALTUNG.VESG_FK_EIGE;
GO

if exists(	select	1
		from	sysindexes
		where	name = 'VESG_FK_VOTE' 
		and	id = object_id('akkradm.IO_VERANSTALTUNG')
		)

	drop index akkradm.IO_VERANSTALTUNG.VESG_FK_VOTE;
GO

if exists(	select	1
		from	sysindexes
		where	name = 'VESG_FK_ANBO' 
		and	id = object_id('akkradm.IO_VERANSTALTUNG')
		)

	drop index akkradm.IO_VERANSTALTUNG.VESG_FK_ANBO;
GO

if exists(	select	1
		from	sysindexes
		where	name = 'VESG_FK_GUEB' 
		and	id = object_id('akkradm.IO_VERANSTALTUNG')
		)

	drop index akkradm.IO_VERANSTALTUNG.VESG_FK_GUEB;
GO

if exists(	select	1
		from	sysindexes
		where	name = 'VESG_FK_VERR' 
		and	id = object_id('akkradm.IO_VERANSTALTUNG')
		)

	drop index akkradm.IO_VERANSTALTUNG.VESG_FK_VERR;
GO


-- nicht verwenden CREATE INDEX VESG_FK_MAND ON akkradm.IO_VERANSTALTUNG( MAND_ID );
-- nicht verwenden CREATE INDEX VESG_FK_EIGE ON akkradm.IO_VERANSTALTUNG( EIGE_ID );
CREATE INDEX VESG_FK_VOTE ON akkradm.IO_VERANSTALTUNG( VOTE_ID );
CREATE INDEX VESG_FK_ANBO ON akkradm.IO_VERANSTALTUNG( ANBO_ID );
CREATE INDEX VESG_FK_GUEB ON akkradm.IO_VERANSTALTUNG( GUEB_ID );
CREATE INDEX VESG_FK_VERR ON akkradm.IO_VERANSTALTUNG( VERR_ID );

GO


