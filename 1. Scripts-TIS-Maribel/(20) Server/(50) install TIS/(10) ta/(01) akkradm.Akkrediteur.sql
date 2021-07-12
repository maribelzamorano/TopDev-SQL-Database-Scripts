/*	
 * topdev GmbH, erstellt am 30.09.2009 16:08
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-09-30 16:09:03 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (01) akkradm.Akkrediteur.sql $
 *
 */

if exists ( select * from sysobjects where id = object_id('akkradm.IO_AKKREDITEUR') and OBJECTPROPERTY(id, 'IsTable') = 1)
begin
	GOTO createView;
--	drop table akkradm.IO_AKKREDITEUR;
end;

create table akkradm.IO_AKKREDITEUR(
	AKRT_ID				UDT_ID IDENTITY NOT FOR REPLICATION,


	MAND_ID				UDT_MANDANT		NOT NULL,
	EIGE_ID				UDT_EIGENTUEMER	NOT NULL,

	AKRS_ID				UDT_ID			NOT NULL,	


	TBSH_SHORTNAME			UDT_TABLENAME_SHORT NOT NULL,
	TBSH_ID					UDT_ANZAHL_I		NOT NULL,

		
	AKRT_USER			UDT_USER	NOT NULL,
	AKRT_PTS			UDT_PTS		NOT NULL,
	AKRT_#PTS			UDT_#PTS	NULL,	
	AKRT_ID_INT			UDT_ID_0	NOT NULL,
	AKRT_UQID			UDT_UQID	NOT NULL ROWGUIDCOL,
	AKRT_KZ_FREIGABE	UDT_BOOLEAN	NOT NULL,
	AKRT_KZ_REPLIKATION	UDT_BOOLEAN	NOT NULL,
	AKRT_KZ_GELOESCHT	UDT_BOOLEAN	NOT NULL,

	CONSTRAINT PK_AKRT PRIMARY KEY CLUSTERED( AKRT_ID )
);

CREATE UNIQUE INDEX AKRT_IX_01_U ON akkradm.IO_AKKREDITEUR( AKRT_UQID );
CREATE INDEX		AKRT_IX_02	 ON akkradm.IO_AKKREDITEUR( AKRT_KZ_GELOESCHT );

createView:

if not exists ( select * from sysobjects where id = object_id('akkradm.T_AKKREDITEUR') and OBJECTPROPERTY(id, 'IsView') = 1)
begin
	exec( N'create view akkradm.T_AKKREDITEUR as select * from INFORMATION_SCHEMA.TABLES;' );
end
GO

alter view akkradm.T_AKKREDITEUR(
		AKRT_ID,

		AKRS_ID,	
		TBSH_SHORTNAME,
		TBSH_ID,

		AKRT_USER,
		AKRT_PTS,
		AKRT_#PTS

) as
select	AKRT_ID,

		AKRS_ID,	
		TBSH_SHORTNAME,
		TBSH_ID,

		AKRT_USER,
		AKRT_PTS,
		AKRT_#PTS

from	akkradm.IO_AKKREDITEUR
where	AKRT_KZ_GELOESCHT = 0;

GO
