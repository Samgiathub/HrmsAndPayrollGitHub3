


-- Created By rohit For transfer letter on 12082014
CREATE PROCEDURE [dbo].[SP_RPT_TRANSFER_INFO_GET]    
  @Cmp_ID   numeric    
 ,@From_Date  datetime    
 ,@To_Date   datetime    
 ,@Branch_ID  numeric    
 ,@Cat_ID   numeric     
 ,@Grd_ID   numeric    
 ,@Type_ID   numeric    
 ,@Dept_ID   numeric    
 ,@Desig_ID   numeric    
 ,@Emp_ID   numeric    
 ,@constraint  varchar(MAX)    
AS    
  SET NOCOUNT ON 
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
  SET ARITHABORT ON
		
 IF @Branch_ID = 0      
  set @Branch_ID = null    
      
 IF @Cat_ID = 0      
  set @Cat_ID = null    
    
 IF @Grd_ID = 0      
  set @Grd_ID = null    
    
 IF @Type_ID = 0      
  set @Type_ID = null    
    
 IF @Dept_ID = 0      
  set @Dept_ID = null    
    
 IF @Desig_ID = 0      
  set @Desig_ID = null    
    
 IF @Emp_ID = 0      
  set @Emp_ID = null    
    
 Declare @Emp_Cons Table    
 (    
  Emp_ID numeric
 )    
	  
   
 if @Constraint <> ''    
  begin    
   Insert Into @Emp_Cons    
   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')     
  end  
  else    
  begin    
       
       
   Insert Into @Emp_Cons    
    
   select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join     
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)    
     where Increment_Effective_date <= @To_Date    
     and Cmp_ID = @Cmp_ID    
     group by emp_ID  ) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date     
           
   Where Cmp_ID = @Cmp_ID     
   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))    
   and Branch_ID = isnull(@Branch_ID ,Branch_ID)    
   and Grd_ID = isnull(@Grd_ID ,Grd_ID)    
   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))    
   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))    
   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))    
   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)     
   and I.Emp_ID in     
    ( select Emp_Id from    
    (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry    
    where cmp_ID = @Cmp_ID   and      
    (( @From_Date  >= join_Date  and  @From_Date <= left_date )     
    or ( @To_Date  >= join_Date  and @To_Date <= left_date )    
    or Left_date is null and @To_Date >= Join_Date)    
    or @To_Date >= left_date  and  @From_Date <= left_date )     
       
  end    
  
  -- added by Gadriwala 10042014 -- Start
  select  Top 1  E.Emp_ID,Desig_Name,i.Basic_Salary,i.Increment_ID,I.branch_id,I.cat_id,I.grd_id,I.Dept_id,I.Type_Id,DM.Dept_Name,BM.Branch_Name into #t2 
	
	 from T0095_Increment I WITH (NOLOCK) inner join     
     ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)		-- Ankit 10092014 for Same Date Increment
     where Increment_Effective_date <= @To_Date  
     and Cmp_ID = @Cmp_ID     
     group by emp_ID  ) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID < Qry.Increment_ID Left outer join
	 T0080_EMP_MASTER E  WITH (NOLOCK) on E.Emp_ID = I.Emp_ID  Left outer join 
	 T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID Left join
	 T0040_DEPARTMENT_MASTER  DM WITH (NOLOCK) ON I.Dept_Id = DM.Dept_ID  Left Outer join
	 t0030_branch_master  BM WITH (NOLOCK) ON I.Branch_id = BM.Branch_Id  Left Outer join
	 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.Desig_Id = DGM.Desig_Id 
	 WHERE E.Cmp_ID = @Cmp_Id and	 I.Increment_Effective_Date < @to_Date  and (i.Increment_Type='Transfer' or  i.Increment_Type='Joining')  /*   AND   And  I.Increment_Effective_Date > @From_Date And i.Increment_Type='Increment'  */
	 And E.Emp_ID in (select Emp_ID From @Emp_Cons) order by i.Increment_ID Desc
	 
	 
	 select E.Alpha_Emp_Code,E.Cmp_ID,E.Emp_ID,E.Emp_Full_Name as Emp_Full_Name,CM.Cmp_Name,CM.cmp_logo
		,CM.Cmp_Address,DGm.Desig_Name,E.Emp_First_Name,
		MONTH(I.Increment_Effective_Date) as month
		,Year(I.Increment_Effective_Date) as Year
		,I.Gross_Salary,I.Basic_Salary
		,I.Increment_Effective_Date,dbo.F_Number_TO_Word(Gross_Salary) as Gross_Amount_In_Word
		,i.Branch_ID ,I.Increment_ID ,Old_Increment.Desig_Name as Old_Desig_Name,Old_Increment.Basic_Salary as Old_Basic_Salary 
		,DM.Dept_Name,BM.Branch_Name,Old_Increment.Dept_Name as old_dept_name,Old_Increment.Branch_Name as Old_Branch_name,ERM.emp_full_name as reporting_name
		,CM.Cmp_code,BM.Branch_code
		,E.Present_street,E.Present_City,E.Present_Post_Box,BM.Branch_Address--add by chetan 28-11-16
		,ELR2.Reference_No,ELR2.Issue_Date
		,CM.Cmp_HR_Manager,CM.Cmp_HR_Manager_Desig,E.Date_Of_Join
		  from T0095_Increment I WITH (NOLOCK) inner join     
     ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment    
     where Increment_Effective_date <= @To_Date    
     and Cmp_ID = @Cmp_ID    
     group by emp_ID  ) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID    Left outer join
     T0080_EMP_MASTER E WITH (NOLOCK) on  E.Emp_ID = I.Emp_ID	 Left outer join
     T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID Left outer join
	 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.Desig_Id = DGM.Desig_Id  Left Outer join
	 T0040_DEPARTMENT_MASTER  DM WITH (NOLOCK) ON I.Dept_Id = DM.Dept_ID  Left Outer join
	 t0030_branch_master  BM WITH (NOLOCK) ON I.Branch_id = BM.Branch_Id  	
	 Left Outer join
	 --T0090_EMP_REPORTING_DETAIL  ERD ON I.Emp_id = ERD.emp_id  Left Outer join
	 --t0080_emp_master REM ON ERD.R_Emp_id = REM.Emp_id  Left Outer join
	 --update by chetan 30-11-16
				--Left Join
					(SELECT		Q.EMP_ID,MAX(RD.R_EMP_ID) AS R_EMP_ID 
					 FROM		T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK) INNER JOIN
								(SELECT  MAX(EFFECT_DATE) MAX_DATE,EMP_ID 
								 FROM	 T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
								 WHERE	 EFFECT_DATE <= getdate() AND CMP_ID = @CMP_ID 
								 GROUP BY EMP_ID)Q ON Q.EMP_ID = RD.EMP_ID AND Q.MAX_DATE = RD.EFFECT_DATE								 
					 GROUP BY Q.EMP_ID)MAIN	ON Main.Emp_ID = I.Emp_ID LEFT JOIN 
								T0080_EMP_MASTER ERM WITH (NOLOCK) ON MAIN.R_EMP_ID = ERM.EMP_ID Left join
											
								---------------------------------------		
	 
	 #t2 Old_Increment on Old_Increment.Emp_ID = e.Emp_ID Left Outer join
	 (SELECT ELR1.EMP_ID,MAX(ELR1.Tran_Id)Tran_Id,ELR1.Reference_No,ELR1.Issue_Date  --Mukti(10012017)
		 FROM		T0081_Emp_LetterRef_Details ELR1 WITH (NOLOCK) INNER JOIN
		(SELECT  MAX(Issue_Date) Issue_Date,EMP_ID  
			 FROM	 T0081_Emp_LetterRef_Details WITH (NOLOCK)
			 WHERE	 Issue_Date <= @To_Date AND CMP_ID =@CMP_ID and Letter_Name='Transfer Letter'
			 GROUP BY EMP_ID)ELR ON ELR.EMP_ID = ELR1.EMP_ID and Letter_Name='Transfer Letter' AND ELR.Issue_Date = ELR1.Issue_Date								 
		GROUP BY ELR1.EMP_ID,ELR1.Reference_No,ELR1.Issue_Date)ELR2 ON ELR2.Emp_ID = E.Emp_ID
	 where E.Cmp_ID = @Cmp_ID and I.Increment_Effective_Date <= @To_Date and I.Increment_Effective_Date >= @From_Date  and 
	 E.Emp_ID in (Select Emp_ID from @Emp_Cons ) order by E.Emp_code asc
	 
 -- added by Gadriwala 10042014 -- End
  	
 --    select E.Emp_Code,E.cmp_id,E.Emp_ID,E.Emp_Full_Name as Emp_Full_Name,CM.Cmp_Name,CM.cmp_logo
	--,CM.Cmp_Address,Desig_Name,E.Emp_First_Name
	--,month(I.Increment_Effective_Date) as month
	--,year(I.Increment_Effective_Date) as YEAR
	--,i.Gross_Salary,i.Basic_salary
	--,I.Increment_Effective_Date,dbo.F_Number_TO_Word(Gross_Salary) as Gross_Amount_In_Word,i.Branch_ID 
	--from T0080_EMP_MASTER E Left outer join 
	--t0095_increment i on E.Increment_ID = I.Increment_Id inner join
	--T0010_Company_master CM on E.Cmp_ID =Cm.Cmp_ID Left join
	--T0040_DESIGNATION_MASTER DGM ON E.Desig_Id = DGM.Desig_Id 
	--WHERE E.Cmp_ID = @Cmp_Id	AND I.Increment_Effective_Date <= @to_Date And  I.Increment_Effective_Date >= @From_Date And i.Increment_Type='Increment'  And
	--E.Emp_ID in (select Emp_ID From @Emp_Cons) order by E.Emp_Code asc 
		
		
		
 Return




