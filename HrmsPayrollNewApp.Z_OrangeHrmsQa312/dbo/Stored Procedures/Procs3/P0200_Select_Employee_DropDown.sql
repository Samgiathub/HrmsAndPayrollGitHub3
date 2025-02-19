



-- =============================================
-- Author:		Sneha
-- ALTER date: 13/02/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Select_Employee_DropDown]
	@cmp_id as numeric(18,0),
	@branch_Id as numeric(18,0),
	@desig_Id as numeric(18,0)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


BEGIN
	
	
	If @cmp_id<>0
		Begin
			If @branch_Id <> 0 and @desig_Id <> 0
				Begin
					select  emp_id, Emp_Full_Name = cast (Alpha_Emp_Code  as varchar) +' - '+ Emp_Full_Name from T0080_EMP_MASTER as e WITH (NOLOCK) ,T0030_BRANCH_MASTER as b WITH (NOLOCK) ,T0040_DESIGNATION_MASTER as d WITH (NOLOCK) where e.cmp_id = @cmp_id and e.Emp_Left ='N' and  b.Branch_ID=@branch_Id and e.branch_Id = b.Branch_ID and d.Desig_ID=@desig_Id and e.Desig_ID = d.Desig_ID Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End 
				End
			 Else If  @branch_Id <> 0 and @desig_Id = 0
				Begin
					select  emp_id, Emp_Full_Name = cast (Alpha_Emp_Code as varchar) +' - '+ Emp_Full_Name from T0080_EMP_MASTER as e WITH (NOLOCK) ,T0030_BRANCH_MASTER as b WITH (NOLOCK) where e.cmp_id = @cmp_id and e.Emp_Left ='N' and  b.Branch_ID = @branch_Id and e.Branch_ID = b.Branch_ID Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
				End
			Else If @branch_Id = 0 and @desig_Id <>0
				Begin
					select  emp_id, Emp_Full_Name = cast (Alpha_Emp_Code as varchar) +' - '+ Emp_Full_Name from T0080_EMP_MASTER as e WITH (NOLOCK) ,T0040_DESIGNATION_MASTER as d WITH (NOLOCK) where e.cmp_id = @cmp_id and e.Emp_Left ='N' and  d.Desig_ID =@desig_Id and e.Desig_Id = d.Desig_ID Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
				End
			Else
				Begin
					select emp_id, Emp_Full_Name = cast (Alpha_Emp_Code as varchar) +' - '+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where cmp_id = @cmp_id and Emp_Left ='N' Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
			When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
				Else Alpha_Emp_Code
			End
				End
			
		End
END




