
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_T0100_WEEKOFF_ADJ_GET]
	 @Cmp_ID 		numeric
	,@For_Date		datetime
	,@Branch_ID		numeric
	,@Grd_ID 		numeric
	,@Emp_ID 		numeric
	,@Cat_Id		Numeric = 0
	,@Dept_Id		numeric = 0
	,@Desig_Id		numeric	= 0
	,@Vertical_Id	numeric	= 0
	,@SubVertical_Id numeric = 0
	,@Status		numeric = 0
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Branch_ID = 0  
		set @Branch_ID = null

	If @Grd_ID = 0
		Set @Grd_ID = Null
		
	IF @Emp_ID = 0  
		set @Emp_ID = null

	CREATE table #Emp_Cons
	(
		Emp_Id Numeric,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC
	)

	DECLARE @From_Date as DATETIME
	DECLARE @To_Date as DATETIME
	SET @From_Date = dbo.GET_MONTH_ST_DATE(Month(@For_Date),YEAR(@For_Date))
	SET @To_Date = dbo.GET_MONTH_END_DATE(Month(@For_Date),YEAR(@For_Date))
	
	EXEC SP_RPT_FILL_EMP_CONS @Cmp_ID,@From_Date,@To_Date,@BRANCH_ID,@CAT_ID,@Grd_ID,0,@DEPT_ID,@DESIG_ID,@EMP_ID,'',0,0,0,@Vertical_Id,@SubVertical_Id,0,0,0,0,0,0,0   
	
		--Insert Into #Emp_Cons(Emp_ID)
		--select I.Emp_Id from T0095_Increment I inner join       
		--	 ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment      
		--	 where Increment_Effective_date <= @For_Date      
		--	 and Cmp_ID = @Cmp_ID      
		--	 group by emp_ID  ) Qry on      
		--	 I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date      
		--   Where Cmp_ID = @Cmp_ID       
		--   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		--   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		--   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)       
		--   and I.Emp_ID in       
		--	( select Emp_Id from      
		--	(select emp_id, cmp_ID, join_Date, isnull(left_Date, @For_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry      
		--	where cmp_ID = @Cmp_ID   and        
		--	(( @For_Date  >= join_Date  and  @For_Date <= left_date )       
		--	or ( @For_Date  >= join_Date  and @For_Date <= left_date )      
		--	or Left_date is null and @For_Date >= Join_Date)      
		--	or @For_Date >= left_date  and  @For_Date <= left_date )      
	
		
				Select E.Emp_ID,W_O.For_Date,W_O.Weekoff_Day, ES.Emp_Id,Emp_Code,Comp_Name,Branch_Address,Branch_NAme,Grd_Name,Dept_NAme,Type_Name,Desig_NAme 
							,Cmp_NAme,Cmp_Address,BM.Branch_ID,I.Grd_ID,I.Dept_ID, I.Type_ID
							,E.Alpha_Emp_Code + ' - ' + E.Emp_Full_Name AS Emp_Full_Name
				From #Emp_Cons ES inner join T0080_Emp_master E WITH (NOLOCK) on Es.Emp_ID = E.Emp_ID inner join 
					--( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date,I.Vertical_ID,I.SubVertical_ID  from T0095_Increment I inner join 
					--		( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
					--		where Increment_Effective_date <= @For_Date
					--		and Cmp_ID = @Cmp_ID
					--		group by emp_ID  ) Qry on
					--		I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date) I_Q 
					--	on E.Emp_ID = I_Q.Emp_ID  
					
					(SELECT	I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID,I1.GRd_Id,I1.Type_Id,I1.Desig_Id,I1.dept_Id
								FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN #Emp_Cons E1 ON I1.Emp_ID=E1.EMP_ID
										INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
													FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN #Emp_Cons E2 ON I2.Emp_ID=E2.EMP_ID
															INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																		FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.EMP_ID
																		WHERE	I3.Increment_Effective_Date <= @For_Date
																		GROUP BY I3.Emp_ID
																		) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
													WHERE	I2.Cmp_ID = @Cmp_Id 
													GROUP BY I2.Emp_ID
													) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
								WHERE	I1.Cmp_ID=@Cmp_Id											
							) I ON E.EMP_ID=I.Emp_ID
						left join

					( select W.Emp_Id, W.For_Date,Weekoff_Day from dbo.T0100_WEEKOFF_ADJ W WITH (NOLOCK) inner join 
							( select max(For_Date) as For_Date , Emp_ID from dbo.T0100_WEEKOFF_ADJ WITH (NOLOCK)
							where For_Date <= @For_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							W.Emp_ID = Qry.Emp_ID and W.For_Date = Qry.For_Date) W_O on
						ES.Emp_Id = W_O.Emp_ID Inner Join
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM WITH (NOLOCK) on I.Branch_ID = BM.Branch_ID Inner join 
							--T0040_WEEKOFF_MASTER WM on I_Q.Branch_ID = WM.Branch_ID And E.Cmp_ID = Wm.Cmp_ID Inner Join
							T0010_company_master cm WITH (NOLOCK) on e.cmp_Id = cm.cmp_ID and Emp_Left<>'Y' 
						
					WHERE   (case when @Status = 0 then 1
							  WHEN @Status = 1 and Weekoff_Day <> '' THEN 1
							  WHEN @Status = 2 and (Weekoff_Day = '' or W_O.Weekoff_Day Is NULL) then 1
							  ELSE 0										  
							  END)	= 1 
			
		
		
 	RETURN


