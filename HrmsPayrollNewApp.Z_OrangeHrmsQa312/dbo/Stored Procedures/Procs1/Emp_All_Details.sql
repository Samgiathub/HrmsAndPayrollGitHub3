



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Emp_All_Details]  
	@Company_Id		numeric  
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric	
	,@Grade_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@Constraint	varchar(max)
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
 declare @Year_End_Date as datetime  
 Declare @User_type varchar(30)  
   
   
  
 	IF @Branch_ID = 0  
		set @Branch_ID = null   
	 If @Grade_ID = 0  
		 set @Grade_ID = null  
	 If @Emp_ID = 0  
		set @Emp_ID = null  
	 If @Desig_ID = 0  
		set @Desig_ID = null  
     If @Dept_ID = 0  
		set @Dept_ID = null 
	 If @Type_ID = 0  
		set @Type_ID = null 	
 
     
   
 Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons(Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
		
			Insert Into @Emp_Cons

				select I.Emp_Id from dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Company_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	 Inner join
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) on i.emp_ID = E.Emp_ID
					Where E.CMP_ID = @Company_ID 
					and i.BRANCH_ID = isnull(@BRANCH_ID ,i.BRANCH_ID)
					and i.Type_ID = isnull(@Type_ID ,i.Type_ID)-- Added by Mitesh on 06/09/2011
					and i.Grd_ID = isnull(@Grade_ID ,i.Grd_ID)
					and isnull(i.Dept_ID,0) = isnull(@Dept_ID ,isnull(i.Dept_ID,0))			
					and Isnull(i.Desig_ID,0) = isnull(@Desig_ID ,Isnull(i.Desig_ID,0))			
					and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0))
					and Date_Of_Join <= @To_Date and I.emp_id in(
						select e.Emp_Id from
						(select e.emp_id, e.cmp_id, Date_Of_Join, isnull(Emp_left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
						where cmp_id = @Company_id   and  
						(( @From_Date  >= Date_Of_Join  and  @From_Date <= Emp_left_date ) 
						or ( @to_Date  >= Date_Of_Join  and @To_Date <= Emp_left_date )
						or Emp_left_date is null and @To_Date >= Date_Of_Join)
						or @To_Date >= Emp_left_date  and  @From_Date <= Emp_left_date )  
			
		end
---------------------  
	
  CREATE table #Allowance_Record 
			(
				Emp_Id     Numeric,
				To_Date    Datetime,  				
				Company_ID Numeric,  				
		   )	
		
		
	Insert into #Allowance_Record (emp_id)
		select Emp_id from @Emp_Cons
		
	Update #Allowance_Record set To_Date = @To_Date, Company_ID = @Company_Id
    
    declare @Allow_dedu_id as numeric
	declare @Description as varchar(900)
	Declare @Description_Org as varchar(900)
	declare @test as Varchar(4000)
	declare @test1 as Varchar(4000)
	declare @Amt as Numeric(18,2)
	
    DECLARE allowance_deduction_master CURSOR FOR
		select AD_NAME,AD_ID from T0050_AD_MASTER WITH (NOLOCK) where CMP_ID = @company_id 
		
		OPEN allowance_deduction_master
			fetch next from allowance_deduction_master into @Description,@Allow_dedu_id
			while @@fetch_status = 0
				Begin
					
					set @Description_Org = @Description
					set @Description=replace (@Description,'(','_')
					set @Description=replace (@Description,'''','_')
					set @Description=replace (@Description,')','_')
					set @Description=replace (@Description,'[','_')
					set @Description=replace (@Description,']','_')
					set @Description=replace (@Description,'%','_')
					set @Description=replace (@Description,'`','_')
					set @Description=replace (@Description,'#','_')
					set @Description=replace (@Description,'+','_')
					set @Description=replace(@Description,' ','_')
					set @Description=replace (@Description,'.','_')
					set @Description=replace (@Description,'. ','_')
					set @Description=replace (@Description,'-','_')
					set @Description=replace (@Description,'/','_')
					set @Description=replace (@Description,'\','_')					
					set @Description=replace (@Description,',','_')					
					set @Description=replace (@Description,'.','_')
					set @Description=replace (@Description,'  ',' ')
					set @Description=replace (@Description,'  ',' ')
					set @Description=replace (@Description,'__','_')
					
					Set @test ='alter   table  #Allowance_Record ADD ['+ @Description +'] numeric(18,2) default 0'
					exec(@test)	
					set @test=''
					
				fetch next from allowance_deduction_master into @Description,@Allow_dedu_id	 
				End
		close allowance_deduction_master	
	deallocate allowance_deduction_master
	
	--------------------------------------------------------------------------------------------------------------
	
	DECLARE Allow_Dedu_Cursor CURSOR FOR

	select ev.emp_id,ev.E_AD_AMOUNT,ev.AD_NAME from V0100_EMP_EARN_DEDUCTION EV inner join  
      ( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_INCREMENT  WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment 
      where Increment_Effective_date <= @To_Date and Cmp_ID = @Company_id Group by emp_ID) Qry  
     on ev.Emp_ID = Qry.Emp_ID and  
     ev.Increment_Id = Qry.Increment_Id and ev.emp_id in (select emp_id from @emp_cons)  		  
		OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @emp_id,@Amt,@Description
			while @@fetch_status = 0
				Begin					
					set @amt=0
					set @Description_Org=@Description
					set @Description=replace (@Description,'(','_')
					set @Description=replace (@Description,')','_')
					set @Description=replace (@Description,'''','_')
					set @Description=replace (@Description,'+','_')
					set @Description=replace (@Description,'[','_')
					set @Description=replace (@Description,']','_')
					set @Description=replace (@Description,'%','_')
					set @Description=replace (@Description,'`','_')
					set @Description=replace (@Description,'#','_')
					set @Description=replace(@Description,' ','_')
					set @Description=replace (@Description,'.','_')									
					set @Description=replace (@Description,'. ','_')
					set @Description=replace (@Description,'-','_')
					set @Description=replace (@Description,'/','_')
					set @Description=replace (@Description,'\','_')	
					set @Description=replace (@Description,',','_')					
					set @Description=replace (@Description,'.','_')				
					set @Description=replace (@Description,'  ',' ')
					set @Description=replace (@Description,'  ',' ')
					set @Description=replace (@Description,'__','_')
					
					select @Amt = ev.E_AD_AMOUNT from V0100_EMP_EARN_DEDUCTION ev inner join  
					  ( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_INCREMENT WITH (NOLOCK)    --Changed by Hardik 10/09/2014 for Same Date Increment
					  where Increment_Effective_date <= @To_Date and Cmp_ID = @Company_id Group by emp_ID) Qry  
					 on ev.Emp_ID = Qry.Emp_ID and ev.Increment_Id = Qry.Increment_Id 
					 Where Ev.Emp_Id = @Emp_id And AD_NAME = @Description_Org
					
					Set @test1 ='Update #Allowance_Record set ' + @Description + ' = ' +  Cast(@amt As Varchar(50)) + ' Where Emp_Id = '+Cast(@emp_id As Varchar(50))
					exec(@test1)
					set @test=''	
					
				fetch next from Allow_Dedu_Cursor into @emp_id,@Amt,@Description	 
				End
		close Allow_Dedu_Cursor	
		deallocate Allow_Dedu_Cursor
  
      
   SELECT Emp_code,Initial,Emp_First_Name,Emp_Second_Name,Emp_Last_Name,BM.Branch_Name,GM.Grd_Name,DM.Desig_Name,TM.Type_Name,CM.Cat_Name,DT.Dept_Name,
		   convert(varchar,Date_Of_Join,103) as Date_Of_Join,SSN_No AS PF_NO,SIN_No AS ESIC_No,Dr_Lic_No,
		   Pan_No,convert(varchar,Date_Of_Birth,103) as Date_Of_Birth,Marital_Status,Gender,Nationality,Street_1,City,State,Zip_code,Home_Tel_no,Mobile_No,
		   Work_Tel_No,Work_Email,Other_Email,Image_Name,Emp_Full_Name,BN.Bank_Name,Inc_Qry.Inc_Bank_Ac_No,Emp_Left,convert(varchar,Emp_Left_Date,103) as Emp_Left_Date,Present_Street,Present_City,
		   Present_State,Present_Post_Box,Enroll_No,Inc_Qry.Emp_OT,Inc_Qry.Emp_Late_Mark,Inc_Qry.Emp_Full_PF,Inc_Qry.Emp_PT,Inc_Qry.Emp_Fix_Salary,Inc_Qry.Emp_Part_time,
		   Inc_Qry.Late_Dedu_Type,Inc_Qry.Emp_Childran,Blood_Group,Religion,Height,Emp_Mark_Of_Identification ,
		   Despencery,Doctor_Name,DespenceryAddress,Insurance_No,convert(varchar,Emp_Confirm_Date,103) as Emp_Confirm_Date,Father_name,datediff(MM,Date_Of_Join,@To_date) As Work_Exp_Month,Inc_Qry.Basic_salary,Inc_Qry.Gross_salary  
			,AR.Emp_Id,Ar.Company_ID,(Select SUP.Emp_Full_Name from dbo.T0080_EMP_MASTER SUP WITH (NOLOCK) where SUP.Emp_ID = E.Emp_Superior) as manager
      FROM dbo.T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN @Emp_cons EC on e.emp_id = Ec.emp_ID INNER JOIN   
      ( select T0095_INCREMENT.Emp_Id ,cat_id,Grd_ID,Dept_ID,Desig_Id,Branch_Id,Type_id,Bank_id,Curr_id,Wages_Type,Salary_Basis_on,Basic_salary,Gross_salary
		,Inc_Bank_Ac_No,Emp_OT,Emp_Late_Mark,Emp_Full_PF,Emp_PT,Emp_Fix_Salary,Emp_Part_time,Late_Dedu_Type,Emp_Childran
      from T0095_INCREMENT WITH (NOLOCK) inner join   
      ( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_INCREMENT WITH (NOLOCK)   --Changed by Hardik 10/09/2014 for Same Date Increment
      where Increment_Effective_date <= @To_Date and Cmp_ID = @Company_ID Group by emp_ID  ) Qry  
     on T0095_INCREMENT.Emp_ID = Qry.Emp_ID and  
     T0095_INCREMENT.Increment_ID   = Qry.Increment_Id   
     where cmp_id = @Company_ID ) Inc_Qry on   
      e.Emp_ID = Inc_Qry.Emp_ID inner join  
      T0040_GRADE_MASTER GM WITH (NOLOCK) ON Inc_Qry.Grd_Id = GM.Grd_Id INNER JOIN
      T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Inc_Qry.Branch_ID = BM.Branch_Id Inner join       
      T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON Inc_Qry.Desig_Id = DM.Desig_Id LEFT OUTER JOIN
      T0040_BANK_MASTER BN WITH (NOLOCK) On Inc_Qry.Bank_id = BN.Bank_Id Left Outer join
      T0040_TYPE_MASTER TM WITH (NOLOCK) On Inc_Qry.Type_Id = TM.Type_Id Left Outer Join
      T0030_CATEGORY_MASTER CM WITH (NOLOCK) On Inc_Qry.Cat_id = CM.Cat_Id Left Outer Join
      T0040_DEPARTMENT_MASTER DT WITH (NOLOCK) ON Inc_Qry.Dept_Id = DT.Dept_Id LEFT OUTER JOIN        
      
      #Allowance_Record AR on inc_Qry.Emp_id = AR.Emp_id       
     WHERE e.Cmp_ID = @Company_ID   

  
    Select
    	Case When row_number() OVER ( PARTITION BY em.Emp_Id order by Em.Emp_Id) = 1 
		Then em.Emp_code Else null End Emp_code,		 
		Case When row_number() OVER ( PARTITION BY em.Emp_Id order by Em.Emp_Id) = 1 
		Then Emp_Full_Name Else '' End Emp_Full_Name, 
		sm.Skill_Name,sm.Description ,es.Skill_Comments,es.Skill_Experience  from T0080_EMP_MASTER em WITH (NOLOCK)
    INNER JOIN @Emp_cons EC on em.emp_id = Ec.emp_ID
    INNER JOIN T0090_EMP_SKILL_DETAIL es WITH (NOLOCK) on es.Emp_ID=EC.Emp_ID
    INNER JOIN T0040_SKILL_MASTER sm WITH (NOLOCK) on sm.Skill_ID = es.Skill_ID
    
    Select
    	Case When row_number() OVER ( PARTITION BY em.Emp_Id order by Em.Emp_Id) = 1 
		Then em.Emp_code Else null End Emp_code,
		Case When row_number() OVER ( PARTITION BY em.Emp_Id order by Em.Emp_Id) = 1 
		Then Emp_Full_Name Else '' End Emp_Full_Name,
		es.Employer_Name, es.Desig_Name, CONVERT(VARCHAR(10), es.St_Date, 103) St_Date, CONVERT(VARCHAR(10), es.End_Date, 103) End_Date  from T0080_EMP_MASTER em WITH (NOLOCK)
    INNER JOIN @Emp_cons EC on em.emp_id = Ec.emp_ID
    INNER JOIN T0090_EMP_EXPERIENCE_DETAIL es WITH (NOLOCK) on em.Emp_ID=es.Emp_ID
      
    
    Select
    	Case When row_number() OVER ( PARTITION BY em.Emp_Id order by Em.Emp_Id) = 1 
		Then em.Emp_code Else null End Emp_code, 
		Case When row_number() OVER ( PARTITION BY em.Emp_Id order by Em.Emp_Id) = 1 
		Then Emp_Full_Name Else '' End Emp_Full_Name, 
		es.Name, es.RelationShip, CONVERT(VARCHAR(10), es.BirthDate , 103) BirthDate, es.D_Age, es.Address, es.Share,
		Is_Resident = case when es.Is_Resi = 1 then 'Yes' else 'No' end  from T0080_EMP_MASTER em WITH (NOLOCK)
    INNER JOIN @Emp_cons EC on em.emp_id = Ec.emp_ID
    INNER JOIN T0090_EMP_DEPENDANT_DETAIL es WITH (NOLOCK) on em.Emp_ID=es.Emp_ID
    
    
    Select 
		Case When row_number() OVER ( PARTITION BY em.Emp_Id order by Em.Emp_Id) = 1 
		Then em.Emp_code Else null End Emp_code, 
		Case When row_number() OVER ( PARTITION BY em.Emp_Id order by Em.Emp_Id) = 1 
		Then Emp_Full_Name Else '' End Emp_Full_Name, 
		es.Name, es.Relationship, es.Gender, CONVERT(VARCHAR(10), es.Date_Of_Birth, 103) Date_Of_Birth, es.C_Age, 
		Is_Resident = case when es.Is_Resi = 1 then 'Yes' else 'No' end, 
		Is_Dependent = case when es.Is_Dependant = 1 then 'Yes' else 'No' end  from T0080_EMP_MASTER em WITH (NOLOCK)
    INNER JOIN @Emp_cons EC on em.emp_id = Ec.emp_ID
    INNER JOIN T0090_EMP_CHILDRAN_DETAIL es WITH (NOLOCK) on em.Emp_ID=es.Emp_ID  
    
    Select
    	Case When row_number() OVER ( PARTITION BY em.Emp_Id order by Em.Emp_Id) = 1 
		Then em.Emp_code Else null End Emp_code,
		Case When row_number() OVER ( PARTITION BY em.Emp_Id order by Em.Emp_Id) = 1 
		Then Emp_Full_Name Else '' End Emp_Full_Name, 
		am.Asset_Name, am.Asset_Desc, es.Model_No, CONVERT(VARCHAR(10), es.Issue_Date, 103) Issue_Date, CONVERT(VARCHAR(10), es.Return_Date, 103) Return_Date, es.Asset_Comment  from T0080_EMP_MASTER em WITH (NOLOCK)
    INNER JOIN @Emp_cons EC on em.emp_id = Ec.emp_ID
    INNER JOIN T0090_EMP_ASSET_DETAIL es WITH (NOLOCK) on em.Emp_ID=es.Emp_ID
    INNER JOIN T0040_ASSET_MASTER am WITH (NOLOCK) on am.Asset_ID = es.Asset_ID
    
    
    Select
    	Case When row_number() OVER ( PARTITION BY em.Emp_Id order by Em.Emp_Id) = 1 
		Then em.Emp_code Else null End Emp_code,
		Case When row_number() OVER ( PARTITION BY em.Emp_Id order by Em.Emp_Id) = 1 
		Then Emp_Full_Name Else '' End Emp_Full_Name, 
		qm.Qual_Name, es.Specialization, es.Year, es.Score, CONVERT(VARCHAR(10), es.St_Date, 103) St_Date, CONVERT(VARCHAR(10), es.End_Date, 103) End_Date, es.Comments  from T0080_EMP_MASTER em WITH (NOLOCK)
    INNER JOIN @Emp_cons EC on em.emp_id = Ec.emp_ID
    INNER JOIN T0090_EMP_QUALIFICATION_DETAIL es WITH (NOLOCK) on em.Emp_ID=es.Emp_ID  
    INNER JOIN T0040_QUALIFICATION_MASTER qm WITH (NOLOCK) on qm.Qual_ID=es.Qual_ID
 RETURN   




