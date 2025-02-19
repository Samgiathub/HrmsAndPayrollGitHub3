
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_RPT_MONTHLY_PAYMENT_SLIP_VIEW_IN_SALARY_SLIP]  
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
 ,@constraint  varchar(MAX)            
 ,@Sal_Type  numeric = 0        
 ,@Salary_Cycle_id numeric = 0      
 ,@Segment_Id  numeric = 0 
 ,@Vertical_Id numeric = 0 
 ,@SubVertical_Id numeric = 0 
 ,@SubBranch_Id numeric = 0 
 ,@Status varchar(20) = '' 
  
 -- @CMP_ID   NUMERIC  
 --,@EMP_ID   NUMERIC  
 --,@PROCESS_TYPE VARCHAR(500) = 'SALARY'
 --,@AD_ID NUMERIC = 0
 --,@PAYMENT_PROCESS_ID NUMERIC(18,0) = 0
 --,@PROCESS_TYPE_ID NUMERIC(18,0) = 0
 --,@CONSTRAINT  varchar(max)=''
 --,@From_Date  datetime =null
 --,@To_Date   datetime  =null
 --,@Branch_ID  varchar(max) = '0'
 --,@Cat_ID  varchar(max) = '0'
 --,@Grd_ID   varchar(max) = '0'
 --,@Type_ID varchar(max) = '0'
 --,@Dept_ID   varchar(max) = '0'
 --,@Desig_ID   varchar(max) = '0' 
 --,@Sal_Type  numeric = 0  
 --,@Salary_Cycle_id numeric = NULL
 --,@Segment_Id  varchar(max) = '0'	 
 --,@Vertical_Id varchar(max) = '0'	 
 --,@SubVertical_Id varchar(max) = '0' 
 --,@SubBranch_Id varchar(max) = '0'
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON   


  CREATE TABLE #Process_Detail
  (
	[tran_id] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[cmp_id] [numeric](18, 0) NOT NULL,
	[emp_id] [numeric](18, 0) NOT NULL,
	[For_Date] [datetime] NOT NULL,
	[process_type_id] [numeric](18, 0) NOT NULL,
	[payment_process_id] [numeric](18, 0) NOT NULL,
	[Ad_id] [numeric](18, 0) NOT NULL,
	[Amount] [numeric](18, 2) NOT NULL,
	[Esic] [numeric](18, 2) NOT NULL,
	[Comp_Esic] [numeric](18, 2) NOT NULL,
	[Net_Amount] [numeric](18, 2) NOT NULL,
	[modify_date] [datetime] NOT NULL,
	[TDS] [numeric](18, 2) NOT NULL,
	[Loan_Id] [numeric](18, 2) NOT NULL,
	[Leave_Id] [numeric](18, 2) NOT NULL,
	[Hours] [numeric](18,0) null,
	[Punja] [numeric](18,2) not null default(0),
	[Intrim_Bonus] [Numeric](18,2) not null default(0),
	[mis_deduction] [numeric] (18,2) not null default(0), 
	[Income_Tax] [numeric](18,2) not null default(0),
	[Ad_Name] [varchar](100),
	[Loan_Amount] [Numeric](18,2) not null default(0),
	Gujarati_Alias Nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS Null,
	ESIC_Gujarati_Alias Nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS Null
 )	
  EXEC P_RPT_MONTHLY_PAYMENT_SLIP_VIEW @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,
		@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@Constraint=@Constraint,@Sal_Type=999,@Salary_Cycle_id=@Salary_Cycle_id,
		@Segment_Id=@Segment_Id,@Vertical_Id=@Vertical_Id,@SubVertical_Id=@SubVertical_Id,@SubBranch_Id=@SubBranch_Id,@process_type='Allowance',@process_type_id=0,@ad_Id=0	

	update #Process_Detail
		set Gujarati_Alias = LD.Gujarati_Alias
	from #Process_Detail PS 
		inner JOIN  T0050_AD_MASTER LD on PS.Cmp_ID = LD.CMP_ID
    and lower(PS.Ad_Name) = lower(LD.AD_NAME)

	update #Process_Detail
		set ESIC_Gujarati_Alias = LD.Gujarati_Alias
	from #Process_Detail PS 
		inner JOIN  T0050_AD_MASTER LD on PS.Cmp_ID = LD.CMP_ID
    and LD.AD_DEF_ID = 3


select * from #Process_Detail

 RETURN   
