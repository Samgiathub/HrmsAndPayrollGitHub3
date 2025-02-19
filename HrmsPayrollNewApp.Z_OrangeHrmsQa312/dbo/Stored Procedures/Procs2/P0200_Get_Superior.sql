



-- =============================================
-- Author:		Sneha
-- ALTER date:02/03/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Get_Superior]
	@cmp_id as numeric(18,0),
	@exit_id as numeric(18,0)
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
Declare @emp_id as numeric(18,0)	
	
	If @cmp_id <>0
		Begin
			--Select @s_emp_id =s_emp_id from T0200_Emp_ExitApplication where cmp_id = 7 and exit_id = @exit_id
			--Change By Jaina 04-06-2016
			Select @emp_id =EM.Emp_Superior from T0200_Emp_ExitApplication E WITH (NOLOCK) inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID=E.emp_id where E.cmp_id = @cmp_id and E.exit_id = @exit_id
			
			--Select Superior_Id,Emp_Superior from Get_Emp_Superior where Cmp_Id = 7 and Superior_Id = @s_emp_id
			select Emp_ID As Superior_Id ,Alpha_Emp_Code + ' - ' + Emp_Full_Name As Emp_Superior from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_id and Emp_ID = @emp_id
		End
   
END




