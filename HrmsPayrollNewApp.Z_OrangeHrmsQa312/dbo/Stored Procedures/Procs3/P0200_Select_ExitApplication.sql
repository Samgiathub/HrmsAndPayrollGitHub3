


CREATE PROCEDURE [dbo].[P0200_Select_ExitApplication]
	 @branch_Id as numeric(18,0),
	 @cmp_id as numeric(18,0),
	 @str as varchar(max),
	 @str1 as varchar(max),
	 @qry as tinyint
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	If @branch_Id <> 0
		Begin
			If @str = ''
				Begin
					SELECT x.exit_id,e.Alpha_Emp_Code,x.resignation_date,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.emp_id = e.emp_id and  status='H' order by exit_id desc
				End
			Else
				Begin
					If @qry = 1
						Begin
							SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.emp_id = e.emp_id and e.Emp_Full_Name like '%' + @str + '%' and  status='H'  order by exit_id desc
						End
					Else If @qry = 2
						Begin
							If @str1 <> ''
								Begin
									SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.emp_id = e.emp_id and x.resignation_date Between @str and @str1  and  status='H'  order by exit_id desc
								End
							Else
								Begin
									SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK),T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.emp_id = e.emp_id and x.resignation_date >= @str  and  status='H'  order by exit_id desc
								End
							
						End
					Else If @qry = 3
						Begin
							SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.emp_id = e.emp_id and e.Alpha_Emp_Code = @str and  status='H'  order by exit_id desc
						End
				End	
		End
	Else
		Begin
			If @str = ''
				Begin
					SELECT  x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and  x.emp_id = e.emp_id and  status='H' order by exit_id desc
				End
			Else
				Begin
					If @qry = 1
						Begin
							SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.emp_id = e.emp_id and e.Emp_Full_Name like '%' + @str + '%' and  status='H'  order by exit_id desc
						End
					Else If @qry = 2
						Begin
							If @str1 <> ''
								Begin
									SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.emp_id = e.emp_id and x.resignation_date Between @str and @str1  and  status='H'  order by exit_id desc
								End
							Else
								Begin
									SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.emp_id = e.emp_id and x.resignation_date >= @str  and  status='H'  order by exit_id desc
								End
							
						End
					Else If @qry = 3
						Begin
							SELECT x.exit_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.emp_id = e.emp_id and e.Alpha_Emp_Code =  @str  and  status='H'  order by exit_id desc
						End
				End
		End
END




