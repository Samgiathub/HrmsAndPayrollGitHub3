



-- =============================================
-- Author:		Sneha	
-- ALTER date: 01/03/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Select_ExitApplicationStatus]
	@branch_Id as numeric(18,0),
	 @cmp_id as numeric(18,0),
	 @str as varchar(max),
	 @str1 as varchar(max),
	 @qry as numeric(18,0)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


BEGIN
	
	if @branch_Id <> 0
		Begin
			If @str = ''
				Begin
					SELECT x.exit_id,e.Alpha_Emp_Code,x.resignation_date,x.sup_ack,x.status,e.emp_full_name ,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK),T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.emp_id = e.emp_id  order by exit_id desc
				End
			Else
				Begin
					If @qry =1
						Begin
							SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK),T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.emp_id = e.emp_id and e.Emp_Full_Name like '%' + @str + '%' order by exit_id desc
						End
					Else If @qry = 2
						Begin
							If @str1 <> ''
								Begin
									SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.emp_id = e.emp_id and x.resignation_date Between @str and @str1  order by exit_id desc
								End
							Else
								Begin
									SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.emp_id = e.emp_id and x.resignation_date >= @str  order by exit_id desc
								End
						End
					Else If @qry = 3
						Begin
							If @str = 'Approve' or @str = 'A'
								set @str = 'A'
							Else If @str ='Reject' or @str='R'
								set @str = 'R'
							Else If @str = 'H' or @str ='Pending'
								set @str = 'H'
							Else If @str = 'P' or @str = 'In Process'
								Set @str ='P'
							SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.emp_id = e.emp_id and x.status = @str  order by exit_id desc
						End
					Else If @qry= 4
						Begin
							SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.emp_id = e.emp_id and e.Alpha_Emp_Code = @str  order by exit_id desc
						End
				End	
		End
	Else
		Begin
			If @str = ''
				Begin
					SELECT  x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and  x.emp_id = e.emp_id  order by exit_id desc
				End
			Else
				Begin
					If @qry = 1
						Begin
							SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and e.Emp_Full_Name like '%' + @str + '%' and x.emp_id = e.emp_id  order by exit_id desc
						End
					Else If @qry = 2
						Begin
							If @str1 <> ''
								Begin
									SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.resignation_date Between @str and @str1 and x.emp_id = e.emp_id  order by exit_id desc
								End
							Else
								Begin
									SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.resignation_date >= @str and x.emp_id = e.emp_id  order by exit_id desc
								End
							
						End
					Else If @qry = 3
						Begin
							If @str = 'Approve' or @str = 'A'
								set @str = 'A'
							Else If @str ='Reject' or @str='R'
								set @str = 'R'
							Else If @str = 'H' or @str ='Pending'
								set @str = 'H'
							Else If @str = 'P' or @str = 'In Process'
								Set @str ='P'
							SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.status = @str and x.emp_id = e.emp_id  order by exit_id desc
						End
					Else If @qry= 4
						Begin
							SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and e.Alpha_Emp_Code = @str  and x.emp_id = e.emp_id  order by exit_id desc
						End
				End
		End
END




