-- =============================================
-- Author:		<Gadriwala Muslim >
-- Create date: <24/09/2015>
-- Description:	<check here Leave Policy rules violate or not >
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Check_Leave_application_After_Resuming_duty]
@cmp_ID numeric(18,0),
@emp_ID numeric(18,0),
@Leave_ID numeric(18,0),
@For_Date datetime,
@Application_Date datetime

AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Grd_ID as numeric(18,0)
	Declare @Leave_Full_Name as nvarchar(max)
	Declare @After_Resuming_Limit as numeric(18,2)
	Declare @Resuming_Hours as numeric(18,2)
	Declare @Resuming_duty_date as datetime
	
	set @Application_Date = GETDATE() -- Check with current datetime
	select @Grd_ID = Grd_ID from T0095_INCREMENT IE WITH (NOLOCK) inner join
		(
			select max(Increment_ID) as Increment_ID,Emp_ID from T0095_INCREMENT IE WITH (NOLOCK)
			where Increment_Effective_Date <= @For_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID group by Emp_ID
		) Qry on Qry.Increment_ID = IE.Increment_ID
		where Cmp_ID = @Cmp_ID and IE.Emp_ID =@Emp_ID
		
	select @After_Resuming_Limit = LD.After_Resuming_Duty , 
		   @Leave_Full_Name =  Leave_Code + '-' + Leave_Name  
	from T0050_LEAVE_DETAIL LD WITH (NOLOCK) inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LD.Leave_ID = LM.Leave_ID 
		 where LM.Leave_ID = @Leave_ID and LM.Cmp_ID = @Cmp_ID and Grd_ID = @Grd_ID
			

	if @After_Resuming_Limit > 0
		begin
			if @For_date < @Application_Date
				begin				
					select Top 1 @Resuming_duty_date = In_time from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
					where 
					For_date	>= @For_Date and 
					For_Date <= @Application_Date and emp_ID = @emp_ID and Cmp_ID = @cmp_ID
					order by for_Date,In_Time
				end
			else
				begin
					set @Resuming_duty_date = @Application_Date
					
				end
		end
	else
		begin
			set @Resuming_duty_date = @Application_Date
		end
		
		
		set @Resuming_Hours = datediff(HH,@Resuming_duty_date,@Application_Date)
		
		if @Resuming_Hours > @After_Resuming_Limit 
		   begin
				select  'Leave avail rules violate here!, leave application made after avail leave' as Rules_Violate_msg
		   end
		 else
			begin
				select  '' as Rules_Violate_msg
			end

 	
END

