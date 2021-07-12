/*	
 * topdev GmbH, erstellt am 29.09.2009 13:28
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-09-29 13:28:45 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (01) akkradm.Gueltigkeitsbereich.sql $
 *
 */

if exists ( select * from sysobjects where id = object_id('akkradm.IO_GUELTIGKEITSBEREICH') and OBJECTPROPERTY(id, 'IsTable') = 1)
begin
	GOTO createView;
--	drop table akkradm.IO_GUELTIGKEITSBEREICH;
end;

create table akkradm.IO_GUELTIGKEITSBEREICH(
	GUEB_ID				UDT_ID IDENTITY NOT FOR REPLICATION,


	MAND_ID				UDT_MANDANT		NOT NULL,
	EIGE_ID				UDT_EIGENTUEMER	NOT NULL,


	GUEB_BEZEICHNUNG    nvarchar(255) NOT NULL,
	GUEB_KZ_ANMELDUNG	UDT_BOOLEAN	  NOT NULL,
			

	GUEB_USER			UDT_USER	NOT NULL,
	GUEB_PTS			UDT_PTS		NOT NULL,
	GUEB_#PTS			UDT_#PTS		NULL,
	GUEB_ID_INT			UDT_ID_0	NOT NULL,
	GUEB_UQID			UDT_UQID	NOT NULL ROWGUIDCOL,
	GUEB_KZ_FREIGABE	UDT_BOOLEAN	NOT NULL,
	GUEB_KZ_REPLIKATION	UDT_BOOLEAN	NOT NULL,
	GUEB_KZ_GELOESCHT	UDT_BOOLEAN	NOT NULL,
	GUEB_SORT           UDT_ANZAHL_S NOT NULL,
	GUEB_GUELTIG_VON    Datetime    NULL,
	GUEB_GUELTIG_BIS    Datetime    NULL,

	CONSTRAINT PK_GUEB PRIMARY KEY CLUSTERED( GUEB_ID )
);

CREATE UNIQUE INDEX GUEB_IX_01_U ON akkradm.IO_GUELTIGKEITSBEREICH( GUEB_UQID );
CREATE INDEX		GUEB_IX_02	 ON akkradm.IO_GUELTIGKEITSBEREICH( GUEB_KZ_GELOESCHT );

createView:

if not exists ( select * from sysobjects where id = object_id('akkradm.T_GUELTIGKEITSBEREICH') and OBJECTPROPERTY(id, 'IsView') = 1)
begin
	exec( N'create view akkradm.T_GUELTIGKEITSBEREICH as select * from INFORMATION_SCHEMA.TABLES;' );
end
GO

alter view akkradm.T_GUELTIGKEITSBEREICH(
		GUEB_ID,

		GUEB_BEZEICHNUNG,
		GUEB_KZ_ANMELDUNG,

		GUEB_USER,
		GUEB_PTS,
		GUEB_#PTS,
		GUEB_SORT,
		GUEB_GUELTIG_VON,
		GUEB_GUELTIG_BIS

) as
select	GUEB_ID,

		GUEB_BEZEICHNUNG,
		GUEB_KZ_ANMELDUNG,

		GUEB_USER,
		GUEB_PTS,
		GUEB_#PTS,
		GUEB_SORT,
		GUEB_GUELTIG_VON,
		GUEB_GUELTIG_BIS

from	akkradm.IO_GUELTIGKEITSBEREICH
where	GUEB_KZ_GELOESCHT = 0;

GO
