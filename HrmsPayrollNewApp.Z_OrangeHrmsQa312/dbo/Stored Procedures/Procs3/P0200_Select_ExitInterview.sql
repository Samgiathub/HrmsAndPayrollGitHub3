


-- =============================================
-- Author:		Sneha 
-- ALTER date: 13/02/2012
-- Description:	Bind Interview Candidates@P_Branch
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Select_ExitInterview] 
	 @branch_Id as numeric(18,0),
	 @Dept_id as numeric(18,0),
	 @cmp_id as numeric(18,0),
	 @str as varchar(max),
	 @str1 as varchar(max),
	 @qry as tinyint,
	 @P_Branch as varchar(max)= '',  --Added By Jaina 03-09-2015
	 @P_dept as varchar(max) = '',
	 @flag as tinyint = 0   --Added By Jaina 04-06-2016
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN

	
	IF (@P_Branch = '' OR @P_Branch = '0') --Added By Jaina 31-08-2015
	SET @P_Branch = NULL;    
  IF (@P_dept = '' OR @P_dept = '0') --Added By Jaina 31-08-2015
	SET @P_dept = NULL;    
  

	--Added By Jaina 04-06-2016 Start	
	Declare @StrSql varchar(max)
	set @StrSql = ''
	
	--Added by Mukti(03082018)start
	Declare @Reminder_Days as Numeric(18,0)
	Declare @Exit_CostCenterWise as Numeric(18,0)
		set @Reminder_Days = 0
		set @Exit_CostCenterWise = 0
	
	Select @Exit_CostCenterWise = Isnull(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_Id and Setting_Name ='Enable Exit Clearance Process Cost Center Wise'   					
	
	if @Exit_CostCenterWise = 1 		
			Select @Reminder_Days = Isnull(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_Id and Setting_Name ='Reminder Days for Exit Clearance Cost Center Wise'   				
	--Added by Mukti(03082018)end
		
if @Flag = 1
	Begin
	print '555'
		set @StrSql = 'SELECT DISTINCT E.Emp_ID,E.Cmp_ID,E.Branch_ID,E.Dept_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,EA.resignation_date,
									EA.last_date,EA.exit_id,D.Dept_Name,EA.sup_ack,E.Emp_Left
					FROM T0200_Emp_ExitApplication EA WITH (NOLOCK) INNER JOIN
						  T0080_EMP_MASTER E WITH (NOLOCK) ON EA.emp_id = E.Emp_ID left outer JOIN
						  T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON D.Dept_Id = E.Dept_ID INNER JOIN
						  T0300_Exit_Clearance_Approval EC WITH (NOLOCK) ON EC.Emp_ID=EA.emp_id AND EC.Exit_ID=EA.exit_id
					WHERE EA.Status <> ''R'' and E.Emp_Left <> ''Y'' and ' + @str +' and E.Cmp_ID = ' + cast(@cmp_id as varchar(15));
					-- Handle Branch_ID Filtering
						IF @P_Branch  <> 0
						BEGIN
							SET @StrSql = @StrSql + ' AND E.Branch_ID = ' + CAST(@P_Branch AS VARCHAR(15));
						END
						IF @P_dept <> 0
						BEGIN
							SET @StrSql = @StrSql + ' AND E.Dept_ID = ' + CAST(@P_dept AS VARCHAR(15));
						END
						SET @StrSql = @StrSql + ' ORDER BY ' + @str1;
					--+ 'order by ' + @str1+'' --ronakb051223'
			---E.Emp_Left <> ''Y'' condition added by aswini 19042024
			--Added by Mukti(03082018)start
			if @Reminder_Days > 0
				BEGIN
					set	@StrSql += ' and (GETDATE() BETWEEN DateAdd(DAY,-' + CAST(@Reminder_Days as VARCHAR(15)) + ',EA.last_date) AND (EA.last_date+1)or GETDATE() >= EA.last_date)
					    			 order by ' + @str1+''
									--((DateAdd(DAY,-' + CAST(@Reminder_Days as VARCHAR(15)) + ',EA.last_date) >= EA.last_date
									-- or GETDATE() >= EA.last_date))
					--set	@StrSql += ' and GETDATE()  
					--		between DateAdd(DAY,-' + CAST(@Reminder_Days as VARCHAR(15)) + ',EA.last_date)
					--		and DateAdd(DAY,' + CAST(@Reminder_Days as VARCHAR(15)) + ',EA.last_date) 
					--		order by ' + @str1+''
				END
			--Added by Mukti(03082018)end
				PRINT @StrSql
			exec(@StrSql)			
	End
	--Added By Jaina 04-06-2016 End
ELSE
    Begin
    
	If @branch_Id <> 0
		Begin
			If @str = ''
				Begin
					SELECT x.emp_id,x.exit_id,x.branch_id,e.Alpha_Emp_Code,x.resignation_date,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and status = 'P'  and x.emp_id = e.emp_id order by exit_id desc
					--union 
					--SELECT x.emp_id,x.exit_id,x.resignation_date,x.sup_ack,x.status,CAST(e.Emp_Code as varchar(50))+'-'+e.emp_full_name as emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process from T0200_Emp_EXITAPPLICATION as x,T0080_EMP_MASTER as e where x.cmp_id=@cmp_id and status = 'A'  and x.emp_id = e.emp_id order by exit_id desc
				End
			Else
				Begin
				
					If @qry = 1
					
						Begin
							SELECT x.emp_id,x.exit_id,x.branch_id,e.Alpha_Emp_Code,x.resignation_date,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process  from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and e.Emp_Full_Name like '%' + @str + '%' and status = 'P'  and x.emp_id = e.emp_id order by exit_id desc
						--	Union
							--SELECT x.emp_id,x.exit_id,x.resignation_date,x.sup_ack,x.status,CAST(e.Emp_Code as varchar(50))+'-'+e.emp_full_name as emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process  from T0200_Emp_EXITAPPLICATION as x,T0080_EMP_MASTER as e where x.cmp_id=@cmp_id and e.Emp_Full_Name like '%' + @str + '%' and status = 'A'  and x.emp_id = e.emp_id order by exit_id desc
						End
					Else If @qry= 2
						Begin
							If @str1 <> ''
								Begin
									SELECT x.emp_id,x.exit_id,x.branch_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process  from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.resignation_date Between @str and @str1 and status = 'P'  and x.emp_id = e.emp_id order by exit_id desc
								End
							Else
								Begin
									SELECT x.emp_id,x.exit_id,x.branch_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process  from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.resignation_date >= @str and status = 'P'  and x.emp_id = e.emp_id order by exit_id desc
								End
											
						End
					Else If @qry = 3
						Begin
							SELECT x.emp_id,x.exit_id,x.branch_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process  from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and e.Alpha_Emp_Code = @str and status = 'P'  and x.emp_id = e.emp_id order by exit_id desc
						End
				End
		End
		--Added By Jaina 03-09-2015 Start
	Else If @P_Branch IS NOT NULL
		begin
			print 1
			If @str = ''
				Begin
				print 1
					SELECT x.emp_id,x.exit_id,x.branch_id,e.Alpha_Emp_Code,x.resignation_date,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process 
					from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK)
					INNER join (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@P_Branch,'#')) T ON T.Branch_ID=e.Branch_ID  --Added By Jaina 03-09-2015
					where x.cmp_id=@cmp_id and status = 'P'  and x.emp_id = e.emp_id order by exit_id desc
					--union 
					--SELECT x.emp_id,x.exit_id,x.resignation_date,x.sup_ack,x.status,CAST(e.Emp_Code as varchar(50))+'-'+e.emp_full_name as emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process from T0200_Emp_EXITAPPLICATION as x,T0080_EMP_MASTER as e where x.cmp_id=@cmp_id and status = 'A'  and x.emp_id = e.emp_id order by exit_id desc
				End
			Else
				Begin
				
					If @qry = 1
					
						Begin
							SELECT x.emp_id,x.exit_id,x.branch_id,e.Alpha_Emp_Code,x.resignation_date,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process  
							from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK)
							INNER join (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@P_Branch,'#')) T ON T.Branch_ID=e.Branch_ID  --Added By Jaina 03-09-2015
							where x.cmp_id=@cmp_id and e.Emp_Full_Name like '%' + @str + '%' and status = 'P'  and x.emp_id = e.emp_id order by exit_id desc
						--	Union
							--SELECT x.emp_id,x.exit_id,x.resignation_date,x.sup_ack,x.status,CAST(e.Emp_Code as varchar(50))+'-'+e.emp_full_name as emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process  from T0200_Emp_EXITAPPLICATION as x,T0080_EMP_MASTER as e where x.cmp_id=@cmp_id and e.Emp_Full_Name like '%' + @str + '%' and status = 'A'  and x.emp_id = e.emp_id order by exit_id desc
						End
					Else If @qry= 2
						Begin
							If @str1 <> ''
								Begin
									SELECT x.emp_id,x.exit_id,x.branch_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process 
									 from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK)
									 INNER join (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@P_Branch,'#')) T ON T.Branch_ID=e.Branch_ID  --Added By Jaina 03-09-2015
									where x.cmp_id=@cmp_id and x.resignation_date Between @str and @str1 and status = 'P'  and x.emp_id = e.emp_id order by exit_id desc
								End
							Else
								Begin
									SELECT x.emp_id,x.exit_id,x.branch_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process  
									from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK)
									INNER join (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@P_Branch,'#')) T ON T.Branch_ID=e.Branch_ID  --Added By Jaina 03-09-2015
									where x.cmp_id=@cmp_id and x.resignation_date >= @str and status = 'P'  and x.emp_id = e.emp_id order by exit_id desc
								End
											
						End
					Else If @qry = 3
						Begin
							SELECT x.emp_id,x.exit_id,x.branch_id,x.resignation_date,e.Alpha_Emp_Code,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process 
							 from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK)
							 INNER join (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@P_Branch,'#')) T ON T.Branch_ID=e.Branch_ID  --Added By Jaina 03-09-2015
							where x.cmp_id=@cmp_id and e.Alpha_Emp_Code = @str and status = 'P'  and x.emp_id = e.emp_id order by exit_id desc
						End
					End
				
		end
	--Added By Jaina 03-09-2015 End
	Else
		Begin
			If @str = ''
				Begin
					SELECT x.emp_id,x.exit_id,x.branch_id,e.Alpha_Emp_Code,x.resignation_date,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and status = 'P'  and e.emp_id = x.emp_id order by exit_id desc
				--	union
					--SELECT x.emp_id,x.exit_id,x.resignation_date,x.sup_ack,x.status,CAST(e.Emp_Code as varchar(50))+'-'+e.emp_full_name as emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process from T0200_Emp_EXITAPPLICATION as x,T0080_EMP_MASTER as e where x.cmp_id=@cmp_id and status = 'A'  and e.emp_id = x.emp_id order by exit_id desc
				End
			Else
				Begin
					If @qry = 1
						Begin
							SELECT x.emp_id,x.exit_id,x.branch_id,e.Alpha_Emp_Code,x.resignation_date,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process  from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and e.Emp_Full_Name like '%' + @str + '%' and status = 'P'  and x.emp_id = e.emp_id order by exit_id desc
						--	Union
						--	SELECT x.emp_id,x.exit_id,x.resignation_date,x.sup_ack,x.status,CAST(e.Emp_Code as varchar(50))+'-'+e.emp_full_name as emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process  from T0200_Emp_EXITAPPLICATION as x,T0080_EMP_MASTER as e where x.cmp_id=@cmp_id and e.Emp_Full_Name like '%' + @str + '%' and status = 'A'  and x.emp_id = e.emp_id order by exit_id desc
						End
					Else If @qry= 2
						Begin
							--SELECT x.emp_id,x.exit_id,x.branch_id,e.Alpha_Emp_Code,x.resignation_date,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process  from T0200_Emp_EXITAPPLICATION as x,T0080_EMP_MASTER as e where x.cmp_id=@cmp_id and x.resignation_date = @str and status = 'P'  and x.emp_id = e.emp_id order by exit_id desc
							If @str1 <> ''
								Begin
									SELECT x.emp_id,x.exit_id,x.branch_id,e.Alpha_Emp_Code,x.resignation_date,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process  from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.resignation_date Between @str and @str1  and status = 'P'  and x.emp_id = e.emp_id order by exit_id desc
								End
							Else
								Begin
									SELECT x.emp_id,x.exit_id,x.branch_id,e.Alpha_Emp_Code,x.resignation_date,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process  from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and x.resignation_date >= @str and status = 'P'  and x.emp_id = e.emp_id order by exit_id desc
								End
						End
					Else If @qry = 3
						Begin
							SELECT x.emp_id,x.exit_id,x.branch_id,e.Alpha_Emp_Code,x.resignation_date,x.sup_ack,x.status,e.emp_full_name,x.last_date,x.interview_date , x.interview_time,Is_Process  from T0200_Emp_EXITAPPLICATION as x WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where x.cmp_id=@cmp_id and e.Alpha_Emp_Code = @str  and status = 'P'  and x.emp_id = e.emp_id order by exit_id desc
						End
				End
		End
	End	
    
END




