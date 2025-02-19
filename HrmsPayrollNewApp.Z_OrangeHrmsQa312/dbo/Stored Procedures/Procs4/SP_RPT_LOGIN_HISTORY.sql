
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_LOGIN_HISTORY]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(max)
	,@Report_For	varchar(10)
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
	
	CREATE TABLE #Emp_Cons	-- Ankit 08092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint --,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 	
	--Declare #Emp_Cons Table
	--(
	--	Emp_ID	numeric
	--)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons(Emp_ID)
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
	--		Insert Into #Emp_Cons(Emp_ID)

	--		select I.Emp_Id from T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
	--		Where Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date  and  @From_Date <= left_date )
	--	end
	
	Declare @Emp_Id_Cur As Numeric
	
	If @Report_For <> 'Login'	
		Begin
			CREATE table #Temp_Date
			(For_Date DateTime)
		
			CREATE table #Temp_Date_1
			(Emp_Id Numeric,
			 For_Date DateTime)

			Declare @Temp_From_Date Datetime
			
			Set @Temp_From_Date = @From_Date
			
			While @Temp_From_Date <= @To_Date
				Begin
					Insert Into #Temp_Date
					Select @Temp_From_Date 					
						
					Set @Temp_From_Date = DATEADD(DD,1,@Temp_From_Date)
				End	
					
			Insert Into #Temp_Date_1
			Select EC.Emp_ID,For_Date From #Emp_Cons EC Cross Join #Temp_Date 					
		
		End		

		--Ronak added grouby filter by vertical

	If @Report_For = 'Login'
		Begin
			Select distinct E.Emp_Id, E.Emp_code,E.Emp_full_Name, L.Login_ID, LH.Login_Date,LH.Ip_Address,
					Branch_Address,Comp_Name, Branch_Name,Vertical_Name,SubVertical_Name,SubBranch_Name, Dept_Name, Grd_Name, Desig_Name,TYPE_NAME,E.Emp_First_Name
					,Cmp_Name, Cmp_Address
					,@From_Date as P_From_date ,@To_Date as P_To_Date,E.Alpha_Emp_Code,BM.Branch_id 
			 From T0011_Login_History LH WITH (NOLOCK) Inner Join T0011_LOGIN L WITH (NOLOCK) on LH.Login_ID = L.Login_ID And LH.Cmp_ID = L.Cmp_ID
					Inner Join T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID Inner Join
					#Emp_Cons EC on E.Emp_ID = EC.Emp_ID
					INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,vertical_Id,subvertical_Id,SubBranch_ID,I.Emp_ID,I.Type_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
										( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment	WITH (NOLOCK) -- Ankit 08092014 for Same Date Increment
										where Increment_Effective_date <= @To_Date
										and Cmp_ID = @Cmp_ID
										group by emp_ID  ) Qry on
										I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID)Q_I ON
							E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID left outer JOIN
					T0040_Vertical_Segment vs WITH (NOLOCK) on Q_I.vertical_Id = vs.Vertical_ID left outer JOIN
					T0050_SubVertical sv WITH (NOLOCK) on Q_I.subvertical_Id = sv.SubVertical_ID inner join
					T0050_SubBranch SB  WITH (NOLOCK) ON Q_I.SubBranch_ID = SB.SubBranch_ID Inner join
					T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_id	Left Outer Join
					T0040_TYPE_MASTER TM WITH (NOLOCK) On Q_I.Type_ID = TM.Type_ID
			Where LH.Login_ID in 
				(select Login_ID from T0011_Login_History WITH (NOLOCK) where Login_Date >= @From_Date And Login_Date <= @To_Date And Cmp_ID = @Cmp_ID)
			And Login_Date >= @From_Date And Login_Date <= @To_Date And LH.Cmp_ID = @Cmp_ID
			--ORDER BY Login_Date
			--ORDER BY Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
			--		When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
			--		Else Alpha_Emp_Code
			--	 End
			
		End
	Else
		Begin


		--	Select TM1.Emp_Id,For_Date,E.Emp_code,E.Emp_full_Name,
		--			Branch_Address,Comp_Name, Branch_Name, Dept_Name, Grd_Name, Desig_Name,Type_Name,
		--			E.Emp_First_Name
		--			,Cmp_Name, Cmp_Address ,Max_Login_Date
		--			,@From_Date as P_From_date ,@To_Date as P_To_Date ,E.Alpha_Emp_Code From T0011_LOGIN L 
		--	Inner Join T0011_Login_History LH On L.Login_Id = LH.Login_Id 
		--	Right Outer Join  #Temp_Date_1 TM1 on TM1.Emp_Id = L.Emp_ID And Tm1.For_Date = Cast(CAST(LH.Login_Date As varchar(11)) As Datetime)
		--	Inner Join T0080_EMP_MASTER E on TM1.Emp_ID = E.Emp_ID
		--	INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.Type_ID FROM T0095_Increment I inner join 
		--						( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment
		--						where Increment_Effective_date <= @To_Date
		--						and Cmp_ID = @Cmp_ID
		--						group by emp_ID  ) Qry on
		--						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date)Q_I ON
		--			E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
		--	T0030_BRANCH_MASTER BM ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
		--	T0040_DEPARTMENT_MASTER DM ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
		--	T0040_DESIGNATION_MASTER DGM ON Q_I.DESIG_ID = DGM.DESIG_ID Inner join 
		--	T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_id	Left Outer Join
		--	T0040_TYPE_MASTER TM On Q_I.Type_ID = TM.Type_ID
		--	Left Outer Join
		--	(Select L.Emp_ID, Log_In_Date As Max_Login_Date From T0011_Login_History L1 Inner Join
		--		T0011_LOGIN L On L1.Login_ID = L.Login_ID
		--	 Inner Join 
		--		(Select MAX(Login_Date)As Log_In_Date,Login_Id From T0011_Login_History Where Cmp_ID = @Cmp_ID  And 
		--			Login_Date <=GETDATE() Group By Login_ID) Qry1 on L1.Login_ID = Qry1.Login_ID And 
		--			L1.Login_Date = Qry1.Log_In_Date)Q_L on TM1.Emp_Id = Q_L.Emp_ID
		--	Where Login_Date Is null 
		--order by Emp_Id,For_Date

					
			Select TM1.Emp_Id,For_Date,E.Emp_code,E.Emp_full_Name,
					Branch_Address,Comp_Name, Branch_Name, Dept_Name, Grd_Name, Desig_Name,Type_Name,
					E.Emp_First_Name
					,Cmp_Name, Cmp_Address ,Max_Login_Date
					,@From_Date as P_From_date ,@To_Date as P_To_Date ,E.Alpha_Emp_Code,BM.BRANCH_ID From T0011_LOGIN L WITH (NOLOCK)
			Inner Join T0011_Login_History LH WITH (NOLOCK) On L.Login_Id = LH.Login_Id 
			Right Outer Join  #Temp_Date_1 TM1 on TM1.Emp_Id = L.Emp_ID And Tm1.For_Date = Cast(CAST(LH.Login_Date As varchar(11)) As Datetime)
			Inner Join T0080_EMP_MASTER E WITH (NOLOCK) on TM1.Emp_ID = E.Emp_ID Inner Join
					#Emp_Cons EC on E.Emp_ID = EC.Emp_ID
			INNER JOIN (SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.Type_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
								( select max(T0095_Increment.Increment_ID) as Increment_ID , T0095_Increment.Emp_ID From T0095_Increment WITH (NOLOCK) -- Ankit 08092014 for Same Date Increment
								Inner Join #Emp_Cons EC on T0095_Increment.Emp_ID = EC.Emp_ID
								where Increment_Effective_date <= @To_Date
								and Cmp_ID = @Cmp_ID
								group by T0095_Increment.Emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID)Q_I  ON
					E.EMP_ID = Q_I.EMP_ID 
					LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID LEFT OUTER JOIN 
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Inner join 
			T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_id	Left Outer Join
			T0040_TYPE_MASTER TM WITH (NOLOCK) On Q_I.Type_ID = TM.Type_ID
			Left Outer Join
			(Select L.Emp_ID, Log_In_Date As Max_Login_Date From T0011_Login_History L1 WITH (NOLOCK) Inner Join
				T0011_LOGIN L WITH (NOLOCK) On L1.Login_ID = L.Login_ID
			 Inner Join 
				(Select MAX(Login_Date)As Log_In_Date,H.Login_ID From T0011_Login_History H WITH (NOLOCK)
						Inner join T0011_LOGIN L WITH (NOLOCK) on H.Login_ID = L.Login_ID
						Inner Join #Emp_Cons EC on L.Emp_ID = EC.Emp_ID
					Where H.Cmp_ID = @Cmp_ID  And 
					Login_Date <=GETDATE() Group By H.Login_ID) Qry1 on L1.Login_ID = Qry1.Login_ID And 
					L1.Login_Date = Qry1.Log_In_Date)Q_L on TM1.Emp_Id = Q_L.Emp_ID
			Where Login_Date Is null 
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
		--order by RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500),For_Date, Q_I.Grd_Id
			
		End


	RETURN


