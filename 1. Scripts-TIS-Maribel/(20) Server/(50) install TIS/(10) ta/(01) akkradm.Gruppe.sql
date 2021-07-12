/*	
 * topdev GmbH, erstellt am 01.10.2009 11:32
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-10-01 11:32:54 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (01) akkradm.Gruppe.sql $
 *
 */

if exists ( select * from sysobjects where id = object_id('akkradm.IO_GRUPPE') and OBJECTPROPERTY(id, 'IsTable') = 1)
begin
	GOTO createView;
--	drop table akkradm.IO_GRUPPE;
end;

create table akkradm.IO_GRUPPE(
	GRUP_ID				UDT_ID IDENTITY NOT FOR REPLICATION,


	MAND_ID				UDT_MANDANT		NOT NULL,
	EIGE_ID				UDT_EIGENTUEMER	NOT NULL,


	GRUP_NAME				nvarchar(255)	NOT NULL,
	
		

	GRUP_USER			UDT_USER	NOT NULL,
	GRUP_PTS			UDT_PTS		NOT NULL,
	GRUP_#PTS			UDT_#PTS	NULL,	
	GRUP_ID_INT			UDT_ID_0	NOT NULL,
	GRUP_UQID			UDT_UQID	NOT NULL ROWGUIDCOL,
	GRUP_KZ_FREIGABE	UDT_BOOLEAN	NOT NULL,
	GRUP_KZ_REPLIKATION	UDT_BOOLEAN	NOT NULL,
	GRUP_KZ_GELOESCHT	UDT_BOOLEAN	NOT NULL,

	CONSTRAINT PK_GRUP PRIMARY KEY CLUSTERED( GRUP_ID )
);

CREATE UNIQUE INDEX GRUP_IX_01_U ON akkradm.IO_GRUPPE( GRUP_UQID );
CREATE INDEX		GRUP_IX_02	 ON akkradm.IO_GRUPPE( GRUP_KZ_GELOESCHT );

createView:

if not exists ( select * from sysobjects where id = object_id('akkradm.T_GRUPPE') and OBJECTPROPERTY(id, 'IsView') = 1)
begin
	exec( N'create view akkradm.T_GRUPPE as select * from INFORMATION_SCHEMA.TABLES;' );
end
GO

alter view akkradm.T_GRUPPE(
		GRUP_ID,

		GRUP_NAME,

		GRUP_USER,
		GRUP_PTS,
		GRUP_#PTS

) as
select	GRUP_ID,

		GRUP_NAME,

		GRUP_USER,
		GRUP_PTS,
		GRUP_#PTS

from	akkradm.IO_GRUPPE
where	GRUP_KZ_GELOESCHT = 0;

GO
