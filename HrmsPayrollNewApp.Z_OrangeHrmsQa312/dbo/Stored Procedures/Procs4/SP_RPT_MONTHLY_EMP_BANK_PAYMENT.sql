
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_MONTHLY_EMP_BANK_PAYMENT]  
  @Cmp_ID   numeric  
 ,@From_Date  datetime  
 ,@To_Date   datetime  
 ,@Branch_ID  numeric  
 ,@Cat_ID   numeric   
 ,@Grd_ID   numeric  
 ,@Type_ID   numeric  
 ,@Dept_ID   numeric  
 ,@Desig_ID   numeric  
 ,@Emp_ID   numeric  
 ,@constraint  varchar(max)  
 ,@Sal_Type  numeric = 0  
 ,@Bank_ID  numeric = 0  
 ,@Payment_mode varchar(20) ='Transfer'  
 ,@salary_status  varchar(50) = 'All'
 ,@Director_details tinyint = 0   
 ,@Salary_Cycle_id numeric = NULL
 ,@Segment_Id  numeric = 0		 
 ,@Vertical_Id numeric = 0		 
 ,@SubVertical_Id numeric = 0	 
 ,@SubBranch_Id numeric = 0
 ,@process_type varchar(500) = 'Salary'
 ,@ad_Id numeric = 0
 		 
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON   
   
 IF @Branch_ID = 0    
  set @Branch_ID = null  
    
 IF @Cat_ID = 0    
  set @Cat_ID = null  
  
 IF @Grd_ID = 0    
  set @Grd_ID = null  
  
 IF @Type_ID = 0    
  set @Type_ID = null  
  
 IF @Dept_ID = 0    
  set @Dept_ID = null  
  
 IF @Desig_ID = 0    
  set @Desig_ID = null  
  
 IF @Emp_ID = 0    
  set @Emp_ID = null  
    
 if @Bank_ID =0  
  set @Bank_ID = null  
  IF @Salary_Cycle_id = 0	
	set @Salary_Cycle_id = null	
	If @Segment_Id = 0		
	set @Segment_Id = null
	If @Vertical_Id = 0		
	set @Vertical_Id = null
	If @SubVertical_Id = 0	
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	
	set @SubBranch_Id = null	

   if @process_type <> 'Allowance' --@process_type = 'Salary' or  @process_type = 'Bonus' or  @process_type = 'Leave Encashment'  -- Change Condition by Hardik 10/04/2018 for AIA
  begin
	set @ad_Id=0
  end
  
  
 CREATE table #Emp_Cons 
 (      
   Emp_ID numeric ,     
   Branch_ID numeric,
   Increment_ID numeric    
 )    
   
 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 

 if @Payment_mode = 'Transfer'  
  set @Payment_mode = 'Bank Transfer' 
  
  if @Payment_mode =''
	set @Payment_mode = null 

 --Declare @Temp table  
 --(  
 --Cmp_ID numeric(18,0),  
 --Total_Amount numeric(18,2),
 --Bank_Id Numeric(18,0)  ,
 --Payment_mode varchar(100)  
 --) 
 
 --COMMENTED OLD METHOD AND ADDED NEW ONE BY RAMIZ ON 22/11/2018-- 
   CREATE TABLE #BANK_DETAILS
	 (  
		Cmp_ID numeric(18,0),  
		Total_Amount numeric(18,2),
		Bank_Id Numeric(18,0)  ,
		Payment_mode varchar(100)  
	 )  
  

  
    INSERT INTO #BANK_DETAILS
	SELECT @Cmp_id,ISNULL(SUM(ISNULL(Net_Amount,0)),0 ),ISNULL(Emp_Bank_ID,0),Payment_mode
	FROM MONTHLY_EMP_BANK_PAYMENT WITH (NOLOCK)
		INNER JOIN #Emp_Cons ON MONTHLY_EMP_BANK_PAYMENT.emp_id = #Emp_Cons.emp_id
  	WHERE MONTHLY_EMP_BANK_PAYMENT.Cmp_ID = @Cmp_Id   
		AND isnull(MONTHLY_EMP_BANK_PAYMENT.Emp_Bank_ID,0) = ISNULL(@Bank_ID,ISNULL(MONTHLY_EMP_BANK_PAYMENT.Emp_Bank_ID,0))
		AND MONTHLY_EMP_BANK_PAYMENT.Payment_mode = ISNULL(@Payment_mode,MONTHLY_EMP_BANK_PAYMENT.Payment_mode)  
		AND MONTHLY_EMP_BANK_PAYMENT.For_Date >=@From_Date and MONTHLY_EMP_BANK_PAYMENT.For_Date  <= @To_Date 
		AND ad_id = @ad_id
		AND 1 = (case when MONTHLY_EMP_BANK_PAYMENT.Process_Type = @process_type then 1 when @ad_Id > 0 then 1 else 0 end)
	GROUP BY Emp_Bank_ID,Payment_mode
	

   
	SELECT Emp_full_Name,Branch_Address,branch_name,Comp_name,Grd_Name,DAteName(M,MS.For_date)as Month,YEar(MS.For_date)as Year ,Branch_NAme,Comp_Name  
		   ,Alpha_Emp_Code as EMP_CODE,Type_Name,Dept_Name,Desig_Name,PAN_no,DAte_of_Birth,Date_of_Join
		   ,SSN_No as PF_No,SIN_No as ESIC_No ,dbo.F_Number_TO_Word(BNKD.Total_Amount) as Net_Amount_In_Word  
		   ,bk.Bank_Name ,CMP_NAME,CMP_ADDRESS, cm.Image_name Cmp_Image_Name
		   ,Branch_Code,DATE_OF_JOIN,BK.Bank_Ac_No As Cmp_Acc_No,MS.Emp_Bank_AC_No as Inc_Bank_Ac_no ,MS.Emp_Bank_AC_No  as Inc_Bank_Ac_no1
		   --Case When Bank_Name like '%UTI%' or Bank_Name like '%Axis%' Then Cast(RIGHT ('000000000000' + cast(tem.Total_Amount  as varchar(15)),15) As varchar(20)) Else CAST(tem.Total_Amount   as varchar(30)) End As Total_Amount,
		   ,BNKD.Total_Amount  As Total_Amount -- As per discussion with maitry and hardikbhai for Amazon client on 08122016
		   ,dbo.F_Number_TO_Word(BNKD.Total_Amount) as Total_Amount_In_Word, MS.Payment_mode  as Payment_Mode,bk.Bank_ID,bk.Bank_Address 
		   ,(Case when I_Q.Bank_ID = MS.Emp_Bank_ID THEN E.Ifsc_Code WHEN E.Bank_ID_Two = MS.Emp_Bank_ID THEN E.Ifsc_Code_Two End) as Ifsc_Code,BM.Branch_ID,cast(e.Alpha_Emp_Code as nvarchar(50)) as Alpha_Emp_Code
		   --Case When Bank_Name like '%UTI%' or Bank_Name like '%Axis%' Then Cast(RIGHT ('000000000000' + cast(Net_Amount as varchar(15)),15) As varchar(20)) Else CAST(Net_Amount as varchar(30)) End As Net_Amt
		   ,Net_Amount As Net_Amt -- As per discussion with maitry and hardikbhai for Amazon client on 08122016
		   ,ms.process_type,ms.ad_id,ms.For_date,ms.payment_Date,MS.Status , CCM.Center_Code , BS.Segment_Code
	FROM MONTHLY_EMP_BANK_PAYMENT MS WITH (NOLOCK)
		INNER JOIN		 T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID 
		INNER JOIN		 #Emp_Cons EC on MS.Emp_ID = EC.Emp_ID
		INNER JOIN		 T0095_Increment I_Q WITH (NOLOCK) on EC.Increment_ID = I_Q.Increment_ID 
		LEFT JOIN		 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
		LEFT OUTER JOIN  T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
		LEFT OUTER JOIN  T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
		LEFT OUTER JOIN  T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
		INNER JOIN		 T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID 
		LEFT OUTER JOIN	 T0040_Bank_master bk WITH (NOLOCK) on MS.Emp_Bank_ID = Bk.Bank_ID 
		INNER JOIN		 T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID
		LEFT OUTER JOIN  T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON CCM.Center_ID = I_Q.Center_ID
		LEFT OUTER JOIN  T0040_Business_Segment BS	WITH (NOLOCK) ON BS.Segment_ID = I_Q.Segment_ID
		LEFT JOIN		 #BANK_DETAILS BNKD on ms.Cmp_ID = BNKD.Cmp_ID and isnull(ms.Emp_Bank_ID,0) = BNKD.Bank_Id and ms.Payment_Mode =  BNKD.Payment_mode	
	WHERE E.Cmp_ID = @Cmp_Id   
		and isnull(MS.Emp_Bank_ID,0) = isnull(@Bank_ID,isnull(MS.Emp_Bank_ID,0))
		and I_q.Payment_mode = isnull(@Payment_mode,I_q.Payment_mode)  
		and MS.For_Date >=@From_Date and MS.For_Date  <=@To_Date 
		and ad_id = @ad_id
		and 1 = (case when ms.Process_Type = @process_type  then 1 when @ad_Id >0 then 1 else 0 end)
		and 1=(case when (MS.Status = @salary_status) or (@salary_status = 'All') then 1 else 0 end)
	   
 RETURN   
  
  
  

