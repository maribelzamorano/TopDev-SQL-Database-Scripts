/*	
 * topdev GmbH, erstellt am 30.09.2009 13:55
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-09-30 13:55:26 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (01) akkradm.Akkreditierungsbescheid.sql $
 *
 */

if exists ( select * from sysobjects where id = object_id('akkradm.IO_AKKREDITIERUNGSBESCHEID') and OBJECTPROPERTY(id, 'IsTable') = 1)
begin
	GOTO createView;
--	drop table akkradm.IO_AKKREDITIERUNGSBESCHEID;
end;

create table akkradm.IO_AKKREDITIERUNGSBESCHEID(
	AKRB_ID				UDT_ID IDENTITY NOT FOR REPLICATION,


	MAND_ID				UDT_MANDANT		NOT NULL,
	EIGE_ID				UDT_EIGENTUEMER	NOT NULL,

	ABIE_ID				UDT_ID		NOT NULL,	
	ANBO_ID				UDT_ID		NOT NULL,
	AKRS_ID				UDT_ID		NOT NULL,
	AKRA_ID				UDT_ID   	NOT NULL,
	AKRT_ID				UDT_ID   	NOT NULL,
		

	AKRB_USER			UDT_USER	NOT NULL,
	AKRB_PTS			UDT_PTS		NOT NULL,
	AKRB_#PTS			UDT_#PTS	NULL,	
	AKRB_ID_INT			UDT_ID_0	NOT NULL,
	AKRB_UQID			UDT_UQID	NOT NULL ROWGUIDCOL,
	AKRB_KZ_FREIGABE	UDT_BOOLEAN	NOT NULL,
	AKRB_KZ_REPLIKATION	UDT_BOOLEAN	NOT NULL,
	AKRB_KZ_GELOESCHT	UDT_BOOLEAN	NOT NULL,

	CONSTRAINT PK_AKRB PRIMARY KEY CLUSTERED( AKRB_ID )
);

CREATE UNIQUE INDEX AKRB_IX_01_U ON akkradm.IO_AKKREDITIERUNGSBESCHEID( AKRB_UQID );
CREATE INDEX		AKRB_IX_02	 ON akkradm.IO_AKKREDITIERUNGSBESCHEID( AKRB_KZ_GELOESCHT );

createView:

if not exists ( select * from sysobjects where id = object_id('akkradm.T_AKKREDITIERUNGSBESCHEID') and OBJECTPROPERTY(id, 'IsView') = 1)
begin
	exec( N'create view akkradm.T_AKKREDITIERUNGSBESCHEID as select * from INFORMATION_SCHEMA.TABLES;' );
end
GO

alter view akkradm.T_AKKREDITIERUNGSBESCHEID(
		AKRB_ID,

		ABIE_ID,	
		ANBO_ID,
		AKRS_ID,
		AKRA_ID,
		AKRT_ID,

		AKRB_USER,
		AKRB_PTS,
		AKRB_#PTS

) as
select	AKRB_ID,

		ABIE_ID,	
		ANBO_ID,
		AKRS_ID,
		AKRA_ID,
		AKRT_ID,

		AKRB_USER,
		AKRB_PTS,
		AKRB_#PTS

from	akkradm.IO_AKKREDITIERUNGSBESCHEID
where	AKRB_KZ_GELOESCHT = 0;

GO
