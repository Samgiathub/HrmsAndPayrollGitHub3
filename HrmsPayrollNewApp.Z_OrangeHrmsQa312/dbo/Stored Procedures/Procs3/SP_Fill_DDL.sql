




CREATE PROCEDURE [dbo].[SP_Fill_DDL]
	@Cmp_ID numeric,
	@Emp_ID numeric
	
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

   Declare @Branch table
    (
       Branch_Name varchar(50),
       Branch_ID   numeric(18,2)
    )
    Insert into @Branch(Branch_Name,Branch_ID)
    Select Branch_Name,Branch_ID from T0030_Branch_Master WITH (NOLOCK) where Cmp_ID=@Cmp_ID  order by Branch_Name asc
    
   Declare @Shift table
	(
		 Shift_ID numeric(18,2),
		 Shift_name varchar(50)
	) 
	insert into @Shift(Shift_ID,Shift_Name)
	select Shift_ID,Shift_Name from T0040_SHIFT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID order by Shift_Name asc
	
	Declare @Dept table
	(
	   Dept_ID numeric(18,0),
	   Dept_name Varchar(50)
	)
	insert into @Dept(Dept_ID,Dept_Name)
	select Dept_Id,Dept_Name from T0040_Department_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID order by Dept_Name asc
	
   
   Declare @Desig table
   (
      Desig_ID numeric(18,0),
      Desig_Name varchar(50)
   )
   insert into @Desig(Desig_ID,Desig_Name)
   select Desig_ID,Desig_Name from T0040_DESIGNATION_MASTER WITH (NOLOCK) where Cmp_ID =@Cmp_ID order by Desig_Name asc
   
   
   
   Declare @Grd table
   (
     Grd_ID numeric(18,0),
     Grd_Name varchar(50)
   )
   insert into @Grd (Grd_ID,Grd_Name)
   select Grd_Id,Grd_Name from T0040_Grade_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID order by Grd_Name asc
   
   
   Declare @Type table
   (
      Type_ID numeric(18,0),
      Type_Name varchar(50)
   )
   insert into @Type(Type_ID,Type_Name)
   select Type_ID,Type_Name from T0040_TYPE_MASTER WITH (NOLOCK) where Cmp_ID =@Cmp_ID order by Type_Name asc
	
	
	Declare @Location table
	(
	   Loc_ID numeric(18,0),
	   Loc_name varchar(50)
	)
	insert into @Location(Loc_ID,Loc_name)
	select Loc_Id,Loc_Name from T0001_Location_Master WITH (NOLOCK) order by Loc_Name asc
	
	Declare @Currency table
	(
	   Cur_ID numeric(18,0),
	   Cur_name varchar(50)
	)
	insert into @Currency(Cur_ID,Cur_name)
	select Curr_ID,Curr_Name from T0040_CURRENCY_MASTER WITH (NOLOCK) where Cmp_ID =@Cmp_ID order by Curr_Name asc
	

   Declare @Bank table
    (
       Bank_ID numeric(18,0),
       Bank_name varchar(20)
    )
	insert into @Bank(Bank_ID,Bank_name)
	select Bank_ID,Bank_Name from T0040_BANK_MASTER WITH (NOLOCK) where Cmp_ID =@Cmp_ID order by Bank_Name asc
	
	
	Declare @Tally_Led table
	(
	  Tally_Led_ID numeric(18,0),
	  Tally_Led_name varchar(50)
	)
	Insert into @Tally_Led(Tally_Led_ID,Tally_Led_Name)
	select Tally_Led_ID,Tally_Led_name from V0040_Tally_Emp_Led_Master where Cmp_ID =@Cmp_ID order by Tally_Led_name asc
	
	
	
	Declare @Asset table
	(
	  Asset_Id numeric(18,0),
	  Asset_Name varchar(50)
	)
	insert into @Asset(Asset_ID,Asset_Name)
	select Asset_Id,Asset_Name from T0040_Asset_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID order by Asset_Name asc
	
	
	Declare @Skill table
	(
	   Skill_ID numeric(18,0),
	   Skill_name varchar(50)
	)
	insert into @Skill(Skill_ID,Skill_name)
	select Skill_Id,Skill_Name from T0040_Skill_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID order by Skill_Name asc
	
	
	
	Declare @Emp_Superior table
	(
	   Emp_Full_Name_new varchar(50),
	   Emp_ID  numeric(18,0)
	)
	insert into @Emp_Superior(Emp_Full_name_new,Emp_ID)
	
	select Emp_Full_Name_new,emp_ID from v0080_employee_MASTER where Cmp_ID= @Cmp_ID And Emp_ID <> @Emp_ID And isnull(def_id,0) = 1  and Emp_Left<>'Y' order by Emp_Full_Name asc
	
	Declare @Lang table
	(
	    Lang_ID numeric(18,0),
	    Lang_name varchar(50)
	)
	insert into @Lang(Lang_ID,Lang_Name)
	Select Lang_ID,Lang_Name from T0040_Language_master WITH (NOLOCK) where Cmp_ID=@Cmp_Id
	

	Declare @Project table
	(
	   prj_name varchar(50),
	   prj_ID numeric(18,0)
	)
	
	insert into @Project (prj_name,prj_ID)
	select prj_name,prj_ID from T0040_Project_master WITH (NOLOCK) where cmp_id=@Cmp_ID
	

    Declare @Policy table
    (
       Ins_Name  varchar(100),
       Ins_Tran_ID numeric(18,0)
    )
    insert into @Policy(Ins_Name,Ins_Tran_ID)
    select Ins_Name,Ins_Tran_ID from T0040_INSURANCE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID
    
     Declare @Document table
    (
       Doc_Name  varchar(100),
       Doc_ID numeric(18,0)
    )
    insert into @Document(Doc_Name,Doc_ID)
    select Doc_Name,Doc_ID from T0040_Document_master WITH (NOLOCK) where Cmp_ID=@Cmp_ID
	

    Declare @Qual table
    (
       qual_name varchar(50),
       qual_ID numeric(18,0)
    )
    insert into @Qual(qual_Name,qual_ID)
    Select qual_Name,qual_ID from T0040_Qualification_Master WITH (NOLOCK) where Cmp_ID=@Cmp_ID
	
	Select * from   @Branch 
	Select * from   @Grd    
	Select * from   @Desig  
	Select * from   @Dept   
	Select * from   @Shift    
	Select * from   @Type   
	Select * from   @Location 
	Select * from   @Bank   
	Select * from   @Tally_Led  
	Select * from   @Skill  
	Select * from   @Asset  
	Select * from   @Tally_Led 
	Select * from   @Currency  
	Select * from   @Lang
	Select * from   @Project
	Select * from   @Emp_Superior
	Select * from   @Policy
	Select * from   @Document
	Select * from   @Qual
	
	
	
RETURN




