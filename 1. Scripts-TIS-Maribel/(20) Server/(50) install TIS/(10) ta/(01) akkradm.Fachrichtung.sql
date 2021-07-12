/*	
 * topdev GmbH, erstellt am 29.09.2009 13:28
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-09-29 13:28:45 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (01) akkradm.Fachrichtung.sql $
 *
 */

if exists ( select * from sysobjects where id = object_id('akkradm.IO_FACHRICHTUNG') and OBJECTPROPERTY(id, 'IsTable') = 1)
begin
	GOTO createView;
--	drop table akkradm.IO_FACHRICHTUNG;
end;

create table akkradm.IO_FACHRICHTUNG(
	FACH_ID				UDT_ID IDENTITY NOT FOR REPLICATION,


	MAND_ID				UDT_MANDANT		NOT NULL,
	EIGE_ID				UDT_EIGENTUEMER	NOT NULL,


	FACH_BEZEICHNUNG  nvarchar(255)   NOT NULL,
	FACH_KZ_NORMAL 		UDT_BOOLEAN   NOT NULL,
	FACH_KZ_SPF 		UDT_BOOLEAN   NOT NULL,

			

	FACH_USER			UDT_USER	NOT NULL,
	FACH_PTS			UDT_PTS		NOT NULL,
	FACH_#PTS			UDT_#PTS		NULL,
	FACH_ID_INT			UDT_ID_0	NOT NULL,
	FACH_UQID			UDT_UQID	NOT NULL ROWGUIDCOL,
	FACH_KZ_FREIGABE	UDT_BOOLEAN	NOT NULL,
	FACH_KZ_REPLIKATION	UDT_BOOLEAN	NOT NULL,
	FACH_KZ_GELOESCHT	UDT_BOOLEAN	NOT NULL,
	FACH_SORT           UDT_ANZAHL_S NOT NULL,
	FACH_GUELTIG_VON    Datetime    NULL,
	FACH_GUELTIG_BIS    Datetime    NULL,


	CONSTRAINT PK_FACH PRIMARY KEY CLUSTERED( FACH_ID )
);

CREATE UNIQUE INDEX FACH_IX_01_U ON akkradm.IO_FACHRICHTUNG( FACH_UQID );
CREATE INDEX		FACH_IX_02	 ON akkradm.IO_FACHRICHTUNG( FACH_KZ_GELOESCHT );

createView:

if not exists ( select * from sysobjects where id = object_id('akkradm.T_FACHRICHTUNG') and OBJECTPROPERTY(id, 'IsView') = 1)
begin
	exec( N'create view akkradm.T_FACHRICHTUNG as select * from INFORMATION_SCHEMA.TABLES;' );
end
GO

alter view akkradm.T_FACHRICHTUNG(
		FACH_ID,

		FACH_BEZEICHNUNG,
		FACH_KZ_NORMAL,
		FACH_KZ_SPF,

		FACH_USER,
		FACH_PTS,
		FACH_#PTS,
		FACH_SORT,
		FACH_GUELTIG_VON,
		FACH_GUELTIG_BIS

) as
select	FACH_ID,

		FACH_BEZEICHNUNG,
		FACH_KZ_NORMAL,
		FACH_KZ_SPF,

		FACH_USER,
		FACH_PTS,
		FACH_#PTS,
		FACH_SORT,
		FACH_GUELTIG_VON,
		FACH_GUELTIG_BIS

from	akkradm.IO_FACHRICHTUNG
where	FACH_KZ_GELOESCHT = 0;

GO
