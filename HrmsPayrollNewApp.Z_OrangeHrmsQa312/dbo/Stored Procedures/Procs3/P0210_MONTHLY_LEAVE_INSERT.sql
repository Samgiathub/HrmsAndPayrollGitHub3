
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0210_MONTHLY_LEAVE_INSERT]
	 @Cmp_ID as numeric
	,@Emp_ID as numeric
	,@From_Date as datetime
	,@To_Date as datetime
	,@Sal_Tran_ID as numeric 
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @M_Leave_Tran_Id as numeric 
	Declare @Leave_ID as numeric 
	Declare @Leave_Days as numeric(18,2)
	Declare @Leave_Type as varchar(50)
	Declare @Paid_Unpaid as varchar(5)
	
	IF @Sal_Tran_ID = 0
		set @Sal_Tran_ID = null

	 --REMOVE CURSOR 
	
	-----------------------------------------------------------------------------------------
	--INSERT INTO dbo.T0210_MONTHLY_LEAVE_DETAIL(Emp_ID, Cmp_Id, Leave_ID, Sal_Tran_ID, For_Date, Leave_Days,Temp_Sal_Tran_ID,LeavE_Type,Leave_paid_unpaid)		                   		
	--SELECT @Emp_ID,@Cmp_ID,LT.Leave_ID ,Null,@From_Date,  Sum(CASE WHEN LM.Apply_Hourly = 0 THEN (Case When Isnull(Half_Paid,0)=1 and Isnull(Half_Payment_Days,0)=0 then LeavE_Used/2 else Leave_Used End + isnull(CompOff_Used,0)) ELSE case when (Case When Isnull(Half_Paid,0)=1 and Isnull(Half_Payment_Days,0)=0 then LeavE_Used/2 else Leave_Used End + isnull(CompOff_Used,0)) * 0.125 > 1 then 1 else (Case When Isnull(Half_Paid,0)=1 and Isnull(Half_Payment_Days,0)=0 then LeavE_Used/2 else Leave_Used End + isnull(CompOff_Used,0)) * 0.125 end END) ,--Changed by Gadriwala Muslim 02102014
	--@Sal_Tran_ID,Leave_Type,Leave_Paid_Unpaid  
	--From dbo.T0140_leave_Transaction LT
	--Inner join dbo.T0040_Leave_Master LM on LT.Leave_ID = LM.Leave_ID and (isnull(eff_in_salary,0) <> 1 
	--		or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) <= 0) 
	--		or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) >= 0 and (isnull(Leave_Used,0) > 0 or ISNULL(CompOff_Used,0) > 0))) -- Changed By Gadriwala Muslim 02102014
	--WHERE Emp_ID = @Emp_ID and For_Date >=@From_Date and For_Date <=@To_date
	--GROUP BY Emp_ID,LT.Leave_ID,Leave_Type,Leave_Paid_Unpaid
	-----------------------------------------------------------------------------------------
	-- For Regulart Leave
	--Changed by Gadriwala Muslim 01012015 - Start
	 INSERT INTO dbo.T0210_MONTHLY_LEAVE_DETAIL(Emp_ID, Cmp_Id, Leave_ID, Sal_Tran_ID, For_Date, Leave_Days,Temp_Sal_Tran_ID,LeavE_Type,Leave_paid_unpaid)		                   		
	SELECT @Emp_ID,@Cmp_ID,LT.Leave_ID ,Null,@From_Date,  Sum(CASE WHEN LM.Apply_Hourly = 0 THEN (Case When Isnull(Half_Paid,0)=1 and Isnull(Half_Payment_Days,0)=0 then LeavE_Used/2 else Leave_Used End ) ELSE case when (Case When Isnull(Half_Paid,0)=1 and Isnull(Half_Payment_Days,0)=0 then LeavE_Used/2 else Leave_Used End ) * 0.125 > 1 then 1 else (Case When Isnull(Half_Paid,0)=1 and Isnull(Half_Payment_Days,0)=0 then LeavE_Used/2 else Leave_Used End) * 0.125 end END) ,--Changed by Gadriwala Muslim 02102014
	@Sal_Tran_ID,Leave_Type,Leave_Paid_Unpaid  
	From dbo.T0140_leave_Transaction LT WITH (NOLOCK)
	Inner join dbo.T0040_Leave_Master LM WITH (NOLOCK) on LT.Leave_ID = LM.Leave_ID and (isnull(eff_in_salary,0) <> 1 
			or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) <= 0) 
			or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) >= 0 and (isnull(Leave_Used,0) > 0))) and isnull(LM.Default_Short_Name,'') <> 'COMP' 
	WHERE Emp_ID = @Emp_ID and For_Date >=@From_Date and For_Date <=@To_date And ISNULL(LM.Add_In_Working_Hour,0) = 0
	GROUP BY Emp_ID,LT.Leave_ID,Leave_Type,Leave_Paid_Unpaid
	-----------------------------------------------------------------------------------------
	-- For CompOff Leave
	INSERT INTO dbo.T0210_MONTHLY_LEAVE_DETAIL(Emp_ID, Cmp_Id, Leave_ID, Sal_Tran_ID, For_Date, Leave_Days,Temp_Sal_Tran_ID,LeavE_Type,Leave_paid_unpaid)		                   		
	 select @Emp_ID,@Cmp_ID,LT.Leave_ID ,Null,@From_Date,isnull(sum(isnull(CASE WHEN Apply_Hourly = 0 THEN case when CompOff_Used >= Leave_Encash_Days then CompOff_Used - Leave_Encash_Days else CompOff_Used end ELSE case when CompOff_Used >= Leave_Encash_Days then (CompOff_Used - Leave_Encash_Days) * 0.125 Else CompOff_Used * 0.125 End END,0)),0), -- Changed By Gadriwala 01102014
			@Sal_Tran_ID,Leave_Type,Leave_Paid_Unpaid  
			from dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
			Inner join dbo.T0040_Leave_Master LM WITH (NOLOCK) on LT.Leave_ID = LM.Leave_ID and (isnull(eff_in_salary,0) <> 1 
			or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) <= 0) 
			or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) >= 0 and (isnull(CompOff_Used,0) > 0))) and isnull(LM.Default_Short_Name,'') = 'COMP'
			where For_Date >= @From_Date and For_Date <= @To_Date and Emp_ID = @Emp_ID  And ISNULL(LM.Add_In_Working_Hour,0) = 0
			GROUP BY Emp_ID,LT.Leave_ID,Leave_Type,Leave_Paid_Unpaid
	--Changed by Gadriwala Muslim 01012015 - End		
	
	--Declare Cur_leave cursor for
	--	select LT.Leave_ID ,Sum(LeavE_Used + Leave_encash_days),Leave_Type,Leave_Paid_Unpaid  From T0140_leave_Transaction LT
	--		Inner join T0040_Leave_Master LM on LT.Leave_ID = LM.Leave_ID and (isnull(eff_in_salary,0) <> 1 
	--				or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) <= 0) -- added by mitesh on 02/052012 for leave encashment with leave on same day
	--				or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) >= 0 and isnull(Leave_Used,0) > 0))
	--	Where Emp_ID = @Emp_ID and For_Date >=@From_Date and For_Date <=@To_date
	--	Group by Emp_ID,LT.Leave_ID,Leave_Type,Leave_Paid_Unpaid
		
	--open cur_leave
	--Fetch next From Cur_LEave into @Leave_ID ,@Leave_Days,@Leave_Type,@Paid_Unpaid	
	--while @@Fetch_status =0
	--	begin
			
		
	--		Select @M_Leave_Tran_Id  = Isnull(Max(M_Leave_Tran_ID),0) + 1 From T0210_MONTHLY_LEAVE_DETAIL
	--		INSERT INTO T0210_MONTHLY_LEAVE_DETAIL
	--		                      (M_Leave_Tran_ID, Emp_ID, Cmp_Id, Leave_ID, Sal_Tran_ID, For_Date, Leave_Days,Temp_Sal_Tran_ID,LeavE_Type,Leave_paid_unpaid)
	--		VALUES     (@M_Leave_Tran_ID, @Emp_ID, @Cmp_Id, @Leave_ID,null, @From_Date, @Leave_Days,@Sal_Tran_ID,@Leave_Type,@Paid_Unpaid)
			
		
	--		Fetch next From Cur_Leave into @Leave_ID ,@Leave_Days,@Leave_Type,@Paid_Unpaid		
	--	END
	--close cur_Leave
	--Deallocate Cur_LEave

   
   return
  



