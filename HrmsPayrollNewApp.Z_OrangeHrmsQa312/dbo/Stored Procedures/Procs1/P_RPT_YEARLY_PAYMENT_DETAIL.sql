
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_RPT_YEARLY_PAYMENT_DETAIL]  
	  @CMP_ID		NUMERIC  
	 ,@FROM_DATE	DATETIME  
	 ,@TO_DATE		DATETIME  
	 ,@BRANCH_ID	varchar(Max)   
	 ,@CAT_ID		varchar(Max)   
	 ,@GRD_ID		varchar(Max)  
	 ,@TYPE_ID		varchar(Max)  
	 ,@DEPT_ID		varchar(Max)  
	 ,@DESIG_ID		varchar(Max)  
	 ,@EMP_ID		NUMERIC  
	 ,@CONSTRAINT	VARCHAR(MAX)
	,@is_column		tinyint = 0
	,@Payment_Type  Varchar(200) = ''
	,@AD_ID	Numeric = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 IF @BRANCH_ID = '0' or @BRANCH_ID = ''
	 SET @BRANCH_ID = NULL  
    
	IF @CAT_ID = '0' or @CAT_ID = ''    
	SET @CAT_ID = NULL  
	  
	IF @GRD_ID = '0' or @GRD_ID = ''    
	SET @GRD_ID = NULL  
	  
	IF @TYPE_ID = '0' or @TYPE_ID = ''    
	SET @TYPE_ID = NULL  
	  
	IF @DEPT_ID = '0' or @DEPT_ID = ''    
	SET @DEPT_ID = NULL  
	  
	IF @DESIG_ID = '0' or @DESIG_ID = ''    
	SET @DESIG_ID = NULL  
	  
	IF @EMP_ID = 0    
	SET @EMP_ID = NULL 

	if @Payment_Type = '--Select--'
		Set @Payment_Type = ''

	If object_ID('tempdb..#Emp_Cons') is not null
		Begin 
			Drop table #Emp_Cons
		End
	
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)   
	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,'','','','',0,0,0,'',0,0   
	
	if Object_ID('tempdb..#Payment_Process') is not null
		Begin
			Drop table #Payment_Process
		End

	Create Table #Payment_Process
	(
		Emp_Id Numeric,
		--Emp_Code Varchar(50),
		--Emp_Name varchar(200),
		Process_Name Varchar(200),
		Increment_ID Numeric--,
		--Payment_Date Varchar(11)
	)

	if @Payment_Type <> ''
		Begin
			Insert Into #Payment_Process (Emp_ID,Process_Name,Increment_ID) --,Payment_Date
			Select Distinct EC.Emp_id,ME.Process_Type,EC.Increment_ID--,Replace(Convert(Varchar(11),Getdate(),104),'.','/')
			FROM MONTHLY_EMP_BANK_PAYMENT ME WITH (NOLOCK)
				 INNER JOIN #Emp_Cons EC ON EC.Emp_ID = ME.Emp_ID
				 LEFT OUTER JOIN T0301_Process_Type_Master PTM WITH (NOLOCK) On PTM.Process_Type_Id = ME.payment_process_id and PTM.Cmp_id = ME.Cmp_ID
			WHERE ME.Process_Type = @Payment_Type and ME.For_Date between @From_Date And @To_Date
				  And ME.Ad_Id = (Case when @Ad_ID <> 0 then @Ad_Id else ME.Ad_Id end) and ME.Cmp_ID = @CMP_ID
		End
	Else
		Begin
			Insert Into #Payment_Process (Emp_ID,Process_Name,Increment_ID) --,Payment_Date
			Select Distinct EC.Emp_id, ME.Process_Type,EC.Increment_ID--,Replace(Convert(Varchar(11),Getdate(),104),'.','/') 
			FROM MONTHLY_EMP_BANK_PAYMENT ME WITH (NOLOCK)
				 INNER JOIN #Emp_Cons EC ON EC.Emp_ID = ME.Emp_ID
				 LEFT OUTER JOIN T0301_Process_Type_Master PTM WITH (NOLOCK) On PTM.Process_Type_Id = ME.payment_process_id and PTM.Cmp_id = ME.Cmp_ID
			WHERE ME.For_Date between @From_Date And @To_Date and ME.Cmp_ID = @CMP_ID
		End
	

	Declare @For_Date Datetime
	Set @For_Date = @From_Date

	Declare @Qry Varchar(2000)
	Set @Qry = ''

	Declare @MonthName Varchar(20)
	Set @MonthName = ''


	While @For_Date <= @To_Date
		Begin
			
			Set @MonthName = Upper(LEFT(DATENAME(MONTH,@For_Date),3)) + '_' + Cast(Year(@For_Date) as varchar(4)) 

			Set @Qry = 'ALTER TABLE #Payment_Process ADD ' + @MonthName + ' varchar(20) not null default(0)'
			Exec(@Qry)

			if @Payment_Type <> ''
				Begin
					Set @Qry = ''
					Set @Qry = 'Update P Set [' + @MonthName + ']= Net_Amount
								From MONTHLY_EMP_BANK_PAYMENT ME Inner Join #Payment_Process P On ME.Emp_ID = P.Emp_ID
								LEFT OUTER JOIN T0301_Process_Type_Master PTM On PTM.Process_Type_Id = ME.payment_process_id and PTM.Cmp_id = ME.Cmp_ID
								Where ME.Process_Type = ''' + @Payment_Type + ''' And Month(For_Date) = ' + Cast(Month(@For_Date) as varchar(2)) + ' 
								And Year(For_Date) = ' + Cast(Year(@For_Date) As varchar(4)) + '
								And ME.Ad_Id = (Case when ' + Cast(@Ad_ID as varchar(10)) + ' <> 0 then ' +  Cast(@Ad_ID as varchar(10)) + ' else ME.Ad_Id end) 
								And ME.Cmp_ID = ' + Cast(@CMP_ID as Varchar(10))
					Exec(@Qry)
				End
			Else
				Begin
					Set @Qry = ''
					Set @Qry = 'Update P Set [' + @MonthName + ']= Net_Amount
								From MONTHLY_EMP_BANK_PAYMENT ME Inner Join #Payment_Process P On ME.Emp_ID = P.Emp_ID and ME.Process_Type = P.Process_Name
								LEFT OUTER JOIN T0301_Process_Type_Master PTM On PTM.Process_Type_Id = ME.payment_process_id and PTM.Cmp_id = ME.Cmp_ID
								Where Month(For_Date) = ' + Cast(Month(@For_Date) as varchar(2)) + ' 
								And Year(For_Date) = ' + Cast(Year(@For_Date) As varchar(4)) + '
								And ME.Cmp_ID = ' + Cast(@CMP_ID as Varchar(10))
					Exec(@Qry)
				End
			Set @For_Date = DATEADD(mm,1,@For_Date)
		End

		Set @Qry = ''
		Set @Qry = 'ALTER TABLE #Payment_Process ADD TOTAL varchar(20) not null default(0)'
		Exec(@Qry)

		if @Payment_Type <> ''
			Begin
				Set @Qry = ''
				Set @Qry = 'Update P Set [TOTAL]= Qry.Net_Amount
					FROM (Select Sum(Net_Amount) As Net_Amount, ME.Emp_Id
								From	MONTHLY_EMP_BANK_PAYMENT ME WITH (NOLOCK) Inner Join #Payment_Process P On ME.Emp_ID = P.Emp_ID
								LEFT OUTER JOIN T0301_Process_Type_Master PTM WITH (NOLOCK) On PTM.Process_Type_Id = ME.payment_process_id and PTM.Cmp_id = ME.Cmp_ID
								Where	ME.Process_Type=''' + @Payment_Type + '''
										And ME.Ad_Id = (Case when ' + Cast(@Ad_ID as varchar(10)) + ' <> 0 then ' +  Cast(@Ad_ID as varchar(10)) + ' else ME.Ad_Id end) 
										And For_Date Between ''' + cast(@From_Date as varchar(11)) + ''' And ''' + cast(@To_Date as varchar(11)) + '''' + ' 
										And ME.Cmp_ID = ' + Cast(@CMP_ID as Varchar(10))  + '
										Group by ME.Emp_Id
						 ) Qry  INNER JOIN #Payment_Process P ON Qry.Emp_Id = P.Emp_Id'
				Exec(@Qry)
			End
		Else
			Begin
				Set @Qry = ''
				Set @Qry = 'Update P Set [TOTAL]= Qry.Net_Amount
					FROM (Select Sum(Net_Amount) As Net_Amount, ME.Emp_Id,ME.Process_Type
								From	MONTHLY_EMP_BANK_PAYMENT ME WITH (NOLOCK) Inner Join #Payment_Process P On ME.Emp_ID = P.Emp_ID and ME.Process_Type = P.Process_Name
								LEFT OUTER JOIN T0301_Process_Type_Master PTM WITH (NOLOCK) On PTM.Process_Type_Id = ME.payment_process_id and PTM.Cmp_id = ME.Cmp_ID
								Where	For_Date Between ''' + cast(@From_Date as varchar(11)) + ''' And ''' + cast(@To_Date as varchar(11)) + '''' + '
										And ME.Cmp_ID = ' + Cast(@CMP_ID as Varchar(10))  + ' 
										Group by ME.Emp_Id,ME.Process_Type
						 ) Qry  INNER JOIN #Payment_Process P ON Qry.Emp_Id = P.Emp_Id and Qry.Process_Type = P.Process_Name'
				Exec(@Qry)
			End
		

	Select 
		EM.Alpha_Emp_Code,
		EM.Emp_Full_Name,
		BM.Branch_Name,
		GM.Grd_Name,
		DM.Dept_Name,
		DE.Desig_Name,
		P.*
		From #Payment_Process P 
	Inner Join T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID = P.Emp_Id
	Inner Join T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = P.Increment_ID
	Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = I.Branch_ID
	Inner Join T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.Grd_ID = I.Grd_ID
	Left Outer Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.Dept_Id = I.Dept_ID
	Left Outer Join T0040_DESIGNATION_MASTER DE WITH (NOLOCK) ON DE.Desig_ID = I.Desig_Id
	



