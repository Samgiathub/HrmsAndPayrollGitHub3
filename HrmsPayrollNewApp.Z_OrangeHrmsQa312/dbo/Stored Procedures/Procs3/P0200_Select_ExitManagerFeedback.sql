



-- =============================================
-- Author:		Sneha
-- ALTER date:16/02/2012
-- Description:	<Description,,>
---12/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Select_ExitManagerFeedback]
@branch_Id as numeric(18,0),
 @cmp_id as numeric(18,0),
 @emp_id as numeric(18,0),
 @str as varchar(max),
 @str1 as varchar(max),
 @qry as tinyint
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
		
--	If @branch_Id <> 0
--		Begin
--			If @str = ''
--				Begin
--					SELECT  exit_id,cast(E.Emp_code as varchar)+' '+E.emp_full_name as emp_full_name,resignation_date,last_date,sup_ack,status from T0200_Emp_ExitApplication as X,T0080_EMP_MASTER as E ,Get_Emp_Superior as r where  X.cmp_id = @cmp_id and  r.Superior_Id =@emp_id  and r.emp_id = x.emp_id  and e.Emp_id = x.Emp_ID order by exit_id desc
--				End
--			Else
--				Begin
--					If @qry = 1
--						Begin
--							select exit_id,cast(emp_code as varchar)+' '+E.emp_full_name as emp_full_name,resignation_date,last_date,sup_ack,status from T0200_Emp_ExitApplication as X,T0080_EMP_MASTER as E where X.cmp_id=@cmp_id  and  E.Emp_Full_Name like '%' + @str + '%' and E.Emp_id = X.Emp_ID  order by exit_id desc
--						End
--					Else If @qry = 2
--						Begin
--							select exit_id,cast(emp_code as varchar)+' '+E.emp_full_name as emp_full_name,resignation_date,last_date,sup_ack,status from T0200_Emp_ExitApplication as X,T0080_EMP_MASTER as E where X.cmp_id=@cmp_id  and  X.resignation_date = @str and E.Emp_id = X.Emp_ID  order by exit_id desc
--						End
--				End
--		End
--	Else
--		Begin
--			If @str = ''
--				Begin
--					select exit_id,cast(emp_code as varchar)+' '+E.emp_full_name as emp_full_name,resignation_date,last_date,sup_ack,status from T0200_Emp_ExitApplication as x,T0080_EMP_MASTER as E,Get_Emp_Superior as r where x.cmp_id= @cmp_id and r.Superior_Id = @emp_id and r.emp_id = x.emp_id and e.Emp_id = x.Emp_ID order by exit_id desc
--				End
--			Else
--				Begin
--					If @qry = 1
--						Begin
--							select exit_id,cast(emp_code as varchar)+' '+emp_full_name as emp_full_name,resignation_date,last_date,sup_ack,status from T0200_Emp_ExitApplication as X,T0080_EMP_MASTER as E where X.cmp_id = @cmp_id and E.Emp_Full_Name like '%' + @str + '%' and E.Emp_id = X.Emp_ID order by exit_id desc
--						End
--					Else If @qry = 2
--						Begin
--							select exit_id,cast(emp_code as varchar)+' '+emp_full_name as emp_full_name,resignation_date,last_date,sup_ack,status from T0200_Emp_ExitApplication as X,T0080_EMP_MASTER as E where X.cmp_id = @cmp_id and X.resignation_date = @str and E.Emp_id = X.Emp_ID order by exit_id desc
--						End
--				End
--		End
--END
If @branch_Id <> 0
		Begin
			If @str = ''
				Begin
					SELECT distinct x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) ,Get_Emp_Superior as g where x.cmp_id=@cmp_id and g.Superior_Id= x.s_emp_id and  e.emp_id = x.emp_id and x.s_emp_id = @emp_id order by exit_id desc
				End
			Else
				Begin
					If @qry = 1
						Begin
							SELECT distinct x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) ,Get_Emp_Superior as g  where x.cmp_id=@cmp_id and g.Superior_Id= x.s_emp_id and  e.emp_id = x.emp_id and e.Emp_Full_Name like '%' + @str + '%' and x.s_emp_id = @emp_id order by exit_id desc
						End
					Else If @qry = 2
						Begin
							If @str1 <> ''
								Begin
									SELECT distinct x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) ,Get_Emp_Superior as g  where x.cmp_id=@cmp_id and g.Superior_Id= x.s_emp_id and  e.emp_id = x.emp_id and x.resignation_date Between @str and @str1  and x.s_emp_id = @emp_id  order by exit_id desc
								End
							Else
								Begin
									SELECT distinct x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) ,Get_Emp_Superior as g  where x.cmp_id=@cmp_id and g.Superior_Id= x.s_emp_id and  e.emp_id = x.emp_id and x.resignation_date >= @str  and x.s_emp_id = @emp_id  order by exit_id desc
								End
							
						End
					Else If @qry = 3
						Begin
							SELECT distinct x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) ,Get_Emp_Superior as g  where x.cmp_id=@cmp_id and g.Superior_Id= x.s_emp_id and  e.emp_id = x.emp_id and e.Alpha_Emp_Code = @str  and x.s_emp_id = @emp_id order by exit_id desc
						End
				End	
		End
	Else
		Begin
			If @str = ''
				Begin
					SELECT distinct x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) ,Get_Emp_Superior as g  where x.cmp_id=@cmp_id and g.Superior_Id= x.s_emp_id and   e.emp_id = x.emp_id  and x.s_emp_id = @emp_id order by exit_id desc
				End
			Else
				Begin
					If @qry = 1
						Begin
							SELECT distinct x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) ,Get_Emp_Superior as g  where x.cmp_id=@cmp_id and g.Superior_Id= x.s_emp_id and  e.emp_id = x.emp_id and e.Emp_Full_Name like '%' + @str + '%' and x.s_emp_id = @emp_id  order by exit_id desc
						End
					Else If @qry = 2
						Begin
							If @str1 <> ''
								Begin
									SELECT distinct x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) ,Get_Emp_Superior as g  where x.cmp_id=@cmp_id and g.Superior_Id= x.s_emp_id and  e.emp_id = x.emp_id and x.resignation_date Between @str and @str1 and x.s_emp_id = @emp_id order by exit_id desc
								End
							Else
								Begin
									SELECT distinct x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) ,Get_Emp_Superior as g  where x.cmp_id=@cmp_id and g.Superior_Id= x.s_emp_id and  e.emp_id = x.emp_id and x.resignation_date >= @str and x.s_emp_id = @emp_id order by exit_id desc
								End
						End
					Else If @qry = 3
						Begin
							SELECT distinct x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) ,Get_Emp_Superior as g  where x.cmp_id=@cmp_id and g.Superior_Id= x.s_emp_id and  e.emp_id = x.emp_id and e.Alpha_Emp_Code = @str  and x.s_emp_id = @emp_id order by exit_id desc
						End
				End
		End
END



