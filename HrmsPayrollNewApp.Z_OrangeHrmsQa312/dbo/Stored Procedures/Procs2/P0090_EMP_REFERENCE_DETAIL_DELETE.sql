

-- =============================================
-- Author     :	Alpesh
-- ALTER date: 13-Aug-2012
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[P0090_EMP_REFERENCE_DETAIL_DELETE]

@Cmp_ID			numeric(18, 0),
@Emp_ID			numeric(18, 0),
@Referance_ID   numeric(18, 0)

AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	

	If exists (Select 1 from T0090_EMP_REFERENCE_DETAIL WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID AND Reference_ID = @Referance_ID)
		Begin
			Declare @R_Emp_ID numeric(18, 0)
			Declare @Ref_Month numeric(18,0) -- 'Added by nilesh patel on 03092015
			Declare @Ref_Year  numeric(18,0) -- 'Added by nilesh patel on 03092015
						
			Select @R_Emp_ID = R_Emp_ID ,@Ref_Month = Isnull(Ref_Month,0),@Ref_Year = Isnull(Ref_Year,0) from T0090_EMP_REFERENCE_DETAIL WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID AND Reference_ID = @Referance_ID
			
			-- 'Comment by nilesh patel on 03092015 -Start
			
			--If exists (Select 1 from T0200_MONTHLY_SALARY where Cmp_ID = @Cmp_ID and Emp_ID = @R_Emp_ID and /*MONTH(Month_End_Date)*/ CONVERT(VARCHAR(7), Month_End_Date, 120) in
			--				(Select CONVERT(VARCHAR(7), For_Date, 120) /*MONTH(For_Date)*/ from T0090_EMP_REFERENCE_DETAIL where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID AND Reference_ID = @Referance_ID))
			--	Begin
			--		Raiserror('Salary Exists For Referenced Employee',16,2)
			--		return -1
			--	End
			
			-- 'Comment by nilesh patel on 03092015 -End
			
			-- 'Added by nilesh patel on 03092015 -Start
			If exists (Select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @R_Emp_ID and  MONTH(Month_End_Date) = @Ref_Month AND YEAR(Month_End_Date) = @Ref_Year)
				Begin
					Raiserror('@@Salary Exists For Referenced Employee',16,2)
					return -1
				End
			-- 'Added by nilesh patel on 03092015 -End
			
			Delete from T0090_EMP_REFERENCE_DETAIL where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID AND Reference_ID = @Referance_ID
		
		End
	
	
    
END


