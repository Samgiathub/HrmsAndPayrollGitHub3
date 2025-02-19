CREATE PROCEDURE [dbo].[SP_RPT_EMP_PASSWORD_DETAILS]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		varchar(Max)=''
	,@Cat_ID		varchar(Max)=''
	,@Grd_ID		varchar(Max)=''
	,@Type_ID		varchar(Max)=''
	,@Dept_ID		varchar(Max)=''
	,@Desig_ID		varchar(Max)=''
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''
	,@Salary_Cycle_id Numeric(18,0) = 0
	,@Segment_Id   varchar(max) = ''
	,@Vertical_Id  varchar(max) = '' 
	,@SubVertical_Id  varchar(max) = '' 
	,@SubBranch_Id   varchar(max) = ''
	,@Report_Type Numeric(2,0) = 0
	,@Bank_ID	varchar(MAX) = ''
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'',@Vertical_Id,@SubVertical_Id,'',0,0,0,'0',0,0,@Bank_ID   --Change By Jaina 3-10-2015
	
	
	if @Report_Type = 0
		Begin
			Select E.Alpha_Emp_Code,E.Emp_Full_Name,E.Emp_ID
			FROM	T0080_EMP_MASTER E WITH (NOLOCK)
					INNER JOIN (SELECT	I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
								FROM	T0095_Increment I WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(Increment_ID) AS Increment_ID,Emp_ID 
													FROM	T0095_Increment WITH (NOLOCK)
													WHERE	Increment_Effective_date <= @To_Date 
															AND Cmp_ID = @Cmp_ID
													GROUP BY emp_ID
													) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID
								) I_Q ON E.Emp_ID = I_Q.Emp_ID  
					INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
					LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
					LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
					LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
					INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID
					INNER JOIN #Emp_Cons EC ON E.Emp_ID=EC.Emp_ID 
			WHERE	E.Cmp_ID = @Cmp_Id and E.Date_Of_Join >= @From_Date and E.Date_Of_Join <= @To_Date and e.Emp_Left = 'N'
					AND NOT EXISTS(
						SELECT 1 FROM T0250_Change_Password_History CPH WITH (NOLOCK) Where CPH.Emp_ID = E.Emp_ID
					)
			union 
			Select distinct E.Alpha_Emp_Code,E.Emp_Full_Name,E.Emp_ID
			FROM	T0080_EMP_MASTER E WITH (NOLOCK)
					INNER JOIN (SELECT	I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
								FROM	T0095_Increment I WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(Increment_ID) AS Increment_ID,Emp_ID 
													FROM	T0095_Increment WITH (NOLOCK)
													WHERE	Increment_Effective_date <= @To_Date 
															AND Cmp_ID = @Cmp_ID
													GROUP BY emp_ID
													) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID
								) I_Q ON E.Emp_ID = I_Q.Emp_ID  
					INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
					LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
					LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
					LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
					INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID
					INNER JOIN #Emp_Cons EC ON E.Emp_ID=EC.Emp_ID 
					inner join T0250_Change_Password_History CP on  CP.Emp_ID = E.Emp_ID 
			WHERE	E.Cmp_ID = @Cmp_Id and E.Date_Of_Join >= @From_Date and E.Date_Of_Join <= @To_Date and e.Emp_Left = 'N'
					


		End
	Else
		Begin
			Select ROW_NUMBER() OVER(ORDER BY E.Emp_ID) as Sr_no,
			E.Alpha_Emp_Code,E.Emp_Full_Name,E.Emp_ID,BM.Branch_Name,DGM.Desig_Name,DM.Dept_Name,
			Replace(Convert(varchar(11),E.Date_Of_Join,105),'-','/') as Date_Of_Join,LT.Login_Name
			,case when isnull([Password],'') <> '' then [Password] else LT.Login_Password ENd  as Login_Password
			,CM.Cmp_Name,CM.Cmp_Address,GM.Grd_Name,ETM.Type_Name,vS.Vertical_Name,Sv.SubVertical_Name
			FROM	T0080_EMP_MASTER E WITH (NOLOCK)
					INNER JOIN (SELECT	I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID
								FROM	T0095_Increment I WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(Increment_ID) AS Increment_ID,Emp_ID 
													FROM	T0095_Increment WITH (NOLOCK)
													WHERE	Increment_Effective_date <= @To_Date 
															AND Cmp_ID = @Cmp_ID
													GROUP BY emp_ID
													) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID
								) I_Q ON E.Emp_ID = I_Q.Emp_ID  
					INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
					LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
					LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
					LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
					INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID
					INNER JOIN #Emp_Cons EC ON E.Emp_ID=EC.Emp_ID 
					INNER JOIN T0011_LOGIN LT WITH (NOLOCK) ON LT.Emp_ID = E.Emp_ID 
					LEFT OUTER JOIN T0040_Vertical_Segment vS WITH (NOLOCK) oN VS.Vertical_ID = I_Q.Vertical_ID 
					LEFT OUTER JOIN T0050_SubVertical Sv  WITH (NOLOCK) On Sv.SubVertical_ID = I_Q.SubVertical_ID
					Left Outer Join (
										select CP.Emp_id,Effective_From_Date,CP.[Password] from T0250_Change_Password_History CP WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(Effective_From_Date) as Eff_date, Emp_ID 
													FROM	T0250_Change_Password_History WITH (NOLOCK)
													WHERE	Effective_From_Date <= GETDATE()
															AND Cmp_ID = @Cmp_ID
													GROUP BY emp_ID
										) Qry1 ON CP.Emp_ID = Qry1.Emp_ID and CP.Effective_From_Date = Qry1.Eff_date
					)Qry2 on  Qry2.Emp_ID = E.Emp_ID
			WHERE	E.Cmp_ID = @Cmp_Id 
			order by E.Emp_ID
		End
	RETURN
