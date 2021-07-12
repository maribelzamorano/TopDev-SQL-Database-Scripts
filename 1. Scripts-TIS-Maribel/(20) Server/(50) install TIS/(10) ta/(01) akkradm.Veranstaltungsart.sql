/*	
 * topdev GmbH, erstellt am 29.09.2009 13:28
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-09-29 13:28:45 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (01) akkradm.Veranstaltungsart.sql $
 *
 */

if exists ( select * from sysobjects where id = object_id('akkradm.IO_VERANSTALTUNGSART') and OBJECTPROPERTY(id, 'IsTable') = 1)
begin
	GOTO createView;
--	drop table akkradm.IO_VERANSTALTUNGSART;
end;

create table akkradm.IO_VERANSTALTUNGSART(
	VERR_ID				UDT_ID IDENTITY NOT FOR REPLICATION,


	MAND_ID				UDT_MANDANT		NOT NULL,
	EIGE_ID				UDT_EIGENTUEMER	NOT NULL,


	VERR_BEZEICHNUNG  nvarchar(255) NOT NULL,

			

	VERR_USER			UDT_USER	NOT NULL,
	VERR_PTS			UDT_PTS		NOT NULL,
	VERR_#PTS			UDT_#PTS	NULL,	
	VERR_ID_INT			UDT_ID_0	NOT NULL,
	VERR_UQID			UDT_UQID	NOT NULL ROWGUIDCOL,
	VERR_KZ_FREIGABE	UDT_BOOLEAN	NOT NULL,
	VERR_KZ_REPLIKATION	UDT_BOOLEAN	NOT NULL,
	VERR_KZ_GELOESCHT	UDT_BOOLEAN	NOT NULL,
	VERR_SORT           UDT_ANZAHL_S NOT NULL,
	VERR_GUELTIG_VON	Datetime   NULL,
	VERR_GUELTIG_BIS    Datetime   NULL,

	CONSTRAINT PK_VERR PRIMARY KEY CLUSTERED( VERR_ID )
);

CREATE UNIQUE INDEX VERR_IX_01_U ON akkradm.IO_VERANSTALTUNGSART( VERR_UQID );
CREATE INDEX		VERR_IX_02	 ON akkradm.IO_VERANSTALTUNGSART( VERR_KZ_GELOESCHT );

createView:

if not exists ( select * from sysobjects where id = object_id('akkradm.T_VERANSTALTUNGSART') and OBJECTPROPERTY(id, 'IsView') = 1)
begin
	exec( N'create view akkradm.T_VERANSTALTUNGSART as select * from INFORMATION_SCHEMA.TABLES;' );
end
GO

alter view akkradm.T_VERANSTALTUNGSART(
		VERR_ID,

		VERR_BEZEICHNUNG,

		VERR_USER,
		VERR_PTS,
		VERR_#PTS,
		VERR_SORT,
		VERR_GUELTIG_VON,
		VERR_GUELTIG_BIS

) as
select	VERR_ID,

		VERR_BEZEICHNUNG,

		VERR_USER,
		VERR_PTS,
		VERR_#PTS,
		VERR_SORT,
		VERR_GUELTIG_VON,
		VERR_GUELTIG_BIS

from	akkradm.IO_VERANSTALTUNGSART
where	VERR_KZ_GELOESCHT = 0;

GO
