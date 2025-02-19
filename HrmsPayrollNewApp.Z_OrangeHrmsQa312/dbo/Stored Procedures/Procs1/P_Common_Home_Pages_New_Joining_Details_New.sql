

CREATE PROCEDURE [dbo].[P_Common_Home_Pages_New_Joining_Details_New]
   @Cmp_ID numeric(18,0),
   @P_Branch varchar(max) = '',  --Added By Jaina 11-08-2016
   @P_Department varchar(max) ='', --Added By Jaina 11-08-2016
   @P_Vertical varchar(max)='', --Added By Jaina 11-08-2016
   @P_SubVertical varchar(max) = '', --Added By Jaina 11-08-2016
   @P_FromDate DateTime =null--Added By Niraj 08-07-2021
   
AS  
	set @P_FromDate = cast(convert(varchar(50),@P_FromDate,103) as date)

	    SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
	
		--Added By Jaina 11-08-2016 Start

	IF	@P_Branch = '' or @P_Branch = '0'
		set @P_Branch = NULL
		
	IF @P_Vertical = '' or @P_Vertical = '0'
		set @P_Vertical = NULL
				
	IF @P_SubVertical = '' or @P_SubVertical='0'
		set @P_SubVertical = NULL
			
	IF @P_Department = '' or @P_Department='0'
		set @P_Department = NULL
	
	IF @P_FromDate = ''
		set @P_FromDate = NULL
		
	/*	
	if @P_Branch is null
		Begin	
			select   @P_Branch = COALESCE(@P_Branch + '#', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER where Cmp_ID=@Cmp_ID 
			set @P_Branch = @P_Branch + '#0'
		End
			
	if @P_Vertical is null
		Begin	
			select   @P_Vertical = COALESCE(@P_Vertical + '#', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment where Cmp_ID=@Cmp_ID 
				
			If @P_Vertical IS NULL
				set @P_Vertical = '0';
			else
				set @P_Vertical = @P_Vertical + '#0'		
			End
			
	if @P_SubVertical is null
		Begin	
			select   @P_SubVertical = COALESCE(@P_SubVertical + '#', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical where Cmp_ID=@Cmp_ID 
				
			If @P_SubVertical IS NULL
				set @P_SubVertical = '0';
			else
				set @P_SubVertical = @P_SubVertical + '#0'
			End

	IF @P_Department is null
		Begin
			select   @P_Department = COALESCE(@P_Department + '#', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER where Cmp_ID=@Cmp_ID 		
				
			if @P_Department is null
				set @P_Department = '0';
			else
				set @P_Department = @P_Department + '#0'
			End
*/			
	--Added By Jaina 11-08-2016 End	
	
	
		CREATE table #New_Joining 
		(			
			Emp_Id Numeric,
			Employee_Full_Name varchar(250),
			Alpha_Emp_Code Varchar(100),
			Date_Of_join datetime,	
			Desig_Name Varchar(100),
			Dept_Name Varchar(100),	
			Branch_Name Varchar(100),
			Image_Name Varchar(100),
			Company_Name varchar(250), 	
			Is_GroupOfCmp TINYINT	,			
			Sort_ID NUMERIC,
			Gender Varchar(10),
			Emp_First_Name Varchar(200),
			Cat_Name  VARCHAR(250)       --Added By Jimit 05102018
		)
		CREATE NONCLUSTERED INDEX IX_New_Joining_Emp_Id ON #New_Joining(Emp_ID,Sort_ID);
		
	   
	    Declare @Show_GrpCompany_NewJoining as Numeric(18,0)
	    Declare @Is_GroupOfComp as Numeric(18,0)
	    DECLARE @Setting_Name as VARCHAR(100)
	    
	    SET @Setting_Name ='Show New Joining Details for All Group Company wise on Dashboard'
	          
		select @Show_GrpCompany_NewJoining = isnull(Setting_Value , 0)  from T0040_SETTING WITH (NOLOCK) where Setting_Name = @Setting_Name and Cmp_ID = @Cmp_ID
		    
		select @Is_GroupOfComp = is_GroupOFCmp from T0010_COMPANY_MASTER WITH (NOLOCK) where cmp_id = @Cmp_ID

		Declare @Where_Query varchar(2000)
		Declare @Qry varchar(2000)
		Set @Where_Query= '1=1'
		
			If @P_Branch Is Not null
				Set @Where_Query = @Where_Query + ' and EXISTS (select Data from dbo.Split('' ' + @P_Branch + ''', ''#'') B Where cast(B.data as numeric)=Isnull(E.Branch_ID,0))'

			If @P_Vertical Is Not null
				Set @Where_Query = @Where_Query + ' and EXISTS (select Data from dbo.Split( ''' + @P_Vertical + ''', ''#'') B Where cast(B.data as numeric)=Isnull(E.Branch_ID,0))'

			If @P_SubVertical Is Not null
				Set @Where_Query = @Where_Query + ' and EXISTS (select Data from dbo.Split( ''' + @P_SubVertical + ''', ''#'') B Where cast(B.data as numeric)=Isnull(E.Branch_ID,0))'

			If @P_Department Is Not null
				Set @Where_Query = @Where_Query + ' and EXISTS (select Data from dbo.Split( ''' + @P_Department + ''', ''#'') B Where cast(B.data as numeric)=Isnull(E.Branch_ID,0))'
			
			If @P_FromDate Is Not null --Added By Niraj
				Set @Where_Query = @Where_Query + ' and Date_Of_Join >= '''+CONVERT(varchar,+ @P_FromDate,121)+''' '

	Set @Qry = 'insert into #New_Joining
			select  Emp_ID,Emp_Full_Name,Alpha_Emp_Code,Date_Of_Join,Isnull(Desig_Name,''''),Isnull(Dept_Name,''''),Branch_Name,
				(CASE WHEN E.Image_Name = '''' OR E.Image_Name = ''0.jpg''  THEN 
					(Case When E.Gender = ''Male'' THEN ''Emp_default.png'' ELSE ''Emp_Default_Female.png'' END) 
				 Else 
					Image_Name 
				 END) as IMAGE_NAME,
				 cmp_name,is_GroupOFCmp,
				(Case When E.Cmp_ID = ' + Cast(@Cmp_ID as varchar(3)) + ' then 0 Else E.Cmp_ID End) as Sort_Id,E.Gender,Emp_First_Name				
				,E.Cat_Name
			from	V0080_EMPLOYEE_MASTER  E inner join
				(SELECT Cmp_ID,S.Setting_Value From T0040_SETTING S WITH (NOLOCK) 
				WHERE Setting_Name= ''' + @Setting_Name + ''' ) T ON E.Cmp_ID=T.Cmp_ID
			WHERE
				--Date_Of_Join Between cast(CAST( DATEADD(DAY,-30,GETDATE()) as varchar(11)) AS datetime) and GETDATE()
				Show_New_Join_Employee = 1
				AND  emp_Left <> ''Y'' AND (Case When  ' + Cast(@Show_GrpCompany_NewJoining as varchar) + ' = 1 and ' + Cast(@Is_GroupOfComp as varchar) + '= 1 AND E.is_GroupOFCmp=1 AND T.Setting_Value=1  Then 
					' + Cast(@Cmp_ID as Varchar(3)) + '
				Else E.Cmp_ID End) = ' + Cast(@Cmp_ID as Varchar(3)) + '
				And ' + @Where_Query
		print @Qry
		Exec(@Qry)
				
		IF @Is_GroupOfComp = 1
			BEGIN
				Insert Into #New_Joining(Emp_Id,Company_Name,Employee_Full_Name,Alpha_Emp_Code,Sort_ID,Gender,Desig_Name,Dept_Name,Date_Of_join,Emp_First_Name,Cat_Name)
				--Select 0,Company_Name, '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ Company_Name +' </i></b>','', Sort_ID, '','','','',''
				Select 0,Company_Name,Company_Name,'', Sort_ID, '','','',Dateadd(MONTH,6,getdate()),'',''
				From #New_Joining
				Group By Company_Name, Sort_ID		    
			END
		
     Select	Employee_Full_Name,Branch_Name,Image_Name,Alpha_Emp_Code,Dept_Name,Desig_Name,Emp_Id,
			Convert(varchar(11),Date_Of_join,103) as Date_Of_join,Gender,Emp_First_Name,	
			Date_Of_join as Date_Of_join1,Cat_Name
	 from #New_Joining  order by Sort_ID Asc,Date_Of_join1 Desc     
    
    DROP TABLE #New_Joining
    
RETURN 

