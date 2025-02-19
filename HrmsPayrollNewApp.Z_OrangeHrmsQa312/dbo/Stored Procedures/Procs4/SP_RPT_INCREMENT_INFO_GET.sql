

 ---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_INCREMENT_INFO_GET]    
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
 ,@flag   numeric = 0
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
	SELECT  E.Emp_ID,Desig_Name,i.Basic_Salary,i.Increment_ID,GM.Grd_Name,DM.Dept_Name,Vs.Vertical_Name,Gross_Salary ,CTC,CAM.Cat_Name
	INTO #t2 	
	FROM T0095_INCREMENT I WITH (NOLOCK)
		INNER JOIN     
			(SELECT MAX(Increment_id) as Increment_id , Emp_ID 
			 FROM T0095_Increment WITH (NOLOCK)   
			 WHERE Increment_Effective_date < @From_Date and Cmp_ID = @Cmp_ID   and Increment_Type <> 'Transfer'   
			 GROUP BY emp_ID
			) Qry ON I.Emp_ID = Qry.Emp_ID and I.Increment_id = Qry.Increment_id 
		LEFT OUTER JOIN T0080_EMP_MASTER E WITH (NOLOCK)  on E.Emp_ID = I.Emp_ID
		LEFT OUTER JOIN T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID
		Left join		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.Desig_Id = DGM.Desig_Id
		LEFT OUTER JOIN	T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_ID = GM.Grd_ID 
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.Dept_ID = DM.Dept_Id 
		LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) on I.Vertical_ID = Vs.Vertical_ID
		left OUTER JOIN T0030_CATEGORY_MASTER CAM WITH (NOLOCK) ON I.Cat_ID = CAM.Cat_ID
	 WHERE E.Cmp_ID = @Cmp_Id AND	 I.Increment_Effective_Date < @From_Date  and (i.Increment_Type='Increment' or  i.Increment_Type='Joining')  /*   AND   And  I.Increment_Effective_Date > @From_Date And i.Increment_Type='Increment'  */
	 And E.Emp_ID in (select Emp_ID From @Emp_Cons) order by i.Increment_ID Desc
	 
 
	 --update by chetan 21-12-16 for back date increment
	  SELECT E.Alpha_Emp_Code,E.Cmp_ID,E.Emp_ID,E.Emp_Full_Name as Emp_Full_Name,CM.Cmp_Name,CM.cmp_logo
		,CM.Cmp_Address,DGm.Desig_Name,E.Emp_First_Name,MONTH(I.Increment_Effective_Date) as month,Year(I.Increment_Effective_Date) as Year
		,I.Gross_Salary,I.Basic_Salary,I.CTC,I.Increment_Effective_Date,dbo.F_Number_TO_Word(I.Gross_Salary) as Gross_Amount_In_Word
		,i.Branch_ID ,I.Increment_ID ,Old_Increment.Desig_Name as Old_Desig_Name,Old_Increment.Basic_Salary as Old_Basic_Salary 
		,cm.Cmp_code,BM.Branch_Code,BM.Branch_Name,GM.Grd_Name , Old_Increment.Grd_Name AS Old_Grd_Name,DM.Dept_Name,Old_Increment.Dept_Name As Old_Dept_Name,Vs.Vertical_Name,E.Date_of_join
		,Old_Increment.Gross_Salary as old_Gross_Salary,Old_Increment.CTC as old_ctc,ELR2.Reference_No,ELR2.Issue_Date
		,CM.Cmp_HR_Manager,CM.Cmp_HR_Manager_Desig
		,CAM.Cat_Name
		,Old_Increment.Cat_Name as Old_Cat_Name
		,E.Old_Ref_No
		,E.Initial
		,E.Emp_Last_Name
		,I.Reason_Name
	  FROM T0095_INCREMENT I WITH (NOLOCK)
	  INNER JOIN
		( 
			SELECT	I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID
			FROM	T0095_INCREMENT I1 WITH (NOLOCK)
			INNER JOIN @Emp_Cons E1 ON I1.Emp_ID=E1.EMP_ID
			INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
						FROM	T0095_INCREMENT I2 WITH (NOLOCK)
						INNER JOIN @Emp_Cons E2 ON I2.Emp_ID=E2.EMP_ID
						INNER JOIN (
									SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
									FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN @Emp_Cons E3 ON I3.Emp_ID=E3.EMP_ID
									WHERE	I3.Increment_Effective_Date <= @to_Date
									GROUP BY I3.Emp_ID
									) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
						WHERE	I2.Cmp_ID = @Cmp_Id 
						GROUP BY I2.Emp_ID
						) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
			WHERE	I1.Cmp_ID=@Cmp_Id											
		) Qry ON I.EMP_ID=Qry.Emp_ID AND I.Increment_ID = Qry.INCREMENT_ID
       LEFT OUTER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on  E.Emp_ID = I.Emp_ID
       LEFT OUTER JOIN T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID
       LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.Desig_Id = DGM.Desig_Id
       LEFT OUTER JOIN T0030_Branch_Master BM WITH (NOLOCK) ON I.Branch_Id = BM.Branch_Id
       LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_ID = GM.Grd_ID
       LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.Dept_ID = DM.Dept_Id
       left OUTER JOIN T0030_CATEGORY_MASTER as CAM WITH (NOLOCK) on I.Cat_ID = CAM.Cat_ID
       LEFT OUTER JOIN #t2 Old_Increment on Old_Increment.Emp_ID = e.Emp_ID
       LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) on I.Vertical_ID = Vs.Vertical_ID
       LEFT OUTER JOIN
		(SELECT ELR1.EMP_ID,MAX(ELR1.Tran_Id)Tran_Id,ELR1.Reference_No,ELR1.Issue_Date  --Mukti(10012017)
		 FROM		T0081_Emp_LetterRef_Details ELR1 WITH (NOLOCK) INNER JOIN
		(SELECT  MAX(Issue_Date) Issue_Date,EMP_ID  
			 FROM	 T0081_Emp_LetterRef_Details WITH (NOLOCK)
			 WHERE	 Issue_Date <= @To_Date AND CMP_ID =@CMP_ID and 
			 Letter_Name=case when @flag = 2 then 'Promotion Letter' when @flag=3 then 'Reward Letter' 
			 else 'Increment Letter' end
			 GROUP BY EMP_ID)ELR ON ELR.EMP_ID = ELR1.EMP_ID and Letter_Name=case when @flag = 2 then 'Promotion Letter' when @flag=3 then 'Reward Letter' 
			 else 'Increment Letter' end AND ELR.Issue_Date = ELR1.Issue_Date								 
		GROUP BY ELR1.EMP_ID,ELR1.Reference_No,ELR1.Issue_Date)ELR2 ON ELR2.Emp_ID = E.Emp_ID
	 --comment by chetan 21-12-16
	
	
	 --select E.Alpha_Emp_Code,E.Cmp_ID,E.Emp_ID,E.Emp_Full_Name as Emp_Full_Name,CM.Cmp_Name,CM.cmp_logo
		--,CM.Cmp_Address,DGm.Desig_Name,E.Emp_First_Name,
		--MONTH(I.Increment_Effective_Date) as month
		--,Year(I.Increment_Effective_Date) as Year
		--,I.Gross_Salary,I.Basic_Salary,I.CTC
		--,I.Increment_Effective_Date,dbo.F_Number_TO_Word(I.Gross_Salary) as Gross_Amount_In_Word
		--,i.Branch_ID ,I.Increment_ID ,Old_Increment.Desig_Name as Old_Desig_Name,Old_Increment.Basic_Salary as Old_Basic_Salary 
		--,cm.Cmp_code,BM.Branch_Code,BM.Branch_Name
		--,GM.Grd_Name , Old_Increment.Grd_Name AS Old_Grd_Name,DM.Dept_Name,Old_Increment.Dept_Name As Old_Dept_Name,Vs.Vertical_Name,E.Date_of_join
		--,Old_Increment.Gross_Salary as old_Gross_Salary,Old_Increment.CTC as old_ctc
		--  from T0095_Increment I inner join     
  --   ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment		-- Ankit 10092014 for Same Date Increment 
  --   where Increment_Effective_date <= @To_Date    
  --   and Cmp_ID = @Cmp_ID    
  --   group by emp_ID  ) Qry on    
  --   I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID    Left outer join
  --   T0080_EMP_MASTER E on  E.Emp_ID = I.Emp_ID	 Left outer join
  --   T0010_Company_master CM on E.Cmp_ID =Cm.Cmp_ID Left outer join
	 --T0040_DESIGNATION_MASTER DGM ON I.Desig_Id = DGM.Desig_Id  Left Outer join
	 --T0030_Branch_Master BM ON I.Branch_Id = BM.Branch_Id Left Outer join
	 --T0040_GRADE_MASTER GM ON I.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
	 --T0040_DEPARTMENT_MASTER DM ON I.Dept_ID = DM.Dept_Id LEFT OUTER JOIN
	 --#t2 Old_Increment on Old_Increment.Emp_ID = e.Emp_ID left outer join
	 --T0040_Vertical_Segment VS on I.Vertical_ID = Vs.Vertical_ID
	 --where E.Cmp_ID = @Cmp_ID and I.Increment_Effective_Date <= @To_Date and I.Increment_Effective_Date >= @From_Date  and 
	 --E.Emp_ID in (Select Emp_ID from @Emp_Cons ) order by E.Emp_code asc
	 
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




