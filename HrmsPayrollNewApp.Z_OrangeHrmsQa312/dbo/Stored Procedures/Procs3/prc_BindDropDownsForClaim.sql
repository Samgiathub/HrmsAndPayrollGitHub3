-- exec prc_BindDropDownsForClaim 119
-- drop proc prc_BindDropDownsForClaim
CREATE procedure prc_BindDropDownsForClaim
@rCmp_Id int
as
begin
	declare @tbl table(tid int identity(1,1),MainId int,Title varchar(200),m_Type int)
	insert into @tbl
	select Unit_Type_Id,Unit_Type_Name,1 from T0040_Unit_Type_Master where Cmp_Id = @rCmp_Id

	union all	
	select Bill_Id,Bill_Name,2 from T0050_Bill_Type_Master where Cmp_Id = @rCmp_Id 

	select * from @tbl
end