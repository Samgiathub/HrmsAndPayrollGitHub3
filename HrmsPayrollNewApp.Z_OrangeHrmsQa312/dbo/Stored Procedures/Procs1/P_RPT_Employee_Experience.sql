

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_RPT_Employee_Experience] 
	 @Cmp_ID		numeric  
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		varchar(max) = ''
	,@Grd_ID 		varchar(max) = ''
	,@Type_ID 		varchar(max) = ''
	,@Dept_ID 		varchar(max) = ''
	,@Desig_ID 		varchar(max) = ''
	,@Emp_ID 		numeric = 0
	,@Constraint	varchar(max) = ''
	,@Cat_ID        varchar(max) = ''
	,@Format		numeric = 0 

AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)
	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,0,'','','','',0,0,0,'0',0,0			
	
	if @format = 0 
	BEGIN	
	
	CREATE table #Emp_Experience_Detail
			(
			emp_Id    NUMERIC,
			cmp_Id		numeric,
			Branch_Id	numeric,
			Emp_Code  Varchar(100) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,       
			Emp_Full_Name  varchar(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
			Date_Of_join VARCHAR(50) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
			branch_Name			VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
			Employer_Name		VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
			desig_Name			varchar(50)  COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
			st_date				VARCHAR(25)  COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
			end_date			VARCHAR(25)  COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
			Emp_branch			varchar(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
			Emp_Location		varchar(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Manager_Name		varchar(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Contact_number		varchar(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Exp_Remarks			varchar(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Gross_Salary		numeric(18,2),
			CTC_Amount			numeric(18,2),			
			Experience	VARCHAR(10) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Industry_Type		VARCHAR(150) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS 	  --added by jimit 22032017	
			)	
	
	
	
			INSERT INTO #Emp_Experience_Detail
			SELECT     E.Emp_ID,E.Cmp_ID, E.Branch_ID,E.Alpha_Emp_Code, E.Emp_Full_Name, Convert(varchar(25),E.Date_Of_Join,103) as Date_of_Join, 
							  BM.Branch_Name, EED.Employer_Name, EED.Desig_Name, 
							  CONVERT(VARCHAR(25),EED.St_Date,103) AS St_Date, CONVERT(VARCHAR(25),EED.End_Date,103) AS End_Date, 
							  EED.Emp_Branch AS Branch, EED.Emp_Location AS Location, 
							  EED.Manager_Name AS Manager, EED.Contact_number AS Manager_Contact_Number, 
							  EED.Exp_Remarks, EED.Gross_Salary, 
							  EED.CTC_Amount,EED.EmpExp
							  ,EED.IndustryType
			FROM          dbo.T0080_EMP_MASTER E WITH (NOLOCK) LEFT Outer JOIN
							  dbo.T0090_EMP_EXPERIENCE_DETAIL EED WITH (NOLOCK) ON EED.Emp_ID = E.Emp_ID INNER JOIN
							  dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON E.Branch_ID = BM.Branch_ID INNER JOIN
							  #Emp_Cons EC On Ec.Emp_ID = E.Emp_ID
	
			INSERT INTO	#Emp_Experience_Detail
			SELECT			  E.Emp_ID,E.Cmp_ID, E.Branch_ID,E.Alpha_Emp_Code, E.Emp_Full_Name, 
							  Convert(varchar(25),E.Date_Of_Join,103) as Date_of_Join,BM.Branch_Name,cmd.Director_Name,Dm.Desig_Name, 
							  CONVERT(VARCHAR(25),E.Date_Of_Join,103) AS St_Date,CONVERT(VARCHAR(25),E.Emp_Left_Date,103) AS End_Date, 
							  Bm.Branch_Name,cm.cmp_city AS Location, 
							  (Select top 1 E.EMP_FULL_NAME From T0080_EMP_MASTER E WITH (NOLOCK)
									Left JOIN  T0090_EMP_REPORTING_DETAIL M WITH (NOLOCK) ON E.Emp_ID=M.R_Emp_id 
									WHERE I_Q.Emp_ID=M.Emp_id and I_Q.Cmp_ID = M.Cmp_ID) AS Manager,
							   (Select top 1 E.Mobile_No From T0080_EMP_MASTER E WITH (NOLOCK)
									Left JOIN  T0090_EMP_REPORTING_DETAIL M WITH (NOLOCK) ON E.Emp_ID=M.R_Emp_id 
									WHERE I_Q.Emp_ID=M.Emp_id and I_Q.Cmp_ID = M.Cmp_ID) AS Manager_Contact_Number, 
							  '',I_Q.Gross_Salary,I_Q.CTC,dbo.F_GET_AGE(Date_Of_Join,GETDATE(),'Y','') as Current_Experience
							  ,EED.IndustryType
			FROM			 T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN
							  #Emp_Cons EC On Ec.Emp_ID = E.Emp_ID INNER JOIN
							  T0010_COMPANY_MASTER Cm WITH (NOLOCK) On Cm.Cmp_Id = E.Cmp_ID Left outer JOIN
							  T0010_COMPANY_DIRECTOR_DETAIL CMD	WITH (NOLOCK) On Cmd.Cmp_Id = Cm.Cmp_Id INNER JOIN                      
								(SELECT	TI.Increment_ID,TI.Branch_ID,TI.Emp_ID, TI.INCREMENT_EFFECTIVE_dATE,TI.Desig_Id,TI.Cmp_ID,TI.Gross_Salary,TI.CTC
										FROM	t0095_increment TI WITH (NOLOCK)
												INNER JOIN (
															SELECT	MAX(T0095_Increment.Increment_ID) AS Increment_ID,T0095_Increment.Emp_ID 
															FROM	T0095_Increment WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON T0095_INCREMENT.Emp_ID=E.Emp_ID
															WHERE	T0095_Increment.Increment_effective_Date <= @to_date AND T0095_Increment.Cmp_ID =55  
															GROUP BY T0095_Increment.emp_ID
															) new_inc ON TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_ID=new_inc.Increment_ID
										WHERE	Increment_effective_Date <= @to_date  )I_Q  On  I_Q.Emp_ID = E.Emp_ID INNER JOIN
							 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID  LEFT OUTER JOIN
							 T0040_DESIGNATION_MASTER Dm WITH (NOLOCK) On Dm.Desig_ID = I_Q.Desig_Id LEFT Outer JOIN
							  dbo.T0090_EMP_EXPERIENCE_DETAIL EED WITH (NOLOCK) ON EED.Emp_ID = E.Emp_ID
	ENd
	Else if @format = 1
		BEGIN
		
		
		CREATE table #Emp_Experience
		(
			emp_Id    NUMERIC,
			Emp_Code  Varchar(100) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,       
			Emp_Full_Name  varchar(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,       
			Date_Of_join VARCHAR(50) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,       
			Previous_Experience	VARCHAR(10) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,       
			Current_experience VARCHAR(10) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,       
			Total_Experience VARCHAR(10) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Industry_Type		VARCHAR(150) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Branch_Id	NUMERIC(18)            
		)	

		DECLARE @Month_Pre varchar(10)
		DECLARE @Month varchar(10)
		DECLARE @Month_curr varchar(10)
		DECLARE @Month_Total varchar(10)
		DECLARE @Previous_exp varchar(10)
		DECLARE @current_exp varchar(10)
		DECLARE @Total_exp varchar(10)
		DECLARE @Year VARCHAR(10)
		DECLARE @Emp_Id_Cur NUMERIC
		
		Declare curEmp cursor for                    
			Select Emp_Id From #Emp_Cons
		open curEmp                      
		fetch next from curEmp into @Emp_Id_Cur 
		while @@fetch_status = 0                    
		begin     
		
			 
			
				SELECT @Month_Pre = (((Sum(convert(numeric(18,2),dbo.AGE(St_Date,End_Date,'y'))) * 12) +                       
									   Sum(convert(numeric(18,2),dbo.AGE(St_Date,End_Date,'M')))))  
				from T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK)
				WHERE Emp_ID = @Emp_Id_Cur
			
			
			set @Year = floor(convert(NUMERIC(18,0),@Month_Pre)/12)
			set @Month = convert(NUMERIC(18,0),@Month_Pre) % 12
			SET @Previous_exp = @Year + '.' + @Month
			
			SELECT @Month_curr = (convert(numeric(18,2),dbo.AGE(Date_Of_Join,GETDATE(),'y') * 12 + convert(numeric(18,2),dbo.AGE(Date_Of_Join,GETDATE(),'M'))))
			from T0080_EMP_MASTER WITH (NOLOCK)
			WHERE Emp_ID = @Emp_Id_Cur
			
			set @Year = FLOOR(convert(NUMERIC(18,0),@Month_curr)/12)
			set @Month = convert(NUMERIC(18,0),@Month_curr) % 12
			SET @current_exp = @Year + '.' + @Month
			
			SET @Month_Total = ISNULL(convert(NUMERIC(18,0),@Month_Pre),0) + IsNULL(convert(NUMERIC(18,0),@Month_curr),0)
			
			
			set @Year = FLOOR(convert(NUMERIC(18,0),@Month_Total)/12)
			set @Month = convert(NUMERIC(18,0),@Month_Total) % 12
			SET @Total_exp = @Year + '.' + @Month
			
			
			Insert INTO #Emp_Experience		
			SELECT			E.emp_Id,E.Alpha_Emp_Code, E.Emp_Full_Name, Convert(varchar(25),E.Date_Of_Join,103) as Date_of_Join
						   ,Isnull(@Previous_exp,0) AS Previous_Experience,
						   Isnull(@current_exp,0) AS current_Experience,
						   IsNull(@Total_exp,0) AS Total_Experience,
						   EED.IndustryType,E.Branch_ID
			FROM          dbo.T0080_EMP_MASTER E WITH (NOLOCK)LEFT outer join
							dbo.T0090_EMP_EXPERIENCE_DETAIL EED WITH (NOLOCK) ON EED.Emp_ID = E.Emp_ID 
			WHERE e.Emp_ID = @Emp_Id_Cur                      
			GROUP By E.Emp_ID,E.Cmp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,E.Date_Of_Join,E.Branch_ID,EED.IndustryType
         
         fetch next from curEmp into @Emp_Id_Cur
	    end                    
		close curEmp                    
		deallocate curEmp 
                      
                      
                      
		END
	
	
	if @Format = 1
		BEGIN
			SELECT * from #Emp_Experience
			Drop TABLE #Emp_Experience
		END
	ELSE IF @Format = 0 
		BEGIN
			SELECT * from #Emp_Experience_Detail Order BY emp_Id ASC
			DROP TABLE #Emp_Experience_Detail
		END
	
	
	
END
	

