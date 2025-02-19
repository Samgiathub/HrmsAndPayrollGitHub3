


---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE  PROCEDURE [dbo].[Set_Salary_Register_Amount_NIIT_Lable_Nikunj]
 @Cmp_ID		numeric
,@From_Date		datetime
,@To_Date		datetime 
,@Branch_ID		numeric   
,@Cat_ID		numeric  
,@Grd_ID		numeric 
,@Type_ID		numeric  
,@Dept_ID		numeric  
,@Desig_ID		numeric 
,@Emp_ID		numeric 
,@Constraint	varchar(5000) 
,@Sal_Type    numeric


AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DEclare @month as numeric(18,0)
	Declare @Year as numeric(18,0)
	
/*	Declare @Payement varchar(50) 
	Declare @Transaction_ID Numeric	
	set @Payement = ''
	set @Transaction_ID=0
	
	 if isnull(@Payement,'') = ''
		set  @Payement = ''
	Declare @Row_id as numeric
	Declare @Label_Name as varchar(100)
	Declare @Total_Allowance as numeric(22,2) 
	Declare @Is_Search as varchar(30)
	Declare @Basic_salary as numeric(22,2)
	Declare @Total_Allow as numeric (22,2)
	declare @Value_String as varchar(250)
	Declare @Amount as numeric (22,2)

	Declare @OTher_Allow as numeric(22,2)
	Declare @CO_Amount as numeric(22,2)
	Declare @Total_Deduction as numeric(22,2)
	Declare @Other_Dedu as numeric(22,2)
	Declare @Loan as numeric(22,2)
	Declare @Advance as numeric(22,2)
	Declare @Net_Salary as numeric(22,2)
	Declare @Revenue_amt numeric(10)
	Declare @Lwf_amt numeric(10)
	Declare @PT as numeric(22,2)
	Declare @LWF as numeric(22,2)
	Declare @Revenue as numeric(22,2)
	Declare @Allow_Name as varchar(100)
	Declare @P_Days as numeric(22,2)
	Declare @A_Days as numeric(22,2)
	Declare @Act_Gross_salary as numeric(18,2)	
	DEclare @TDS numeric(18,2)
	Declare @Settl numeric(22,2)
	*/
	
	IF	EXISTS (SELECT * FROM [tempdb].dbo.sysobjects where name like '#Temp_report_Label')		
			BEGIN
				DROP TABLE #Temp_report_Label
			END
		/*IF	EXISTS (SELECT * FROM [tempdb].dbo.sysobjects where name like '#Temp_Salary_Muster_Report')		
			BEGIN
				DROP TABLE #Temp_Salary_Muster_Report
			END
						*/			
	
	CREATE table #Temp_report_Label
	(
	Row_ID  numeric(18, 0) NOt null,
	Label_Name  varchar(200) not null,
	Income_Tax_ID numeric(18, 0) null,
	Is_Active	varchar(1) null
	)
	
	--ALTER index idx_1 on #Temp_report_Label (Row_ID)
	Create CLUSTERED INDEX ind_temp ON #Temp_report_Label(Row_ID)
	Create NONCLUSTERED INDEX ind_temp6 ON #Temp_report_Label(Label_Name)

		set @month = month(@From_Date)
	set @Year = Year(@From_Date)
	  
	EXEC Set_Salary_Register_Lable @Cmp_ID,@month,@Year
	
	Select Distinct Label_name,Row_ID  from dbo.#Temp_report_Label order by Row_ID
		
	RETURN

	/*ALTER table dbo.#Temp_Salary_Muster_Report		
	(
		Emp_ID numeric(18, 0) Not Null,
		Cmp_ID numeric(18, 0) Not Null,
		Transaction_ID numeric(18, 0) Not Null,
		Month numeric(18, 0) Not Null,
		Year numeric(18, 0) Not Null,
		Label_Name varchar(200) Not Null,
		Amount numeric(18, 2) null,
		Value_String varchar(250) Not Null,
		INCOME_TAX_ID numeric(18, 0)  Default 0,
		Row_id numeric(18, 0) Null
	)
	Create CLUSTERED INDEX ind_temp1	ON #Temp_Salary_Muster_Report(Row_id)
	Create NONCLUSTERED INDEX ind_temp2 ON #Temp_Salary_Muster_Report(Emp_ID)
	Create NONCLUSTERED INDEX ind_temp3 ON #Temp_Salary_Muster_Report(Cmp_ID)
	Create NONCLUSTERED INDEX ind_temp4 ON #Temp_Salary_Muster_Report(Label_Name)
	Create NONCLUSTERED INDEX ind_temp5 ON #Temp_Salary_Muster_Report(Value_String)*/
		
/*	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null*/
		
		
	

