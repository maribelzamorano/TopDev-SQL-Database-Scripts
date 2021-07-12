/*	
 * topdev GmbH, erstellt am 29.09.2009 13:28
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-09-29 13:28:45 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (01) akkradm.Schwerpunkt.sql $
 *
 */

if exists ( select * from sysobjects where id = object_id('akkradm.IO_SCHWERPUNKT') and OBJECTPROPERTY(id, 'IsTable') = 1)
begin
	GOTO createView;
--	drop table akkradm.IO_SCHWERPUNKT;
end;

create table akkradm.IO_SCHWERPUNKT(
	SCHW_ID				UDT_ID IDENTITY NOT FOR REPLICATION,


	MAND_ID				UDT_MANDANT		NOT NULL,
	EIGE_ID				UDT_EIGENTUEMER	NOT NULL,


	SCHW_BEZEICHNUNG  nvarchar(255) NOT NULL,

		

	SCHW_USER			UDT_USER	NOT NULL,
	SCHW_PTS			UDT_PTS		NOT NULL,
	SCHW_#PTS			UDT_#PTS	NULL,	
	SCHW_ID_INT			UDT_ID_0	NOT NULL,
	SCHW_UQID			UDT_UQID	NOT NULL ROWGUIDCOL,
	SCHW_KZ_FREIGABE	UDT_BOOLEAN	NOT NULL,
	SCHW_KZ_REPLIKATION	UDT_BOOLEAN	NOT NULL,
	SCHW_KZ_GELOESCHT	UDT_BOOLEAN	NOT NULL,
	SCHW_SORT           UDT_ANZAHL_S NOT NULL,
	SCHW_GUELTIG_VON	Datetime   NULL,
	SCHW_GUELTIG_BIS    Datetime   NULL,



	CONSTRAINT PK_SCHW PRIMARY KEY CLUSTERED( SCHW_ID )
);

CREATE UNIQUE INDEX SCHW_IX_01_U ON akkradm.IO_SCHWERPUNKT( SCHW_UQID );
CREATE INDEX		SCHW_IX_02	 ON akkradm.IO_SCHWERPUNKT( SCHW_KZ_GELOESCHT );

createView:

if not exists ( select * from sysobjects where id = object_id('akkradm.T_SCHWERPUNKT') and OBJECTPROPERTY(id, 'IsView') = 1)
begin
	exec( N'create view akkradm.T_SCHWERPUNKT as select * from INFORMATION_SCHEMA.TABLES;' );
end
GO

alter view akkradm.T_SCHWERPUNKT(
		SCHW_ID,

		SCHW_BEZEICHNUNG,

		SCHW_USER,
		SCHW_PTS,
		SCHW_#PTS,
		SCHW_SORT,
		SCHW_GUELTIG_VON,
		SCHW_GUELTIG_BIS

) as
select	SCHW_ID,

		SCHW_BEZEICHNUNG,

		SCHW_USER,
		SCHW_PTS,
		SCHW_#PTS,
		SCHW_SORT,
		SCHW_GUELTIG_VON,
		SCHW_GUELTIG_BIS

from	akkradm.IO_SCHWERPUNKT
where	SCHW_KZ_GELOESCHT = 0;

GO


	