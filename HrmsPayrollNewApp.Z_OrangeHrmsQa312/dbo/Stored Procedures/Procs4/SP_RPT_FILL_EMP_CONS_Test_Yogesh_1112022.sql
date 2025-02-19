

-- =============================================
-- Author:		<Ankit>
-- ALTER date: <27082014,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [DBO].[SP_RPT_FILL_EMP_CONS_Test_Yogesh_1112022]          
  @Cmp_ID			numeric          
 ,@From_Date		datetime          
 ,@To_Date			datetime          
 ,@Branch_ID		numeric          
 ,@Cat_ID			numeric           
 ,@Grd_ID			numeric          
 ,@Type_ID			numeric          
 ,@Dept_ID			numeric          
 ,@Desig_ID			numeric          
 ,@Emp_ID			numeric          
 ,@constraint		varchar(MAX)          
 ,@Sal_Type			numeric = 0      
 ,@Salary_Cycle_id	numeric = 0    
 ,@Segment_Id		numeric = 0   
 ,@Vertical_Id		numeric = 0   
 ,@SubVertical_Id	numeric = 0 
 ,@SubBranch_Id		numeric = 0   
 ,@New_Join_emp		Numeric = 0 
 ,@Left_Emp			Numeric = 0
 ,@SalScyle_Flag	Numeric = 0	 
 ,@PBranch_ID		varchar(MAX) = '0'
 ,@With_Ctc			Numeric = 0
 ,@Type				numeric = 0
AS 
         
SET NOCOUNT ON	
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
   


IF @Branch_ID = 0            
  SET @Branch_ID = Null          
      
IF @Cat_ID = 0            
  SET @Cat_ID = null          
       
IF @Grd_ID = 0            
  SET @Grd_ID = null          
       
IF @Type_ID = 0            
  SET @Type_ID = null          
       
IF @Dept_ID = 0            
  SET @Dept_ID = null          
       
IF @Desig_ID = 0            
  SET @Desig_ID = null          
       
IF @Emp_ID = 0            
  SET @Emp_ID = null          
      
IF @Segment_Id = 0     
  SET @Segment_Id = null    
  
IF @Vertical_Id= 0     
  SET @Vertical_Id = null    
  
IF @SubVertical_Id = 0     
  SET @SubVertical_Id= Null    
  
IF @SubBranch_Id = 0  
  SET @SubBranch_Id = null    
 
IF @Salary_Cycle_id = 0  
	SET @Salary_Cycle_id = null    	

	
	IF @Constraint <> ''
		BEGIN				
			INSERT INTO #Emp_Cons 
			SELECT  EMP_ID, 0,0
			FROM	(Select Cast(Data As Numeric) As Emp_ID FROM dbo.Split(@Constraint,'#') T Where T.Data <> '') E
			
			UPDATE  E 
			SET		Branch_ID = I.Branch_ID, Increment_ID=I.Increment_ID
			FROM	#Emp_Cons E						
					INNER JOIN (SELECT	I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID
								FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN #Emp_Cons E1 ON I1.Emp_ID=E1.EMP_ID
										INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
													FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN #Emp_Cons E2 ON I2.Emp_ID=E2.EMP_ID
															INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																		FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.EMP_ID
																		WHERE	I3.Increment_Effective_Date <= @To_Date
																		GROUP BY I3.Emp_ID
																		) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
													WHERE	I2.Cmp_ID = IsNull(@Cmp_Id , I2.Cmp_ID)
													GROUP BY I2.Emp_ID
													) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
								WHERE	I1.Cmp_ID=IsNull(@Cmp_Id , I1.Cmp_ID)											
							) I ON E.EMP_ID=I.Emp_ID								
		END
	ELSE IF @New_Join_emp = 1 
		BEGIN
			INSERT INTO #Emp_Cons      
			SELECT DISTINCT VE.emp_id,branch_id,VE.Increment_ID
			FROM V_Emp_Cons VE WITH (NOLOCK)
				INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
					LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
									FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
														WHERE Effective_date <= @To_Date
														GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								) AS QrySC ON QrySC.eid = VE.Emp_ID
			WHERE VE.Cmp_ID=IsNull(@Cmp_Id , VE.Cmp_ID) 
				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
				AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))     
				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 
				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 
				and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) 
				and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
				and VE.Emp_ID = isnull(@Emp_ID ,VE.Emp_ID)  
				and Increment_Effective_Date <= @To_Date 
				and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
			ORDER BY Emp_ID
						
			--DELETE FROM #Emp_Cons WHERE Increment_ID Not In
			--	(SELECT TI.Increment_ID FROM t0095_increment TI inner join
			--		(SELECT Max(Increment_ID) AS Increment_ID,Emp_ID FROM T0095_Increment
			--			WHERE Increment_effective_Date <= @to_date GROUP BY emp_ID) new_inc
			--	ON TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
			--	WHERE Increment_effective_Date <= @to_date)
			Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
				(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
			Where Qry.Increment_ID is null
			
		END	
	ELSE IF @Left_Emp = 1 
		BEGIN
			INSERT INTO #Emp_Cons      
			SELECT DISTINCT VE.Emp_ID,branch_id,VE.Increment_ID 
			FROM V_Emp_Cons VE WITH (NOLOCK)
					INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
					LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
									FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) 
														WHERE Effective_date <= @To_Date
														GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								) AS QrySC ON QrySC.eid = VE.Emp_ID
			WHERE VE.Cmp_ID=IsNull(@Cmp_Id , VE.Cmp_ID) 
				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
				AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))     
				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	
				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	
				and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))
				and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
				and VE.Emp_ID = isnull(@Emp_ID ,VE.Emp_ID)  
				and Increment_Effective_Date <= @To_Date 
				and Left_date >=@From_Date and Left_Date <=@to_Date
			ORDER BY Emp_ID
						
			Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
				(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
			Where Qry.Increment_ID is null
		END	
	ELSE IF @SalScyle_Flag = 1	-- Use SP : Set_Salary_Register_Amount
		BEGIN
			INSERT INTO #Emp_Cons 
			SELECT I.Emp_Id,I.Branch_ID,I.Increment_ID 
			FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
					( SELECT max(Increment_ID) as Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
						WHERE Increment_Effective_date <= @To_Date
						and Cmp_ID = IsNull(@Cmp_Id , Cmp_ID)
						GROUP BY emp_ID  ) Qry ON
						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID
						  LEFT OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
						  INNER JOIN (SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date <= @To_Date
									GROUP BY emp_id) Qry on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
				   ON QrySC.eid = Qry.Emp_ID
			WHERE Cmp_ID = IsNull(@Cmp_Id , Cmp_ID) 
				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
				and Branch_ID = isnull(@Branch_ID ,Branch_ID)
				and Grd_ID = isnull(@Grd_ID ,Grd_ID)
				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 
				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))
				and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))
				and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0))
	   			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
				and I.Emp_ID IN 
					( select Emp_Id from
						(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
						where cmp_ID = IsNull(@Cmp_Id , Cmp_ID)   and  
						(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )
						or Left_date is null and @To_Date >= Join_Date)
						or @To_Date >= left_date  and  @From_Date <= left_date )
		END
	ELSE IF @SalScyle_Flag = 2	-- Use SP : Set_Salary_Wages_Register_Amount_With_Late,Set_Salary_Register_Amount_NIIT
		BEGIN
			IF @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0  -- added by mitesh on 02042012
				BEGIN
				
					INSERT INTO #Emp_Cons
					select I.Emp_Id, I.Branch_ID,I.Increment_ID  from dbo.T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = IsNull(@Cmp_Id , Cmp_ID)
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
					Where Cmp_ID = IsNull(@Cmp_Id , Cmp_ID) 
						and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
						and Grd_ID = isnull(@Grd_ID ,Grd_ID)
						and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
						and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
						and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
						and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
						and Branch_ID in (select cast(data as numeric) from dbo.Split(@PBranch_ID,'#'))
						and I.Emp_ID in 
						( select Emp_Id from
						(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
						where cmp_ID = IsNull(@Cmp_Id , Cmp_ID)   and  
						(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )
						or Left_date is null and @To_Date >= Join_Date)
						or @To_Date >= left_date  and  @From_Date <= left_date ) 
				END
			ELSE
				BEGIN
					INSERT INTO #Emp_Cons
					SELECT I.Emp_Id,I.Branch_ID,I.Increment_ID from dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN 
							( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = IsNull(@Cmp_Id , Cmp_ID)
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID
					WHERE Cmp_ID = IsNull(@Cmp_Id , Cmp_ID) 
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
						where cmp_ID = IsNull(@Cmp_Id , Cmp_ID)   and  
						(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )
						or Left_date is null and @To_Date >= Join_Date)
						or @To_Date >= left_date  and  @From_Date <= left_date ) 
				END
		END
	ELSE IF @With_Ctc = 1		-- Use SP : SP_RPT_YEARLY_SALARY_GET
		BEGIN
				INSERT INTO #Emp_Cons
				SELECT DISTINCT V.emp_id,branch_id,V.Increment_ID FROM V_Emp_Cons V  WITH (NOLOCK)
					INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = V.Emp_ID 
					LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
									FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
														WHERE Effective_date <= @To_Date
														GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								) AS QrySC ON QrySC.eid = V.Emp_ID
				WHERE 
				   V.cmp_id=IsNull(@Cmp_Id , V.Cmp_ID) 		
				   AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))          
				   AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)      
				   AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)      
				   AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))      
				   AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))      
				   AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
				   AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))     
				   And ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,IsNull(Segment_ID,0))
				   And ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,IsNull(Vertical_ID,0))
				   And ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_Id,IsNull(SubVertical_ID,0))
				   And ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,IsNull(subBranch_ID,0)) 
				   and ms.month_end_date >= @from_date and ms.month_end_date <= @to_date
				   and ms.Is_FNF = 0
				   AND V.Emp_Id = ISNULL(@Emp_Id,V.Emp_Id) 
				   AND Increment_Effective_Date <= @To_Date 
				   AND ( (@From_Date  >= join_Date  AND  @From_Date <= left_date )      
						OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )      
						OR (Left_date IS NULL AND @To_Date >= Join_Date)      
						OR (@To_Date >= left_date  AND  @From_Date <= left_date )
						OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
						)
			 
				ORDER BY Emp_ID

				--DELETE  FROM #Emp_Cons WHERE Increment_ID NOT IN (SELECT MAX(Increment_ID) FROM T0095_Increment
				--	WHERE  Increment_effective_Date <= @to_date
				--	GROUP BY emp_ID )
			Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
				(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
			Where Qry.Increment_ID is null
				
		END
	ELSE IF @SalScyle_Flag = 3	--Use Sp : SP_RPT_EMP_ATTENDANCE_MUSTER_GET
		BEGIN
			IF @Type = 0 -- All Employee
				BEGIN
					 INSERT INTO #Emp_Cons  
					 SELECT DISTINCT emp_id,branch_id,Increment_ID 
					 FROM V_Emp_Cons WITH (NOLOCK)
							LEFT OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
							INNER JOIN (SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle  WITH (NOLOCK)
										WHERE Effective_date <= @To_Date GROUP BY emp_id) Qry
									ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
								ON QrySC.eid = V_Emp_Cons.Emp_ID
					 WHERE cmp_id=IsNull(@Cmp_Id , Cmp_ID) 
						   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
						   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
						   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
						   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
						   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
						   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
						   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
						   and Increment_Effective_Date <= @To_Date 
						   and 
							( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
							or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
							or (Left_date is null and @To_Date >= Join_Date)      
							--or (@To_Date >= left_date  and  @From_Date <= left_date )
							--OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date )) then 1 else 0 end)
							)
					 ORDER BY Emp_ID
								

					Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
						(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
					Where Qry.Increment_ID is null

				
			END
			ELSE IF @Type = 1 -- Active Employee
				BEGIN
					 INSERT INTO #Emp_Cons  
					 SELECT DISTINCT emp_id,branch_id,Increment_ID FROM V_Emp_Cons WITH (NOLOCK)
							LEFT OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
							INNER JOIN (SELECT max(Effective_date) as Effective_date,emp_id 
										FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date <= @To_Date GROUP BY emp_id) Qry
								ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
							ON QrySC.eid = V_Emp_Cons.Emp_ID
					  WHERE cmp_id=IsNull(@Cmp_Id , Cmp_ID) 
						   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
						   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
						   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
						   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
						   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
						   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 				   
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
					  ORDER BY Emp_ID
									

					Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
						(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
					Where Qry.Increment_ID is null
				
				END
			ELSE IF @Type = 2 -- InActive Employee
				BEGIN
					INSERT INTO #Emp_Cons  
					SELECT DISTINCT emp_id,branch_id,Increment_ID from V_Emp_Cons WITH (NOLOCK)
							LEFT OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
							INNER JOIN (SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle  WITH (NOLOCK)
										WHERE Effective_date <= @To_Date GROUP BY emp_id) Qry
								on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
						ON QrySC.eid = V_Emp_Cons.Emp_ID
					 WHERE cmp_id=IsNull(@Cmp_Id , Cmp_ID) 
						   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
						   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
						   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
						   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
						   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
						   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
						   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
						   and Increment_Effective_Date <= @To_Date 
						   and (V_Emp_Cons.Emp_Left = 'Y' Or V_Emp_Cons.Emp_Left = 'y')					  
						   and (--(@From_Date  >= join_Date  and  @From_Date <= left_date )      
							--or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
							--or (Left_date is null and @To_Date >= Join_Date)      
							(@To_Date >= left_date  and  @From_Date <= left_date )
							--OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date )) then 1 else 0 end))
							)
					 ORDER BY Emp_ID
									

					Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
						(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
					Where Qry.Increment_ID is null
				
				END
		END
	ELSE IF @SalScyle_Flag = 4	--Use Sp : SP_RPT_Form_ER_1
		BEGIN
			IF @New_Join_emp = 1
				BEGIN
					IF @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
						BEGIN
							INSERT INTO #Emp_Cons      
							SELECT DISTINCT VE.emp_id,branch_id,VE.Increment_ID 
							FROM V_Emp_Cons VE 
								INNER JOIN dbo.T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Emp_ID = VE.Emp_ID 
									LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
													FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
														INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
																		FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
																		WHERE Effective_date <= @To_Date
																		GROUP BY emp_id
																	) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
												) AS QrySC ON QrySC.eid = VE.Emp_ID
							WHERE VE.Cmp_ID=IsNull(@Cmp_Id , VE.Cmp_ID) 
								and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
								and Branch_ID in (select cast(data as numeric) from dbo.Split(@PBranch_ID,'#'))      
								and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
								and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
								and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
								and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
								AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))     
								and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 
								and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 
								and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) 
								and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
								and VE.Emp_ID = isnull(@Emp_ID ,VE.Emp_ID)  
								and Increment_Effective_Date <= @To_Date 
								and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
							ORDER BY Emp_ID
										
							Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
							Where Qry.Increment_ID is null
						
						END
					ELSE
						BEGIN
							INSERT INTO #Emp_Cons      
							SELECT DISTINCT VE.emp_id,branch_id,VE.Increment_ID 
							FROM V_Emp_Cons VE WITH (NOLOCK)
								INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
									LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
													FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
														INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
																		FROM T0095_Emp_Salary_Cycle  WITH (NOLOCK)
																		WHERE Effective_date <= @To_Date
																		GROUP BY emp_id
																	) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
												) AS QrySC ON QrySC.eid = VE.Emp_ID
							WHERE VE.Cmp_ID=IsNull(@Cmp_Id , VE.Cmp_ID) 
								and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
								and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
								and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
								and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
								and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
								and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
								AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))     
								and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 
								and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 
								and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) 
								and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
								and VE.Emp_ID = isnull(@Emp_ID ,VE.Emp_ID)  
								and Increment_Effective_Date <= @To_Date 
								and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
							ORDER BY Emp_ID
										
							Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
							Where Qry.Increment_ID is null
						END
				END		
			ELSE IF @Left_Emp = 1
				BEGIN
					IF @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
						BEGIN
							INSERT INTO #Emp_Cons      
							SELECT DISTINCT VE.Emp_ID,branch_id,VE.Increment_ID 
							FROM V_Emp_Cons VE WITH (NOLOCK)
									INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
									LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
													FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
														INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
																		FROM T0095_Emp_Salary_Cycle  WITH (NOLOCK)
																		WHERE Effective_date <= @To_Date
																		GROUP BY emp_id
																	) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
												) AS QrySC ON QrySC.eid = VE.Emp_ID
							WHERE VE.Cmp_ID=IsNull(@Cmp_Id , VE.Cmp_ID) 
								and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
								and Branch_ID in (select cast(data as numeric) from dbo.Split(@PBranch_ID,'#'))
								and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
								and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
								and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
								and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
								AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))     
								and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	
								and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	
								and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))
								and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
								and VE.Emp_ID = isnull(@Emp_ID ,VE.Emp_ID)  
								and Increment_Effective_Date <= @To_Date 
								and Left_date >=@From_Date and Left_Date <=@to_Date
							ORDER BY Emp_ID
										
							Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
							Where Qry.Increment_ID is null
						
						END
					ELSE
						BEGIN
							INSERT INTO #Emp_Cons      
							SELECT DISTINCT VE.Emp_ID,branch_id,VE.Increment_ID 
							FROM V_Emp_Cons VE WITH (NOLOCK)
									INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
									LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
													FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
														INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
																		FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
																		WHERE Effective_date <= @To_Date
																		GROUP BY emp_id
																	) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
												) AS QrySC ON QrySC.eid = VE.Emp_ID
							WHERE VE.Cmp_ID=IsNull(@Cmp_Id , VE.Cmp_ID) 
								and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
								and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
								and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
								and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
								and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
								and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
								AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))     
								and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	
								and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	
								and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))
								and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
								and VE.Emp_ID = isnull(@Emp_ID ,VE.Emp_ID)  
								and Increment_Effective_Date <= @To_Date 
								and Left_date >=@From_Date and Left_Date <=@to_Date
							ORDER BY Emp_ID
										
							Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
							Where Qry.Increment_ID is null
						
						END
				END
			ELSE 
				BEGIN
				
					  INSERT INTO #Emp_Cons 	
					  SELECT DISTINCT VE.Emp_ID,branch_id,VE.Increment_ID 
					  FROM dbo.V_Emp_Cons VE WITH (NOLOCK)
					  WHERE Cmp_id=IsNull(@Cmp_Id , Cmp_ID) 
						   AND Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
						   AND Branch_ID = isnull(@Branch_ID ,Branch_ID)      
						   AND Grd_ID = isnull(@Grd_ID ,Grd_ID)      
						   AND isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
						   AND Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
						   AND Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
						   AND ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	
						   AND ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 
						   AND ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) 
						   AND ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
						   AND VE.Emp_ID = isnull(@Emp_ID ,VE.Emp_ID)   
						   AND Increment_Effective_Date <= @To_Date 
						   AND ( (@From_Date  >= join_Date  AND  @From_Date <= left_date )      
									or ( @To_Date  >= join_Date  AND @To_Date <= left_date )      
									or (Left_date is null AND @To_Date >= Join_Date)      
									or (@To_Date >= left_date  AND  @From_Date <= left_date )) 
					ORDER BY Emp_ID
								
					
					Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
						(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK)inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
					Where Qry.Increment_ID is null
				End		
		END
	ELSE 
		BEGIN
			IF @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0	
				BEGIN
						
					INSERT	INTO #Emp_Cons(Emp_ID,Branch_ID,Increment_ID)
					SELECT	I.Emp_ID,I.Branch_ID,I.Increment_ID 
					FROM	T0095_INCREMENT I WITH (NOLOCK)
							INNER JOIN T0080_EMP_MASTER EM ON I.EMP_ID=EM.EMP_ID
							INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
										FROM	T0095_INCREMENT I1 WITH (NOLOCK)
												INNER JOIN (SELECT	Emp_ID, Max(Increment_Effective_Date) As Increment_Effective_Date
															FROM	T0095_INCREMENT I2 WITH (NOLOCK)
															WHERE	I2.Increment_Effective_Date	 <= @To_Date
															GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID and I1.Increment_Effective_Date=I2.Increment_Effective_Date
										GROUP BY I1.Emp_ID) I1 ON I.Increment_ID=I1.Increment_ID
					WHERE	EM.Cmp_id=IsNull(@Cmp_Id , EM.Cmp_ID) 
							AND Isnull(I.Cat_ID,0) = Isnull(@Cat_ID ,Isnull(I.Cat_ID,0))      
							and I.Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))							   
							AND I.Grd_ID = isnull(@Grd_ID ,I.Grd_ID)      
							AND isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0))      
							AND Isnull(I.Type_ID,0) = isnull(@Type_ID ,Isnull(I.Type_ID,0))      
							AND Isnull(I.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I.Desig_ID,0))
							AND ISNULL(I.Segment_ID,0) = ISNULL(@Segment_Id,Isnull(I.Segment_ID,0))	
							AND ISNULL(I.Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(I.Vertical_ID,0))	 
							AND ISNULL(I.SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(I.SubVertical_ID,0)) 
							AND ISNULL(I.subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(I.subBranch_ID,0)) 
							AND EM.Emp_ID = isnull(@Emp_ID ,EM.Emp_ID)   
							AND I.Increment_Effective_Date <= @To_Date 
							AND ( (@From_Date  >= Date_Of_Join  AND  @From_Date <= Emp_Left_Date )      
									or ( @To_Date  >= Date_Of_Join  AND @To_Date <= Emp_Left_Date )      
									or (Emp_Left_Date is null AND @To_Date >= Date_Of_Join)      
									or (@To_Date >= Emp_Left_Date  AND  @From_Date <= Emp_Left_Date )
								) 
					ORDER BY I.Emp_ID
				END
			ELSE						
				BEGIN
					INSERT	INTO #Emp_Cons(Emp_ID,Branch_ID,Increment_ID)
					SELECT	I.Emp_ID,I.Branch_ID,I.Increment_ID 
					FROM	T0095_INCREMENT I WITH (NOLOCK)
							INNER JOIN T0080_EMP_MASTER EM ON I.EMP_ID=EM.EMP_ID 
							INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
										FROM	T0095_INCREMENT I1 WITH (NOLOCK)
												INNER JOIN (SELECT	Emp_ID, Max(Increment_Effective_Date) As Increment_Effective_Date
															FROM	T0095_INCREMENT I2 WITH (NOLOCK)
															WHERE	I2.Increment_Effective_Date	 <= @To_Date AND CMP_ID=@CMP_ID
															GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID and I1.Increment_Effective_Date=I2.Increment_Effective_Date
										GROUP BY I1.Emp_ID) I1 ON I.Increment_ID=I1.Increment_ID AND I.Emp_ID=I1.Emp_ID
					WHERE	I.Cmp_id=IsNull(@Cmp_Id , I.Cmp_ID) 
							AND Isnull(I.Cat_ID,0) = Isnull(@Cat_ID ,Isnull(I.Cat_ID,0))      
							AND I.Branch_ID = isnull(@Branch_ID,I.Branch_ID)      
							AND I.Grd_ID = isnull(@Grd_ID ,I.Grd_ID)      
							AND isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0))      
							AND Isnull(I.Type_ID,0) = isnull(@Type_ID ,Isnull(I.Type_ID,0))      
							AND Isnull(I.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I.Desig_ID,0))
							AND ISNULL(I.Segment_ID,0) = ISNULL(@Segment_Id,Isnull(I.Segment_ID,0))	
							AND ISNULL(I.Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(I.Vertical_ID,0))	 
							AND ISNULL(I.SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(I.SubVertical_ID,0)) 
							AND ISNULL(I.subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(I.subBranch_ID,0)) 
							AND I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)   
							AND I.Increment_Effective_Date <= @To_Date 
							--AND Date_Of_Join <= @To_Date
							--AND (Emp_Left_Date >= @From_Date or Emp_Left_Date is null)
							
							--AND ( (@From_Date  >= Date_Of_Join  AND  @From_Date <= Emp_Left_Date )      
							--		or ( @To_Date  >= Date_Of_Join  AND @To_Date <= Emp_Left_Date )      
							--		or (Emp_Left_Date is null AND @To_Date >= Date_Of_Join)      
							--		or (@To_Date >= Emp_Left_Date  AND  @From_Date <= Emp_Left_Date )
							--	) 
					--ORDER BY I.Emp_ID
										
					DELETE	EC
					FROM	#EMP_CONS EC
							LEFT OUTER JOIN T0080_EMP_MASTER E ON EC.EMP_ID=E.EMP_ID AND Date_Of_Join <= @To_Date
							AND (Emp_Left_Date >= @From_Date or Emp_Left_Date is null)
					WHERE	E.EMP_ID IS NULL	
				End

		End	
		
		
		

