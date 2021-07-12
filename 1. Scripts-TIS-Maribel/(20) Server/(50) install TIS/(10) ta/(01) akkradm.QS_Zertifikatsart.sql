/*	
 * topdev GmbH, erstellt am 29.09.2009 13:28
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-09-29 13:28:45 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (01) akkradm.QS_Zertifikatsart.sql $
 *
 */

if exists ( select * from sysobjects where id = object_id('akkradm.IO_QS_ZERTIFIKATSART') and OBJECTPROPERTY(id, 'IsTable') = 1)
begin
	GOTO createView;
--	drop table akkradm.IO_QS_ZERTIFIKATSART;
end;

create table akkradm.IO_QS_ZERTIFIKATSART(
	ZERT_ID				UDT_ID IDENTITY NOT FOR REPLICATION,


	MAND_ID				UDT_MANDANT		NOT NULL,
	EIGE_ID				UDT_EIGENTUEMER	NOT NULL,


	ZERT_BEZEICHNUNG  nvarchar(255) NOT NULL,

		

	ZERT_USER			UDT_USER	NOT NULL,
	ZERT_PTS			UDT_PTS		NOT NULL,
	ZERT_#PTS			UDT_#PTS	NULL,	
	ZERT_ID_INT			UDT_ID_0	NOT NULL,
	ZERT_UQID			UDT_UQID	NOT NULL ROWGUIDCOL,
	ZERT_KZ_FREIGABE	UDT_BOOLEAN	NOT NULL,
	ZERT_KZ_REPLIKATION	UDT_BOOLEAN	NOT NULL,
	ZERT_KZ_GELOESCHT	UDT_BOOLEAN	NOT NULL,
	ZERT_SORT           UDT_ANZAHL_S NOT NULL,
	ZERT_GUELTIG_VON    Datetime    NULL,
	ZERT_GUELTIG_BIS    Datetime    NULL,


	CONSTRAINT PK_ZERT PRIMARY KEY CLUSTERED( ZERT_ID )
);

CREATE UNIQUE INDEX ZERT_IX_01_U ON akkradm.IO_QS_ZERTIFIKATSART( ZERT_UQID );
CREATE INDEX		ZERT_IX_02	 ON akkradm.IO_QS_ZERTIFIKATSART( ZERT_KZ_GELOESCHT );

createView:

if not exists ( select * from sysobjects where id = object_id('akkradm.T_QS_ZERTIFIKATSART') and OBJECTPROPERTY(id, 'IsView') = 1)
begin
	exec( N'create view akkradm.T_QS_ZERTIFIKATSART as select * from INFORMATION_SCHEMA.TABLES;' );
end
GO

alter view akkradm.T_QS_ZERTIFIKATSART(
		ZERT_ID,

		ZERT_BEZEICHNUNG,

		ZERT_USER,
		ZERT_PTS,
		ZERT_#PTS,
		ZERT_SORT,
		ZERT_GUELTIG_VON,
		ZERT_GUELTIG_BIS

) as
select	ZERT_ID,

		ZERT_BEZEICHNUNG,

		ZERT_USER,
		ZERT_PTS,
		ZERT_#PTS,
		ZERT_SORT,
		ZERT_GUELTIG_VON,
		ZERT_GUELTIG_BIS

from	akkradm.IO_QS_ZERTIFIKATSART
where	ZERT_KZ_GELOESCHT = 0;

GO
