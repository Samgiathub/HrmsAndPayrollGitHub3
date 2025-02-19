

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_SubExpenseREIM_CLOSING_AS_ON_DATE]
	@CMP_ID		Numeric(18,0),
	@EMP_ID		Numeric(18,0),
	@FOR_DATE	DATETIME,
	@RC_ID		Numeric(18,0),
	@Desig_ID   Numeric(18,0),
	@Def_ID		Numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @AD_Exp_Master_ID as numeric(18,0)
	Declare @AD_Exp_Name as varchar(255)
	Declare @Amount_max_Limit as numeric(18,2)
	Declare @Fixed_Max_Limit as numeric(18,2)
	Declare @Used_Amount as numeric(18,2)
	
	Declare @Temp table
	  (
		AD_Exp_Master_ID numeric(18,0),
	    SubExpense_Name varchar(255),
	    Opening numeric(18,2),
	    Used_Amount numeric(18,2),
	    Closing numeric(18,2)
	  )
	
	Declare CurSubExp cursor for
		SELECT  ALM.AD_Exp_Master_ID,ALM.AD_Exp_Name,isnull(Al.Amount_max_Limit,0)Amount_max_Limit,isnull(ALM.Fixed_Max_Limit,0)Fixed_Max_Limit 
			FROM T0050_AD_Expense_Limit_Master ALM WITH (NOLOCK)
				 left join T0050_AD_Expense_Limit AL WITH (NOLOCK) On ALM.AD_Exp_Master_ID = AL.AD_Exp_Master_ID
			Where ALM.Cmp_ID = @CMP_ID and AD_ID = @RC_ID and isnull(AL.Desig_ID,0) in (0,@Desig_ID) and  Max_Limit_Type = 'Yearly'
	Open CurSubExp
	Fetch next from CurSubExp into @AD_Exp_Master_ID,@AD_Exp_Name,@Amount_max_Limit,@Fixed_Max_Limit
	While @@fetch_status =0
		Begin
			
			if @Def_ID = 8
				Begin
					select @Used_Amount = isnull(sum(RLTD.Apr_Amount),0) From T0120_RC_Approval RA WITH (NOLOCK)
						   inner join T0110_RC_LTA_Travel_Detail RLTD WITH (NOLOCK) On RLTD.RC_App_id = RA.RC_App_id 
						   inner join T0050_AD_Expense_Limit_Master ALM WITH (NOLOCK) on ALM.AD_Exp_master_ID = RLTD.AD_Exp_master_ID 
						   where RA.Emp_id = @EMP_ID and RA.RC_id = @RC_ID and RLTD.AD_Exp_master_ID = @AD_Exp_Master_ID
						   And Apr_Date between DATEADD(YEAR,YEAR(GETDATE()) - YEAR(StDate_Year),StDate_Year) --Added By Mukti(18042016)
						   and Dateadd(dd,-1,DateAdd(yy,NoOfYear,DATEADD(YEAR,YEAR(GETDATE()) - YEAR(StDate_Year),StDate_Year)))
                           and @FOR_DATE between  DATEADD(YEAR,YEAR(GETDATE()) - YEAR(StDate_Year),StDate_Year)
                           and Dateadd(dd,-1,DateAdd(yy,NoOfYear,DATEADD(YEAR,YEAR(GETDATE()) - YEAR(StDate_Year),StDate_Year)))
						   --And Apr_Date between StDate_Year and Dateadd(dd,-1,DateAdd(yy,NoOfYear,StDate_Year)) --commented By Mukti(18042016)
         --                  and @FOR_DATE between  StDate_Year and Dateadd(dd,-1,DateAdd(yy,NoOfYear,StDate_Year))
				End
			Else if @Def_ID = 9
				Begin
				
						-- ADDED BY RAJPUT  ON 08012018 CONCERN WITH NIMESH BHAI - Reimbursement USED AMOUNT NOT COME(INDUCTOTHERM CLIENT CASE)
						--DECLARE @ST_DATE DATETIME --Added by Rajput ( Help by Nimesh Bhai ) on 03012017
						--SET @ST_DATE = CAST('2000-04-01' AS DATETIME) 
						--SET @ST_DATE = DATEADD(YYYY, YEAR(GETDATE()) - (YEAR(@ST_DATE)  + CASE WHEN MONTH(GETDATE()) > 3 THEN 0 ELSE 1 END), @ST_DATE)
				
					select @Used_Amount = isnull(sum(RDD.Apr_Amount),0) From T0120_RC_Approval RA WITH (NOLOCK)
						inner join  T0110_RC_Dependant_Detail RDD WITH (NOLOCK) On RDD.RC_App_id = RA.RC_App_id 
						inner join T0050_AD_Expense_Limit_Master ALM WITH (NOLOCK) on ALM.AD_Exp_master_ID = RDD.AD_Exp_master_ID 
						 where RA.Emp_id = @EMP_ID and RA.RC_id = @RC_ID and RDD.AD_Exp_master_ID = @AD_Exp_Master_ID
						 And Apr_Date between DATEADD(YEAR,YEAR(GETDATE()) - YEAR(StDate_Year),StDate_Year) 
						 and Dateadd(dd,-1,DateAdd(yy,NoOfYear,DATEADD(YEAR,YEAR(GETDATE()) - YEAR(StDate_Year),StDate_Year)))
                         and @FOR_DATE between  DATEADD(YEAR,YEAR(GETDATE()) - YEAR(StDate_Year),StDate_Year)
                         and Dateadd(dd,-1,DateAdd(yy,NoOfYear,DATEADD(YEAR,YEAR(GETDATE()) - YEAR(StDate_Year),StDate_Year)))
						 --And Apr_Date between StDate_Year and Dateadd(dd,-1,DateAdd(yy,NoOfYear,StDate_Year)) 
						 --and @FOR_DATE between  StDate_Year and Dateadd(dd,-1,DateAdd(yy,NoOfYear,StDate_Year))
				End
			Else
				Begin
					select @Used_Amount = isnull(sum(RRD.Apr_Amount),0) From T0120_RC_Approval RA WITH (NOLOCK)
						inner join T0110_RC_Reimbursement_Detail RRD WITH (NOLOCK) On RRD.RC_App_id = RA.RC_App_id 
						inner join T0050_AD_Expense_Limit_Master ALM WITH (NOLOCK) on ALM.AD_Exp_master_ID = RRD.AD_Exp_master_ID 
						where RA.Emp_id = @EMP_ID and RA.RC_id = @RC_ID and RRD.AD_Exp_master_ID = @AD_Exp_Master_ID
						And Apr_Date between DATEADD(YEAR,YEAR(GETDATE()) - YEAR(StDate_Year),StDate_Year) 
						and Dateadd(dd,-1,DateAdd(yy,NoOfYear,DATEADD(YEAR,YEAR(GETDATE()) - YEAR(StDate_Year),StDate_Year)))
                        and @FOR_DATE between  DATEADD(YEAR,YEAR(GETDATE()) - YEAR(StDate_Year),StDate_Year)
                        and Dateadd(dd,-1,DateAdd(yy,NoOfYear,DATEADD(YEAR,YEAR(GETDATE()) - YEAR(StDate_Year),StDate_Year)))
						--And Apr_Date between StDate_Year and Dateadd(dd,-1,DateAdd(yy,NoOfYear,StDate_Year)) 
      --                  and @FOR_DATE between  StDate_Year and Dateadd(dd,-1,DateAdd(yy,NoOfYear,StDate_Year))
				End
				

				if @Amount_max_Limit <> 0
					Begin
						insert into @Temp values(@AD_Exp_Master_ID,@AD_Exp_Name,@Amount_max_Limit,@Used_Amount,(@Amount_max_Limit-@Used_Amount))
					End
				else If @Fixed_Max_Limit <> 0
					Begin
						insert into @Temp values(@AD_Exp_Master_ID,@AD_Exp_Name,@Fixed_Max_Limit,@Used_Amount,(@Fixed_Max_Limit-@Used_Amount))
					End
				Else
					Begin
						insert into @Temp values(@AD_Exp_Master_ID,@AD_Exp_Name,0,@Used_Amount,(-@Used_Amount))
					End
					
				Fetch next from CurSubExp into @AD_Exp_Master_ID,@AD_Exp_Name,@Amount_max_Limit,@Fixed_Max_Limit
		End
	  Close CurSubExp
	  Deallocate CurSubExp
	  
	  select * from @Temp
	
END


