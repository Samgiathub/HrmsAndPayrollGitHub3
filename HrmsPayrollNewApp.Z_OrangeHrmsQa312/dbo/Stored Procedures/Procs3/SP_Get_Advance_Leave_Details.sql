

-- =============================================
-- Author:		Nilesh Patel
-- Create date: 08/02/2016 
-- Description:	Get Leave Details of Advance Leave Balance 
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Advance_Leave_Details]
	-- Add the parameters for the stored procedure here
	@Cmp_ID Numeric(18,0),
	@Type_ID Numeric(18,0),
	@Join_Date Datetime,
	@Branch_ID Numeric(18,0),--Mukti(08092017)
	@flag varchar(10) = '', --Mukti(02092017)to add Advance Leave Balance while importing of employee master
	@Emp_ID numeric(18,0) = 0, --Mukti(02092017)to add Advance Leave Balance while importing of employee master
	@Grade_ID numeric(18,0)=0--added by chetan 22122017
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @date DATETIME
	DECLARE @days Numeric(18,0)
	DECLARE @Month_days Numeric(18,0)
	--Added by Mukti(02082017)start
	DECLARE @Leave_ID as NUMERIC(18,0)
	DECLARE @Leave_Upto_date as DATETIME
	DECLARE @P_Days as NUMERIC(18,2)
	DECLARE @CF_Leave_Days as NUMERIC(18,2)
	DECLARE @CF_Type as varchar(10)
	DECLARE @Branch_Required as INT
	--Added by Mukti(02082017)end
	
	select @Branch_Required=isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID=@CMP_ID and Setting_Name='Branch wise Leave'  
	
	if Object_ID('tempdb..#Advance_Leave_Calculation') is not null
		drop TABLE #Advance_Leave_Calculation
		
	CREATE Table #Advance_Leave_Calculation
	(
	   Cmp_ID Numeric(18,0),
	   Leave_ID Numeric(18,0),
	   Type_ID Numeric(18,0),
	   From_Date Datetime,
	   To_Date Datetime,
	   Present_Day Numeric(18,2),
	   Leave_Again_Present_Day Numeric(18,2),
	   CF_Day Numeric(18,2),
	   Actual_Present_Day Numeric(18,2),
	   Advance_Leave_Balance Numeric(18,2),
	   Recovery_Balance Numeric(18,2),
	   Duration Varchar(250),
	   CF_Type_ID Numeric(2,0)
	)
	
	Insert Into #Advance_Leave_Calculation
	(	
		Cmp_ID,
		Leave_ID,
		Type_ID,
		From_Date,
		To_Date,
		Present_Day,
		Leave_Again_Present_Day,
		CF_Day,
		Actual_Present_Day,
		Advance_Leave_Balance,
		Recovery_Balance,
		Duration,
		CF_Type_ID
	)
	SELECT 
			LM.Cmp_ID,
			LM.Leave_ID,
			qry.Type_ID,
			@Join_Date,
			(Case When qry.Duration = 'Monthly' THEN dbo.GET_MONTH_END_DATE(Month(@Join_Date),year(@Join_Date)) 
			 WHEN qry.Duration = 'Yearly' THEN 
			   (CASE WHEN qry.Release_Month > 3 THEN
				--Cast(YEAR('2016-04-16 00:00.000') + 1 as varchar(4)) + '-' + '0' + CAST((qry.Release_Month - 1) AS varchar(2)) + '-' + '31 00:00:00.000'
					(CASE When Month(@Join_Date) > 3 Then
						dbo.GET_YEAR_END_DATE(YEAR(@Join_Date) + 1, qry.Release_Month - 1,0)
					Else
						dbo.GET_YEAR_END_DATE(YEAR(@Join_Date), qry.Release_Month - 1,0)
					END)
			   ELSE
					--Cast(YEAR('2016-04-16 00:00.000') as varchar(4)) + '-' + '0' + CAST((Case When qry.Release_Month > 1 THEN (qry.Release_Month - 1) ELSE 12 END) AS varchar(2)) + '-' + '31 00:00:00.000' 
					dbo.GET_YEAR_END_DATE(YEAR(@Join_Date),12,1)
			   END)
			 ELSE
				0
			 END), 
			-- Cast(YEAR(@Join_Date) as varchar(4)) +'-'+ Cast(Month(DATEADD(DD,-1,qry.Effectivedate)) as varchar(2)) +'-'+ Cast(Day(DATEADD(DD,-1,qry.Effectivedate)) as varchar(2)) + ' 00:00:00.000' ELSE 0 END),
			LPD.Present_Day,
			LPD.Leave_Again_Present_Day,
			0,
			0,
			0,
			0,
			qry.Duration,
			qry.CF_Type_ID	
	From	T0040_LEAVE_MASTER LM WITH (NOLOCK)
			INNER JOIN 
				(Select Effective_Date as Effectivedate,Type_ID,CETD.Leave_ID,Duration,Release_Month,CF_Type_ID 
				From T0050_CF_EMP_TYPE_DETAIL CETD WITH (NOLOCK) Inner Join  
					(Select MAX(Effective_Date) as Max_Effective_date, Leave_ID From T0050_CF_EMP_TYPE_DETAIL WITH (NOLOCK) Where Cmp_Id = @Cmp_Id Group by Leave_id) Qry
						On CETD.Leave_ID = Qry.Leave_ID And CETD.Effective_Date = Qry.Max_Effective_date
				where Cmp_ID = @Cmp_ID) as qry 
				On qry.Leave_ID = LM.Leave_ID 
			INNER JOIN T0050_LEAVE_CF_Present_Day LPD WITH (NOLOCK) On LPD.Effective_Date = qry.Effectivedate and LPD.Leave_ID = qry.Leave_ID and LPD.Type_ID = qry.Type_ID
			INNER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON TM.Type_ID = LPD.Type_ID
	where	LM.Is_Advance_Leave_Balance = 1 and LM.Cmp_ID = @Cmp_ID and TM.Type_ID = @Type_ID and CF_Type_ID = 1
	UNION ALL
	SELECT	LM.Cmp_ID,
			LM.Leave_ID,
			qry.Type_ID,
			@Join_Date,
			(Case When qry.Duration = 'Monthly' THEN dbo.GET_MONTH_END_DATE(Month(@Join_Date),year(@Join_Date)) 
			 WHEN qry.Duration = 'Yearly' THEN 
			   (CASE WHEN qry.Release_Month > 3 THEN
					(CASE When Month(@Join_Date) > 3 Then
						dbo.GET_YEAR_END_DATE(YEAR(@Join_Date) + 1, qry.Release_Month - 1,0)
					Else
						dbo.GET_YEAR_END_DATE(YEAR(@Join_Date), qry.Release_Month - 1,0)
					END)
			   ELSE
					dbo.GET_YEAR_END_DATE(YEAR(@Join_Date),12,1)
			   END)
			 ELSE
				0
			 END),
			 CASE	WHEN IsNull(Allowed_CF_Join_After_Day,0) = 0 THEN LPD.CF_M_Days
					WHEN IsNull(Allowed_CF_Join_After_Day,0) < DAY(@Join_Date) THEN LPD.CF_M_DaysAfterJoining
					ELSE LPD.CF_M_Days 
			 END,
			0,
			0,
			0,
			0,
			0,
			qry.Duration,
			qry.CF_Type_ID			
	From	T0040_LEAVE_MASTER LM WITH (NOLOCK)
			INNER JOIN 
				(Select Effective_Date as Effectivedate,Type_ID,CETD.Leave_ID,Duration,Release_Month,CF_Type_ID 
				From T0050_CF_EMP_TYPE_DETAIL CETD WITH (NOLOCK) Inner Join  
					(Select MAX(Effective_Date) as Max_Effective_date, Leave_ID From T0050_CF_EMP_TYPE_DETAIL WITH (NOLOCK) Where Cmp_Id = @Cmp_Id Group by Leave_id) Qry
						On CETD.Leave_ID = Qry.Leave_ID And CETD.Effective_Date = Qry.Max_Effective_date
				where Cmp_ID = @Cmp_ID) as qry 
				On qry.Leave_ID = LM.Leave_ID 
			INNER JOIN T0050_LEAVE_CF_MONTHLY_SETTING LPD WITH (NOLOCK) On LPD.Effective_Date = qry.Effectivedate and LPD.Leave_ID = qry.Leave_ID and LPD.Type_ID = qry.Type_ID 
							AND Month(LPD.For_Date) = (CASE WHEN qry.Duration='Monthly' then MONTH(@Join_Date) Else (CASE WHEN Release_Month = 1 THEN 12 ELSE qry.Release_Month - 1 END) END)
			INNER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON TM.Type_ID = LPD.Type_ID
	where	LM.Is_Advance_Leave_Balance = 1 and LM.Cmp_ID = @Cmp_ID and TM.Type_ID = @Type_ID and CF_Type_ID = 2
	
	

	Update 	#Advance_Leave_Calculation
		Set Actual_Present_Day = Datediff(d,From_Date,To_Date) + 1,
			CF_Day = CAST((CASE When(Datediff(d,From_Date,To_Date) + 1) > Present_Day then Leave_Again_Present_Day else (Leave_Again_Present_Day * (Datediff(d,From_Date,To_Date) + 1))/ Present_Day ENd) AS numeric(18,2)),
			Advance_Leave_Balance = CAST((CASE When(Datediff(d,From_Date,To_Date) + 1) > Present_Day then Leave_Again_Present_Day else (Leave_Again_Present_Day * (Datediff(d,From_Date,To_Date) + 1))/ Present_Day ENd) AS numeric(18,2))
	Where Type_ID = @Type_ID and CF_Type_ID = 1

	
	UPDATE #Advance_Leave_Calculation set
	To_Date =  dbo.GetQuarterLastdate(From_Date)
	Where  duration = 'Quarterly'
	
	
	
	Update 	#Advance_Leave_Calculation
	Set Actual_Present_Day = DATEDIFF(MONTH,From_Date,To_Date) + 1,
		CF_Day = (Case WHEN Duration = 'Yearly' THEN (Present_Day/12) * (DATEDIFF(MONTH,From_Date,To_Date) + 1) Else Present_Day END)
	Where Type_ID = @Type_ID and CF_Type_ID = 2 

	
	 
	--Added by Mukti(02082017)start 
	if @flag ='Import'
		BEGIN		
			declare curLeaveAdvance cursor for 
				Select ALC.Leave_ID,ALC.To_Date as Leave_Upto_date,ALC.Actual_Present_Day as P_Days,
				Case When LM.Adv_Balance_Round_off <> '0' THEN 
							    CASE WHEN Adv_Balance_Round_off = 'Nearest' THEN	
										 CASE WHEN LM.Adv_Balance_Round_off_Type > 0 THEN
											ROUND(ALC.CF_Day/LM.Adv_Balance_Round_off_Type,0) * LM.Adv_Balance_Round_off_Type
										 ELSE
											ROUND(ALC.CF_Day,0)
										 END
									 WHEN Adv_Balance_Round_off = 'Upper' THEN
										 CASE WHEN LM.Adv_Balance_Round_off_Type > 0 THEN
										 	CEILING(ALC.CF_Day/LM.Adv_Balance_Round_off_Type) * LM.Adv_Balance_Round_off_Type
										 ELSE
											CEILING(ALC.CF_Day)
										 END 
									 WHEN Adv_Balance_Round_off = 'Lower' THEN
										 CASE WHEN LM.Adv_Balance_Round_off_Type > 0 THEN
											FLOOR(ALC.CF_Day/LM.Adv_Balance_Round_off_Type) * LM.Adv_Balance_Round_off_Type
										 ELSE
											FLOOR(ALC.CF_Day)
										 END 
								END
					Else  ALC.CF_Day END as Leave_Days,
				--ALC.CF_Day as Leave_Days,
				ALC.Duration
				--TM.Type_Name,LM.Leave_Name,LM.Leave_Code,ALC.Type_ID,ALC.Leave_ID,ALC.Present_Day,ALC.CF_Day as Leave_Days,
				--ALC.To_Date as Leave_Upto_date,ALC.Actual_Present_Day as P_Days,ALC.From_Date,ALC.Duration,ALC.CF_Type_ID  
				From #Advance_Leave_Calculation ALC
				INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.Leave_ID = ALC.Leave_ID
				INNER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON TM.Type_ID = ALC.Type_ID
				INNER JOIN T0050_LEAVE_DETAIL LD WITH (NOLOCK) ON LM.Leave_ID = LD.Leave_ID AND LD.Grd_ID = @Grade_ID--added by chetan 22/12/2017
				where ALC.Type_ID = @Type_ID    
				--and CAST(@Branch_ID as varchar) IN (SELECT  CAST(data as varchar) FROM dbo.Split(ISNULL(LM.Multi_Branch_ID,''), '#')) --Mukti(08092017)			
				AND ( CASE WHEN @Branch_Required = 0 THEN 1
							   WHEN @Branch_Required = 1 AND EXISTS(SELECT 1 FROM dbo.Split(ISNULL(LM.Multi_Branch_ID,''), '#') T WHERE DATA <> '' AND CAST(DATA AS NUMERIC) = @BRANCH_ID) THEN 1
							   ELSE 0
						 END) =1 --Mukti(13092017)
			open curLeaveAdvance                        
			  fetch next from curLeaveAdvance into @Leave_ID,@Leave_Upto_date,@P_Days,@CF_Leave_Days,@CF_Type
			 while @@fetch_status = 0                      
			  begin 
			  
				 EXEC P0100_LEAVE_CF_DETAIL @Leave_CF_ID=0,@Cmp_ID=@Cmp_ID,@Emp_ID=@Emp_Id,@Leave_ID=@Leave_ID,
				 @CF_For_Date=@Join_Date,@CF_From_Date=@Join_Date,@CF_To_Date=@Leave_Upto_date,@CF_P_Days=@P_Days,
				 @CF_Leave_Days=@CF_Leave_Days,@CF_Type=@CF_Type,@tran_type='Insert',@Advance_Leave_Balance=@CF_Leave_Days,@New_Joing_Falg=1
				 --,@Leave_CompOff_Dates='',@Reset_Flag=0,@User_Id=0,@IP_Address='',@Advance_Leave_Balance=0,@Advance_Leave_Recover_Balance=0,
			   		 
					 
			   fetch next from curLeaveAdvance into @Leave_ID,@Leave_Upto_date,@P_Days,@CF_Leave_Days,@CF_Type  
			  end                      
			 close curLeaveAdvance                      
			 deallocate curLeaveAdvance  
		END--Added by Mukti(02082017)end
	ELSE
		BEGIN
		
			Select	TM.Type_Name,LM.Leave_Name,LM.Leave_Code,ALC.Type_ID,
					ALC.Leave_ID,ALC.Present_Day,
					Cast( Case When LM.Adv_Balance_Round_off <> '0' THEN 
								CASE WHEN Adv_Balance_Round_off = 'Nearest' THEN	
										 CASE WHEN LM.Adv_Balance_Round_off_Type > 0 THEN
											ROUND(ALC.CF_Day/LM.Adv_Balance_Round_off_Type,0) * LM.Adv_Balance_Round_off_Type
										 ELSE
											ROUND(ALC.CF_Day,0)
										 END
									 WHEN Adv_Balance_Round_off = 'Upper' THEN
										 CASE WHEN LM.Adv_Balance_Round_off_Type > 0 THEN
										    CEILING(ALC.CF_Day/LM.Adv_Balance_Round_off_Type) * LM.Adv_Balance_Round_off_Type 
										 ELSE
											CEILING(ALC.CF_Day)
										 END
									 WHEN Adv_Balance_Round_off = 'Lower' THEN
										 CASE WHEN LM.Adv_Balance_Round_off_Type > 0 THEN
											FLOOR(ALC.CF_Day/LM.Adv_Balance_Round_off_Type) * LM.Adv_Balance_Round_off_Type
										 ELSE
											FLOOR(ALC.CF_Day)
										 END
								 END
					Else  ALC.CF_Day END as Numeric(18,2)) as Leave_Days,
					ALC.To_Date as Leave_Upto_date,
					Cast(ALC.Actual_Present_Day as Varchar(10)) + ' ' +  (Case When ALC.CF_Type_ID = 1 then 'Days' When ALC.CF_Type_ID = 2 then 'Months' else '' End) as P_Days,
					ALC.From_Date,ALC.Duration,
					ALC.CF_Type_ID,LM.Multi_Branch_ID ,LM.Adv_Balance_Round_off_Type,Adv_Balance_Round_off
			From	#Advance_Leave_Calculation ALC
					INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.Leave_ID = ALC.Leave_ID 
					INNER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON TM.Type_ID = ALC.Type_ID
					INNER JOIN T0050_LEAVE_DETAIL LD WITH (NOLOCK) ON LM.Leave_ID = LD.Leave_ID AND LD.Grd_ID = @Grade_ID--added by chetan 22/12/2017
			where	ALC.Type_ID = @Type_ID 
					--and CAST(@Branch_ID as varchar) IN (SELECT  CAST(data as varchar) FROM dbo.Split(ISNULL(LM.Multi_Branch_ID,''), '#')) --Mukti(08092017)			
					AND ( CASE WHEN @Branch_Required = 0 THEN 1
							   WHEN @Branch_Required = 1 AND EXISTS(SELECT 1 FROM dbo.Split(ISNULL(LM.Multi_Branch_ID,''), '#') T WHERE DATA <> '' AND CAST(DATA AS NUMERIC) = @BRANCH_ID) THEN 1
							   ELSE 0
						 END) =1 --Mukti(08092017)
		END
END


