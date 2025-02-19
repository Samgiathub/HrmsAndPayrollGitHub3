

-- =============================================
-- Author:		<Mukti>
-- Create date: <17-01-2018>
-- Description:	<Get List of employee of Passport/Visa/Licence Expiry Details>
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Document_Expiry_List]
		@CMP_ID			NUMERIC(18,0),
		@PBranch_ID	varchar(max)= '', 
		@PVertical_ID	varchar(max)= '', 
		@PSubVertical_ID	varchar(max)= '', 
		@PDept_ID varchar(max)='',
		@flag varchar(15)=''  
AS 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
 
	declare @Document_Expiry_Days as numeric(18,0)
		set @Document_Expiry_Days =0
		
	IF @PBranch_ID = '0' or @PBranch_ID='' 
		set @PBranch_ID = null   	
	
	if @PVertical_ID ='0' or @PVertical_ID = ''		
		set @PVertical_ID = null
	
	if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	
		set @PsubVertical_ID = null
	
	IF @PDept_ID = '0' or @PDept_Id=''  
		set @PDept_ID = NULL	 

	CREATE TABLE #DEPT
	(
		Dept_ID		NUMERIC
	)

	CREATE UNIQUE CLUSTERED INDEX IX_DEPT ON #DEPT(Dept_ID)

	
	if @PBranch_ID is null
	Begin	
		select   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		IF @PBranch_ID is null
			set @PBranch_ID = '0';
		else
			set @PBranch_ID = @PBranch_ID + ',0'
	End
	
	if @PVertical_ID is null
	Begin	
		select   @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		If @PVertical_ID IS NULL
			set @PVertical_ID = '0';
		else
			set @PVertical_ID = @PVertical_ID + ',0'	
	End
	if @PsubVertical_ID is null
	Begin	
		select   @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		If @PsubVertical_ID IS NULL
			set @PsubVertical_ID = '0';
		else
			set @PsubVertical_ID = @PsubVertical_ID + ',0'
	End
	IF @PDept_ID is null
		BEGIN
			INSERT INTO #DEPT
			select Dept_ID FROM T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		

			INSERT INTO #DEPT
			SELECT 0
			--select   @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER where Cmp_ID=@Cmp_ID 		
			--if @PDept_ID is null
			--	set @PDept_ID = '0';
			--else
			--	set @PDept_ID = @PDept_ID + ',0'	
		END	
	ELSE
		BEGIN
			INSERT INTO #DEPT
			SELECT CAST(DATA AS NUMERIC) AS Dept_ID FROM dbo.Split(@PDept_ID, ',') D WHere Data <> ''
		END
	
	
	CREATE table #Emp_Cons 
	(
		Emp_ID	NUMERIC,
		Branch_Id numeric,
		Dept_Id numeric
	);	

	  CREATE table #Temp (
		--Row_No Numeric,
		Cmp_Id Numeric,
		Emp_Id numeric,
		Emp_Name varchar(200),
		Branch_name varchar(100),
		Document_Type varchar(100),
		ExpiryDate Datetime,		
		Dept_Name Varchar(200),
		Tran_ID	NUMERIC,
		Passport_No Varchar(200),
		Emp_Code VARCHAR(200),
		Export_For	VARCHAR(20) ---Added By Jimit 15022018
	 )	
							  
	INSERT INTO #Emp_Cons(Emp_ID,Branch_Id,Dept_Id)
	SELECT I.Emp_Id,I.Branch_ID,I.Dept_ID 
		FROM T0095_Increment I WITH (NOLOCK)
			INNER JOIN (SELECT MAX(Increment_Id) AS Increment_ID,i2.Emp_ID  
							FROM T0095_Increment I2 WITH (NOLOCK)
								INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
											FROM	T0095_INCREMENT I3 WITH (NOLOCK)
											WHERE	I3.Increment_Effective_Date <= GETDATE()
											GROUP BY I3.Emp_ID
											) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
							GROUP BY i2.emp_ID 
						) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID						  
			INNER JOIN #DEPT D ON IsNull(I.Dept_ID, 0) = D.Dept_ID
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID=I.Emp_ID 
		WHERE I.Cmp_ID = @Cmp_ID and EM.Emp_Left <> 'Y' 
			and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') B Where cast(B.data as numeric)=Isnull(I.Branch_ID,0))
			and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
			and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
			--and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0)) 
					
		Select @Document_Expiry_Days=Setting_Value from T0040_SETTING WITH (NOLOCK) where Cmp_Id = @CMP_ID and setting_Name = 'Reminder Days for Document Expiry'						
		--select * from #Emp_Cons
		--print @Document_Expiry_Days
		if @flag = '' 
			BEGIN	
			PRINT @Document_Expiry_Days
					Select Ecd.Imm_Date_of_Expiry as [Expiry_Date],EM.Emp_Full_Name,EM.Alpha_Emp_Code,BM.Branch_Name,ECD.Imm_No,DM.Dept_Name,DATEDIFF(dd,GETDATE(),ECD.Imm_Date_of_Expiry)as [Days]			
					from T0090_EMP_IMMIGRATION_DETAIL ECD WITH (NOLOCK) 
						inner join t0080_Emp_Master EM WITH (NOLOCK) on   ECD.Emp_ID=EM.Emp_ID 
						inner join #Emp_Cons I ON EM.Emp_ID=I.Emp_ID 
						inner join T0030_Branch_Master BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
						LEFT join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) On I.Dept_Id = DM.Dept_Id 
					Where ECD.Imm_Date_of_Expiry between Convert(Date,GETDATE(),103) and DateAdd(DAY,@Document_Expiry_Days,Convert(Date,GETDATE(),103))
					And ECD.Cmp_ID= @CMP_ID and ECD.Imm_Type='Passport'
					order by Ecd.Imm_Date_of_Expiry
					
					Select Ecd.Imm_Date_of_Expiry as [Expiry_Date],EM.Emp_Full_Name,EM.Alpha_Emp_Code,BM.Branch_Name,ECD.Imm_No,DM.Dept_Name,DATEDIFF(dd,GETDATE(),ECD.Imm_Date_of_Expiry)as [Days]	
					from T0090_EMP_IMMIGRATION_DETAIL ECD WITH (NOLOCK) 
						inner join t0080_Emp_Master EM WITH (NOLOCK) on   ECD.Emp_ID=EM.Emp_ID 
						inner join #Emp_Cons I ON EM.Emp_ID=I.Emp_ID 
						inner join T0030_Branch_Master BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
						LEFT join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) On I.Dept_Id = DM.Dept_Id 
					Where ECD.Imm_Date_of_Expiry between  Convert(Date,GETDATE(),103) and DateAdd(DAY,@Document_Expiry_Days,Convert(Date,GETDATE(),103))    
					And ECD.Cmp_ID= @CMP_ID and ECD.Imm_Type='Visa'
					order by Ecd.Imm_Date_of_Expiry
					
					Select Ecd.Lic_End_Date as [Expiry_Date],EM.Emp_Full_Name,EM.Alpha_Emp_Code,BM.Branch_Name,LM.Lic_Name,DM.Dept_Name,DATEDIFF(dd,GETDATE(),ECD.Lic_End_Date)as [Days],ECD.Lic_Number	
					from T0090_EMP_LICENSE_DETAIL ECD  WITH (NOLOCK)
						inner join t0080_Emp_Master EM WITH (NOLOCK) on   ECD.Emp_ID=EM.Emp_ID 
						inner join #Emp_Cons I ON EM.Emp_ID=I.Emp_ID 
						inner join T0030_Branch_Master BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
						LEFT join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) On I.Dept_Id = DM.Dept_Id 
						inner JOIN T0040_LICENSE_MASTER LM WITH (NOLOCK) on ECD.LIC_ID=LM.Lic_ID
					Where  ECD.Lic_End_Date  between Convert(Date,GETDATE(),103) and DateAdd(DAY,@Document_Expiry_Days,Convert(Date,GETDATE(),103))    
					And ECD.Cmp_ID= @CMP_ID 
					order by Ecd.Lic_End_Date
					
					---Added By Jimit 14022018
					SELECT	ECD.DATE_OF_EXPIRY AS [EXPIRY_DATE],EM.EMP_FULL_NAME,EM.ALPHA_EMP_CODE,BM.BRANCH_NAME,DNM.Doc_Name AS [DOC_NAME],
							DM.DEPT_NAME,DATEDIFF(DD,GETDATE(),ECD.DATE_OF_EXPIRY)AS [DAYS]
					FROM	T0090_EMP_DOC_DETAIL ECD WITH (NOLOCK) INNER JOIN 
							T0080_EMP_MASTER EM WITH (NOLOCK) ON ECD.EMP_ID=EM.EMP_ID INNER JOIN 
							#EMP_CONS I ON EM.EMP_ID=I.EMP_ID INNER JOIN 
							T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.BRANCH_ID = BM.BRANCH_ID INNER JOIN 
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID INNER JOIN
							T0040_DOCUMENT_MASTER DNM WITH (NOLOCK)  ON DNM.DOC_ID = ECD.DOC_ID INNER JOIN
							(
								SELECT		MAX(DM.DATE_OF_EXPIRY) AS DATE_OF_EXPIRY,DM.DOC_ID,EM.EMP_ID
								FROM		T0040_DOCUMENT_MASTER DMN WITH (NOLOCK) INNER JOIN
											T0090_EMP_DOC_DETAIL DM WITH (NOLOCK) ON DM.DOC_ID = DMN.DOC_ID INNER JOIN
											T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID = DM.EMP_ID
								WHERE		EM.CMP_ID = @CMP_ID  
								GROUP BY	DM.DOC_ID,EM.EMP_ID
							)Q ON Q.EMP_ID = ECD.EMP_ID AND Q.DOC_ID = ECD.DOC_ID AND Q.DATE_OF_EXPIRY = ECD.Date_of_Expiry										
					WHERE ECD.DATE_OF_EXPIRY BETWEEN Convert(Date,GETDATE(),103) and DateAdd(DAY,@Document_Expiry_Days,Convert(Date,GETDATE(),103)) AND   
							ECD.CMP_ID= @CMP_ID	
					order by Ecd.DATE_OF_EXPIRY			
					----ended
			END 
		ELSE
			BEGIN
					Insert into #Temp	
					Select	ECD.Cmp_ID,ECD.Emp_ID,
							EM.Emp_Full_Name as Emp_Full_Name,BM.Branch_Name,'Passport',Ecd.Imm_Date_of_Expiry,DM.Dept_Name,ECD.Row_ID,ECD.Imm_No,EM.Alpha_Emp_Code 			
							,'Passport'
					from T0090_EMP_IMMIGRATION_DETAIL ECD WITH (NOLOCK)  
						inner join t0080_Emp_Master EM WITH (NOLOCK) on   ECD.Emp_ID=EM.Emp_ID 
						inner join #Emp_Cons I ON EM.Emp_ID=I.Emp_ID 
						inner join T0030_Branch_Master BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
						LEFT join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) On I.Dept_ID = DM.Dept_Id 
					Where   ECD.Imm_Date_of_Expiry between  Convert(Date,GETDATE(),103) and DateAdd(DAY,@Document_Expiry_Days,Convert(Date,GETDATE(),103))    
					And ECD.Cmp_ID= @CMP_ID and ECD.Imm_Type='Passport'
					order by Ecd.Imm_Date_of_Expiry
					
					Insert into #Temp
					Select	ECD.Cmp_ID,ECD.Emp_ID,
							EM.Emp_Full_Name as Emp_Full_Name,BM.Branch_Name,'Visa',Ecd.Imm_Date_of_Expiry,DM.Dept_Name,ECD.Row_ID,ECD.Imm_No,EM.Alpha_Emp_Code 		
							,'Visa'
					from	T0090_EMP_IMMIGRATION_DETAIL ECD WITH (NOLOCK) 
						inner join t0080_Emp_Master EM WITH (NOLOCK) on ECD.Emp_ID=EM.Emp_ID 
						inner join #Emp_Cons I ON EM.Emp_ID=I.Emp_ID 
						inner join T0030_Branch_Master BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
						LEFT join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) On I.Dept_ID = DM.Dept_Id 
					Where   ECD.Imm_Date_of_Expiry between  Convert(Date,GETDATE(),103) and DateAdd(DAY,@Document_Expiry_Days,Convert(Date,GETDATE(),103))    
					And ECD.Cmp_ID= @CMP_ID and ECD.Imm_Type='Visa'
					order by Ecd.Imm_Date_of_Expiry
					
					Insert into #Temp
					Select	ECD.Cmp_ID,ECD.Emp_ID,
							EM.Emp_Full_Name as Emp_Full_Name,BM.Branch_Name,LM.Lic_Name,Ecd.Lic_End_Date,DM.Dept_Name,
							ECD.Row_ID,ECD.Lic_Number,EM.Alpha_Emp_Code  			 
							,'Licence'
					from	T0090_EMP_LICENSE_DETAIL ECD WITH (NOLOCK) 
						inner join t0080_Emp_Master EM WITH (NOLOCK) on   ECD.Emp_ID=EM.Emp_ID 
						inner join #Emp_Cons I ON EM.Emp_ID=I.Emp_ID 
						inner join T0030_Branch_Master BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
						LEFT join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) On I.Dept_ID = DM.Dept_Id 
						inner JOIN T0040_LICENSE_MASTER LM WITH (NOLOCK) on ECD.LIC_ID=LM.Lic_ID
					Where   ECD.Lic_End_Date between Convert(Date,GETDATE(),103) and DateAdd(DAY,@Document_Expiry_Days,Convert(Date,GETDATE(),103))
					And ECD.Cmp_ID= @CMP_ID 
					order by Ecd.Lic_End_Date
					
					---Added By Jimit 14022018
					Insert into #Temp					
					SELECT	ECD.Cmp_ID,ECD.Emp_ID,
							EM.Emp_Full_Name as Emp_Full_Name,BM.Branch_Name,DNM.Doc_Name,ECD.DATE_OF_EXPIRY,DM.DEPT_NAME
							,ECD.Row_ID,'',EM.Alpha_Emp_Code
							,'Document'
					FROM	T0090_EMP_DOC_DETAIL ECD  WITH (NOLOCK) INNER JOIN 
							T0080_EMP_MASTER EM WITH (NOLOCK) ON ECD.EMP_ID=EM.EMP_ID INNER JOIN 
							#EMP_CONS I ON EM.EMP_ID=I.EMP_ID INNER JOIN 
							T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.BRANCH_ID = BM.BRANCH_ID INNER JOIN 
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID INNER JOIN
							T0040_DOCUMENT_MASTER DNM WITH (NOLOCK) ON DNM.DOC_ID = ECD.DOC_ID INNER JOIN
							(
								SELECT		MAX(DM.DATE_OF_EXPIRY) AS DATE_OF_EXPIRY,DM.DOC_ID,EM.EMP_ID
								FROM		T0040_DOCUMENT_MASTER DMN WITH (NOLOCK) INNER JOIN
											T0090_EMP_DOC_DETAIL DM WITH (NOLOCK) ON DM.DOC_ID = DMN.DOC_ID INNER JOIN
											T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID = DM.EMP_ID
								WHERE		EM.CMP_ID = @CMP_ID  
								GROUP BY	DM.DOC_ID,EM.EMP_ID
							)Q ON Q.EMP_ID = ECD.EMP_ID AND Q.DOC_ID = ECD.DOC_ID AND Q.DATE_OF_EXPIRY = ECD.Date_of_Expiry										
					WHERE   ECD.DATE_OF_EXPIRY BETWEEN Convert(Date,GETDATE(),103) and DateAdd(DAY,@Document_Expiry_Days,Convert(Date,GETDATE(),103)) AND   
							ECD.CMP_ID= @CMP_ID		
					order by Ecd.DATE_OF_EXPIRY		
					----ended
					
					SELECT  
					ROW_NUMBER() OVER(ORDER BY ExpiryDate) as [Sr.No],
					Emp_Code  as [Employee Code],
					Emp_Name  as [Employee Name],
					Passport_No as[Document No.],
					Isnull(Branch_name,'-') as [Branch],
					Isnull(Dept_Name,'-') as [Department],
					Isnull(Document_Type,'-') as [Document Type],
					Convert(nvarchar(11), ExpiryDate, 113) As [Date of Expiry],
					DATEDIFF(dd,GETDATE(),ExpiryDate) AS [Days]
					FROM #Temp 
					where Export_For = @flag --Added By Jimit 15022018
					order by ExpiryDate				
		END
END

