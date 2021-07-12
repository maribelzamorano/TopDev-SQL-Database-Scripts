/*	
 * topdev GmbH, erstellt am 29.09.2009 13:28
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-09-29 13:28:45 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (01) akkradm.Vorlaeufiger_Termin.sql $
 *
 */

if exists ( select * from sysobjects where id = object_id('akkradm.IO_VORLAEUFIGER_TERMIN') and OBJECTPROPERTY(id, 'IsTable') = 1)
begin
	GOTO createView;
--	drop table akkradm.IO_VORLAEUFIGER_TERMIN;
end;

create table akkradm.IO_VORLAEUFIGER_TERMIN(
	VOTE_ID				UDT_ID IDENTITY NOT FOR REPLICATION,


	MAND_ID				UDT_MANDANT		NOT NULL,
	EIGE_ID				UDT_EIGENTUEMER	NOT NULL,


	VOTE_BEZEICHNUNG  nvarchar(255) NOT NULL,
	VOTE_DATUM		  datetime		NOT NULL,

		

	VOTE_USER			UDT_USER	NOT NULL,
	VOTE_PTS			UDT_PTS		NOT NULL,
	VOTE_#PTS			UDT_#PTS	NULL,	
	VOTE_ID_INT			UDT_ID_0	NOT NULL,
	VOTE_UQID			UDT_UQID	NOT NULL ROWGUIDCOL,
	VOTE_KZ_FREIGABE	UDT_BOOLEAN	NOT NULL,
	VOTE_KZ_REPLIKATION	UDT_BOOLEAN	NOT NULL,
	VOTE_KZ_GELOESCHT	UDT_BOOLEAN	NOT NULL,
	VOTE_KZ_GESPERRT	UDT_BOOLEAN	NOT NULL,
	VOTE_SORT           UDT_ANZAHL_S NOT NULL,
	VOTE_GUELTIG_VON	Datetime   NULL,
	VOTE_GUELTIG_BIS    Datetime   NULL,

	CONSTRAINT PK_VOTE PRIMARY KEY CLUSTERED( VOTE_ID )
);

CREATE UNIQUE INDEX VOTE_IX_01_U ON akkradm.IO_VORLAEUFIGER_TERMIN( VOTE_UQID );
CREATE INDEX		VOTE_IX_02	 ON akkradm.IO_VORLAEUFIGER_TERMIN( VOTE_KZ_GELOESCHT );

createView:

if not exists ( select * from sysobjects where id = object_id('akkradm.T_VORLAEUFIGER_TERMIN') and OBJECTPROPERTY(id, 'IsView') = 1)
begin
	exec( N'create view akkradm.T_VORLAEUFIGER_TERMIN as select * from INFORMATION_SCHEMA.TABLES;' );
end
GO

alter view akkradm.T_VORLAEUFIGER_TERMIN(
		VOTE_ID,

		VOTE_BEZEICHNUNG,
	    VOTE_DATUM,

		VOTE_USER,
		VOTE_PTS,
		VOTE_#PTS,
		VOTE_KZ_GESPERRT,
		VOTE_SORT,
		VOTE_GUELTIG_VON,
		VOTE_GUELTIG_BIS

) as
select	VOTE_ID,

		VOTE_BEZEICHNUNG,
	    VOTE_DATUM,

		VOTE_USER,
		VOTE_PTS,
		VOTE_#PTS,
		VOTE_KZ_GESPERRT,
		VOTE_SORT,
		VOTE_GUELTIG_VON,
		VOTE_GUELTIG_BIS

from	akkradm.IO_VORLAEUFIGER_TERMIN
where	VOTE_KZ_GELOESCHT = 0;

GO
