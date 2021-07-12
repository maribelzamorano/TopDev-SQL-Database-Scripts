/*	
 * topdev GmbH, erstellt am 28.09.2009 15:42
 *
 * $Author: Maribel Zamorano $
 * $Date: 2009-09-28 15:42:31 $
 * $Rev: _ $
 * -------------------------------------------
 * $Workfile: (01) tis02o.Gruppe.sql $
 *
 */

if not exists ( select * from sysobjects where id = object_id('tis02o.T_GRUPPE') and OBJECTPROPERTY(id, 'IsView') = 1)
begin
	exec( N'create view tis02o.T_GRUPPE as select * from INFORMATION_SCHEMA.TABLES;' );
end
GO

declare	@sql	nvarchar(max)

select	@sql = 'alter view tis02o.T_GRUPPE(
		GRUP_ID, GRUP_NAME
) as
select	GRUP_ID, GRUP_NAME
from	' + services.pfn_GetTIS02O() + '.thillmuser.T_GRUPPE;'

exec( @sql )
GO

