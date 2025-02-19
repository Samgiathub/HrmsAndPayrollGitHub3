---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_PROBATION_GET]
	@Cmp_ID numeric(18,0) 
	,@Leave_ID numeric(18,0)
	,@Emp_ID numeric(18,0)
	,@App_Date datetime
	,@From_Date datetime
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @Probarion numeric(18,0)
Declare @Emp_Probarion numeric(18,0)
Declare @Lv_Month numeric(2,0)
Declare @Branch_ID numeric(18,0)
Declare @Date_Of_join datetime
Declare @Is_Probation tinyint
Declare @Leave_Applicable numeric(18,0)
Declare @no_of_days numeric(18,0)
Declare @Out numeric(1,0)
declare @leave_type nvarchar(50)
declare @is_paid varchar(1)
declare @Default_Short_Name nvarchar(50)

-- Started by Divyaraj Kiri on 27/09/2024
Declare @Probation_Leave numeric(18,0)
SET @Probation_Leave = 0
Declare @Grd_Id as numeric(18,0)
SET @Grd_Id = 0
-- Ended by Divyaraj Kiri on 27/09/2024

set @leave_type = ''
set @is_paid = 'U'

select @Branch_ID=Branch_ID from t0080_Emp_Master WITH (NOLOCK) where Emp_ID=@Emp_ID --and Cmp_ID=@cmp_ID

select @Probarion=Probation,@Lv_Month=isnull(Lv_Month,0) 
  from T0040_GENERAL_SETTING WITH (NOLOCK) where Branch_ID = @Branch_ID                    
 and For_Date = (select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@App_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)                    --cmp_ID = @cmp_ID and 
  
select	@Emp_Probarion=isnull(Probation,0),
		@Date_Of_join= Case When IsNull(GroupJoiningDate,'1900-01-01') <> '1900-01-01' THEN GroupJoiningDate Else  Date_Of_join End,
		@Is_Probation=isnull(Is_On_Probation,0) 
from	t0080_Emp_Master WITH (NOLOCK) where Emp_ID=@Emp_ID --and Cmp_ID=@Cmp_ID

-- Started by Divyaraj Kiri on 27/09/2024
Select top 1 @Grd_Id = Grd_ID
From T0095_INCREMENT with (NOLOCK) where Emp_ID = @Emp_ID
order by Increment_ID desc
-- Ended by Divyaraj Kiri on 27/09/2024


select	@Leave_Applicable=isnull(Leave_Applicable,0),@leave_type = Leave_Type ,  @is_paid = isnull(Leave_Paid_Unpaid,'U'),@Default_Short_Name=Default_Short_Name 
from	T0040_Leave_MASTER WITH (NOLOCK) where Leave_id = @Leave_Id
select @no_of_days=isnull(datediff(day, @Date_Of_join, @App_Date),0) from v0080_Employee_master  where emp_id = @Emp_ID

Select @Probation_Leave=Is_Probation from T0050_LEAVE_DETAIL where Cmp_ID=@Cmp_ID and Leave_ID=@Leave_ID and Grd_ID=@Grd_ID	-- Added by Divyaraj Kiri on 27/09/2024

--Select @Probation_Leave,@Is_Probation,@Grd_Id,@no_of_days,@Leave_Applicable

IF @Probation_Leave = 1 AND @Is_Probation =1
	BEGIN 
		SET @Leave_Applicable = 99999999
	END

--if @Probation_Leave = 1
--begin
	if isnull(@no_of_days,0) < @Leave_Applicable 
	Begin
		set @Out=0
		select @Out as Out
	End
else 
	Begin
		select @no_of_days=isnull(datediff(day, @Date_Of_join, @From_Date),0) from v0080_Employee_master  where emp_id = @Emp_ID		
		if isnull(@no_of_days,0) < @Leave_Applicable 
			Begin
			
				set @Out=0
				select @Out as Out
			End	
		else
			Begin
				---Start
				--- Add by jignesh 7-Mar-2013
				if isnull(@Default_short_Name,'')  = 'COMP' 
				begin
					set @Out=1
					select @Out as Out
					return
				end
				
				------------------
				if (@leave_type <> 'Company Purpose' and @is_paid <> 'U') 
					begin
						
						if @Is_Probation <> 0
							BEgin
								--select @App_Date,@From_Date,dateadd(m,isnull(@Lv_Month,0),@Date_Of_join)
								if /*@App_Date  < dateadd(m,@Lv_Month,@Date_Of_join) And*/  @From_Date < dateadd(m,@Lv_Month,@Date_Of_join)
												Begin
													set @Out=0
													select @Out as Out
												End
								else
									Begin
												Begin
													set @Out=1
													select @Out as Out
												End
									End				
							End 
						else
							BEgin
								set @Out=1
								select @Out as Out
							End	
					end
				Else
					begin
						set @Out=1
						select @Out as Out
					end
				--End
				
			End	
	End
--end
--else
--begin
--	if isnull(@no_of_days,0) < @Leave_Applicable 
--	Begin
--		set @Out=0
--		select @Out as Out
--	End
--else 
--	Begin
--		select @no_of_days=isnull(datediff(day, @Date_Of_join, @From_Date),0) from v0080_Employee_master  where emp_id = @Emp_ID		
--		if isnull(@no_of_days,0) < @Leave_Applicable 
--			Begin
			
--				set @Out=0
--				select @Out as Out
--			End	
--		else
--			Begin
--				---Start
--				--- Add by jignesh 7-Mar-2013
--				if isnull(@Default_short_Name,'')  = 'COMP' 
--				begin
--					set @Out=1
--					select @Out as Out
--					return
--				end
				
--				------------------
--				if (@leave_type <> 'Company Purpose' and @is_paid <> 'U') 
--					begin
						
--						if @Is_Probation <> 0
--							BEgin
--								--select @App_Date,@From_Date,dateadd(m,isnull(@Lv_Month,0),@Date_Of_join)
--								if /*@App_Date  < dateadd(m,@Lv_Month,@Date_Of_join) And*/  @From_Date < dateadd(m,@Lv_Month,@Date_Of_join)
--												Begin
--													set @Out=0
--													select @Out as Out
--												End
--								else
--									Begin
--												Begin
--													set @Out=1
--													select @Out as Out
--												End
--									End				
--							End 
--						else
--							BEgin
--								set @Out=1
--								select @Out as Out
--							End	
--					end
--				Else
--					begin
--						set @Out=1
--						select @Out as Out
--					end
--				--End
				
--			End	
--	End
--end



  
  


