-- exec prc_BindDropDownsForClaim 119
-- drop proc prc_BindDropDownsForClaim
Create procedure [dbo].[prc_BindDropDownsForClaimGroup]
@rCmp_Id int
as
begin
	declare @tbl table(tid int identity(1,1),MainId int,Title varchar(200),m_Type int)
	insert into @tbl
	select Claim_Group_Id,Claim_Group_Name,1 from T0040_Claim_Group_Master where Cmp_Id = @rCmp_Id

	union all	
	select Bill_Id,Bill_Name,2 from T0050_Bill_Type_Master where Cmp_Id = @rCmp_Id 

	select * from @tbl
end