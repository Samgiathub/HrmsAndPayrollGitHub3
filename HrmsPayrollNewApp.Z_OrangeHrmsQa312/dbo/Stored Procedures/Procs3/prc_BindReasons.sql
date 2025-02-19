-- exec prc_BindReasons 0
-- drop proc prc_BindReasons
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[prc_BindReasons]
@rCmp_Id int
as
begin
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	select isnull(Reason_Name,'') as ReasonName,ISNULL(Type,'') as ReasonType,
	ResonActive = case isactive when 1 then 'Active' else 'InActive' end
	from V0040_Reason_Master order by Reason_Name
end