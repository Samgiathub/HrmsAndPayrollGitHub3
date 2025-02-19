


-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <21-09-2015>
-- Description:	<check leave application limit per year.>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Check_Leave_Application_Per_Year] 
@Cmp_ID numeric(18,0),
@Emp_ID numeric(18,0),
@Leave_ID numeric(18,0),
@For_Date datetime
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Leave_applied as numeric(18,2)
	declare @Start_Date_Year as datetime
	declare @End_Date_Year as datetime
	Declare @Leave_applied_Limit as numeric(18,2)
	Declare @Leave_Full_Name as nvarchar(max)
	Declare @Leave_Application_Alert as nvarchar(max)
	Declare @Grd_ID as numeric(18,0)
	Declare @Branch_ID as numeric(18,0) --Added By Jaina 27-08-2016
	Declare @Year_Type as tinyint --Added By Jaina 27-08-2016
	
	set @Leave_Full_Name = ''
	set @Leave_applied = 0
	set @Leave_applied_Limit = 0
	set @Leave_Application_Alert = ''
	--set @Start_Date_Year = dbo.GET_MONTH_ST_DATE(month(@for_Date),YEAR(@for_Date))
	--set @End_Date_Year = dbo.GET_MONTH_END_DATE(month(@for_Date),YEAR(@for_Date))
	set @Start_Date_Year = dbo.GET_YEAR_START_DATE(YEAR(@For_Date),Month(@For_date),0)
	set @End_Date_Year = dbo.GET_YEAR_END_DATE(YEAR(@For_Date),Month(@For_date),0)
	
	set @Year_Type = 0  --Added by Jaina 27-08-2016
	set @Branch_ID = 0  --Added by Jaina 27-08-2016
	
	--Comment By Jaina 27-08-2016
	--select @Grd_ID = Grd_ID from T0095_INCREMENT IE inner join
	--(
	--	select max(Increment_ID) as Increment_ID,Emp_ID from T0095_INCREMENT IE 
	--	where Increment_Effective_Date <= @For_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID group by Emp_ID
	--) Qry on Qry.Increment_ID = IE.Increment_ID
	--where Cmp_ID = @Cmp_ID and IE.Emp_ID =@Emp_ID
	
	--Added By Jaina 27-08-2016 Start
	select @Grd_ID = Grd_ID,@Branch_ID= Branch_ID from T0095_INCREMENT IE WITH (NOLOCK) inner join
	(
		select max(Increment_Effective_Date) as Effective_Date  from T0095_INCREMENT Sub_IE  WITH (NOLOCK) Inner join
		(
			select max(Increment_ID) as Increment_ID,Emp_ID from T0095_INCREMENT WITH (NOLOCK)
			where Increment_Effective_Date <= @For_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID group by Emp_ID
		) Sub_Qry on Sub_Qry.Increment_ID = Sub_IE.Increment_ID
		
		where Increment_Effective_Date <= @For_Date  and Cmp_ID = @Cmp_ID and Sub_IE.Emp_ID = @Emp_ID
	) Qry on Qry.Effective_Date = IE.Increment_Effective_Date
	where Cmp_ID = @Cmp_ID and IE.Emp_ID =@Emp_ID
	
	select @Year_Type = isnull(Validity_Period_Type,0) from T0040_GENERAL_SETTING GS WITH (NOLOCK) inner join
	(
		select max(For_Date) as for_date from T0040_General_Setting WITH (NOLOCK)
		where Branch_ID = @Branch_ID and Cmp_ID = @cmp_ID
	 )as qry on qry.for_date = GS.For_Date
	where Cmp_ID = @cmp_ID and Branch_ID = @Branch_ID 
	
	set @Start_Date_Year = dbo.GET_YEAR_START_DATE(YEAR(@For_Date),Month(@For_date),@Year_Type)
	set @End_Date_Year = dbo.GET_YEAR_END_DATE(YEAR(@For_Date),Month(@For_date),@Year_Type)

	--Added By Jaina 27-08-2016 End
	
	select @Leave_applied_Limit = Max_Leave_App , @Leave_Full_Name =  Leave_Code + '-' + Leave_Name  from T0050_LEAVE_DETAIL LD WITH (NOLOCK)
	inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LD.Leave_ID = LM.Leave_ID 
	 where LM.Leave_ID = @Leave_ID and LM.Cmp_ID = @Cmp_ID and Grd_ID = @Grd_ID


	IF @Leave_applied_Limit > 0
		begin
			select @Leave_applied = isnull(Count(LA.Leave_Approval_ID),0) + 1  from  T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join
			T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID
			where From_Date >= @Start_Date_Year and From_Date <= @End_Date_Year and LA.Cmp_ID = @Cmp_ID 
			and Emp_ID = @Emp_ID and LAD.Leave_ID = @Leave_ID
			
			if @Leave_applied_Limit >= @Leave_Applied 
				begin
				    set @Leave_Application_Alert = ''
					select @Leave_Application_Alert as Leave_Application_Alert
				end
			else
				begin
				  set @Leave_Application_Alert =   'Notes :' + @Leave_Full_Name + ' maximum application limit in year is a ' + Convert(varchar(20),@Leave_applied_Limit) + ',However employee have applied leave application in this year is a ' + Convert(varchar(20),@Leave_applied)  
				  select @Leave_Application_Alert as  Leave_Application_Alert
				end
		end
	else
		begin
			
		    set @Leave_Application_Alert = ''
		    select @Leave_Application_Alert as Leave_Application_Alert
		end
			
  
END

