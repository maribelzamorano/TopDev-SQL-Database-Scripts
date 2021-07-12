/*	
 * topdev GmbH, erstellt am 29.09.2009 13:28
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-09-29 13:28:45 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (01) akkradm.Register.sql $
 *
 */

if exists ( select * from sysobjects where id = object_id('akkradm.IO_REGISTER') and OBJECTPROPERTY(id, 'IsTable') = 1)
begin
	GOTO createView;
--	drop table akkradm.IO_REGISTER;
end;

create table akkradm.IO_REGISTER(
	REGI_ID				UDT_ID IDENTITY NOT FOR REPLICATION,


	MAND_ID				UDT_MANDANT		NOT NULL,
	EIGE_ID				UDT_EIGENTUEMER	NOT NULL,


	REGI_BEZEICHNUNG  nvarchar(255) NOT NULL,

		

	REGI_USER			UDT_USER	NOT NULL,
	REGI_PTS			UDT_PTS		NOT NULL,
	REGI_#PTS			UDT_#PTS		NULL,
	REGI_ID_INT			UDT_ID_0	NOT NULL,
	REGI_UQID			UDT_UQID	NOT NULL ROWGUIDCOL,
	REGI_KZ_FREIGABE	UDT_BOOLEAN	NOT NULL,
	REGI_KZ_REPLIKATION	UDT_BOOLEAN	NOT NULL,
	REGI_KZ_GELOESCHT	UDT_BOOLEAN	NOT NULL,
	REGI_SORT           UDT_ANZAHL_S NOT NULL,
	REGI_GUELTIG_VON    Datetime    NULL,
	REGI_GUELTIG_BIS    Datetime    NULL,



	CONSTRAINT PK_REGI PRIMARY KEY CLUSTERED( REGI_ID )
);

CREATE UNIQUE INDEX REGI_IX_01_U ON akkradm.IO_REGISTER( REGI_UQID );
CREATE INDEX		REGI_IX_02	 ON akkradm.IO_REGISTER( REGI_KZ_GELOESCHT );

createView:

if not exists ( select * from sysobjects where id = object_id('akkradm.T_REGISTER') and OBJECTPROPERTY(id, 'IsView') = 1)
begin
	exec( N'create view akkradm.T_REGISTER as select * from INFORMATION_SCHEMA.TABLES;' );
end
GO

alter view akkradm.T_REGISTER(
		REGI_ID,

		REGI_BEZEICHNUNG,

		REGI_USER,
		REGI_PTS,
		REGI_#PTS,
		REGI_SORT,
		REGI_GUELTIG_VON,
		REGI_GUELTIG_BIS

) as
select	REGI_ID,

		REGI_BEZEICHNUNG,

		REGI_USER,
		REGI_PTS,
		REGI_#PTS,
		REGI_SORT,
		REGI_GUELTIG_VON,
		REGI_GUELTIG_BIS

from	akkradm.IO_REGISTER
where	REGI_KZ_GELOESCHT = 0;

GO
