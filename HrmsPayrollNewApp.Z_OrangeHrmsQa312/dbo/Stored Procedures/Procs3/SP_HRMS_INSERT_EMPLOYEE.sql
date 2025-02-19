



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_HRMS_INSERT_EMPLOYEE]
	@Cmp_ID numeric(18,0),
	@For_Date DateTime,
	@Resume_ID numeric(18,0)
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
				
					Declare  @Branch_ID		numeric(18,0)
					Declare  @Cat_ID			numeric(18,0)
					Declare  @Grd_ID			numeric(18,0)
					Declare  @Dept_ID		numeric(18,0)
					Declare  @Desig_Id		numeric(18,0)
					Declare  @Type_ID		numeric(18,0)
					Declare  @Shift_ID		numeric(18,0)
					Declare  @Bank_ID		numeric(18,0)
					Declare  @Increment_ID	numeric(18,0)
					Declare  @Emp_code		numeric(18,0)
					Declare  @Initial		varchar(10)
					Declare  @Emp_First_Name varchar(100)
					Declare  @Emp_Second_Name varchar(100)
					Declare  @Emp_Last_Name	varchar(100)
					Declare  @Curr_ID		numeric(18,0)
					Declare  @Date_Of_Join	datetime
					Declare  @SSN_No			varchar(30)
					Declare  @SIN_No			varchar(30)
					Declare  @Dr_Lic_No		varchar(30)
                    Declare	 @Pan_No			varchar(30)
					Declare  @Date_Of_Birth  DATETIME 
					Declare  @Marital_Status varchar(20)
					Declare  @Gender			char(1)
					Declare  @Dr_Lic_Ex_Date DATETIME 
					Declare  @Nationality	varchar(20)
					Declare  @Loc_ID			numeric(18,0)
					Declare  @Street_1		varchar(250)
					Declare  @City			varchar(30)
					Declare  @State			varchar(20)
					Declare  @Zip_code		varchar(20)
					Declare  @Home_Tel_no	varchar(30)
					Declare  @Mobile_No		varchar(30)
					Declare  @Work_Tel_No	varchar(30)
					Declare   @Work_Email		varchar(50)
					Declare   @Other_Email	varchar(50)
					Declare   @Present_Street varchar(250)
					Declare   @Present_City   varchar(30)
					Declare   @Present_State  varchar(30)
					Declare   @Present_Post_Box varchar(20)
					Declare   @Emp_Superior   numeric(18)
					Declare   @Basic_Salary	numeric(18,2)
					Declare   @Image_Name		varchar(100)
					Declare   @Wages_Type		varchar(10)
					Declare   @Salary_Basis_On varchar(10)
					Declare   @Payment_Mode	varchar(20)
					Declare   @Inc_Bank_AC_No	varchar(20)
					Declare   @Emp_OT			numeric(18)
					Declare   @Emp_OT_Min_Limit	varchar(10)
					Declare   @Emp_OT_Max_Limit	varchar(10)
					Declare   @Emp_Late_mark	Numeric(18)
					Declare   @Emp_Full_PF	Numeric(18)
					Declare   @Emp_PT			Numeric(18)
					Declare   @Emp_Fix_Salary	Numeric(18)
					Declare   @tran_type		char(1)
					Declare   @Gross_salary	numeric(22)
					Declare   @Tall_Led_Name varchar(250)
					Declare   @Religion varchar(50)
					Declare   @Height  varchar(50)
					Declare   @Mark_Of_Idetification varchar(250)
					Declare   @Dispencery varchar(50)
					Declare   @Doctor_name varchar(100)
					Declare   @DispenceryAdd varchar(250)
					Declare   @Insurance_No varchar(50)
					Declare   @Is_Gr_App tinyint
					Declare   @Is_Yearly_Bonus numeric(5, 2)
					Declare   @Yearly_Leave_Days numeric(7, 2)
					Declare   @Yearly_Leave_Amount numeric(7, 2)
					Declare   @Yearly_Bonus_Per numeric(5, 2)
					Declare   @Yearly_Bonus_Amount numeric(7, 2)
					Declare   @Emp_Late_Limit varchar(10)
					Declare   @Late_Dedu_Type varchar(10)
					Declare   @Emp_Part_Time  numeric(10)
					Declare   @Emp_Confirmation_date dateTime
					Declare   @Is_On_Probation numeric(1,0)
					Declare   @Tally_Led_ID numeric(18,0)
					Declare   @Blood_Group varchar(10)
					Declare   @Probation numeric(2,0)
					Declare   @enroll_No numeric(18,0)
					Declare   @Dep_Reminder tinyint
				 
				 
				 
	RETURN




