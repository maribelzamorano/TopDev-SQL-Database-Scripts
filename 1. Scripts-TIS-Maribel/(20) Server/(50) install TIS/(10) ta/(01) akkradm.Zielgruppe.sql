/*	
 * topdev GmbH, erstellt am 29.09.2009 13:28
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-09-29 13:28:45 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (01) akkradm.Zielgruppe.sql $
 *
 */

if exists ( select * from sysobjects where id = object_id('akkradm.IO_ZIELGRUPPE') and OBJECTPROPERTY(id, 'IsTable') = 1)
begin
	GOTO createView;
--	drop table akkradm.IO_ZIELGRUPPE;
end;

create table akkradm.IO_ZIELGRUPPE(
	ZIGR_ID				UDT_ID IDENTITY NOT FOR REPLICATION,


	MAND_ID				UDT_MANDANT		NOT NULL,
	EIGE_ID				UDT_EIGENTUEMER	NOT NULL,


	ZIGR_BEZEICHNUNG  nvarchar(255) NOT NULL,

		

	ZIGR_USER			UDT_USER	NOT NULL,
	ZIGR_PTS			UDT_PTS		NOT NULL,
	ZIGR_#PTS			UDT_#PTS	NULL,	
	ZIGR_ID_INT			UDT_ID_0	NOT NULL,
	ZIGR_UQID			UDT_UQID	NOT NULL ROWGUIDCOL,
	ZIGR_KZ_FREIGABE	UDT_BOOLEAN	NOT NULL,
	ZIGR_KZ_REPLIKATION	UDT_BOOLEAN	NOT NULL,
	ZIGR_KZ_GELOESCHT	UDT_BOOLEAN	NOT NULL,
	ZIGR_SORT           UDT_ANZAHL_S NOT NULL,
	ZIGR_GUELTIG_VON	Datetime   NULL,
	ZIGR_GUELTIG_BIS    Datetime   NULL,

	CONSTRAINT PK_ZIGR PRIMARY KEY CLUSTERED( ZIGR_ID )
);

CREATE UNIQUE INDEX ZIGR_IX_01_U ON akkradm.IO_ZIELGRUPPE( ZIGR_UQID );
CREATE INDEX		ZIGR_IX_02	 ON akkradm.IO_ZIELGRUPPE( ZIGR_KZ_GELOESCHT );

createView:

if not exists ( select * from sysobjects where id = object_id('akkradm.T_ZIELGRUPPE') and OBJECTPROPERTY(id, 'IsView') = 1)
begin
	exec( N'create view akkradm.T_ZIELGRUPPE as select * from INFORMATION_SCHEMA.TABLES;' );
end
GO

alter view akkradm.T_ZIELGRUPPE(
		ZIGR_ID,

		ZIGR_BEZEICHNUNG,

		ZIGR_USER,
		ZIGR_PTS,
		ZIGR_#PTS,
		ZIGR_SORT,
		ZIGR_GUELTIG_VON,
		ZIGR_GUELTIG_BIS

) as
select	ZIGR_ID,

		ZIGR_BEZEICHNUNG,

		ZIGR_USER,
		ZIGR_PTS,
		ZIGR_#PTS,
		ZIGR_SORT,
		ZIGR_GUELTIG_VON,
		ZIGR_GUELTIG_BIS

from	akkradm.IO_ZIELGRUPPE
where	ZIGR_KZ_GELOESCHT = 0;

GO
