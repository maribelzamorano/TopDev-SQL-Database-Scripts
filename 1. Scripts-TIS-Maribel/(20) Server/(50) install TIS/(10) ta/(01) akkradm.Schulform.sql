/*	
 * topdev GmbH, erstellt am 29.09.2009 13:28
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-09-29 13:28:45 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (01) akkradm.Schulform.sql $
 *
 */

if exists ( select * from sysobjects where id = object_id('akkradm.IO_SCHULFORM') and OBJECTPROPERTY(id, 'IsTable') = 1)
begin
	GOTO createView;
--	drop table akkradm.IO_SCHULFORM;
end;

create table akkradm.IO_SCHULFORM(
	SCHF_ID				UDT_ID IDENTITY NOT FOR REPLICATION,


	MAND_ID				UDT_MANDANT		NOT NULL,
	EIGE_ID				UDT_EIGENTUEMER	NOT NULL,


	SCHF_BEZEICHNUNG  nvarchar(255) NOT NULL,

			

	SCHF_USER			UDT_USER	NOT NULL,
	SCHF_PTS			UDT_PTS		NOT NULL,
	SCHF_#PTS			UDT_#PTS	NULL,	
	SCHF_ID_INT			UDT_ID_0	NOT NULL,
	SCHF_UQID			UDT_UQID	NOT NULL ROWGUIDCOL,
	SCHF_KZ_FREIGABE	UDT_BOOLEAN	NOT NULL,
	SCHF_KZ_REPLIKATION	UDT_BOOLEAN	NOT NULL,
	SCHF_KZ_GELOESCHT	UDT_BOOLEAN	NOT NULL,
	SCHF_KZ_GESPERRT	UDT_BOOLEAN	NOT NULL,
	SCHF_SORT           UDT_ANZAHL_S NOT NULL,
	SCHF_GUELTIG_VON    Datetime    NULL,
	SCHF_GUELTIG_BIS    Datetime    NULL,



	CONSTRAINT PK_SCHF PRIMARY KEY CLUSTERED( SCHF_ID )
);

CREATE UNIQUE INDEX SCHF_IX_01_U ON akkradm.IO_SCHULFORM( SCHF_UQID );
CREATE INDEX		SCHF_IX_02	 ON akkradm.IO_SCHULFORM( SCHF_KZ_GELOESCHT );

createView:

if not exists ( select * from sysobjects where id = object_id('akkradm.T_SCHULFORM') and OBJECTPROPERTY(id, 'IsView') = 1)
begin
	exec( N'create view akkradm.T_SCHULFORM as select * from INFORMATION_SCHEMA.TABLES;' );
end
GO

alter view akkradm.T_SCHULFORM(
		SCHF_ID,

		SCHF_BEZEICHNUNG,

		SCHF_USER,
		SCHF_PTS,
		SCHF_#PTS,
		SCHF_KZ_GESPERRT,
		SCHF_SORT,
		SCHF_GUELTIG_VON,
		SCHF_GUELTIG_BIS

) as
select	SCHF_ID,

		SCHF_BEZEICHNUNG,

		SCHF_USER,
		SCHF_PTS,
		SCHF_#PTS,
		SCHF_KZ_GESPERRT,
		SCHF_SORT,
		SCHF_GUELTIG_VON,
		SCHF_GUELTIG_BIS

from	akkradm.IO_SCHULFORM
where	SCHF_KZ_GELOESCHT = 0;

GO
