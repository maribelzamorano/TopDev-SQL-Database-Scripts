/*	
 * topdev GmbH, erstellt am 28.09.2009 15:42
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-09-28 15:42:31 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (01) akkradm.Schulamtskreis.sql $
 *
 */

if exists ( select * from sysobjects where id = object_id('akkradm.IO_SCHULAMTSKREIS') and OBJECTPROPERTY(id, 'IsTable') = 1)
begin
	GOTO createView;
--	drop table akkradm.IO_SCHULAMTSKREIS;
end;

create table akkradm.IO_SCHULAMTSKREIS(
	KREI_ID				UDT_ID IDENTITY NOT FOR REPLICATION,


	MAND_ID				UDT_MANDANT		NOT NULL,
	EIGE_ID				UDT_EIGENTUEMER	NOT NULL,


	KREI_BEZEICHNUNG		nvarchar(50)	NOT NULL,
	KREI_SCHLUESSEL			smallint		NOT NULL,
		

	KREI_USER			UDT_USER	 NOT NULL,
	KREI_PTS			UDT_PTS		 NOT NULL,
	KREI_#PTS			UDT_#PTS	 NULL,	
	KREI_ID_INT			UDT_ID_0	 NOT NULL,
	KREI_UQID			UDT_UQID	 NOT NULL ROWGUIDCOL,
	KREI_KZ_FREIGABE	UDT_BOOLEAN	 NOT NULL,
	KREI_KZ_REPLIKATION	UDT_BOOLEAN	 NOT NULL,
	KREI_KZ_GELOESCHT	UDT_BOOLEAN	 NOT NULL,
	KREI_SORT           UDT_ANZAHL_S NOT NULL,
	KREI_GUELTIG_VON    Datetime    NULL,
	KREI_GUELTIG_BIS    Datetime    NULL,

	CONSTRAINT PK_KREI PRIMARY KEY CLUSTERED( KREI_ID )
);

CREATE UNIQUE INDEX KREI_IX_01_U ON akkradm.IO_SCHULAMTSKREIS( KREI_UQID );
CREATE INDEX		KREI_IX_02	 ON akkradm.IO_SCHULAMTSKREIS( KREI_KZ_GELOESCHT );

createView:

if not exists ( select * from sysobjects where id = object_id('akkradm.T_SCHULAMTSKREIS') and OBJECTPROPERTY(id, 'IsView') = 1)
begin
	exec( N'create view akkradm.T_SCHULAMTSKREIS as select * from INFORMATION_SCHEMA.TABLES;' );
end
GO

alter view akkradm.T_SCHULAMTSKREIS(
		KREI_ID,

		KREI_BEZEICHNUNG,
		KREI_SCHLUESSEL,

		KREI_USER,
		KREI_PTS,
		KREI_#PTS,
		KREI_SORT,
		KREI_GUELTIG_VON,
		KREI_GUELTIG_BIS

) as
select	KREI_ID,

		KREI_BEZEICHNUNG,
		KREI_SCHLUESSEL,

		KREI_USER,
		KREI_PTS,
		KREI_#PTS,
		KREI_SORT,
		KREI_GUELTIG_VON,
		KREI_GUELTIG_BIS

from	akkradm.IO_SCHULAMTSKREIS
where	KREI_KZ_GELOESCHT = 0;

GO
