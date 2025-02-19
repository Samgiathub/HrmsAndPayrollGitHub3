

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_RECORD_GET_ALL_COMPANY_BackuoByDivyarajKiri31032023]     
  @Cmp_ID  numeric      
 ,@From_Date  datetime      
 ,@To_Date  datetime       
 ,@Branch_ID  numeric   
 ,@Cat_ID  numeric 
 ,@Grd_ID  numeric 
 ,@Type_ID  numeric  
 ,@Dept_ID  numeric  
 ,@Desig_ID  numeric 
 ,@Emp_ID  numeric 
 ,@Constraint varchar(MAX) = '' 
 ,@Emp_Search int=0     
 ,@St_Date datetime = NULL
 ,@End_Date datetime = NULL
 ,@BSegment_ID numeric		= 0		--Added By Gadriwala 21102013
 ,@Vertical_ID numeric		= 0		--Added By Gadriwala 21102013
 ,@subVertical_ID numeric	= 0		--Added By Gadriwala 21102013
 ,@subBranch_ID numeric		= 0		--Added By Gadriwala 21102013
 ,@P_Branch		varchar(max) = ''	--(For privilege branch)Jaina 14-09-2015
 ,@P_Vertical		varchar(max) = ''	--(For privilege Vertical)Jaina 14-09-2015
 ,@P_Subvertical		varchar(max) = ''	--(For privilege Subvertical)Jaina 14-09-2015
 ,@P_Department		varchar(max) = ''	--(For privilege Department)Jaina 14-09-2015
 ,@Mode		Varchar(20) = ''	--Added by Nimesh On 13-Jan-2016
 ,@Flag  numeric		= 0	-- Added by nilesh patel
 ,@AD_ID numeric		= 0	-- Added by nilesh patel
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	 /*
	@Flag Detail
	 2	: For Present Import
	 99 : Leave Encash Approval		-Jimit
	101 : Leave Carry Forward
	102 : Bonus						-Jaina			
	103 : Import Page Employeee		-Ramiz
	200 : Salary
	999 : Then Mode will be DROPDOWN
	*/

	
	------if @flag =99 then it is used for Leave Encahment Approval for getting All (Active and Left (Last Calaender Year)) employees  
	
	IF @Flag = 999
		BEGIN
			SET @Mode = 'DROPDOWN'
			SET @Flag = 0
		END
	  
 if @Branch_ID = 0      
  set @Branch_ID = null      
 if @Cat_ID = 0      
  set @Cat_ID = null      
         
 if @Type_ID = 0      
  set @Type_ID = null      
 if @Dept_ID = 0      
  set @Dept_ID = null      
 if @Grd_ID = 0      
  set @Grd_ID = null      
 if @Emp_ID = 0      
  set @Emp_ID = null      
        
 If @Desig_ID = 0      
  set @Desig_ID = null      
 
 if @BSegment_ID = 0 
  set @BSegment_ID = null    
 if @Vertical_ID = 0				--Added By Gadriwala 21102013
  set @Vertical_ID = null
 if @subVertical_ID = 0				--Added By Gadriwala 21102013
  set @subVertical_ID = null
 if @subBranch_ID  = 0				--Added By Gadriwala 21102013
  set @subBranch_ID = null       
       
 IF (@P_Branch = '' OR @P_Branch = '0') --Added By Jaina 14-09-2015
	SET @P_Branch = NULL;    
	
 IF (@P_Vertical = '' OR @P_Vertical = '0') --Added By Jaina 14-09-2015
	SET @P_Vertical = NULL
	
 IF (@P_Subvertical = '' OR @P_Subvertical = '0') --Added By Jaina 14-09-2015
	set @P_Subvertical = NULL
	
IF (@P_Department = '' OR @P_Department = '0') --Added By Jaina 14-09-2015
	set @P_Department = NULL
	
	
--Added By Jaina 7-11-2015 Start		
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
	if @P_Subvertical is null
	Begin	
		select   @P_Subvertical = COALESCE(@P_Subvertical + '#', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		If @P_Subvertical IS NULL
			set @P_Subvertical = '0';
		else
			set @P_Subvertical = @P_Subvertical + '#0'
	End
	IF @P_Department is null
	Begin
		select   @P_Department = COALESCE(@P_Department + '#', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		
		if @P_Department is null
			set @P_Department = '0';
		else
			set @P_Department = @P_Department + '#0'
	End
	--Added By Jaina 7-11-2015 End
	
 CREATE table #Emp_Cons 
 (      
  Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric
 )      
         
       
 if @Constraint <> ''      
	begin
		
		Insert Into #Emp_Cons      
		select  cast(data  as numeric),I.Branch_ID,i.Increment_ID from dbo.Split (@Constraint,'#') S 
		INNER JOIN (
					SELECT	EMP_ID, INCREMENT_ID, BRANCH_ID
					FROM	T0095_INCREMENT I1 WITH (NOLOCK)
					WHERE	I1.Cmp_ID = @Cmp_Id And I1.Increment_ID=(
												SELECT	MAX(INCREMENT_ID)
												FROM	T0095_INCREMENT I2 WITH (NOLOCK)
												WHERE	I2.Cmp_ID = @Cmp_Id And I2.Increment_Effective_Date = (
																						SELECT	MAX(INCREMENT_EFFECTIVE_DATE)
																						FROM	T0095_INCREMENT I3 WITH (NOLOCK)
																						WHERE	I3.Cmp_ID = @Cmp_Id And I3.Emp_ID=I2.Emp_ID 
																								AND Increment_Effective_Date <= @To_Date
																					   )
														AND I2.Emp_ID=I1.Emp_ID
											)
				) I ON cast(data  as numeric)=I.Emp_ID      
	end
 else if @Flag = 200 --Hardik 23/04/2018 for Payslip and Salary Generation Drop down not showing Left Employee where salary cycle is different
	Begin
		EXEC SP_EMP_SALARY_Constraint @Cmp_ID=@Cmp_ID, @From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@Salary_Cycle_id=0 ,@Branch_Constraint=@P_Branch,
@Segment_ID=@BSegment_ID,@Vertical=@Vertical_ID,@SubVertical=@subVertical_ID,@subBranch=@subBranch_ID,@Constraint=@Constraint
	End
 else      
	begin      
	   
	if isnull(@St_Date,0) = 0 or isnull(@end_date,0) = 0
		begin 
			
		   Insert Into #Emp_Cons      
			  select	DISTINCT  Emp_ID,VE.branch_id,Increment_ID  
			  from		V_Emp_Cons  VE  inner join 
						T0040_GENERAL_SETTING g WITH (NOLOCK) on VE.branch_id=g.branch_id left OUTER JOIN 
						(
							SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid 
							FROM	T0095_Emp_Salary_Cycle ESC WITH (NOLOCK) inner join 
							(
								SELECT	max(Effective_date) as Effective_date,emp_id 
								FROM	T0095_Emp_Salary_Cycle WITH (NOLOCK) 
								where	Effective_date <= @To_Date
										and cmp_id = @Cmp_ID 
								GROUP BY emp_id
							) Qry  on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
						 ) as QrySC ON QrySC.eid = VE.Emp_ID 
		       where  --Change By Jaina 14-09-2015
			  VE.cmp_id=@Cmp_ID 
			   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and VE.Branch_ID = isnull(@Branch_ID ,VE.Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
		   and ISNULL(Segment_ID,0) = ISNULL(@BSegment_ID,isnull(Segment_ID,0)) --Added By Gadriwala 21102013
		   and ISNULL(Vertical_ID,0) = ISNULL(@vertical_id,isnull(Vertical_ID,0))		--Added By Gadriwala 21102013
		   and ISNULL(SubVertical_ID,0) = ISNULL(@subVertical_ID,isnull(SubVertical_ID,0)) --Added By Gadriwala 21102013
		   and ISNULL(subBranch_ID,0) = ISNULL(@subBranch_ID,isnull(subBranch_ID,0)) --Added By Gadriwala 21102013
		  
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
			  and Increment_Effective_Date <= @To_Date 
			  and 
					  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)
						or (@To_Date >= left_date  and  @From_Date <= left_date ))
						order by Emp_ID
			
			--Delete From #Emp_Cons Where Increment_ID Not In	--Ankit 30012014
			--	(select TI.Increment_ID from t0095_increment TI inner join
			--	(Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment
			--	Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
			--	on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
			--	Where Increment_effective_Date <= @to_date)			
						
			--Changed by Gadriwala Muslim 10012015 - Start
			
			Delete	#Emp_Cons 
			From	#Emp_Cons EC 
					Left Outer Join (
										SELECT	Max(TI.Increment_ID) Increment_Id,ti.Emp_ID 
										FROM	t0095_increment TI  WITH (NOLOCK)
												INNER JOIN 
												(	
													Select	Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID 
													FROM	T0095_Increment WITH (NOLOCK)
													Where	Increment_effective_Date <= @to_date and cmp_id=@Cmp_Id
													Group by emp_ID
												) new_inc ON TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date										
										group by ti.emp_id
									) Qry on Ec.Increment_Id = Qry.Increment_Id
			Where Qry.Increment_ID is null
			
			--Changed by Gadriwala Muslim 10012015 - End
			
			--delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment
			--	where  Increment_effective_Date <= @to_date
			--	group by emp_ID)
				
		 --  select I.Emp_Id,I.Branch_ID from T0095_Increment I inner join       
			-- ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment      
			-- where Increment_Effective_date <= @To_Date      
			-- and Cmp_ID = @Cmp_ID      
			-- group by emp_ID  ) Qry on      
			-- I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date      
		 --  Where Cmp_ID = @Cmp_ID       
		 --  and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		 --  and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		 --  and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		 --  and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		 --  and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		 --  and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
		 --  and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)       
		 --  and I.Emp_ID in       
			--( select Emp_Id from      
			--(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry      
			--where cmp_ID = @Cmp_ID   and        
			--(( @From_Date  >= join_Date  and  @From_Date <= left_date )       
			--or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
			--or Left_date is null and @To_Date >= Join_Date)      
			--or @To_Date >= left_date  and  @From_Date <= left_date )   
		end
	else
		begin
		
		
		   Insert Into #Emp_Cons      
			  select emp_id,branch_id,Increment_ID 
			  from V_Emp_Cons where 
			  cmp_id=@Cmp_ID 
			   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
		   and ISNULL(Segment_ID,0) = ISNULL(@BSegment_ID,isnull(Segment_ID,0)) --Added By Gadriwala 21102013
		   and ISNULL(Vertical_ID,0) = ISNULL(@vertical_id,isnull(Vertical_ID,0))		--Added By Gadriwala 21102013
		   and ISNULL(SubVertical_ID,0) = ISNULL(@subVertical_ID,isnull(SubVertical_ID,0)) --Added By Gadriwala 21102013
		   and ISNULL(subBranch_ID,0) = ISNULL(@subBranch_ID,isnull(subBranch_ID,0)) --Added By Gadriwala 21102013
		 
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)  
			  and Increment_Effective_Date <= @To_Date 
			  and 
					 ( isnull(Left_date,@to_date) = @to_date or 
					(@St_Date <= isnull(left_date,@St_Date) )-- and @end_date >= isnull(left_date,@end_date) ) --Commented by Hardik 23/06/2017 for BMA, If employee left on 23/05/2017 and IT Declaration checked for 2016-2017 Year then employee is not showing, it will only show in 2017-2018
					 OR (join_Date <= @End_Date and isnull(left_date,@To_Date) = @To_Date)  ) 
						order by Emp_ID

			--Delete From #Emp_Cons Where Increment_ID Not In	--Ankit 30012014
			--	(select TI.Increment_ID from t0095_increment TI inner join
			--	(Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment
			--	Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
			--	on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
			--	Where Increment_effective_Date <= @to_date)	
			
			
			--Changed by Gadriwala Muslim 10012015 - Start
			Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date and cmp_id=@cmp_Id Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
			Where Qry.Increment_ID is null
			
			--Changed by Gadriwala Muslim 10012015 - End				
			
			--delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment
			--	where  Increment_effective_Date <= @to_date
			--	group by emp_ID)

			
			--Insert Into #Emp_Cons      
		 --  select I.Emp_Id,I.Branch_ID from T0095_Increment I inner join       
			-- ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment      
			-- where Increment_Effective_date <= @To_Date      
			-- and Cmp_ID = @Cmp_ID      
			-- group by emp_ID  ) Qry on      
			-- I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date      
		 --  Where Cmp_ID = @Cmp_ID       
		 --  and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		 --  and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		 --  and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		 --  and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		 --  and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		 --  and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
		 --  and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)       
		 --  and I.Emp_ID in       
			--( select Emp_Id from      
			--(
			--select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN
			--) qry      
			--where cmp_ID = @Cmp_ID   and        
			--( Left_date = @to_date or 
			--(@St_Date <= left_date  and @end_date >= left_date ) 
			--)   )
			
		end    
  end    
  

  --Added By Jaina 14-09-2015 Start   --Change By Jaina 7-11-2015
  IF (@P_Branch IS NOT NULL) 
  BEGIN	  
	  DELETE #Emp_Cons FROM #Emp_Cons E INNER JOIN T0095_INCREMENT I ON E.Increment_ID=I.Increment_ID AND I.Cmp_ID=@CMP_ID
	  --WHERE	I.Branch_ID NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@P_Branch, '#'))
	  WHERE NOT EXISTS (select Data from dbo.Split(@P_Branch, '#') B Where cast(B.data as numeric)=Isnull(I.Branch_ID,0))
  END
  
  IF (@P_Vertical IS NOT NULL) 
  BEGIN	  
	  DELETE #Emp_Cons FROM #Emp_Cons E INNER JOIN T0095_INCREMENT I ON E.Increment_ID=I.Increment_ID AND I.Cmp_ID=@CMP_ID
	  --WHERE	I.Vertical_ID NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@P_Vertical, '#')) OR I.Vertical_ID IS NULL
	  WHERE NOT EXISTS (select Data from dbo.Split(@P_Vertical, '#') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
	  
  END
  
  IF (@P_Subvertical IS NOT NULL) 
  BEGIN
	  DELETE #Emp_Cons FROM #Emp_Cons E INNER JOIN T0095_INCREMENT I ON E.Increment_ID=I.Increment_ID AND I.Cmp_ID=@CMP_ID
	  --WHERE	I.SubVertical_ID NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@P_Subvertical, '#')) OR I.SubVertical_ID IS NULL
	  WHERE NOT EXISTS (select Data from dbo.Split(@P_Subvertical, '#') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
  END
  
  IF (@P_Department IS NOT NULL) 
  BEGIN

	  DELETE #Emp_Cons FROM #Emp_Cons E INNER JOIN T0095_INCREMENT I ON E.Increment_ID=I.Increment_ID AND I.Cmp_ID=@CMP_ID
	  --WHERE	I.Dept_ID NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@P_Department, '#')) OR I.Dept_ID IS NULL
	  WHERE NOT EXISTS (select Data from dbo.Split(@P_Department, '#') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0)) 
  END
  --Added By Jaina 14-09-2015 End
  
  Declare @Show_Left_Employee_for_Salary as tinyint
  Set @Show_Left_Employee_for_Salary = 0
  
  Select @Show_Left_Employee_for_Salary = Isnull(Setting_Value,0) 
  From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Setting_Name like 'Show Left Employee for Salary'
  

   /*
	@Flag Detail

	101 : Leave Carry Forward
	99 : Leave Encash APproval
	*/

	Declare @ShowLeftEmp Bit 
	SET @ShowLeftEmp = 0
	
	
	IF @Flag = 101 AND Exists(Select 1 FROM T0040_SETTING WITH (NOLOCK) WHERE Setting_Name = 'Show Current Year Left Employee in Leave Carry Forward' AND Setting_Value=1 And Cmp_ID=@Cmp_ID)
		SET @ShowLeftEmp = 1
	IF ((@St_Date IS NOT NULL AND @End_Date IS NOT NULL) or @Mode = 'DROPDOWN') AND Exists(Select 1 FROM T0040_SETTING WITH (NOLOCK) WHERE Setting_Name='Show Left Employee for Salary' AND Setting_Value=1 And Cmp_ID=@Cmp_ID)
		SET @ShowLeftEmp = 1
   
   If (@Show_Left_Employee_for_Salary = 0  and  (isnull(@St_Date,0) = 0 or isnull(@end_date,0) = 0)) or @Mode = 'DROPDOWN'
		BEGIN		
			IF (@Mode = 'DROPDOWN' and @Flag = 0)
				BEGIN
					
					SELECT * 
					FROM	(
								SELECT	e.Emp_ID, CASE @Emp_Search 
											WHEN 0
												THEN CAST( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
											WHEN 1
												THEN  CAST( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											WHEN 2
												THEN  CAST( E.Alpha_Emp_Code as varchar)
											WHEN 3
												THEN  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											WHEN 4	
												THEN  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
										END AS Emp_Full_Name,
										I_Q.Branch_ID,I_Q.Desig_Id,I_Q.Dept_ID
										,E.Emp_Left --Added By Jimit 07042018
										,I_Q.Grd_ID,I_Q.Cat_ID,I_Q.Segment_ID,I_Q.subBranch_ID,I_Q.SubVertical_ID,I_Q.Vertical_ID --Added By Jimit 05032019 as require filter based on this masters 
								FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN  T0010_company_master Cm WITH (NOLOCK) ON E.Cmp_ID = Cm.Cmp_ID 
										LEFT OUTER JOIN T0100_LEFT_EMP EL WITH (NOLOCK) ON E.Emp_Id=EL.Emp_Id 										
										INNER JOIN #Emp_Cons EC ON ec.Emp_ID = e.Emp_ID
										INNER JOIN ( 
													SELECT	I.Emp_Id,I.Branch_ID,Desig_ID,Dept_ID,I.Vertical_ID,I.SubVertical_ID,I.Grd_ID,I.Cat_ID,I.Segment_ID,I.subBranch_ID
													FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
													) I_Q ON I_Q.Emp_ID = E.Emp_ID --Added By Jaina 01-09-2015 End
								WHERE	E.Cmp_ID = @Cmp_Id AND 
									(CASE WHEN @ShowLeftEmp = 1 THEN 1 WHEN @ShowLeftEmp=0 AND Emp_left_Date > @To_Date OR Emp_Left_Date IS NULL THEN 1 ELSE 0 END) = 1				
							) T
					ORDER BY EMP_FULL_NAME
					
				END
			---added by jimit for getting All (Active and Left (Last Calender Year)) employees 
			Else If (@Mode = 'DROPDOWN' and @Flag = 99)
				Begin
					SELECT	e.Emp_ID, CASE @Emp_Search 
								WHEN 0
									THEN CAST( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
								WHEN 1
									THEN  CAST( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
								WHEN 2
									THEN  CAST( E.Alpha_Emp_Code as varchar)
								WHEN 3
									THEN  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
								WHEN 4	
									THEN  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
							END AS Emp_Full_Name,
							I_Q.Branch_ID,I_Q.Desig_Id,I_Q.Dept_ID, e.Emp_Left_Date
							,E.Emp_Left --Added By Jimit 07042018
							,I_Q.Grd_ID,I_Q.Cat_ID,I_Q.Vertical_ID,I_Q.subBranch_ID,I_Q.SubVertical_ID,I_Q.Segment_ID --Added By Jimit 07042018
					FROM	T0080_EMP_MASTER E 	WITH (NOLOCK)																			
							INNER JOIN #Emp_Cons EC on ec.Emp_ID = e.Emp_ID   
							INNER JOIN T0095_Increment I_Q WITH (NOLOCK) ON I_Q.Increment_ID=EC.Increment_ID
					WHERE	E.Cmp_ID = @Cmp_Id   --And E.Emp_ID in (select Emp_ID From #Emp_Cons) 	
										 		  
					ORDER BY	(Case @Emp_Search 
									When 3 Then
										e.Emp_First_Name
									When 4 Then
										e.Emp_First_Name
									Else
										Case 
											When IsNumeric(e.Alpha_Emp_Code) = 1 then 
												Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
											When IsNumeric(e.Alpha_Emp_Code) = 0 then 
												Left(e.Alpha_Emp_Code + Replicate('',21), 20)
											Else 
												e.Alpha_Emp_Code
										End								
								End)
				End
			--------------------------------ended ----------------------------------
			ELSE
				BEGIN
					IF @Flag = 1 
						BEGIN
							SELECT	I_Q.* ,E.Emp_Code, 
										case @Emp_Search 
											when 0
												then cast( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
											when 1
												then  cast( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											when 2
												then  cast( E.Alpha_Emp_Code as varchar)
											when 3
												then  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											when 4	
												then  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
										end as Emp_Full_Name
										,Lo.Login_ID,E.Emp_Full_Name as Emp_Full_Name_only,Emp_superior      
										,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
										,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left,E.Alpha_Emp_Code ,E.Emp_First_Name as Emp_First_Name
										,MAD.Amount as Amount , MAD.Comments AS Comments
								FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN  T0010_company_master Cm WITH (NOLOCK) ON E.Cmp_ID = Cm.Cmp_ID 
										LEFT OUTER JOIN T0100_LEFT_EMP EL WITH (NOLOCK) ON E.Emp_Id=EL.Emp_Id 
										INNER JOIN ( 
													SELECT	I.Emp_Id , Grd_ID,I.Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID,subBranch_ID ,I.Segment_ID
													FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
													) I_Q ON I_Q.Emp_ID = E.Emp_ID --Added By Jaina 01-09-2015 End
										INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
										LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
										LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
										LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
										INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
										INNER JOIN T0011_Login LO WITH (NOLOCK)  ON LO.Emp_Id = E.Emp_Id 
										INNER JOIN #Emp_Cons EC ON ec.Emp_ID = e.Emp_ID	
										Left OUTER JOIN T0190_MONTHLY_AD_DETAIL_IMPORT MAD WITH (NOLOCK) ON MAD.Emp_ID = EC.Emp_ID and MAD.Month = Month(@From_Date) and MAD.Year = Year(@From_Date) and MAD.AD_ID = @AD_ID
										WHERE	E.Cmp_ID = @Cmp_Id AND Emp_Left <> 'Y'
								
								GROUP BY I_Q.Emp_Id,I_Q.Grd_ID,I_Q.Branch_ID,I_Q.Cat_ID,I_Q.Desig_ID,I_Q.Dept_ID,I_Q.Type_ID,I_Q.Vertical_ID,I_Q.SubVertical_ID,I_Q.subBranch_ID,I_Q.Segment_ID,
											Emp_Code,Alpha_Emp_Code,Emp_First_Name,Emp_Full_Name
											,Lo.Login_ID,Emp_superior,Emp_Second_Name,Emp_Last_Name,Initial      
											,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
											,Comp_Name,Branch_Address,Cmp_Name,Cmp_address,Emp_Left
											,Amount, Comments 
								ORDER BY 
											Case @Emp_Search 
												When 3 Then
													e.Emp_First_Name
												When 4 Then
													e.Emp_First_Name
												--Else    commented By Mukti 07112014
												--	RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
												--End
												Else   --  Added By Mukti 07112014
													Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
														When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
														Else e.Alpha_Emp_Code
													End
											End
						End
					Else if  @Flag = 2
						BEGIN
							
							
							SELECT	I_Q.* ,E.Emp_Code, 
										case @Emp_Search 
											when 0
												then cast( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
											when 1
												then  cast( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											when 2
												then  cast( E.Alpha_Emp_Code as varchar)
											when 3
												then  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											when 4	
												then  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
										end as Emp_Full_Name
										,Lo.Login_ID,E.Emp_Full_Name as Emp_Full_Name_only,Emp_superior      
										,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
										,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left,E.Alpha_Emp_Code ,E.Emp_First_Name as Emp_First_Name
										,MAD.Extra_Day_Month as Extra_Day_Month
										,MAD.Extra_Day_Year as Extra_Day_Year ,MAD.P_Days,MAD.Extra_Days,MAD.Over_Time,MAD.Cancel_Weekoff_Day,MAD.Cancel_Holiday,MAD.WO_OT_Hour,MAD.HO_OT_Hour
										,MAD.present_on_holiday
								FROM	T0080_EMP_MASTER E WITH (NOLOCK)
										INNER JOIN  T0010_company_master Cm WITH (NOLOCK) ON E.Cmp_ID = Cm.Cmp_ID 
										LEFT OUTER JOIN T0100_LEFT_EMP EL WITH (NOLOCK) ON E.Emp_Id=EL.Emp_Id 
										INNER JOIN ( 
													SELECT	I.Emp_Id , Grd_ID,I.Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID,subBranch_ID ,I.Segment_ID
													FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
													) I_Q ON I_Q.Emp_ID = E.Emp_ID --Added By Jaina 01-09-2015 End
										INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
										LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
										LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
										LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
										INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
										INNER JOIN T0011_Login LO  WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id 
										INNER JOIN #Emp_Cons EC ON ec.Emp_ID = e.Emp_ID	
										Left OUTER JOIN T0190_MONTHLY_PRESENT_IMPORT MAD WITH (NOLOCK) ON MAD.Emp_ID = EC.Emp_ID and MAD.Month = Month(@From_Date) and MAD.Year = Year(@From_Date)					
								--WHERE	E.Cmp_ID = @Cmp_Id AND Emp_Left <> 'Y'	--Commented By Ramiz and Added Below Code on 10/10/2018
								WHERE	E.Cmp_ID = @Cmp_Id AND (E.Emp_Left_Date IS NULL OR E.Emp_Left_Date > @To_Date) AND E.Date_Of_Join <= @To_Date
								
								GROUP BY I_Q.Emp_Id,I_Q.Grd_ID,I_Q.Branch_ID,I_Q.Cat_ID,I_Q.Desig_ID,I_Q.Dept_ID,I_Q.Type_ID,I_Q.Vertical_ID,I_Q.SubVertical_ID,I_Q.subBranch_ID,I_Q.Segment_ID,
											Emp_Code,Alpha_Emp_Code,Emp_First_Name,Emp_Full_Name
											,Lo.Login_ID,Emp_superior,Emp_Second_Name,Emp_Last_Name,Initial      
											,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
											,Comp_Name,Branch_Address,Cmp_Name,Cmp_address,Emp_Left
											,Extra_Day_Month,Extra_Day_Year,MAD.P_Days,MAD.Extra_Days,MAD.Over_Time
											,MAD.Cancel_Weekoff_Day,MAD.Cancel_Holiday,MAD.WO_OT_Hour,MAD.HO_OT_Hour,MAD.present_on_holiday
		
								ORDER BY 
											Case @Emp_Search 
												When 3 Then
													e.Emp_First_Name
												When 4 Then
													e.Emp_First_Name
												Else   --  Added By Mukti 07112014
													Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
														When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
														Else e.Alpha_Emp_Code
													End
											End
						End
					ELSE IF @Flag = 103	--Ramiz 09/10/2018 --For Import Page , If Allowance is Selected , then show on that Employee who are Eligilble for it
						BEGIN

							SET @Constraint = NULL;
							SELECT	@Constraint = COALESCE(@Constraint + '#', '') + CAST(EMP_ID AS VARCHAR(10))
							FROM	#Emp_Cons

							SELECT * INTO #EMP_EARN_DEDUCTION_FIRST
							FROM	dbo.fn_getEmpIncrementDetail(@Cmp_ID , @Constraint , @To_Date)
							WHERE	AD_ID= @AD_ID
							
							
							SELECT	CASE @Emp_Search 
											WHEN 0
												THEN CAST( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
											WHEN 1
												THEN  CAST( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											WHEN 2
												THEN  CAST( E.Alpha_Emp_Code as varchar)
											WHEN 3
												THEN  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											WHEN 4	
												THEN  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
										END AS Emp_Full_Name
									,I_Q.Emp_Id , I_Q.Grd_ID,I_Q.Branch_ID,I_Q.Cat_ID,I_Q.Desig_ID,I_Q.Dept_ID,I_Q.Type_ID,I_Q.Vertical_ID,I_Q.SubVertical_ID
								    ,I_Q.subBranch_ID ,I_Q.Segment_ID ,E.Emp_Code, E.Emp_Full_Name as Emp_Full_Name_only,E.Alpha_Emp_Code ,E.Emp_First_Name as Emp_First_Name
									,MAD.Amount as Amount , MAD.Comments AS Comments
							FROM	T0080_EMP_MASTER E WITH (NOLOCK)
									INNER JOIN		#EMP_EARN_DEDUCTION_FIRST ED ON ED.Emp_ID = E.Emp_ID
									INNER JOIN		T0095_INCREMENT I_Q WITH (NOLOCK) ON ED.Increment_ID = I_Q.Increment_ID AND ED.Emp_ID = I_Q.Emp_ID
									LEFT OUTER JOIN T0190_MONTHLY_AD_DETAIL_IMPORT MAD WITH (NOLOCK) ON MAD.Emp_ID = ED.Emp_ID and MAD.Month = Month(@From_Date) and MAD.Year = Year(@From_Date) and MAD.AD_ID = @AD_ID
							WHERE	E.Cmp_ID = @Cmp_Id
						END
					Else
						BEGIN
								SELECT	I_Q.* ,E.Emp_Code, 
										case @Emp_Search 
											when 0
												then cast( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
											when 1
												then  cast( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											when 2
												then  cast( E.Alpha_Emp_Code as varchar)
											when 3
												then  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											when 4	
												then  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
										end as Emp_Full_Name
										,Lo.Login_ID,E.Emp_Full_Name as Emp_Full_Name_only,Emp_superior      
										,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Emp_Left_Date,Gender      
										,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left,E.Alpha_Emp_Code ,E.Emp_First_Name as Emp_First_Name,E.Date_of_Retirement
								FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN  T0010_company_master Cm WITH (NOLOCK) ON E.Cmp_ID = Cm.Cmp_ID 
										LEFT OUTER JOIN T0100_LEFT_EMP EL WITH (NOLOCK) ON E.Emp_Id=EL.Emp_Id 
										INNER JOIN ( 
													SELECT	I.Emp_Id , Grd_ID,I.Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID,subBranch_ID ,I.Segment_ID,I.CTC
													FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
													) I_Q ON I_Q.Emp_ID = E.Emp_ID --Added By Jaina 01-09-2015 End
										INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
										LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
										LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
										LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
										INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
										INNER JOIN T0011_Login LO  WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id 
										INNER JOIN #Emp_Cons EC ON ec.Emp_ID = e.Emp_ID					
										WHERE	E.Cmp_ID = @Cmp_Id AND Emp_Left <> 'Y'
												--((Emp_Left <> 'Y' AND DateDiff(M,@From_Date,@To_Date) < 2)   --Added By Jimit 07042018 (For WCL In IT declaration Left Employees Not Coming for Last FY)
												--	OR 
												--(DateDiff(M,@From_Date,@To_Date) > 1 AND IsNull(Emp_Left_Date, @To_Date) >= @From_Date ))
								
								GROUP BY I_Q.Emp_Id,I_Q.Grd_ID,I_Q.Branch_ID,I_Q.Cat_ID,I_Q.Desig_ID,I_Q.Dept_ID,I_Q.Type_ID,I_Q.Vertical_ID,I_Q.SubVertical_ID,I_Q.subBranch_ID,I_Q.Segment_ID,
											Emp_Code,Alpha_Emp_Code,Emp_First_Name,Emp_Full_Name
											,Lo.Login_ID,Emp_superior,Emp_Second_Name,Emp_Last_Name,Initial      
											,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
											,Comp_Name,Branch_Address,Cmp_Name,Cmp_address,Emp_Left,Emp_Left_Date,E.Date_of_Retirement,I_Q.CTC
								ORDER BY 
											Case @Emp_Search 
												When 3 Then
													e.Emp_First_Name
												When 4 Then
													e.Emp_First_Name
												--Else    commented By Mukti 07112014
												--	RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
												--End
												Else   --  Added By Mukti 07112014
													Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
														When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
														Else e.Alpha_Emp_Code
													End
											End
						END
				END
		
		END
	ELSE
		BEGIN		
					
					IF @Flag = 1 
						BEGIN
							SELECT I_Q.* ,E.Emp_Code, 
								case @Emp_Search 
									when 0
										then cast( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
									when 1
										then  cast( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
									when 2
										then  cast( E.Alpha_Emp_Code as varchar)
									when 3
										then  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
									when 4	
										then  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
								end as Emp_Full_Name
								,Lo.Login_ID,E.Emp_Full_Name as Emp_Full_Name_only,Emp_superior      
								,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
								,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left,E.Alpha_Emp_Code ,E.Emp_First_Name as Emp_First_Name
								,MAD.Amount as Amount , MAD.Comments AS Comments
							FROM	T0080_EMP_MASTER E WITH (NOLOCK)
									INNER JOIN T0010_company_master Cm WITH (NOLOCK) ON E.Cmp_ID = Cm.Cmp_ID 
									LEFT OUTER JOIN T0100_LEFT_EMP EL WITH (NOLOCK) ON E.Emp_Id=EL.Emp_Id 
									INNER JOIN ( 
												SELECT	I.Emp_Id , Grd_ID,I.Branch_ID,Cat_ID,Desig_ID,I.Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID,subBranch_ID ,I.Segment_ID
												FROM	T0095_Increment I WITH (NOLOCK)
												INNER JOIN #Emp_Cons IEC on I.Increment_ID = IEC.Increment_ID
												) I_Q ON I_Q.Emp_ID = E.Emp_ID 
									INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
									LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
									LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
									LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
									INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
									INNER JOIN T0011_Login LO  WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id 
									INNER JOIN #Emp_Cons EC on ec.Emp_ID = e.Emp_ID     
									Left OUTER JOIN T0190_MONTHLY_AD_DETAIL_IMPORT MAD WITH (NOLOCK) ON MAD.Emp_ID = EC.Emp_ID and MAD.Month = Month(@From_Date) and MAD.Year = Year(@From_Date) and MAD.AD_ID = @AD_ID
							WHERE	E.Cmp_ID = @Cmp_Id   --And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
							
							GROUP BY	I_Q.Emp_Id,I_Q.Grd_ID,I_Q.Branch_ID,I_Q.Cat_ID,I_Q.Desig_ID,I_Q.Dept_ID,I_Q.Type_ID,I_Q.Vertical_ID,I_Q.SubVertical_ID,I_Q.subBranch_ID,I_Q.Segment_ID,
										Emp_Code,Alpha_Emp_Code,Emp_First_Name,Emp_Full_Name
										,Lo.Login_ID,Emp_superior,Emp_Second_Name,Emp_Last_Name,Initial      
										,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
										,Comp_Name,Branch_Address,Cmp_Name,Cmp_address,Emp_Left
										,Amount, Comments 
							ORDER BY	(Case @Emp_Search 
											When 3 Then
												e.Emp_First_Name
											When 4 Then
												e.Emp_First_Name
											Else
												Case 
													When IsNumeric(e.Alpha_Emp_Code) = 1 then 
														Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
													When IsNumeric(e.Alpha_Emp_Code) = 0 then 
														Left(e.Alpha_Emp_Code + Replicate('',21), 20)
													Else 
														e.Alpha_Emp_Code
												End								
										End)
						End
					ELSE IF @Flag = 2
						BEGIN
	
							SELECT	I_Q.* ,E.Emp_Code,
							case @Emp_Search 
								WHEN 0
									THEN cast( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
								WHEN 1
									THEN  cast( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
								WHEN 2
									THEN  cast( E.Alpha_Emp_Code as varchar)
								WHEN 3
									THEN  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
								WHEN 4	
									THEN  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
							end as Emp_Full_Name
							,Lo.Login_ID,E.Emp_Full_Name as Emp_Full_Name_only,Emp_superior      
							,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
							,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left,E.Alpha_Emp_Code ,E.Emp_First_Name as Emp_First_Name
							,MAD.Extra_Day_Month as Extra_Day_Month
							,MAD.Extra_Day_Year as Extra_Day_Year ,MAD.P_Days,MAD.Extra_Days,MAD.Over_Time,MAD.Cancel_Weekoff_Day,MAD.Cancel_Holiday,MAD.WO_OT_Hour,MAD.HO_OT_Hour
							,MAD.present_on_holiday
							FROM	T0080_EMP_MASTER E WITH (NOLOCK)
									INNER JOIN  T0010_company_master Cm WITH (NOLOCK) ON E.Cmp_ID = Cm.Cmp_ID 
									LEFT OUTER JOIN T0100_LEFT_EMP EL WITH (NOLOCK) ON E.Emp_Id=EL.Emp_Id 
									INNER JOIN ( 
												SELECT	I.Emp_Id , Grd_ID,I.Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID,subBranch_ID ,I.Segment_ID
												FROM	T0095_Increment I WITH (NOLOCK)
													INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
												) I_Q ON I_Q.Emp_ID = E.Emp_ID --Added By Jaina 01-09-2015 End
									INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
									LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
									LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
									LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
									INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
									INNER JOIN T0011_Login LO  WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id 
									INNER JOIN #Emp_Cons EC ON ec.Emp_ID = e.Emp_ID
									Left OUTER JOIN T0190_MONTHLY_PRESENT_IMPORT MAD WITH (NOLOCK) ON MAD.Emp_ID = EC.Emp_ID and MAD.Month = Month(@From_Date) and MAD.Year = Year(@From_Date)	
							--WHERE	E.Cmp_ID = @Cmp_Id AND Emp_Left <> 'Y'	--Commented By Ramiz and Added Below Code on 10/10/2018
							WHERE	E.Cmp_ID = @Cmp_Id AND (E.Emp_Left_Date IS NULL OR E.Emp_Left_Date <= @To_Date)
							GROUP BY I_Q.Emp_Id,I_Q.Grd_ID,I_Q.Branch_ID,I_Q.Cat_ID,I_Q.Desig_ID,I_Q.Dept_ID,I_Q.Type_ID,I_Q.Vertical_ID,I_Q.SubVertical_ID,I_Q.subBranch_ID,I_Q.Segment_ID,
										Emp_Code,Alpha_Emp_Code,Emp_First_Name,Emp_Full_Name
										,Lo.Login_ID,Emp_superior,Emp_Second_Name,Emp_Last_Name,Initial      
										,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
										,Comp_Name,Branch_Address,Cmp_Name,Cmp_address,Emp_Left,Extra_Day_Month,Extra_Day_Year
										,MAD.P_Days,MAD.Extra_Days,MAD.Over_Time,MAD.Cancel_Weekoff_Day,MAD.Cancel_Holiday,MAD.WO_OT_Hour,MAD.HO_OT_Hour,MAD.present_on_holiday
							ORDER BY 
										(Case @Emp_Search 
											When 3 Then
												e.Emp_First_Name
											When 4 Then
												e.Emp_First_Name
											Else
												Case 
													When IsNumeric(e.Alpha_Emp_Code) = 1 then 
														Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
													When IsNumeric(e.Alpha_Emp_Code) = 0 then 
														Left(e.Alpha_Emp_Code + Replicate('',21), 20)
													Else 
														e.Alpha_Emp_Code
												End								
										End)
						End 
					ELSE IF @Flag = 102	--@Flag = 102 use for Only Active Employee and Date of Joining  (for Bonus)  --Added by Jaina 03-10-2017
						BEGIN
							SELECT	I_Q.* ,E.Emp_Code, 
										case @Emp_Search 
											when 0
												then cast( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
											when 1
												then  cast( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											when 2
												then  cast( E.Alpha_Emp_Code as varchar)
											when 3
												then  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											when 4	
												then  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
										end as Emp_Full_Name
										,Lo.Login_ID,E.Emp_Full_Name as Emp_Full_Name_only,Emp_superior      
										,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
										,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left,E.Alpha_Emp_Code ,E.Emp_First_Name as Emp_First_Name
										,MAD.Amount as Amount , MAD.Comments AS Comments
								FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN  T0010_company_master Cm WITH (NOLOCK) ON E.Cmp_ID = Cm.Cmp_ID 
										LEFT OUTER JOIN T0100_LEFT_EMP EL WITH (NOLOCK) ON E.Emp_Id=EL.Emp_Id 
										INNER JOIN ( 
													SELECT	I.Emp_Id , Grd_ID,I.Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID,subBranch_ID ,I.Segment_ID
													FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
													) I_Q ON I_Q.Emp_ID = E.Emp_ID --Added By Jaina 01-09-2015 End
										INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
										LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
										LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
										LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
										INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
										INNER JOIN T0011_Login LO  WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id 
										INNER JOIN #Emp_Cons EC ON ec.Emp_ID = e.Emp_ID	
										Left OUTER JOIN T0190_MONTHLY_AD_DETAIL_IMPORT MAD WITH (NOLOCK) ON MAD.Emp_ID = EC.Emp_ID 
													and MAD.Month = Month(@From_Date) and MAD.Year = Year(@From_Date) and MAD.AD_ID = @AD_ID
								WHERE	E.Cmp_ID = @Cmp_Id AND (E.Emp_Left_Date IS NULL OR E.Emp_Left_Date > @To_Date) AND E.Date_Of_Join <= @To_Date
										---AND Emp_Left <> 'Y' AND E.DATE_OF_JOIN <= @FROM_DATE
								GROUP BY I_Q.Emp_Id,I_Q.Grd_ID,I_Q.Branch_ID,I_Q.Cat_ID,I_Q.Desig_ID,I_Q.Dept_ID,I_Q.Type_ID,I_Q.Vertical_ID,I_Q.SubVertical_ID,I_Q.subBranch_ID,I_Q.Segment_ID,
											Emp_Code,Alpha_Emp_Code,Emp_First_Name,Emp_Full_Name
											,Lo.Login_ID,Emp_superior,Emp_Second_Name,Emp_Last_Name,Initial      
											,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
											,Comp_Name,Branch_Address,Cmp_Name,Cmp_address,Emp_Left
											,Amount, Comments 
								ORDER BY 
											Case @Emp_Search 
												When 3 Then
													e.Emp_First_Name
												When 4 Then
													e.Emp_First_Name
												--Else    commented By Mukti 07112014
												--	RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
												--End
												Else   --  Added By Mukti 07112014
													Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
														When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
														Else e.Alpha_Emp_Code
													End
											End
											
						end
					ELSE IF @Flag = 103	--Ramiz 09/10/2018 --For Import Page , If Allowance is Selected , then show on that Employee who are Eligilble for it
						BEGIN

							SET @Constraint = NULL;
							SELECT	@Constraint = COALESCE(@Constraint + '#', '') + CAST(EMP_ID AS VARCHAR(10))
							FROM	#Emp_Cons

							SELECT * INTO #EMP_EARN_DEDUCTION_SECOND 
							FROM	dbo.fn_getEmpIncrementDetail(@Cmp_ID , @Constraint , @To_Date)
							WHERE	AD_ID= @AD_ID
							
							
							SELECT	CASE @Emp_Search 
											WHEN 0
												THEN CAST( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
											WHEN 1
												THEN  CAST( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											WHEN 2
												THEN  CAST( E.Alpha_Emp_Code as varchar)
											WHEN 3
												THEN  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											WHEN 4	
												THEN  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
										END AS Emp_Full_Name
									,I_Q.Emp_Id , I_Q.Grd_ID,I_Q.Branch_ID,I_Q.Cat_ID,I_Q.Desig_ID,I_Q.Dept_ID,I_Q.Type_ID,I_Q.Vertical_ID,I_Q.SubVertical_ID
								    ,I_Q.subBranch_ID ,I_Q.Segment_ID ,E.Emp_Code, E.Emp_Full_Name as Emp_Full_Name_only,E.Alpha_Emp_Code ,E.Emp_First_Name as Emp_First_Name
									,MAD.Amount as Amount , MAD.Comments AS Comments
							FROM	T0080_EMP_MASTER E WITH (NOLOCK)
									INNER JOIN		#EMP_EARN_DEDUCTION_SECOND ED ON ED.Emp_ID = E.Emp_ID
									INNER JOIN		T0095_INCREMENT I_Q WITH (NOLOCK) ON ED.Increment_ID = I_Q.Increment_ID AND ED.Emp_ID = I_Q.Emp_ID
									LEFT OUTER JOIN T0190_MONTHLY_AD_DETAIL_IMPORT MAD WITH (NOLOCK) ON MAD.Emp_ID = ED.Emp_ID and MAD.Month = Month(@From_Date) and MAD.Year = Year(@From_Date) and MAD.AD_ID = @AD_ID
							WHERE	E.Cmp_ID = @Cmp_Id
						END
					ELSE
						BEGIN
							
							IF (@Mode = 'DROPDOWN')
								BEGIN
									SELECT	e.Emp_ID, CASE @Emp_Search 
												WHEN 0
													THEN CAST( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
												WHEN 1
													THEN  CAST( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
												WHEN 2
													THEN  CAST( E.Alpha_Emp_Code as varchar)
												WHEN 3
													THEN  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
												WHEN 4	
													THEN  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
											END AS Emp_Full_Name,
											I_Q.Branch_ID,I_Q.Desig_Id,I_Q.Dept_ID, e.Emp_Left_Date
											,E.Emp_Left  --Added By Jimit 07042018											
											,I_Q.Grd_ID,I_Q.Cat_ID,I_Q.Segment_ID,I_Q.subBranch_ID,I_Q.SubVertical_ID,I_Q.Vertical_ID --Added By Jimit 05032019 as require filter based on this masters 
									FROM	T0080_EMP_MASTER E 	WITH (NOLOCK)																			
											INNER JOIN #Emp_Cons EC on ec.Emp_ID = e.Emp_ID   
											INNER JOIN T0095_Increment I_Q WITH (NOLOCK) ON I_Q.Increment_ID=EC.Increment_ID
									WHERE	E.Cmp_ID = @Cmp_Id   --And E.Emp_ID in (select Emp_ID From #Emp_Cons) 	
										 		  
									ORDER BY	(Case @Emp_Search 
													When 3 Then
														e.Emp_First_Name
													When 4 Then
														e.Emp_First_Name
													Else
														Case 
															When IsNumeric(e.Alpha_Emp_Code) = 1 then 
																Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
															When IsNumeric(e.Alpha_Emp_Code) = 0 then 
																Left(e.Alpha_Emp_Code + Replicate('',21), 20)
															Else 
																e.Alpha_Emp_Code
														End								
												End)
								END 
							ELSE
								BEGIN
									
									Select I_Q.* ,E.Emp_Code, E.Alpha_Code,
											--case @Emp_Search 
											--	when 0
											--		then cast( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
											--	when 1
											--		then  cast( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											--	when 2
											--		then  cast( E.Alpha_Emp_Code as varchar)
											--	when 3
											--		then  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
											--	when 4	
											--		then  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
											--end as Emp_Full_Name
											CAST('' AS VARCHAR(256)) Emp_Full_Name
											,Lo.Login_ID,E.Emp_Full_Name as Emp_Full_Name_only,Emp_superior      
											,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Emp_Left_Date,Gender      
											,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left,E.Alpha_Emp_Code ,E.Emp_First_Name as Emp_First_Name
											,e.Date_of_Retirement,Cat_Name
									INTO	#RecordSet
									FROM	T0080_EMP_MASTER E WITH (NOLOCK)
											INNER JOIN #Emp_Cons EC on ec.Emp_ID = e.Emp_ID     
											INNER JOIN T0010_company_master Cm WITH (NOLOCK) ON E.Cmp_ID = Cm.Cmp_ID 											
											INNER JOIN ( 
														SELECT	I.Emp_Id , Grd_ID,I.Branch_ID,Cat_ID,Desig_ID,I.Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID,subBranch_ID ,I.Segment_ID,I.CTC
														FROM	T0095_Increment I WITH (NOLOCK)
																INNER JOIN #Emp_Cons IEC on I.Increment_ID = IEC.Increment_ID
														) I_Q ON I_Q.Emp_ID = E.Emp_ID 
											INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
											INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
											INNER JOIN T0011_Login LO WITH (NOLOCK)  ON LO.Emp_Id = E.Emp_Id 			
											LEFT OUTER JOIN T0100_LEFT_EMP EL WITH (NOLOCK) ON E.Emp_Id=EL.Emp_Id 								
											LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
											LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
											LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
											LEFT OUTER JOIN T0030_CATEGORY_MASTER CGM WITH (NOLOCK) ON I_Q.Cat_ID = CGM.Cat_ID
									WHERE	E.Cmp_ID = @Cmp_Id   --And E.Emp_ID in (select Emp_ID From #Emp_Cons) 	
												
									--GROUP BY	I_Q.Emp_Id,I_Q.Grd_ID,I_Q.Branch_ID,I_Q.Cat_ID,I_Q.Desig_ID,I_Q.Dept_ID,I_Q.Type_ID,I_Q.Vertical_ID,I_Q.SubVertical_ID,I_Q.subBranch_ID,I_Q.Segment_ID,
									--			Emp_Code,Alpha_Emp_Code,Emp_First_Name,Emp_Full_Name
									--			,Lo.Login_ID,Emp_superior,Emp_Second_Name,Emp_Last_Name,Initial      
									--			,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Emp_Left_Date,Gender      
									--			,Comp_Name,Branch_Address,Cmp_Name,Cmp_address,Emp_Left	,Date_of_Retirement		 		  
									ORDER BY	(Case @Emp_Search 
													When 3 Then
														e.Emp_First_Name
													When 4 Then
														e.Emp_First_Name
													Else
														e.Alpha_Code
														--Case 
														--	When IsNumeric(e.Alpha_Emp_Code) = 1 then 
														--		Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
														--	When IsNumeric(e.Alpha_Emp_Code) = 0 then 
														--		Left(e.Alpha_Emp_Code + Replicate('',21), 20)
														--	Else 
														--		e.Alpha_Emp_Code
														--End								
												End),e.Emp_code
							
							
								IF @Emp_Search = 0
									UPDATE	RS								
									SET		Emp_Full_Name = cast( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
									FROM	#RecordSet RS 
											INNER JOIN T0080_EMP_MASTER E ON RS.Emp_ID=E.Emp_ID
								ELSE IF @Emp_Search = 1
									UPDATE	RS								
									SET		Emp_Full_Name = cast( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
									FROM	#RecordSet RS 
											INNER JOIN T0080_EMP_MASTER E ON RS.Emp_ID=E.Emp_ID
								ELSE IF @Emp_Search = 2
									UPDATE	RS								
									SET		Emp_Full_Name = cast( E.Alpha_Emp_Code as varchar)
									FROM	#RecordSet RS 
											INNER JOIN T0080_EMP_MASTER E ON RS.Emp_ID=E.Emp_ID
								ELSE IF @Emp_Search = 3
									UPDATE	RS								
									SET		Emp_Full_Name = e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
									FROM	#RecordSet RS 
											INNER JOIN T0080_EMP_MASTER E ON RS.Emp_ID=E.Emp_ID
								ELSE IF @Emp_Search = 4
									UPDATE	RS								
									SET		Emp_Full_Name = e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
									FROM	#RecordSet RS 
											INNER JOIN T0080_EMP_MASTER E ON RS.Emp_ID=E.Emp_ID

								SELECT * FROM #RecordSet
								ORDER BY	(Case @Emp_Search 
													When 3 Then
														Emp_First_Name
													When 4 Then
														Emp_First_Name
													Else
														Alpha_Code
														--Case 
														--	When IsNumeric(e.Alpha_Emp_Code) = 1 then 
														--		Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
														--	When IsNumeric(e.Alpha_Emp_Code) = 0 then 
														--		Left(e.Alpha_Emp_Code + Replicate('',21), 20)
														--	Else 
														--		e.Alpha_Emp_Code
														--End								
												End),Emp_code
							END
					End
			
		END	
			
   
		   
 RETURN