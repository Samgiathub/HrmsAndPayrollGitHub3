

---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Reim_Report]

@Cmp_ID numeric,
@RC_App_ID numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

Declare @RC_ID as numeric
Declare @Emp_ID as numeric
Declare @Block_Period as varchar(255)

select @RC_ID = RC_ID,@Emp_ID=Emp_ID,@Block_Period=Block_Period
		from T0110_RC_LTA_Travel_Detail WITH (NOLOCK)
		where Cmp_ID=@Cmp_ID and RC_APP_ID=@RC_App_ID

if isnull(@Block_Period,'') = ''  --Added By Ripal 20Aug2014
	Begin
		select @RC_ID = RC_ID,@Emp_ID = Emp_ID,@Block_Period = FY
				from T0100_RC_Application WITH (NOLOCK) where Cmp_ID=@Cmp_ID and RC_APP_ID=@RC_App_ID
	End

	 Create table #Temp_Table
	 (
		row_ID    int identity,
		B_Year integer,
		Tax  varchar(10) Default '',
		Non_Tax varchar(10) default ''		
	 )	
	 
	 insert into #Temp_Table
	Select data,0,0 From dbo.split(@Block_Period,'-')
	
	Declare @First as numeric
	Declare @Last as numeric
	
	Select @First = B_Year from   #Temp_Table where row_ID=1
	Select @Last = B_Year from   #Temp_Table where row_ID=2
	
	delete from #Temp_Table
	
	
	
	Declare @Start_date as Datetime
	Declare @End_date as Datetime
	Declare @Taxable_Count as numeric
	Declare @Non_Taxable_Count as numeric
	WHILE (@First <=@Last)
		BEGIN
		
		  			set @Start_date = '01/Jan/'+cast(@First as varchar(4))
					set @End_date ='31/Dec/'+cast(@First as varchar(4))
					
				
				
				if 	exists(SELECT 1 From V0100_RC_Application A 
				Where  APP_Date BETWEEN @Start_date and @End_date AND A.Cmp_ID=@cmp_ID and A.Emp_ID=@emp_ID AND APP_Status=1 AND 
				isnull(A.Tax_Amount,0) <> 0 and A.RC_ID=@RC_ID)
				begin
				
				select @Taxable_Count =COUNT(*)   
				From V0100_RC_Application A 
				Where  APR_Date BETWEEN @Start_date and @End_date AND A.Cmp_ID=@cmp_ID and A.Emp_ID=@emp_ID AND APP_Status=1 AND 
				isnull(A.Tax_Amount,0) <> 0 and A.RC_ID=@RC_ID	
				
				select @Non_Taxable_Count =COUNT(*) 
				From V0100_RC_Application A 
				Where  APR_Date BETWEEN @Start_date and @End_date AND A.Cmp_ID=@cmp_ID and A.Emp_ID=@emp_ID AND APP_Status=1 AND 
				isnull(A.Tax_Free_Amount,0) <> 0 and A.RC_ID=@RC_ID	 
				
				end
				else
				BEGIN
				
				select @Taxable_Count =COUNT(*)   
				From V0100_RC_Application A 
				Where  APP_Date BETWEEN @Start_date and @End_date AND A.Cmp_ID=@cmp_ID and A.Emp_ID=@emp_ID AND APP_Status=0 AND 
				isnull(A.Tax_Amount,0) <> 0 and A.RC_ID=@RC_ID	
				
				select @Non_Taxable_Count =COUNT(*) 
				From V0100_RC_Application A 
				Where  APP_Date BETWEEN @Start_date and @End_date AND A.Cmp_ID=@cmp_ID and A.Emp_ID=@emp_ID AND APP_Status=0 AND 
				isnull(A.Tax_Free_Amount,0) <> 0 and A.RC_ID=@RC_ID	
				
				
				end
					
				
				
				insert into #Temp_Table values(@First,@Taxable_Count,@Non_Taxable_Count)
				
				set @Taxable_Count =0
				set @Non_Taxable_Count =0
		
			SET @First = @First + 1
		END

Select * from V0100_RC_Application where Cmp_ID=@Cmp_ID and RC_APP_ID=@RC_App_ID 
Select RLTD.*,VADE.AD_Exp_Name from T0110_RC_LTA_Travel_Detail RLTD WITH (NOLOCK)
		left join V0050_AD_Expense_Limit_Master VADE On VADE.AD_Exp_Master_ID = RLTD.AD_Exp_Master_ID
		where RLTD.Cmp_ID=@Cmp_ID and RLTD.RC_APP_ID=@RC_App_ID
		
Select RDD.*,VADE.AD_Exp_Name from T0110_RC_Dependant_Detail RDD WITH (NOLOCK)
		left join V0050_AD_Expense_Limit_Master VADE On VADE.AD_Exp_Master_ID = RDD.AD_Exp_Master_ID
		where RDD.Cmp_ID=@Cmp_ID and RDD.RC_APP_ID=@RC_App_ID
		
Select RRD.*,VADE.AD_Exp_Name from T0110_RC_Reimbursement_Detail RRD WITH (NOLOCK)
		left join V0050_AD_Expense_Limit_Master VADE On VADE.AD_Exp_Master_ID = RRD.AD_Exp_Master_ID
		where RRD.Cmp_ID=@Cmp_ID and RRD.RC_APP_ID=@RC_App_ID

select * from #Temp_Table


Declare @Min_Date as Datetime
Declare @Max_Date as Datetime

  CREATE TABLE #LEAVEDATA
  (
   LEAVEFROM VARCHAR(10),
   LEAVETO VARCHAR(10)
  )

	IF EXISTS(
				SELECT	 MIN(FROM_DATE) AS LEAVEFROM,MAX(TO_DATE) AS LEAVETO,RC_APP_ID 
				FROM	 T0110_RC_LTA_TRAVEL_DETAIL WITH (NOLOCK) 
				WHERE	 CMP_ID=@CMP_ID AND RC_APP_ID=@RC_APP_ID
				GROUP BY RC_APP_ID
			 )
			BEGIN			
					SELECT	@MIN_DATE = MIN(FROM_DATE) ,@MAX_DATE = MAX(TO_DATE) 
					FROM	T0110_RC_LTA_TRAVEL_DETAIL WITH (NOLOCK)
					WHERE	CMP_ID=@CMP_ID AND RC_APP_ID=@RC_APP_ID
					GROUP BY RC_APP_ID
					-- Commented By Jimit 31032018  Report is not  open at WCL (dataset is not in use for report)
					 --select convert(varchar(10), LAD.From_Date,103) as LeaveFrom,convert(varchar(10), LAD.To_Date,103) as LeaveTo		
					 -- from T0120_LEAVE_APPROVAL LA inner join T0130_LEAVE_APPROVAL_DETAIL  LAD ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID
					 --inner join T0040_LEAVE_MASTER LM on LAD.Leave_ID = LM.Leave_ID where isnull(LM.Effect_Of_LTA,0) = 1
					 --and LAD.From_Date between @Min_Date and @Max_Date and LA.Emp_ID=@Emp_ID and LAD.cmp_ID=@Cmp_ID
		 
					 INSERT INTO #LEAVEDATA
					 SELECT CONVERT(VARCHAR(10), LAD.FROM_DATE,103) AS LEAVEFROM,CONVERT(VARCHAR(10), LAD.TO_DATE,103) AS LEAVETO 
					 FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK) INNER JOIN T0130_LEAVE_APPROVAL_DETAIL  LAD WITH (NOLOCK) ON LA.LEAVE_APPROVAL_ID = LAD.LEAVE_APPROVAL_ID
							INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LAD.LEAVE_ID = LM.LEAVE_ID 
					 WHERE	ISNULL(LM.EFFECT_OF_LTA,0) = 1
							AND (@MIN_DATE BETWEEN LAD.FROM_DATE AND LAD.TO_DATE OR @MAX_DATE BETWEEN  LAD.FROM_DATE AND LAD.TO_DATE)
							AND LA.EMP_ID=@EMP_ID AND LAD.CMP_ID=@CMP_ID					
			END
		IF NOT EXISTS(SELECT 1 FROM #LEAVEDATA)
			 BEGIN
				  INSERT INTO #LEAVEDATA
				  SELECT 'N/A' AS LEAVEFROM,'N/A' AS LEAVETO--,@RC_APP_ID 				
			 END	
		
		SELECT * FROM #LEAVEDATA	
		
END


