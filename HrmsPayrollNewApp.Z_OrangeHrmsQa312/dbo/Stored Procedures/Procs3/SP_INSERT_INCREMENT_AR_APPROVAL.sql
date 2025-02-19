

/*
	Author : Hardik Barot
	Date : 13/04/2016
	Purpose : Insert New Increment from Old Increment when Optional Allowance Approved, it will copy increment from Last Increment and Insert New Increment Entry
*/
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_INSERT_INCREMENT_AR_APPROVAL]
	@Cmp_ID						numeric, 
	@Emp_Id						numeric,
	@Old_Increment_Id			numeric,
	@Increment_Id				numeric output,
	@Increment_Effective_Date	DateTime
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare	@Basic_Salary				numeric(18,2)
Declare @Gross_Salary				numeric(18,2)
Declare @CTC						numeric(18,2)
DECLARE @Increment_Type varchar(100)	

Declare @Increment_Date				Datetime
Declare @Division_ID				numeric
Declare @Grd_ID						numeric
Declare @Dept_ID					numeric
Declare @Product_ID					numeric
Declare @Desig_Id					numeric
Declare @Type_ID					numeric
Declare @Branch_ID					numeric
Declare @Cat_Id						numeric
Declare @Bank_ID					numeric
Declare @Currency_ID				numeric
Declare @Wages_Type					varchar(10)
Declare @Salary_Basis_On			varchar(10) 
Declare @Payment_Mode				varchar(20) 
Declare @Inc_Bank_AC_No				varchar(50)
Declare @Emp_OT						varchar(1)  
Declare @Emp_OT_Min_Limit			varchar(10) 
Declare @Emp_OT_Max_Limit			varchar(10)	 
Declare @Increment_Per				numeric(18,2) 
Declare @Increment_Amount			numeric(18,2)
Declare @Old_Basic					numeric(18,2)
declare @Old_Gross					numeric(18,2) 
Declare @Old_CTC					numeric(18,2) 

Declare @Emp_Late_Mark				char(1) 
Declare @Emp_Full_PF				char(1) 
Declare @Emp_PT						tinyint
Declare @Fix_Salary					char(1)
Declare @Emp_part_Time				numeric(1,0)
Declare @Late_Dedu_Type				varchar(10)
Declare @Emp_Late_Limit				varchar(10)
Declare @Emp_PT_Amount				numeric(18,2)
Declare @Emp_Childran				numeric 
Declare @Login_ID					numeric(18)
Declare @Yearly_Bonus_Amount		numeric(22,2)
Declare	@Deputation_End_Date		datetime
declare @auto_vpf					char(1) 

declare @Salary_Cycle_id			NUMERIC
declare @Vertical_ID				NUMERIC
declare @SubVertical_ID				NUMERIC
declare @subBranch_ID				NUMERIC
declare @Center_ID					NUMERIC
DECLARE @Segment_ID					NUMERIC
DECLARE @Fix_OT_Hour_Rate_WD		NUMERIC
DECLARE @Fix_OT_Hour_Rate_WO_HO		NUMERIC
Declare @alpha_Emp_Code Varchar(500)
Declare @Reason_ID					numeric

set @Salary_Cycle_id  = 0
set @Vertical_ID	  = 0
set @SubVertical_ID	  = 0
set @subBranch_ID	  = 0
set @alpha_Emp_Code = 0
Set @Reason_ID = 0


			Select @alpha_Emp_Code = Alpha_Emp_Code From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_Id
			
			set @Increment_Date = getdate()

			select 	@Basic_Salary = I.Basic_Salary,@Gross_Salary = I.Gross_Salary,@CTC = I.CTC, @Grd_ID =I.Grd_ID,@Dept_ID =Dept_ID ,
					@Desig_Id =I.Desig_Id,@Type_ID =Type_ID,@Branch_ID=Branch_ID,@Cat_Id=i.Cat_Id,@Bank_ID=Bank_ID
					,@Currency_ID=Curr_ID,@Wages_Type=Wages_Type,@Salary_Basis_On=Salary_Basis_On,@Payment_Mode=Payment_Mode
					,@Inc_Bank_AC_No =Inc_Bank_AC_No,@Emp_OT=Emp_OT,@Emp_OT_Min_Limit=Emp_OT_Min_Limit,@Emp_OT_Max_Limit=Emp_OT_Max_Limit
					,@Old_Basic=Basic_salary,@Old_Gross=Gross_Salary,@Old_CTC = CTC
					,@Emp_Late_Mark=isnull(Emp_Late_mark,0),@Emp_Full_PF=Emp_Full_PF,@Emp_PT=Emp_PT
					,@Fix_Salary=Emp_Fix_Salary,@Emp_part_Time=Emp_part_Time,@Late_Dedu_Type=Late_Dedu_Type,@Emp_Late_Limit=Emp_Late_Limit
					,@Emp_PT_Amount=Emp_PT_Amount,@Emp_Childran=Emp_Childran,@Login_ID=Login_ID,@Yearly_Bonus_Amount = Yearly_Bonus_Amount
					,@Deputation_End_Date=Deputation_End_Date
					,@auto_vpf=Emp_Auto_Vpf,@Salary_Cycle_id = SalDate_id,@Vertical_ID = Vertical_ID,@SubVertical_ID =SubVertical_ID,@subBranch_ID = subBranch_ID 
					,@Center_ID=Center_ID,@Segment_ID=Segment_ID,@Fix_OT_Hour_Rate_WD=Fix_OT_Hour_Rate_WD,@Fix_OT_Hour_Rate_WO_HO=Fix_OT_Hour_Rate_WO_HO
				from T0095_INCREMENT i WITH (NOLOCK) inner join
					T0040_GRADE_MASTER gm WITH (NOLOCK) on gm.Grd_ID = i.Grd_ID
				Where i.Increment_ID = @Old_Increment_Id And i.Emp_ID = @Emp_Id
			
					
			set @Increment_Per  = 0
			Set @Increment_Type = 'Increment'
			Set @Increment_Amount = 0
				
			set @Increment_ID = 0
			

				EXEC P0095_INCREMENT_INSERT @Increment_ID output ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_id,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Currency_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_Salary
					,@Increment_Type,@Increment_Date,@Increment_effective_Date,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Increment_Per,@Increment_Amount,@Old_Basic,@Old_Gross,''
					,@Emp_Late_Mark,@Emp_Full_PF,@Emp_PT,@Fix_Salary,@Emp_Late_Limit,@Late_Dedu_Type,@Emp_part_Time,0,@Login_ID,@Yearly_Bonus_Amount,@Deputation_End_Date,0,1,0,@CTC,@Pre_CTC_Salary = @Old_CTC,@Increment_Mode = 1,@Salary_Cycle_id = @Salary_Cycle_id,@auto_vpf=@auto_vpf,@Vertical_ID =@Vertical_ID,@SubVertical_ID =@SubVertical_ID,@subBranch_ID = @subBranch_ID -- Added by Gadriwala muslim 07042013						
					,@Center_ID=@Center_ID,@Segment_ID=@Segment_ID,@Fix_OT_Hour_Rate_WD=@Fix_OT_Hour_Rate_WD,@Fix_OT_Hour_Rate_WO_HO=@Fix_OT_Hour_Rate_WO_HO 
					,@Reason_ID = @Reason_ID,@Reason_Name = ''
					
				Update T0080_EMP_MASTER set Basic_Salary = @Basic_Salary   WHERE Increment_Id = @Increment_Id
			
			

				Declare @CurAD_Id	Numeric 
				Declare @CurrAD_Amount Numeric(18,2)
				Declare @CurrAD_Per Numeric(18,2)
				Declare @Allow_Name as nvarchar(100)
		
				Set @CurAD_Id	= 0
				Set @CurrAD_Amount = 0
				Set @CurrAD_Per = 0
				
				Declare CusrAllow cursor for	                 
					Select EED.Ad_ID,E_Ad_Amount,E_AD_Percentage From T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Inner Join T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = AM.AD_ID 
					Where Emp_ID = @Emp_Id And Increment_Id = @Old_Increment_Id And Isnull(AM.Is_Optional,0) = 0
						
					Open CusrAllow
						Fetch next from CusrAllow into @CurAD_Id,@CurrAD_Amount,@CurrAD_Per
						While @@fetch_status = 0                    
						Begin 
						
							Select @Allow_Name = Ad_Name From T0050_AD_MASTER WITH (NOLOCK) Where CMP_ID = @Cmp_ID And AD_ID = @CurAD_Id
							
							If @CurrAD_Per > 0 
								Begin
									Exec SP_Import_Allow_Deduct_Data @Cmp_ID,@Emp_Id,@Increment_Id,@Increment_Effective_Date,@Allow_Name,@CurrAD_Per,0,0
								End
							Else
								Begin
									Exec SP_Import_Allow_Deduct_Data @Cmp_ID,@Emp_Id,@Increment_Id,@Increment_Effective_Date,@Allow_Name,@CurrAD_Amount,0,0
								End
							
							fetch next from CusrAllow into @CurAD_Id,@CurrAD_Amount,@CurrAD_Per	
						End
					Close CusrAllow                    
				Deallocate CusrAllow
				
				Exec Update_Gross_Amount @Cmp_ID,@Emp_Id,@Increment_Id
				Exec Update_PT_Amount @Cmp_ID,@Emp_Id,@Increment_Id
				
			
			
	RETURN
	

	

