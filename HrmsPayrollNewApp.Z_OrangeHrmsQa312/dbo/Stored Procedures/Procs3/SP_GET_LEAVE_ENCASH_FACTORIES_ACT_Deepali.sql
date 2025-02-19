
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_LEAVE_ENCASH_FACTORIES_ACT_Deepali]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@Branch_ID		Numeric 
	,@Cat_ID		Numeric
	,@Grd_ID		Numeric
	,@Type_ID		Numeric 
	,@Dept_Id		Numeric
	,@Desig_Id		Numeric
	,@Emp_ID		Numeric
	,@Constraint	varchar(MAX)
	,@Call_For      varchar(30) = 'Report' --- Added by Hardik 22/03/2016
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
	
	--Declare @Emp_Cons Table
	--	(
	--		Emp_ID	numeric
	--	)
	
	CREATE TABLE #Emp_Cons
	(
		Emp_id NUMERIC,
		Branch_id	NUMERIC,
		Increment_Id	NUMERIC
	)
	
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0,0,0,0,0
    
	
	 Declare @Lv_Encash_Cal_On varchar(50)   -- Added by mihir 17042012
	 Declare @Lv_Encash_W_Day Numeric
	 SET @Lv_Encash_Cal_On = ''   -- Added by mihir 17042012
	 Set @Lv_Encash_W_Day = 0
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into @Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
	--		Insert Into @Emp_Cons

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
		
		
			--select E.Emp_code,E.Emp_Full_Name,LEA.*,DGM.Desig_Name, LT.Leave_Opening,I_Q .Basic_Salary,@From_Date  as From_Date, @To_Date as To_Date,I_Q.Branch_ID from T0080_EMP_MASTER E  inner join
			--( select I.Emp_Id ,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Basic_Salary  from T0095_Increment I inner join 
			--( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
			--where Increment_Effective_date <= @To_Date
			--and Cmp_ID = @Cmp_ID
			--group by emp_ID  ) Qry on
			--I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
			--on E.Emp_ID = I_Q.Emp_ID  inner join
			--t0120_LEAVE_Encash_APPROVAL LEA  on E.emp_ID=LEA.Emp_id inner join
			--T0140_LEAVE_TRANSACTION LT on LEA.Emp_ID=LT.Emp_ID and LEA.Leave_ID=LT.Leave_ID and
			--LEA.Lv_Encash_Apr_Date=LT.For_Date inner join
			--T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
			--T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID
			--WHERE E.Cmp_ID = @Cmp_Id And Lv_Encash_Apr_Status='A' and Lv_Encash_Apr_Days>0 And ISnull(Is_FNF,0)<>1
			-- And E.Emp_ID in (select Emp_ID From @Emp_Cons)
			--  And LEA.Lv_Encash_Apr_Date > = @From_Date and LEA.Lv_Encash_Apr_Date <= @To_Date 

			
				select @Lv_Encash_Cal_On = Lv_Encash_Cal_On,@Lv_Encash_W_Day = Lv_Encash_W_Day 
				FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE cmp_ID = @cmp_ID AND Branch_ID = ISNULL(@Branch_ID,Branch_ID)
				AND For_Date = (SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@To_Date AND Branch_ID = ISNULL(@Branch_ID,Branch_ID) AND Cmp_ID = @Cmp_ID) 
				   
					  
				If @Lv_Encash_Cal_On = 'Gross'
						Begin
							--Added by Jaina 14-08-2017
							select E.Emp_code,E.Emp_Full_Name,LEA.*,DGM.Desig_Name, LT.Leave_Opening,I_Q .Gross_Salary As Basic_salary,@From_Date  as From_Date, @To_Date as To_Date, Wages_Type,@Lv_Encash_W_Day as Lv_Encash_W_Day,I_Q.Branch_ID --Add  By  BranchId 28-03-2013
							,Dept_Name,Branch_Name,Desig_Name,Grd_Name,E.Alpha_Emp_code,E.Emp_First_Name   --added jimit 28052015
							,Tm.Type_Name  --added jimit 26062015
							,LM.Leave_Name	--added jimit 03022016
							,LM.Leave_EncashDay_Half_payment,
							Case When @Lv_Encash_W_Day >0 then Isnull(I_Q.Gross_Salary,0) / @Lv_Encash_W_Day ELSE 0 End as Leave_Encash_Day_Rate --Added by Sumit after check differences in Version Sp and Live SP on 01072016
							,Cmp_Name,Comp_Name,Branch_Address
							from T0080_EMP_MASTER E  inner join
							( select I.Emp_Id ,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Basic_Salary,Gross_Salary,Wages_Type  from T0095_Increment I inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  --Changed by Hardik 09/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID) I_Q  --Changed by Hardik 09/09/2014 for Same Date Increment
							on E.Emp_ID = I_Q.Emp_ID  inner join
							t0120_LEAVE_Encash_APPROVAL LEA  on E.emp_ID=LEA.Emp_id inner join
							T0140_LEAVE_TRANSACTION LT on LEA.Emp_ID=LT.Emp_ID and LEA.Leave_ID=LT.Leave_ID and
							LEA.Lv_Encash_Apr_Date=LT.For_Date inner join
							T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
							T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
							T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER TM ON TM.type_Id = I_Q.Type_ID INNER JOIN
							t0040_Leave_Master LM On Lm.Leave_ID = Lea.Leave_ID and Lm.Cmp_ID = Lea.Cmp_ID
							WHERE E.Cmp_ID = @Cmp_Id And Lv_Encash_Apr_Status='A' and Lv_Encash_Apr_Days>0 And ISnull(Is_FNF,0)<>1
							 And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
							 And LEA.Lv_Encash_Apr_Date > = @From_Date and LEA.Lv_Encash_Apr_Date <= @To_Date
							 
							 
							 
							  --Added by Jaina 14-08-2017 (As per discuss with Hardikbhai)
							-- select E.Emp_ID,E.Emp_code,E.Branch_ID,E.Grd_ID,E.Desig_Id,
							-- E.Cmp_ID,
							-- (I_Q.Gross_Salary) AS Gross_Salary,Cmp_Name,Comp_Name,
							-- E.Emp_Full_Name,E.Alpha_Emp_code,E.Emp_First_Name ,LEA.*,						 
						
					  --    Dept_Name,Branch_Name,Desig_Name,Grd_Name,E.Alpha_Emp_code,E.Emp_First_Name   --added jimit 28052015
							--,Tm.Type_Name  --added jimit 26062015
							--,LM.Leave_Name	--added jimit 03022016
							--,LM.Leave_EncashDay_Half_payment,
							
							--@From_Date  as From_Date, @To_Date as To_Date, Wages_Type,I_Q.Branch_ID 
							--		,E.Alpha_Emp_code,E.Emp_First_Name,(case when E.Leave_Encash_Working_Days > 0 then E.Leave_Encash_Working_Days 
							--											else @Lv_Encash_W_Day end) as Lv_Encash_W_Day,
							--		cast(Case When (case when E.Leave_Encash_Working_Days > 0 then E.Leave_Encash_Working_Days 
							--											else @Lv_Encash_W_Day end) > 0 then 
							--					    I_Q.Gross_Salary / (case when E.Leave_Encash_Working_Days > 0 then E.Leave_Encash_Working_Days 
							--											else @Lv_Encash_W_Day end)     --Change Condition By Jimit 08022018
							--			ELSE 0 End as numeric(18,2)) as Leave_Encash_Day_Rate								
									
							--	from T0080_EMP_MASTER E  WITH (NOLOCK) inner join
							--	( select I.Emp_Id ,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Gross_Salary, Wages_Type  from T0095_Increment I WITH (NOLOCK) inner join 
							--	( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
							--		where Increment_Effective_date <= @To_Date
							--		and Cmp_ID = @Cmp_ID
							--		group by emp_ID  ) Qry on
							--	I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q  
							--	on E.Emp_ID = I_Q.Emp_ID  
							--	 left outer join
							--		t0120_LEAVE_Encash_APPROVAL LEA  on E.emp_ID=LEA.Emp_ID
							--		left outer join
							--		T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							--T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							--T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
							--T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
							--T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID LEFT OUTER JOIN
							--T0040_TYPE_MASTER TM ON TM.type_Id = I_Q.Type_ID INNER JOIN
							--t0040_Leave_Master LM On Lm.Leave_ID = Lea.Leave_ID and Lm.Cmp_ID = Lea.Cmp_ID
							

							--WHERE E.Cmp_ID = @Cmp_Id
							--	 And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
								 
						End
					Else
						Begin
						
							CREATE TABLE #Emp_Allow 
							(
								Emp_id NUMERIC,
								AD_Id	NUMERIC,
								Ad_Amount NUMERIC(18,2)
							)
							
							--INSERT INTO #Emp_Allow
							--SELECT EED.EMP_ID,eed.AD_ID ,ISNULL((E_AD_AMOUNT),0)
							--FROM T0100_EMP_EARN_DEDUCTION EED INNER JOIN 
							--	#Emp_Cons EC ON EC.Emp_Id = EED.Emp_ID AND EC.Increment_Id = EEd.INCREMENT_ID INNER JOIN
							--	T0050_AD_MASTER AM ON EED.AD_ID = AM.AD_ID	
							-- WHERE ISNULL(AM.AD_EFFECT_ON_LEAVE,0) = 1 
							
							INSERT INTO #Emp_Allow
							Select EED.EMP_ID,eed.AD_ID,
								Case When Qry1.Increment_ID >= EED.INCREMENT_ID  Then
									Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
								Else eed.e_ad_Amount End 
							FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Inner Join 
								--#Emp_Cons EC ON EC.Emp_Id = EED.Emp_ID AND EC.Increment_Id = EEd.INCREMENT_ID INNER JOIN --commented by Mukti(20052017)
								(select max(IE.Increment_ID) as Increment_ID , IE.Emp_ID from T0095_Increment IE WITH (NOLOCK) INNER JOIN --added By Mukti(20052017)to get record uptodate of Leave Encashment
									t0120_LEAVE_Encash_APPROVAL LEA WITH (NOLOCK) ON IE.emp_ID=LEA.Emp_id 
									where IE.Increment_Effective_date <= LEA.Upto_Date and IE.EMP_ID IN (Select Emp_id From #Emp_Cons)
									and IE.Cmp_ID = @Cmp_ID	group by IE.emp_ID) Qry on Qry.Emp_ID = EED.Emp_ID and EED.Increment_ID = Qry.Increment_ID	Inner Join  
								T0050_AD_MASTER A WITH (NOLOCK) on EED.AD_ID = A.AD_ID And EED.CMP_ID=A.CMP_ID LEFT OUTER JOIN
								( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.ENTRY_TYPE,EEDR.Increment_ID 
									From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
									#Emp_Cons EC ON EC.Emp_Id = EEDR.Emp_ID AND EC.Increment_Id = EEDR.INCREMENT_ID INNER JOIN	
									 ( Select Max(For_Date) For_Date, Ad_Id,EE.EMP_ID From T0110_EMP_Earn_Deduction_Revised EE WITH (NOLOCK) INNER JOIN
										t0120_LEAVE_Encash_APPROVAL LEA WITH (NOLOCK) ON EE.emp_ID=LEA.Emp_id 
										Where For_date <= LEA.Upto_Date and EE.EMP_ID IN ( Select Emp_id From #Emp_Cons ) 
										Group by Ad_Id ,EE.EMP_ID
									 ) Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
								) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID 
								
							WHERE EED.CMP_ID = @Cmp_ID AND Isnull(A.AD_EFFECT_ON_LEAVE,0)=1
							
							UNION 
		
							SELECT EED.EMP_ID,eed.AD_ID,E_AD_Amount
							FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
								#Emp_Cons EC ON EC.Emp_Id = EED.Emp_ID AND EC.Increment_Id = EEd.INCREMENT_ID INNER JOIN
								( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised EE WITH (NOLOCK) INNER JOIN
									t0120_LEAVE_Encash_APPROVAL LEA WITH (NOLOCK) ON EE.emp_ID=LEA.Emp_id 
									Where For_date <=  LEA.Upto_Date and EE.EMP_ID IN ( Select Emp_id From #Emp_Cons ) 
									Group by Ad_Id 
								) Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
							   INNER JOIN dbo.T0050_AD_MASTER ADM  WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                     
							WHERE Adm.AD_ACTIVE = 1 And EEd.ENTRY_TYPE = 'A' AND Isnull(ADM.AD_EFFECT_ON_LEAVE,0)=1
						

						

						If @Call_For = 'Report'
							BEGIN
								SELECT E.Emp_code,E.Emp_Full_Name,LEA.*,DGM.Desig_Name, LT.Leave_Opening,(I_Q.Basic_Salary + ISNULL(SUBI_Q.E_AD_AMOUNT,0)) AS Basic_Salary,	--I_Q.Basic_Salary , ISNULL(SUBI_Q.E_AD_AMOUNT,0),
									@From_Date  as From_Date, @To_Date as To_Date, Wages_Type
									,(Case when E.Leave_Encash_Working_Days > 0 then E.Leave_Encash_Working_Days 
										else @Lv_Encash_W_Day End) as Lv_Encash_W_Day          ---Change By Jimit 08022018
									,I_Q.Branch_ID --Add  By  BranchId 28-03-2013
									,Dept_Name,Branch_Name,Desig_Name,Grd_Name,E.Alpha_Emp_code,E.Emp_First_Name   --added jimit 28052015
									,Tm.Type_Name  --added jimit 26062015
									,LM.Leave_Name	--added jimit 03022016
									,LM.Leave_EncashDay_Half_payment
									,CM.Cmp_Name,CM.Cmp_Address,BM.Comp_Name,BM.Branch_Address  --added by jimit 12092016
									
								from T0080_EMP_MASTER E WITH (NOLOCK) inner join
								( select I.Emp_Id ,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Basic_Salary, Wages_Type  from T0095_Increment I WITH (NOLOCK) inner join 
								( select max(Increment_ID) as Increment_ID , IE.Emp_ID from T0095_Increment IE WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
								--where Increment_Effective_date <= @To_Date --commented by Mukti(20052017)
								inner join t0120_LEAVE_Encash_APPROVAL LEA  WITH (NOLOCK) on IE.emp_ID=LEA.Emp_id --Added By Mukti(20052017)calculate basic salary and ad_amount based on Uptodate of leave encashment
								where Increment_Effective_date <= LEA.Upto_Date 
								and IE.Cmp_ID = @Cmp_ID group by IE.emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q  --Changed by Hardik 09/09/2014 for Same Date Increment
								on E.Emp_ID = I_Q.Emp_ID  inner join
								t0120_LEAVE_Encash_APPROVAL LEA  WITH (NOLOCK) on E.emp_ID=LEA.Emp_id inner join
								T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) on LEA.Emp_ID=LT.Emp_ID and LEA.Leave_ID=LT.Leave_ID and LEA.Lv_Encash_Apr_Date=LT.For_Date inner join
								T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
								T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID LEFT OUTER JOIN
								T0040_TYPE_MASTER TM WITH (NOLOCK) ON TM.type_Id = I_Q.Type_ID  INNER JOIN			--added jimit 26062015
								t0040_Leave_Master LM WITH (NOLOCK) On Lm.Leave_ID = Lea.Leave_ID and Lm.Cmp_ID = LEA.Cmp_ID Left Outer JOIN
								( SELECT ISNULL(SUM(AD_AMOUNT),0) AS E_AD_AMOUNT,EMP_ID FROM #Emp_Allow group by emp_ID	--Ankit 27022016  
								) SUBI_Q  ON E.Emp_ID = SUBI_Q.Emp_ID  
								
								--( SELECT ISNULL(SUM(E_AD_AMOUNT),0) AS E_AD_AMOUNT,EED.EMP_ID from T0100_EMP_EARN_DEDUCTION EED INNER JOIN 
								--	T0050_AD_MASTER AM ON EED.AD_ID = AM.AD_ID	INNER JOIN 
								--	( SELECT max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  
								--		where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
								--		group by emp_ID  
								--	 ) Qry on EED.Emp_ID = Qry.Emp_ID and EED.Increment_ID = Qry.Increment_ID
								--  WHERE ISNULL(AM.AD_EFFECT_ON_LEAVE,0) = 1 GROUP BY EED.EMP_ID) SUBI_Q  ON E.Emp_ID = SUBI_Q.Emp_ID  
									
								WHERE E.Cmp_ID = @Cmp_Id And Lv_Encash_Apr_Status='A' and Lv_Encash_Apr_Days>0 And ISnull(Is_FNF,0)<>1
								 And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
								 And LEA.Lv_Encash_Apr_Date > = @From_Date and LEA.Lv_Encash_Apr_Date <= @To_Date
							END
					
						ELSE  --- Below portion Added by Hardik 22/03/2016
							BEGIN	
								select E.Emp_ID,E.Branch_ID,E.Grd_ID,E.Desig_Id,(I_Q.Basic_Salary + ISNULL(SUBI_Q.E_AD_AMOUNT,0)) AS Basic_Salary,
									@From_Date  as From_Date, @To_Date as To_Date, Wages_Type,I_Q.Branch_ID 
									,E.Alpha_Emp_code,E.Emp_First_Name,
									(Case when E.Leave_Encash_Working_Days > 0 then E.Leave_Encash_Working_Days 
											else @Lv_Encash_W_Day end) as Lv_Encash_W_Day,     --change By Jimit 08022018
									cast(Case When (Case when E.Leave_Encash_Working_Days > 0 then E.Leave_Encash_Working_Days 
											else @Lv_Encash_W_Day end) > 0 then 
									(I_Q.Basic_Salary + ISNULL(SUBI_Q.E_AD_AMOUNT,0)) / (Case when E.Leave_Encash_Working_Days > 0 then E.Leave_Encash_Working_Days 
											else @Lv_Encash_W_Day end)			--change By Jimit 08022017
									ELSE 0 End as numeric(18,2)) as Leave_Encash_Day_Rate								
									
									--cast(Case When @Lv_Encash_W_Day >0 then I_Q.Gross_Salary / @Lv_Encash_W_Day ELSE 0 End as numeric(18,2)) as Leave_Encash_Day_Rate									
									
								from T0080_EMP_MASTER E WITH (NOLOCK) inner join
								( select I.Emp_Id ,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Basic_Salary, Wages_Type  from T0095_Increment I WITH (NOLOCK) inner join 
								( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_ID
									group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q  
								on E.Emp_ID = I_Q.Emp_ID  left outer join
								( SELECT ISNULL(SUM(AD_AMOUNT),0) AS E_AD_AMOUNT,EMP_ID FROM #Emp_Allow group by emp_ID	
								) SUBI_Q  ON E.Emp_ID = SUBI_Q.Emp_ID  
								
								WHERE E.Cmp_ID = @Cmp_Id
								 And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
							END
					End
	RETURN




