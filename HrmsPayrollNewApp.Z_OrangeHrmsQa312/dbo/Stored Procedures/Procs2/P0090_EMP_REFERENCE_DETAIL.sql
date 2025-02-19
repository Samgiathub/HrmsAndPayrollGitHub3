

-- =============================================
-- Author     :	Alpesh
-- ALTER date: 13-Aug-2012
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[P0090_EMP_REFERENCE_DETAIL]

@Reference_ID	numeric(18, 0) output,
@Cmp_ID			numeric(18, 0),
@Emp_ID			numeric(18, 0),
@R_Emp_ID		numeric(18, 0),
@For_Date		datetime,
@Ref_Description	varchar(100),
@Amount			numeric(18, 2),
@Comments		varchar(100),
@Contact_Person varchar(100) = '',
@Contact_Number varchar(100)= 0,
@Designation    varchar(100) = '',
@City			varchar(50) ='',
@Source_Type	integer = 2,
@Source_Name	integer = 0,
@Ref_Month		numeric(18,0) = 0,
@Ref_Year		numeric(18,0) = 0,
@tran_type		varchar(1),
@Effect_In_Salary tinyint = 0

AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	if @Source_Type = 0 
		 set @Source_Type = 2
		
		
    If @tran_type = 'I'
		Begin
			
			--If Exists(Select 1 from T0090_EMP_REFERENCE_DETAIL where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and MONTH(For_Date) = MONTH(@For_Date))
			--	Begin 
			--		raiserror('You Cannot Add Reference Detail For Same Month',16,2)
			--		return -1
			--	End
			-- Coment by nilesh patel on 10/02/2015 after discuss with Hardik bhai 
			
			Select @Reference_ID = isnull(max(Reference_ID),0) + 1 from T0090_EMP_REFERENCE_DETAIL WITH (NOLOCK)
			
			Insert Into T0090_EMP_REFERENCE_DETAIL(Reference_ID,Cmp_ID,Emp_ID,R_Emp_ID,For_Date,Ref_Description,Amount,Comments,Contact_Person,Mobile,Designation,City,Source_Type,Source_Name,Ref_Month,Ref_Year,Effect_In_Salary)
			Values (@Reference_ID,@Cmp_ID,@Emp_ID,@R_Emp_ID,@For_Date,@Ref_Description,@Amount,@Comments,@Contact_Person,@Contact_Number,@Designation,@City,@Source_Type,@Source_Name,@Ref_Month,@Ref_Year,@Effect_In_Salary)
			
		End
    
    
END


