
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_Warning_Get1_29092021]
	 @Cmp_ID			numeric
	,@From_Date			datetime
	,@To_Date			datetime 
	,@Branch_ID			VARCHAR(MAX) = ''
	,@Cat_ID			VARCHAR(MAX) = ''
	,@Grd_ID			VARCHAR(MAX) = ''
	,@Type_ID			numeric  = 0
	,@Dept_ID			VARCHAR(MAX) = ''
	,@Desig_ID			VARCHAR(MAX) = ''
	,@Emp_ID			numeric  = 0
	,@Vertical_ID		VARCHAR(MAX) = ''
	,@SubVertical_ID	VARCHAR(MAX) = ''	
	,@Shift_Id			numeric  = 0
	,@Constraint		varchar(max) = ''
	,@SubBranch_ID	VARCHAR(MAX) = ''	
	,@Segment_ID	VARCHAR(MAX) = ''	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	SET @From_Date = @To_Date;

	--if @Branch_ID = 0
	--	set @Branch_ID = null
	--if @Cat_ID = 0
	--	set @Cat_ID = null
		 
	--if @Type_ID = 0
	--	set @Type_ID = null
	--if @Dept_ID = 0
	--	set @Dept_ID = null
	--if @Grd_ID = 0
	--	set @Grd_ID = null
	--if @Emp_ID = 0
	--	set @Emp_ID = null
		
	--If @Desig_ID = 0
	--	set @Desig_ID = null
		
	--if @Vertical_ID = 0
	--	set @Vertical_ID = null
	
	--if @SubVertical_ID = 0
	--	set @SubVertical_ID = null
	
	if @Shift_Id = 0
		set @Shift_Id = null
	
	 CREATE table #Emp_Cons 
	 (      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	 )            
       
    exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_ID,@Vertical_Id,@SubVertical_Id,@SubBranch_ID,0,0,0,'0',0,0               

 --if @Constraint <> ''        
	--  begin        
	--	   Insert Into #Emp_Cons(Emp_ID)        
	--	   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')         
	--  end        
 --else        
	--	begin        
          
	--	Insert Into #Emp_Cons      
	--	  select distinct emp_id,branch_id,Increment_ID from dbo.V_Emp_Cons where 
	--	  cmp_id=@Cmp_ID 
	--	   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
	--   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
	--   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
	--   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	--   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
	--   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
	--   and Emp_ID = isnull(@Emp_ID ,Emp_ID)
	--   and Isnull(Vertical_ID,0) = isnull(@Vertical_ID ,Isnull(Vertical_ID,0))				--Added by Ramiz on 24072015
	--   and Isnull(SubVertical_ID,0) = isnull(@SubVertical_ID ,Isnull(SubVertical_ID,0))		--Added by Ramiz on 24072015
	--   and Increment_Effective_Date <= @To_Date 
	--		  and 
	--				  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
	--					or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
	--					or (Left_date is null and @To_Date >= Join_Date)      
	--					or (@To_Date >= left_date  and  @From_Date <= left_date )) 
	--					order by Emp_ID
					
	--	delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from dbo.T0095_Increment
	--		where  Increment_effective_Date <= @to_date
	--		group by emp_ID)
	--End
		
		SELECT	I_Q.* , cast( E.Alpha_Emp_Code as varchar) + ' - '+E.Emp_Full_Name as Emp_Full_Name,Shift_Name,E.Shift_id,  -- Change only Emp_code instead of Alfha Emp Code 02 - july -2013
					Emp_code,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender,Emp_Superior --,I_Q.Vertical_ID,I_Q.SubVertical_ID -- Changed BY Gadriwala 21102013
					,E.Alpha_Emp_Code,E.Emp_Full_Name As Emp_Full_Name_Only
		INTO	#Warning --Added by Nimesh 21 May, 2015
		FROM	T0080_EMP_MASTER E WITH (NOLOCK) inner join T0010_Company_Master CM WITH (NOLOCK) on Cm.Cmp_Id =E.Cmp_ID INNER JOIN 
				( 
					SELECT	I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,[Type_ID],Vertical_ID,SubVertical_ID 
					FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN  -- Changed BY Gadriwala 21102013
						(
							SELECT	MAX(Increment_ID) AS Increment_ID , Emp_ID 
							FROM	T0095_Increment WITH (NOLOCK)
							WHERE	Increment_Effective_date <= @To_Date
									AND Cmp_ID = @Cmp_ID
							GROUP BY emp_ID  
						) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID
				) I_Q ON E.Emp_ID = I_Q.Emp_ID  INNER JOIN
				T0040_GRADE_MASTER GM WITH (NOLOCK)  ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
				T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
				T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
				T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
				T0040_Shift_Master SM WITH (NOLOCK) on E.Shift_ID = SM.Shift_ID inner join
				( 
					SELECT dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,@Emp_ID,@From_Date)  as ShitId
				) f on F.ShitId = SM.Shift_ID inner join
				T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
		WHERE	E.Cmp_ID = @Cmp_Id	
				AND E.Emp_ID IN (
					SELECT Emp_ID FROM #emp_cons
								)
		ORDER BY E.Emp_Code ASC
		
		
		--Add by Nimesh 29 April, 2015
		--This sp retrieves the Shift Rotation as per given employee id and effective date.
		--it will fetch all employee's shift rotation detail if employee id is not specified.
		IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
			Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
		--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure			
		Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @Constraint

		DECLARE @For_Date DateTime;
		SET @For_Date = @To_Date
		
		--WHILE (@For_Date <= @To_Date) BEGIN
			--Updating Shift ID From Rotation
			UPDATE	#Warning 
			SET		Shift_ID=R.R_ShiftID, Shift_Name=SM.Shift_Name
			FROM	#Rotation R INNER JOIN T0040_SHIFT_MASTER SM ON R.R_ShiftID=SM.Shift_ID					
			WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @For_Date) As Varchar) AND
					Emp_Id=R.R_EmpID AND R.R_Effective_Date=(SELECT MAX(R_Effective_Date)
						FROM #Rotation R1 WHERE R1.R_EmpID=Emp_Id AND 
							 R_Effective_Date<=@For_Date) 
					--AND For_date=@For_Date

			--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=0
			--And Rotation should be assigned to that particular employee
			UPDATE	#Warning 
			SET		Shift_ID=ESD.Shift_ID, Shift_Name=SM.Shift_Name
			FROM	(#Warning D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
					FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @For_Date) ESD ON
					D.Emp_Id=ESD.Emp_ID AND ESD.For_Date=@For_Date) INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON ESD.Shift_ID=SM.Shift_ID AND SM.Cmp_ID=@Cmp_ID
			WHERE	ESD.Emp_ID IN (Select R.R_EmpID FROM #Rotation R
						WHERE R_DayName = 'Day' + CAST(DATEPART(d, @For_Date) As Varchar) AND R_Effective_Date<=@For_Date
						GROUP BY R.R_EmpID) --AND D.For_date=@For_Date
									

			--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=1 
			--And Rotation should not be assigned to that particular employee
			UPDATE	#Warning 
			SET		Shift_ID=ESD.Shift_ID, Shift_Name=SM.Shift_Name
			FROM	(#Warning D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
					FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @For_Date) ESD ON
					D.Emp_Id=ESD.Emp_ID AND ESD.For_Date=@For_Date) INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON ESD.Shift_ID=SM.Shift_ID AND SM.Cmp_ID=@Cmp_ID
			WHERE	IsNull(ESD.Shift_Type,0)=1 AND ESD.Emp_ID NOT IN (Select R.R_EmpID FROM #Rotation R
						WHERE R_DayName = 'Day' + CAST(DATEPART(d, @For_Date) As Varchar) AND R_Effective_Date<=@For_Date
						GROUP BY R.R_EmpID) --AND D.For_date=@For_Date
			
			--SET @For_Date = DATEADD(d,1,@For_Date);			
		--END
			
		
		SELECT	* 
		FROM	#Warning
		WHERE	ISNULL(Shift_id,0) = ISNULL(@shift_id , Isnull(Shift_id , 0))					--Added by Ramiz on 27072015
		
	RETURN




