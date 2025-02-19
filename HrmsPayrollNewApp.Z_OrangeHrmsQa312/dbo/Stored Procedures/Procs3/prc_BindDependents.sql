-- exec prc_BindDependents 119,662,518,'A,7605'
-- drop proc prc_BindDependents
CREATE procedure [dbo].[prc_BindDependents]
@rCmp_Id numeric,
@rBranchId numeric,
@rGradeId numeric,
@rResult varchar(500)
as

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

begin
	
	declare @lResult varchar(max) = '',@lPrivilege_Id numeric
	declare @For_Date as datetime,@Is_OT as Numeric,@lMinBasicSal numeric
	declare @lAutoEmpPFNo numeric,@lIsDateWise numeric,@lIsJoiningDateWise numeric
	set @Is_OT = 0

	select @lPrivilege_Id = isnull(Privilege_Id,0) from T0020_PRIVILEGE_MASTER WITH (NOLOCK) where cmp_id = @rCmp_Id and (Branch_Id = @rBranchId or @rBranchId = 0 or Branch_Id = 0)
	and Privilege_Name = 'EssUser' and Privilege_Type = 1

	SELECT @lMinBasicSal = isnull(min_basic,0) FROM T0040_GRADE_MASTER WITH (NOLOCK) where cmp_id = @rCmp_Id and Grd_ID=@rGradeId and isnull(min_basic,0) > 0
	select @lIsDateWise = Is_DateWise,@lIsJoiningDateWise = Is_JoiningDateWise from T0010_Company_Master WITH (NOLOCK) where Cmp_ID=@rCmp_Id
	
	if isnull(@lPrivilege_Id,0) = 0
	begin
		select @lPrivilege_Id = Privilege_Id from T0020_PRIVILEGE_MASTER WITH (NOLOCK) where cmp_id = @rCmp_Id and (Branch_Id = @rBranchId or @rBranchId = 0 or Branch_Id = 0)
		and Privilege_Type = 1

		select @lPrivilege_Id = isnull(@lPrivilege_Id,0)
	end

	Select @lAutoEmpPFNo = Setting_Value From T0040_SETTING WITH (NOLOCK) WHERE CMP_ID= @rCmp_Id AND Setting_Name='Auto Generate Employee PF Number'

	select @lResult = @lResult + '<option value="0"> -- Select -- </option>'
	select @lResult = @lResult + '<option value="' + CONVERT(varchar,Privilege_Id) + '"
	' + case when Privilege_Id = @lPrivilege_Id then 'selected="selected"' else '' end + '">' + Privilege_Name + '</option>'
	from T0020_PRIVILEGE_MASTER WITH (NOLOCK) where cmp_id = @rCmp_Id and Privilege_Type = 1
	and (Branch_Id = @rBranchId or @rBranchId = 0 or branch_id = 0)
	
	Declare @temp_table table
	(
		Is_OT Numeric,Is_PF Numeric,Is_PT Numeric,Is_Late_Mark Numeric,Is_LWF Numeric,Branch_ID Numeric,Monthly_Deficit_Adjust_OT_Hrs Numeric,Is_inout_Sal Numeric
	)

	Select @For_Date = max(For_Date) From T0040_General_Setting WITH (NOLOCK) where Branch_ID = @rBranchId and Cmp_ID = @rCmp_Id
		 
	Insert Into @temp_table
	Select Is_OT,Is_PF,Is_PT,Is_Late_Mark,Is_LWF,Branch_ID,Monthly_Deficit_Adjust_OT_Hrs,Is_inout_Sal
	from T0040_General_Setting WITH (NOLOCK) where Branch_ID = @rBranchId and Cmp_ID = @rCmp_Id and for_date= @For_Date
	
	--Added by Hardik 16/03/2015 for Bhashker (They have Grade Wise OT Setting)

	If @rGradeId > 0 
	Begin
		Select @Is_OT = Isnull(OT_Applicable,0) From T0040_GRADE_MASTER WITH (NOLOCK) Where Cmp_ID = @rCmp_Id And Grd_ID = @rGradeId
				
		If not exists(Select Is_OT From @temp_table where Is_OT = 0)
			Update @temp_table Set Is_OT = @Is_OT				
	End

	if not exists((select count(1) from @temp_table))
	begin
		insert into @temp_table
		Select -1,-1,-1,-1,-1,-1,-1,-1
	end

	Select @lResult as DropDown,@rResult as Result,@lAutoEmpPFNo as AutoEmpPFNo,@lMinBasicSal as MinBasic,
	@lIsDateWise as IsDateWise,@lIsJoiningDateWise as IsJoiningDateWise,* from @temp_table

	--select @lResult as DropDown,@rResult as Result
end