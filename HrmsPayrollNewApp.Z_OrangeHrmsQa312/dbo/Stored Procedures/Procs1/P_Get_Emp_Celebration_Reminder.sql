
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Get_Emp_Celebration_Reminder]
   @Cmp_ID numeric(18,0),
   @P_Branch varchar(max) = '',  --Added By Jaina 11-08-2016
   @P_Department varchar(max) ='', --Added By Jaina 11-08-2016
   @P_Vertical varchar(max)='', --Added By Jaina 11-08-2016
   @P_SubVertical varchar(max) = '' --Added By Jaina 11-08-2016   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

	IF	@P_Branch = '' or @P_Branch = '0'
		set @P_Branch = NULL
		
	IF @P_Vertical = '' or @P_Vertical = '0'
		set @P_Vertical = NULL
				
	IF @P_SubVertical = '' or @P_SubVertical='0'
		set @P_SubVertical = NULL
			
	IF @P_Department = '' or @P_Department='0'
		set @P_Department = NULL
			
		
	if @P_Branch is null
		Begin	
			select   @P_Branch = COALESCE(@P_Branch + '#', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
			set @P_Branch = @P_Branch + '#0'
		End
			
	if @P_Vertical is null
		Begin	
			select   @P_Vertical = COALESCE(@P_Vertical + '#', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
				
			If @P_Vertical IS NULL
				set @P_Vertical = '0';
			else
				set @P_Vertical = @P_Vertical + '#0'		
			End
			
	if @P_SubVertical is null
		Begin	
			select   @P_SubVertical = COALESCE(@P_SubVertical + '#', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
				
			If @P_SubVertical IS NULL
				set @P_SubVertical = '0';
			else
				set @P_SubVertical = @P_SubVertical + '#0'
			End

	IF @P_Department is null
		Begin
			select   @P_Department = COALESCE(@P_Department + '#', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
				
			if @P_Department is null
				set @P_Department = '0';
			else
				set @P_Department = @P_Department + '#0'
			End
			
	--Added By Jaina 11-08-2016 End	
	
		CREATE table #Emp_Reminder 
		(			
			Emp_Id Numeric,
			Employee_Full_Name varchar(250),
			Alpha_Emp_Code Varchar(100),
			For_Date datetime,	
			Desig_Name Varchar(100),
			Dept_Name Varchar(100),	
			Branch_Name Varchar(100),
			Image_Name Varchar(100),
			Company_Name varchar(250), 	
			Is_GroupOfCmp TINYINT	,			
			Sort_ID NUMERIC,
			Gender Varchar(10),
			Emp_First_Name Varchar(200),
			Reminder_Type	Tinyint,				--0 : New Joining, 1 : Birthday, 2: Work Anniversary
			Cmp_ID		NUMERIC
		)
		CREATE CLUSTERED INDEX IX_Emp_Reminder_Emp_Id ON #Emp_Reminder(Cmp_ID,Reminder_Type,Emp_ID,Sort_ID);
		
	   
	    Declare @Show_GrpCompany_NewJoining as Numeric(18,0)
	    Declare @Is_GroupOfComp as Numeric(18,0)
	    DECLARE @Setting_Name as VARCHAR(100)
	    
	    SET @Setting_Name ='Show New Joining Details for All Group Company wise on Dashboard'
	          
		select @Show_GrpCompany_NewJoining = isnull(Setting_Value , 0)  from T0040_SETTING WITH (NOLOCK) where Setting_Name = @Setting_Name and Cmp_ID = @Cmp_ID
		    
		select @Is_GroupOfComp = is_GroupOFCmp from T0010_COMPANY_MASTER WITH (NOLOCK) where cmp_id = @Cmp_ID

		/*For New Joining*/
		INSERT INTO #Emp_Reminder		
		select  Emp_ID,Emp_Full_Name,Alpha_Emp_Code,Date_Of_Join,Isnull(Desig_Name,''),Isnull(Dept_Name,''),Branch_Name,
				(CASE WHEN E.Image_Name = '' OR E.Image_Name = '0.jpg'  THEN 
					(Case When E.Gender = 'Male' THEN 'Emp_default.png' ELSE 'Emp_Default_Female.png' END) 
				 Else 
					Image_Name 
				 END) as IMAGE_NAME,
				 cmp_name,is_GroupOFCmp,
				(Case When E.Cmp_ID = @Cmp_ID then 0 Else E.Cmp_ID End) as Sort_Id,E.Gender,Emp_First_Name, 0 Reminder_Type, E.Cmp_ID
		from	V0080_EMPLOYEE_MASTER  E inner join
				(SELECT Cmp_ID,S.Setting_Value From T0040_SETTING S WITH (NOLOCK)
				WHERE Setting_Name=@Setting_Name) T ON E.Cmp_ID=T.Cmp_ID
		WHERE  Date_Of_Join Between cast(CAST( DATEADD(DAY,-30,GETDATE()) as varchar(11)) AS datetime) and GETDATE() and 		       
				Show_New_Join_Employee = 1  --AND T.Setting_Value=1 
				AND  emp_Left <> 'y' AND (Case When  @Show_GrpCompany_NewJoining = 1 and @Is_GroupOfComp = 1 AND E.is_GroupOFCmp=1 AND T.Setting_Value=1  Then 
					@Cmp_ID 
				Else E.Cmp_ID eND) = @Cmp_ID
				--Added By Jaina 11-08-2016 Start
				and EXISTS (select Data from dbo.Split(@P_Branch, '#') B Where cast(B.data as numeric)=Isnull(E.Branch_ID,0))
				and EXISTS (select Data from dbo.Split(@P_Vertical, '#') VE Where cast(VE.data as numeric)=Isnull(E.Vertical_ID,0))
				and EXISTS (select Data from dbo.Split(@P_SubVertical, '#') S Where cast(S.data as numeric)=Isnull(E.SubVertical_ID,0))
				and EXISTS (select Data from dbo.Split(@P_Department, '#') D Where cast(D.data as numeric)=Isnull(E.Dept_ID,0))    		     
				--Added By Jaina 11-08-2016 End		
				

		--IF @Is_GroupOfComp = 1
		--	BEGIN
		--		Insert Into #Emp_Reminder(Emp_Id,Company_Name,Employee_Full_Name,Alpha_Emp_Code,Sort_ID,Gender,Desig_Name,Dept_Name,For_Date,Emp_First_Name,Reminder_Type,Cmp_ID	)
		--		--Select 0,Company_Name, '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ Company_Name +' </i></b>','', Sort_ID, '','','','',''
		--		Select 0,Company_Name,Company_Name,'', Sort_ID, '','','','','', 0 Reminder_Type, Cmp_ID
		--		From #Emp_Reminder
		--		Group By Cmp_ID,Company_Name, Sort_ID		    
		--	END

	
		DECLARE @FROM_DATE DATETIME
		DECLARE @TO_DATE DATETIME

		SET @FROM_DATE = CONVERT(DATETIME, CONVERT(CHAR(10), GETDATE(), 103), 103)
		SET @TO_DATE = DATEADD(D, 7, @FROM_DATE)
		
		
		/*For Birthday*/
		SET @Setting_Name = 'Show Birthday Reminder Group Company wise' 

		INSERT INTO #Emp_Reminder
		SELECT	Emp_ID,Emp_Full_Name,Alpha_Emp_Code,DOB,Desig_Name,Dept_Name,Branch_Name,IMAGE_NAME,Cmp_Name,is_GroupOFCmp,Sort_Id,Gender,Emp_First_Name,Reminder_Type, Cmp_ID
		FROM	(
					SELECT  Emp_ID,Emp_Full_Name,Alpha_Emp_Code,Date_Of_Join,Isnull(Desig_Name,'') As Desig_Name,Isnull(Dept_Name,'') As Dept_Name,Branch_Name,
							(CASE WHEN E.Image_Name = '' OR E.Image_Name = '0.jpg'  THEN 
								(Case When E.Gender = 'Male' THEN 'Emp_default.png' ELSE 'Emp_Default_Female.png' END) 
							 Else 
								Image_Name 
							 END) as IMAGE_NAME,
							 Cmp_Name,is_GroupOFCmp,
							(Case When E.Cmp_ID = @Cmp_ID then 0 Else E.Cmp_ID End) as Sort_Id,E.Gender,Emp_First_Name, 1 Reminder_Type,
							 (CASE WHEN IsNull(Actual_Date_Of_Birth,'1900-01-01') = '1900-01-01' Then IsNull(Date_Of_Birth,'1900-01-01') Else Actual_Date_Of_Birth End) As DOB,
							 Setting_Value,Show_New_Join_Employee, Emp_Left, E.Cmp_ID, Branch_ID, Vertical_ID, SubVertical_ID, Dept_ID
					FROM	V0080_EMPLOYEE_MASTER  E inner join
							(SELECT Cmp_ID,S.Setting_Value From T0040_SETTING S WITH (NOLOCK) WHERE Setting_Name=@Setting_Name) T ON E.Cmp_ID=T.Cmp_ID
				) T
		WHERE	Show_New_Join_Employee = 1  --AND T.Setting_Value=1 
				AND  IsNull(Emp_Left, 'N') <> 'Y' 
				AND (Case When @Is_GroupOfComp = 1 AND is_GroupOFCmp=1 AND T.Setting_Value=1  Then 
						@Cmp_ID 
					Else Cmp_ID eND) = @Cmp_ID				
				AND (EXISTS (select Data from dbo.Split(@P_Branch, '#') B Where cast(B.data as numeric)=Isnull(Branch_ID,0)) OR T.Setting_Value=1)
				AND (EXISTS (select Data from dbo.Split(@P_Vertical, '#') VE Where cast(VE.data as numeric)=Isnull(Vertical_ID,0)) OR T.Setting_Value=1)
				AND (EXISTS (select Data from dbo.Split(@P_SubVertical, '#') S Where cast(S.data as numeric)=Isnull(SubVertical_ID,0)) OR T.Setting_Value=1)
				AND (EXISTS (select Data from dbo.Split(@P_Department, '#') D Where cast(D.data as numeric)=Isnull(Dept_ID,0)) OR T.Setting_Value=1)				
				AND DATEADD(YEAR, datediff(year, dob,@FROM_DATE), DOB) BETWEEN @FROM_DATE AND @TO_DATE
				AND DOB <> '1900-01-01'
		ORDER BY Cmp_ID, DOB, Alpha_Emp_Code

		--IF @Is_GroupOfComp = 1
		--	BEGIN
		--		Insert Into #Emp_Reminder(Emp_Id,Company_Name,Employee_Full_Name,Alpha_Emp_Code,Sort_ID,Gender,Desig_Name,Dept_Name,For_Date,Emp_First_Name,Reminder_Type,Cmp_ID)
		--		--Select 0,Company_Name, '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ Company_Name +' </i></b>','', Sort_ID, '','','','',''
		--		Select 0,Company_Name,Company_Name,'', Sort_ID, '','','','','', 1 Reminder_Type, Cmp_ID
		--		From #Emp_Reminder
		--		Group By Cmp_ID,Company_Name, Sort_ID		    
		--	END
		
		
		/*For Employee Anniversary*/
		SET @Setting_Name = 'Show Birthday Reminder Group Company wise' 

		INSERT INTO #Emp_Reminder
		SELECT	Emp_ID,Emp_Full_Name,Alpha_Emp_Code,Emp_Annivarsary_Date,Desig_Name,Dept_Name,Branch_Name,IMAGE_NAME,Cmp_Name,is_GroupOFCmp,Sort_Id,Gender,Emp_First_Name,Reminder_Type, Cmp_ID
		FROM	(
					SELECT  Emp_ID,Emp_Full_Name,Alpha_Emp_Code,Date_Of_Join,Isnull(Desig_Name,'') As Desig_Name,Isnull(Dept_Name,'') As Dept_Name,Branch_Name,
							(CASE WHEN E.Image_Name = '' OR E.Image_Name = '0.jpg'  THEN 
								(Case When E.Gender = 'Male' THEN 'Emp_default.png' ELSE 'Emp_Default_Female.png' END) 
							 Else 
								Image_Name 
							 END) as IMAGE_NAME,
							 Cmp_Name,is_GroupOFCmp,
							(Case When E.Cmp_ID = @Cmp_ID then 0 Else E.Cmp_ID End) as Sort_Id,E.Gender,Emp_First_Name, 2 Reminder_Type,
							 Emp_Annivarsary_Date,
							 Setting_Value,Show_New_Join_Employee, Emp_Left, E.Cmp_ID, Branch_ID, Vertical_ID, SubVertical_ID, Dept_ID
					FROM	V0080_EMPLOYEE_MASTER  E inner join
							(SELECT Cmp_ID,S.Setting_Value From T0040_SETTING S WITH (NOLOCK) WHERE Setting_Name=@Setting_Name) T ON E.Cmp_ID=T.Cmp_ID
				) T
		WHERE	Show_New_Join_Employee = 1  --AND T.Setting_Value=1 
				AND  IsNull(Emp_Left, 'N') <> 'Y' 
				AND (Case When @Is_GroupOfComp = 1 AND is_GroupOFCmp=1 AND T.Setting_Value=1  Then 
						@Cmp_ID 
					Else Cmp_ID eND) = @Cmp_ID				
				AND (EXISTS (SELECT Data FROM dbo.Split(@P_Branch, '#') B Where cast(B.data as numeric)=Isnull(Branch_ID,0)) OR T.Setting_Value=1)
				AND (EXISTS (SELECT Data FROM dbo.Split(@P_Vertical, '#') VE Where cast(VE.data as numeric)=Isnull(Vertical_ID,0)) OR T.Setting_Value=1)
				AND (EXISTS (SELECT Data FROM dbo.Split(@P_SubVertical, '#') S Where cast(S.data as numeric)=Isnull(SubVertical_ID,0)) OR T.Setting_Value=1)
				AND (EXISTS (SELECT Data FROM dbo.Split(@P_Department, '#') D Where cast(D.data as numeric)=Isnull(Dept_ID,0)) OR T.Setting_Value=1)				
				AND DATEADD(YEAR, datediff(year, Emp_Annivarsary_Date,@FROM_DATE), Emp_Annivarsary_Date) BETWEEN @FROM_DATE AND @TO_DATE
				AND Emp_Annivarsary_Date <> '1900-01-01'
		ORDER BY Cmp_ID, Emp_Annivarsary_Date, Alpha_Emp_Code

				
		--IF @Is_GroupOfComp = 1
		--	BEGIN
		--		Insert Into #Emp_Reminder(Emp_Id,Company_Name,Employee_Full_Name,Alpha_Emp_Code,Sort_ID,Gender,Desig_Name,Dept_Name,For_Date,Emp_First_Name,Reminder_Type	)
		--		--Select 0,Company_Name, '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ Company_Name +' </i></b>','', Sort_ID, '','','','',''
		--		Select 0,Company_Name,Company_Name,'', Sort_ID, '','','','','', 1 Reminder_Type
		--		From #Emp_Reminder
		--		Group By Cmp_ID,Company_Name, Sort_ID		    
		--	END


	 
		/*For Employee Work Anniversary*/
		SET @Setting_Name = 'Show Birthday Reminder Group Company wise' 

		insert into #Emp_Reminder
		select  Emp_ID,Emp_Full_Name,Alpha_Emp_Code,Date_Of_Join,Isnull(Desig_Name,''),Isnull(Dept_Name,''),Branch_Name,
				(CASE WHEN E.Image_Name = '' OR E.Image_Name = '0.jpg'  THEN 
					(Case When E.Gender = 'Male' THEN 'Emp_default.png' ELSE 'Emp_Default_Female.png' END) 
				 Else 
					Image_Name 
				 END) as IMAGE_NAME,
				 cmp_name,is_GroupOFCmp,
				(Case When E.Cmp_ID = @Cmp_ID then 0 Else E.Cmp_ID End) as Sort_Id,E.Gender,Emp_First_Name, 3 Reminder_Type, E.Cmp_ID
		from	V0080_EMPLOYEE_MASTER  E inner join
				(SELECT Cmp_ID,S.Setting_Value From T0040_SETTING S WITH (NOLOCK) WHERE Setting_Name=@Setting_Name) T ON E.Cmp_ID=T.Cmp_ID
		WHERE	Show_New_Join_Employee = 1  --AND T.Setting_Value=1 
				AND  IsNull(Emp_Left, 'N') <> 'Y' 
				AND (Case When @Is_GroupOfComp = 1 AND E.is_GroupOFCmp=1 AND T.Setting_Value=1  Then 
						@Cmp_ID 
					Else E.Cmp_ID eND) = @Cmp_ID
				--Added By Jaina 11-08-2016 Start
				AND (EXISTS (select Data from dbo.Split(@P_Branch, '#') B Where cast(B.data as numeric)=Isnull(E.Branch_ID,0)) OR T.Setting_Value=1)
				AND (EXISTS (select Data from dbo.Split(@P_Vertical, '#') VE Where cast(VE.data as numeric)=Isnull(E.Vertical_ID,0)) OR T.Setting_Value=1)
				AND (EXISTS (select Data from dbo.Split(@P_SubVertical, '#') S Where cast(S.data as numeric)=Isnull(E.SubVertical_ID,0)) OR T.Setting_Value=1)
				AND (EXISTS (select Data from dbo.Split(@P_Department, '#') D Where cast(D.data as numeric)=Isnull(E.Dept_ID,0)) OR T.Setting_Value=1)
				--Added By Jaina 11-08-2016 End		
				AND DATEADD(YEAR, DATEDIFF(YEAR, Date_Of_Join,@FROM_DATE), Date_Of_Join) BETWEEN @FROM_DATE AND @TO_DATE
				AND Date_Of_Join > DATEADD(D,364,@FROM_DATE)
		ORDER BY E.Cmp_ID, Date_Of_Join, Alpha_Emp_Code

		IF @Is_GroupOfComp = 1
			BEGIN
				Insert Into #Emp_Reminder(Emp_Id,Company_Name,Employee_Full_Name,Alpha_Emp_Code,Sort_ID,Gender,Desig_Name,Dept_Name,For_Date,Emp_First_Name,Reminder_Type,Cmp_ID)
				--Select 0,Company_Name, '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ Company_Name +' </i></b>','', Sort_ID, '','','','',''
				Select 0,Company_Name,Company_Name,'', Sort_ID, '','','','','', Reminder_Type, Cmp_ID
				From #Emp_Reminder
				Group By Cmp_ID,Company_Name, Sort_ID,Reminder_Type

			END

	SELECT	Employee_Full_Name,Branch_Name,Image_Name,Alpha_Emp_Code,Dept_Name,Desig_Name,Emp_Id,For_Date,Gender,Emp_First_Name, Reminder_Type, Case When For_Date = @FROM_DATE Then 1 Else 0 End As Todays_Reminder
	FROM	#Emp_Reminder  
	ORDER BY Cmp_ID, Reminder_Type,DATEADD(YEAR, DATEDIFF(YEAR, For_Date,@FROM_DATE), For_Date)
    
    
	DROP TABLE #Emp_Reminder
    
RETURN 
