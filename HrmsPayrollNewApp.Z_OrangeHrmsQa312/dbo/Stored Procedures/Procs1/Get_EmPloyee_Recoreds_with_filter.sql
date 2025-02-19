


-- =============================================
-- Author:		<Author,,Zishanali Tailor>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_EmPloyee_Recoreds_with_filter]
  @Cmp_ID   numeric
 ,@From_Date  datetime
 ,@To_Date   datetime
  --,@Branch_ID  numeric = 0 -- Comment by nilesh patel on 18092014
 --,@Cat_ID   numeric = 0   -- Comment by nilesh patel on 18092014
 --,@Grd_ID   numeric = 0   -- Comment by nilesh patel on 18092014
 --,@Type_ID   numeric = 0  -- Comment by nilesh patel on 18092014
 --,@Dept_ID   numeric = 0  -- Comment by nilesh patel on 18092014
 --,@Desig_ID   numeric = 0 -- Comment by nilesh patel on 18092014
 ,@Branch_ID  Varchar(Max) = '' -- Added by nilesh patel on 18092014
 ,@Cat_ID     Varchar(Max) = '' -- Added by nilesh patel on 18092014
 ,@Grd_ID     Varchar(Max) = '' -- Added by nilesh patel on 18092014
 ,@Type_ID    Varchar(Max) = '' -- Added by nilesh patel on 18092014
 ,@Dept_ID    Varchar(Max) = '' -- Added by nilesh patel on 18092014
 ,@Desig_ID   Varchar(Max) = '' -- Added by nilesh patel on 18092014  
 ,@Emp_ID numeric = 0
 ,@Constraint varchar(Max) = ''
 ,@Salary_Cycle_id numeric = 0	  
 --,@Segment_Id  numeric = 0    -- Comment by nilesh patel on 18092014
 --,@Vertical_Id numeric = 0    -- Comment by nilesh patel on 18092014
 --,@SubVertical_Id numeric = 0 -- Comment by nilesh patel on 18092014
 --,@SubBranch_Id numeric = 0   -- Comment by nilesh patel on 18092014
 ,@Segment_Id  Varchar(Max) = ''   -- Added by nilesh patel on 18092014
 ,@Vertical_Id Varchar(Max) = ''   -- Added by nilesh patel on 18092014
 ,@SubVertical_Id Varchar(Max) = '' -- Added by nilesh patel on 18092014
 ,@SubBranch_Id Varchar(Max) = ''   -- Added by nilesh patel on 18092014
 ,@Type numeric = 0
 ,@Geneder Varchar(100) = '0' -- Added by Nilesh patel on 08012016
  ,@Is_Active tinyint = 0 --add by chetan 120617
  ,@Bank_ID varchar(Max) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN    
   
 -- Added by nilesh patel on 18092014 --start 
 CREATE table #Emp_Cons 
 (      
   Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )
 
 if @Geneder = '0'
	Begin
		Set @Geneder = NULL
	End
	
 exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,3,'0',0,@Type,@Bank_ID   
  
	If @Cmp_ID=0
		Set @Cmp_Id = Null

 -- Added by nilesh patel on 18092014 --End  
 -- Comment by nilesh patel on 18092014 --start 
/*  Declare @Emp_Cons Table  
  (  
	  Emp_ID numeric ,       
	  Branch_ID NUMERIC,  
	  Increment_ID NUMERIC
  )  
  
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
  
 If @Salary_Cycle_id = 0
   set @Salary_Cycle_id = null
   
  If @Segment_ID = 0
  set @Segment_ID = null
        
  if @Vertical_Id =0
   set @Vertical_Id =NULL
  
  if @SubVertical_Id =0
   set @SubVertical_Id =null
  
  if @SubBranch_Id =0
   set @SubBranch_Id =null
   
 IF @Emp_ID = 0    
	set @Emp_ID = null   
	
		IF @Type = 0 -- All Employee
			BEGIN
				 Insert Into @Emp_Cons  
				 Select distinct emp_id,branch_id,Increment_ID/*,Join_Date,Left_Date,@From_Date,@To_Date,Emp_code*/ from V_Emp_Cons 
				 left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC
							inner join 
							(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle where Effective_date <= @To_Date
							GROUP BY emp_id) Qry
							on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
				  ON QrySC.eid = V_Emp_Cons.Emp_ID
				  where 
					 cmp_id=@Cmp_ID 
					   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
				   and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id ,isnull(QrySC.SalDate_id,0))  
				   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))       -- Added By Gadriwala Muslim 24072013
				   and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 24072013
				   and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))  -- Added By Gadriwala Muslim 24072013
				   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013
				   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
					  and Increment_Effective_Date <= @To_Date 
					  and 
					  ((ISNULL(left_date,@To_Date) between @From_Date and @To_Date and Join_Date<=@To_Date)
						or (Join_Date between @From_Date and @To_Date)
						or (isnull(left_Date,@To_Date)>=@To_Date and Join_Date<=@To_Date))
                      /*( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date >= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						--or (@To_Date >= left_date  and  @From_Date <= left_date )
						--OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date )) then 1 else 0 end)
						)*/
						order by Emp_ID
								

				Delete From @Emp_Cons Where Increment_ID Not In
				(select TI.Increment_ID from t0095_increment TI inner join
				(Select Max(Increment_Id) as Increment_Id,Emp_ID from T0095_Increment  --Changed by Hardik 10/09/2014 for Same Date Increment
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Id=new_inc.Increment_Id
				Where Increment_effective_Date <= @to_date) 
				
			END
		ELSE IF @Type = 1 -- Active Employee
			BEGIN
			
				Insert Into @Emp_Cons  
				 Select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons 
				 left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC
							inner join 
							(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle where Effective_date <= @To_Date
							GROUP BY emp_id) Qry
							on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
				  ON QrySC.eid = V_Emp_Cons.Emp_ID
				  where 
					 cmp_id=@Cmp_ID 
					   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
				   and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id ,isnull(QrySC.SalDate_id,0))  
				   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))       -- Added By Gadriwala Muslim 24072013
				   and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 24072013
				   and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))  -- Added By Gadriwala Muslim 24072013
				   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013
				   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
				   and Increment_Effective_Date <= @To_Date 
				   and (V_Emp_Cons.Emp_Left = 'N' Or V_Emp_Cons.Emp_Left = 'n')					  
					  and 
                      ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						--or (@To_Date >= left_date  and  @From_Date <= left_date )
						--OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date )) then 1 else 0 end)
						)
						order by Emp_ID
								

				Delete From @Emp_Cons Where Increment_ID Not In
				(select TI.Increment_ID from t0095_increment TI inner join
				(Select Max(Increment_Id) as Increment_Id,Emp_ID from T0095_Increment  --Changed by Hardik 10/09/2014 for Same Date Increment
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Id=new_inc.Increment_Id
				Where Increment_effective_Date <= @to_date)  
				
				
				--Insert Into @Emp_Cons  
				-- SELECT DISTINCT V.emp_id,V.branch_Id,V.Increment_ID FROM V_Emp_Cons V   
				-- Inner Join  
				-- dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = V.Emp_ID   
				-- LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid   
				--	 FROM T0095_Emp_Salary_Cycle ESC  
				--	  INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id   
				--		  FROM T0095_Emp_Salary_Cycle   
				--		  WHERE Effective_date <= @To_Date  
				--		  GROUP BY emp_id  
				--		 ) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id  
				--	) AS QrySC ON QrySC.eid = V.Emp_ID  
				-- WHERE   
				--	V.cmp_id=@Cmp_ID     
				-- AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))            
				-- AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)        
				-- AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)        
				-- AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))        
				-- AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))        
				-- AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))  
				-- AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))       
				-- And ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,IsNull(Segment_ID,0))  
				-- And ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,IsNull(Vertical_ID,0))  
				-- And ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_Id,IsNull(SubVertical_ID,0))  
				-- And ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,IsNull(subBranch_ID,0))
				-- and ms.Month_End_Date  >= @from_Date and ms.Month_End_Date  >= @from_Date
				-- and ms.Month_End_Date  <= @To_Date and ms.Month_End_Date  <= @To_Date
				-- and ms.Is_FNF = 0  
				-- AND V.Emp_Id = ISNULL(@Emp_Id,V.Emp_Id)   
				-- AND Increment_Effective_Date <= @To_Date  
				-- AND (V.Emp_Left = 'N' Or V.Emp_Left = 'n')
				-- AND ((@From_Date  >= join_Date  AND  @From_Date <= left_date )
				-- OR (@To_Date  >= join_Date  AND @To_Date <= left_date )
				-- OR (Left_date IS NULL AND @To_Date >= Join_Date)
				-- OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date )) then 1 else 0 end))
				-- ORDER BY Emp_ID  
			END
		ELSE IF @Type = 2 -- InActive Employee
			BEGIN
			
				Insert Into @Emp_Cons  
				 Select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons 
				 left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC
							inner join 
							(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle where Effective_date <= @To_Date
							GROUP BY emp_id) Qry
							on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
				  ON QrySC.eid = V_Emp_Cons.Emp_ID
				  where 
					 cmp_id=@Cmp_ID 
					   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
				   and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id ,isnull(QrySC.SalDate_id,0))  
				   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))       -- Added By Gadriwala Muslim 24072013
				   and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 24072013
				   and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))  -- Added By Gadriwala Muslim 24072013
				   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013
				   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
				   and Increment_Effective_Date <= @To_Date 
				   and (V_Emp_Cons.Emp_Left = 'Y' Or V_Emp_Cons.Emp_Left = 'y')					  
				   and (--(@From_Date  >= join_Date  and  @From_Date <= left_date )      
						--or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						--or (Left_date is null and @To_Date >= Join_Date)      
						(@To_Date >= left_date  and  @From_Date <= left_date )
						--OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date )) then 1 else 0 end))
						)
						order by Emp_ID
								

				Delete From @Emp_Cons Where Increment_ID Not In
				(select TI.Increment_ID from t0095_increment TI inner join
				(Select Max(Increment_Id) as Increment_Id,Emp_ID from T0095_Increment  --Changed by Hardik 10/09/2014 for Same Date Increment
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Id=new_inc.Increment_Id
				Where Increment_effective_Date <= @to_date)  
				
				
				--Insert Into @Emp_Cons  
				-- SELECT DISTINCT V.emp_id,V.branch_Id,V.Increment_ID FROM V_Emp_Cons V   
				-- Inner Join  
				-- dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = V.Emp_ID   
				-- LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid   
				--	 FROM T0095_Emp_Salary_Cycle ESC  
				--	  INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id   
				--		  FROM T0095_Emp_Salary_Cycle   
				--		  WHERE Effective_date <= @To_Date  
				--		  GROUP BY emp_id  
				--		 ) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id  
				--	) AS QrySC ON QrySC.eid = V.Emp_ID  
				-- WHERE   
				--	V.cmp_id=@Cmp_ID     
				-- AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))            
				-- AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)        
				-- AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)        
				-- AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))        
				-- AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))        
				-- AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))  
				-- AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))       
				-- And ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,IsNull(Segment_ID,0))  
				-- And ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,IsNull(Vertical_ID,0))  
				-- And ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_Id,IsNull(SubVertical_ID,0))  
				-- And ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,IsNull(subBranch_ID,0))
				-- and ms.Month_End_Date  >= @from_Date and ms.Month_End_Date  >= @from_Date
				-- and ms.Month_End_Date  <= @To_Date and ms.Month_End_Date  <= @To_Date
				-- and ms.Is_FNF = 0  
				-- AND V.Emp_Id = ISNULL(@Emp_Id,V.Emp_Id)   
				-- AND Increment_Effective_Date <= @To_Date  
				-- AND (V.Emp_Left = 'Y' Or V.Emp_Left = 'y')
				-- --AND ((@From_Date  >= join_Date  AND  @From_Date <= left_date )
				-- --OR (@To_Date  >= join_Date  AND @To_Date <= left_date )
				-- --OR (Left_date IS NULL AND @To_Date >= Join_Date)
				-- AND (@To_Date >= left_date  AND  @From_Date <= left_date )
				-- --OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date )) then 1 else 0 end))
				-- ORDER BY Emp_ID  
			END  */
		-- Comment by nilesh patel on 18092014 --End 
		
	 
		 --Select *
		 --,(select Branch_id from T0095_Increment where Increment_ID in 
		 --(Select Increment_ID from T0080_Emp_master where Emp_Id = temp.Emp_Id and Cmp_Id = @Cmp_ID )) as Branch_Id 
		 --,(Select Alpha_Emp_Code from T0080_Emp_master where Emp_Id = temp.Emp_Id and Cmp_Id = @Cmp_ID ) as Alpha_Emp_Code
		 --,(Select Emp_Full_Name from T0080_Emp_master where Emp_Id = temp.Emp_Id and Cmp_Id = @Cmp_ID ) as Emp_Full_Name
		 ----,(Select Emp_Left from T0080_Emp_master where Emp_Id = temp.Emp_Id and Cmp_Id = @Cmp_ID ) as IS_Left
		 --from (select distinct Emp_ID from #Emp_Cons ) as temp 
		 --order by Alpha_Emp_Code
		 
		 Set @Is_Active = (Case @Is_Active when 0 then 2 when 1 then 1 else 0 end)  	 --add by chetan 120617
	--Added By Jaina 07-09-2016
	DECLARE @Hide_Attendance_For_Fix_Salary Tinyint  
	SELECT @Hide_Attendance_For_Fix_Salary = ISNULL(Setting_Value,0) 
	FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name = 'Hide Attendance For Fix Salary Employee'
	 

	Select INC_Qry.Branch_ID,Alpha_Emp_Code, 
			CASE WHEN Isnull(S.Setting_Value,1)  = 1 then   --Added By Hardik 04/02/2016
				isnull(E.Initial,'')+' '+E.Emp_First_Name +' '+ isnull(E.Emp_Second_Name,'')  + ' '+ isnull(E.Emp_Last_Name,'') 
			ELSE
				E.Emp_First_Name +' '+ isnull(E.Emp_Second_Name,'') + ' ' + isnull(E.Emp_Last_Name,'')
			End AS Emp_Full_Name,

		--Emp_Full_Name,--isnull(E.Initial,'')+' '+E.Emp_First_Name + ' '+ isnull(E.Emp_Last_Name,'') as Emp_Full_Name,
		EC.Emp_ID,E.mobile_no,INC_Qry.Dept_Id from #Emp_Cons EC 
		Inner Join T0080_EMP_MASTER E WITH (NOLOCK) on Ec.Emp_ID = E.Emp_ID Inner Join
		(Select I.Emp_ID,I.Branch_id,I.Emp_Fix_Salary,I.Dept_ID  From T0095_INCREMENT I WITH (NOLOCK) Inner Join 
			(Select MAX(Increment_Id) as Increment_Id, Emp_Id 
				From T0095_INCREMENT WITH (NOLOCK)
				Where Increment_Effective_Date <= @To_Date And Cmp_ID= Isnull(@Cmp_Id,Cmp_Id)
				Group by Emp_Id) Qry on I.Increment_ID = Qry.Increment_Id and I.Emp_Id = Qry.Emp_ID) INC_Qry on INC_Qry.Emp_ID = Ec.Emp_ID 
				Left OUTER JOIN T0040_SETTING S WITH (NOLOCK) on E.Cmp_ID = S.Cmp_ID And S.Setting_Name='Add initial in employee full name' --Added Condition by Hardik 04/02/2016				
				INNER JOIN T0011_Login LO WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id --add by chetan 120617
				LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON INC_Qry.Dept_Id = DM.Dept_Id
		where E.Gender = ISNULL(@Geneder,E.Gender)
			 and (CASE when @Hide_Attendance_For_Fix_Salary = 1 AND INC_Qry.Emp_Fix_Salary = 1 THEN 1 ELSE 0 END) = 0  --Added By Jaina 07-09-2016
			  and 1 = (Case When @Is_Active <> 2 and LO.is_Active = @Is_Active then 1 When @Is_Active = 2 then 1 else 0 End)--add by chetan 120617
	Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
			When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
				Else Alpha_Emp_Code
			End 
END




