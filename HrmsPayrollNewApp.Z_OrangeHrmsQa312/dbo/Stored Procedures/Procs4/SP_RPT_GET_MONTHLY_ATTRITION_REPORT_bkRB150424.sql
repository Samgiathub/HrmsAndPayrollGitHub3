

---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_GET_MONTHLY_ATTRITION_REPORT_bkRB150424]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	varchar(max)
	,@Cat_ID 		VARCHAR(MAX) = ''
	,@Grd_ID 		VARCHAR(MAX) = ''
	,@Type_ID 		VARCHAR(MAX) = ''
	,@Dept_ID 		VARCHAR(MAX) = ''
	,@Desig_ID 		VARCHAR(MAX) = ''
	,@Emp_ID 		numeric = 0
	,@constraint 	varchar(MAX) = ''
	,@Flag			numeric = 0
	,@Report_Name   numeric = 1
	,@SUMMARY		numeric = 0
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Branch_ID = '0' or @Branch_ID = ''
		set @Branch_ID = null
		
	IF @Cat_ID = '0'  or @Cat_ID = '' 
		set @Cat_ID = null

	IF @Grd_ID = '0'  or @Grd_ID = ''
		set @Grd_ID = null

	IF @Type_ID = '0'  or @Type_ID = ''  
		set @Type_ID = null

	IF @Dept_ID = '0'  or @Dept_ID = ''
		set @Dept_ID = null

	IF @Desig_ID = '0' or @Desig_ID = ''  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
	
	CREATE TABLE #EMP_CONS 
				(
					EMP_ID	NUMERIC ,     
					BRANCH_ID NUMERIC,
					INCREMENT_ID NUMERIC 
				)
	
		exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@To_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,
												@Emp_ID,@constraint,0,0,0,0,0,0,0,0,0,'0',0,0
	
	 
	
	if @Report_Name = 1
		BEGIN
				IF Object_ID('tempdb..#Temp_Branch_ID') is not null
					drop TABLE #Temp_Branch_ID
					
				CREATE Table #Temp_Branch_ID 
				(
					Branch_ID numeric
				)
				
				
				if @Branch_ID <> '0'
					begin
						Insert Into #Temp_Branch_ID
						select  cast(data  as numeric) from dbo.Split (@Branch_ID,'#') 
					end
					
					
					IF Object_ID('tempdb..#Monthly_Attrition_Report') is not null
					drop TABLE #Monthly_Attrition_Report

						CREATE table #Monthly_Attrition_Report
						(
							Cmp_ID			numeric ,
							Branch_Id		numeric ,
							Total_Beging_HeadCount Numeric,
							New_join_Curr_Month numeric,
							Exit_Curr_Month Numeric,
							Transfered_from Numeric,
							Transfered_to Numeric,
							Present_Month_Emp Numeric,
							CTC_Prev_Month Numeric(18,2),
							CTC_Curr_Month Numeric(18,2),
							Attrition_analysis Numeric(18,2)						
						)
						

					Declare @Branch_Id_Cur Numeric
					Declare @Branch_name As Varchar(50)


					set @Branch_Id = REPLACE(@Branch_Id,'#',',')

					if @Branch_Id is null
						DECLARE Allow_Dedu_Cursor1 CURSOR FOR select branch_id,Branch_name from t0030_branch_master WITH (NOLOCK) where cmp_id=@Cmp_Id --And Branch_Id = Isnull(@Branch_Id,Branch_ID)
					else
						DECLARE Allow_Dedu_Cursor1 CURSOR FOR select BM.branch_id,Branch_name from t0030_branch_master BM WITH (NOLOCK) inner JOIN #Temp_Branch_ID TB ON BM.Branch_ID = TB.Branch_ID where cmp_id=@Cmp_Id 	
				
						OPEN Allow_Dedu_Cursor1
							fetch next from Allow_Dedu_Cursor1 into @Branch_Id_Cur,@Branch_name 
							while @@fetch_status = 0
								Begin
										Insert Into #Monthly_Attrition_Report
											(Cmp_ID,Branch_Id)
										Values
											(@Cmp_ID,@Branch_Id_Cur)


													
											Update TT
											set Total_Beging_HeadCount = Inn_Qry.EmpID
												,CTC_Prev_Month = Inn_Qry.Prev_CTC
												From #Monthly_Attrition_Report TT 
												Inner Join	(Select count(EM.emp_id) as EmpID ,SUM(Qry_1.CTC) as Prev_CTC,Qry_1.Branch_ID as BranchID from T0080_EMP_MASTER EM WITH (NOLOCK)
													inner JOIN(
														Select I.Emp_ID,I.Branch_ID,I.CTC From T0095_INCREMENT I WITH (NOLOCK) Inner Join
														(
															SELECT MAX(Increment_ID) as Increment_Id,IE.Emp_ID From T0095_INCREMENT IE WITH (NOLOCK)
															Inner JOIN (
																		Select MAX(Increment_Effective_Date) as Effective_Date,Emp_ID FROM T0095_INCREMENT WITH (NOLOCK)
																		Where Increment_Effective_Date < @From_Date and Cmp_ID = @Cmp_ID 
																		GROUP By Emp_ID
																	   ) as Inn_Qry
															ON IE.Increment_Effective_Date = Inn_Qry.Effective_Date and IE.Emp_ID = Inn_Qry.Emp_ID
															GROUP BY IE.Emp_ID
														) as Qry On I.Emp_ID = Qry.Emp_ID AND I.Increment_Id = Qry.Increment_Id
													) As Qry_1 ON EM.Emp_ID = Qry_1.Emp_ID
													where EM.cmp_id = @Cmp_ID  and  EM.Date_Of_Join < @From_Date
													and Qry_1.Branch_ID = @Branch_Id_Cur and (EM.Emp_Left ='N' or (EM.Emp_Left='Y' and EM.Emp_Left_Date >= @From_Date))
													GROUP BY Qry_1.Branch_ID)
												As Inn_Qry On TT.Branch_ID = Inn_Qry.BranchID
											Where Branch_ID =@Branch_Id_Cur

													
											--Update #Monthly_Attrition_Report 
											--set New_join_Curr_Month = 
											--	(Select COUNT(Emp_ID) from T0080_EMP_MASTER
											--		Where Date_Of_Join >= @From_Date and Date_Of_Join <= @To_Date And Cmp_ID = @Cmp_ID And Branch_Id = @Branch_Id_Cur) 
											--Where Branch_Id = @Branch_Id_Cur
											
											--Update #Monthly_Attrition_Report 
											--set Exit_Curr_Month = (SELECT COUNT(Emp_ID) FROM T0080_EMP_MASTER 
											--Where Branch_ID = @Branch_Id_Cur AND Emp_Left='Y' 
											--and Emp_Left_Date >= @From_Date AND Emp_Left_Date <= @To_Date And Cmp_ID = @Cmp_ID)
											--Where Branch_ID =@Branch_Id_Cur

										  --changed By Jimit 17112018 as Branch Id is not coming Effective date wise (case at Corona)
											Update	#Monthly_Attrition_Report 
											set		New_join_Curr_Month = 	(
																				Select	COUNT(EM.Emp_ID) 
																				from	T0080_EMP_MASTER EM WITH (NOLOCK) INNER Join
																						T0095_INCREMENT I WITH (NOLOCK) ON EM.Emp_ID = I.Emp_ID INNER JOIN																					
																						(
																							SELECT MAX(IE.Increment_ID) as Increment_ID,IE.Emp_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER Join
																									(
																										SELECT	Emp_ID,MAX(Increment_Effective_Date) as Effective_Date
																											FROM	T0095_INCREMENT WITH (NOLOCK) 
																											Where	Increment_Effective_Date <= @To_Date And Cmp_ID = @Cmp_ID																							
																										GROUP BY Emp_ID
																									)as inn_Qry ON IE.Emp_ID = inn_Qry.Emp_ID AND IE.Increment_Effective_Date = inn_Qry.Effective_Date
																							GROUP BY IE.Emp_ID
																						) as Qry ON I.Increment_ID = Qry.Increment_ID and I.Emp_ID = Qry.Emp_ID
																				Where Date_Of_Join >= @From_Date and Date_Of_Join <= @To_Date And Em.Cmp_ID = @Cmp_ID And I.Branch_Id = @Branch_Id_Cur
																			) 
											Where Branch_Id = @Branch_Id_Cur
											
											Update	#Monthly_Attrition_Report 
											set		Exit_Curr_Month = (
																		Select	COUNT(EM.Emp_ID) 
																		from	T0080_EMP_MASTER EM WITH (NOLOCK) INNER Join
																				T0095_INCREMENT I WITH (NOLOCK) ON EM.Emp_ID = I.Emp_ID INNER JOIN																					
																				(
																					SELECT MAX(IE.Increment_ID) as Increment_ID,IE.Emp_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER Join
																							(
																								SELECT	Emp_ID,MAX(Increment_Effective_Date) as Effective_Date
																									FROM	T0095_INCREMENT WITH (NOLOCK)
																									Where	Increment_Effective_Date <= @To_Date And Cmp_ID = @Cmp_ID																							
																								GROUP BY Emp_ID
																							)as inn_Qry ON IE.Emp_ID = inn_Qry.Emp_ID AND IE.Increment_Effective_Date = inn_Qry.Effective_Date
																					GROUP BY IE.Emp_ID
																				) as Qry ON I.Increment_ID = Qry.Increment_ID and I.Emp_ID = Qry.Emp_ID
																		Where I.Branch_ID = @Branch_Id_Cur AND Emp_Left='Y' and Emp_Left_Date >= @From_Date AND Emp_Left_Date <= @To_Date And Em.Cmp_ID = @Cmp_ID
																		)
												Where Branch_ID =@Branch_Id_Cur
											----Ended
											
											
											--Update #Monthly_Attrition_Report
											--	SET Transfered_from = (
											--							SELECT COUNT(*) From T0080_EMP_MASTER EM INNER Join
											--							T0095_INCREMENT I ON EM.Emp_ID = I.Emp_ID
											--							INNER JOIN
											--							(
											--								SELECT MAX(IE.Increment_Effective_Date) as Effective_Date,IE.Emp_ID FROM T0095_INCREMENT IE INNER Join
											--										(
											--											SELECT Emp_ID,MAX(Increment_Effective_Date) as Effective_Date
											--											 FROM T0095_INCREMENT Where Increment_Effective_Date >= @From_Date 
											--												AND Increment_Effective_Date <= @To_Date
											--												And Cmp_ID = @Cmp_ID
											--												and Branch_ID <> @Branch_Id_Cur 
											--											GROUP BY Emp_ID
											--										)as inn_Qry ON IE.Emp_ID = inn_Qry.Emp_ID AND IE.Increment_Effective_Date < inn_Qry.Effective_Date
											--								GROUP BY IE.Emp_ID
											--							) as Qry ON I.Increment_Effective_Date = Qry.Effective_Date and I.Emp_ID = Qry.Emp_ID
											--							WHERE I.Branch_ID = @Branch_Id_Cur and (EM.Emp_Left ='N' or (EM.Emp_Left='Y' and EM.Emp_Left_Date >= @To_Date)) --and EM.Emp_Left <> 'Y'
											--						  )
											--	 Where Branch_Id = @Branch_Id_Cur
											
											--commented By Jimit 17112018
											
											Update #Monthly_Attrition_Report
												SET Transfered_from = (
																		SELECT COUNT(1) From T0080_EMP_MASTER EM WITH (NOLOCK) INNER Join
																				T0095_INCREMENT I WITH (NOLOCK) ON EM.Emp_ID = I.Emp_ID INNER JOIN																					
																				(
																					SELECT MAX(IE.Increment_ID) as Increment_ID,IE.Emp_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER Join
																							(
																								SELECT	Emp_ID,MAX(Increment_Effective_Date) as Effective_Date
																									FROM	T0095_INCREMENT WITH (NOLOCK)
																									Where	Increment_Effective_Date <= @To_Date And Cmp_ID = @Cmp_ID	and Branch_ID <> @Branch_Id_Cur																						
																								GROUP BY Emp_ID
																							)as inn_Qry ON IE.Emp_ID = inn_Qry.Emp_ID AND IE.Increment_Effective_Date = inn_Qry.Effective_Date
																					GROUP BY IE.Emp_ID
																				) as Qry ON I.Increment_ID = Qry.Increment_ID and I.Emp_ID = Qry.Emp_ID
																		WHERE I.Branch_ID = @Branch_Id_Cur and (EM.Emp_Left ='N' or (EM.Emp_Left='Y' and EM.Emp_Left_Date >= @To_Date)) --and EM.Emp_Left <> 'Y'
																	  )
												 Where Branch_Id = @Branch_Id_Cur
											
											--Ended

											--Update  #Monthly_Attrition_Report
											--set Transfered_to = ( SELECT COUNT(*) From T0080_EMP_MASTER EM INNER Join
											--						T0095_INCREMENT I ON EM.Emp_ID = I.Emp_ID
											--						INNER JOIN
											--						(
											--							SELECT MAX(IE.Increment_Effective_Date) as Effective_Date,IE.Emp_ID FROM T0095_INCREMENT IE INNER Join
											--							(
											--										SELECT MAX(Increment_Effective_Date) as Effective_Date,Emp_ID FROM T0095_INCREMENT 
											--										Where Increment_Effective_Date >= @From_Date 
											--										And Cmp_ID = @Cmp_ID
											--										AND Increment_Effective_Date <= @To_Date and Branch_ID = @Branch_Id_Cur 
											--										GROUP BY Emp_ID
											--							) As Inn_Qry On IE.Increment_Effective_Date < Inn_Qry.Effective_Date AND IE.Emp_ID = Inn_Qry.Emp_ID
											--							GROUP BY IE.Emp_ID
											--						) as Qry ON I.Increment_Effective_Date = Qry.Effective_Date and I.Emp_ID = Qry.Emp_ID
											--						WHERE I.Branch_ID <> @Branch_Id_Cur and (EM.Emp_Left ='N' or (EM.Emp_Left='Y' and EM.Emp_Left_Date >= @To_Date))
											--					)
											--					Where Branch_Id = @Branch_Id_Cur
											
											--commented By Jimit 17112018

											Update  #Monthly_Attrition_Report
											set Transfered_to = ( SELECT COUNT(*) From T0080_EMP_MASTER EM WITH (NOLOCK) INNER Join
																				T0095_INCREMENT I WITH (NOLOCK) ON EM.Emp_ID = I.Emp_ID INNER JOIN																					
																				(
																					SELECT MAX(IE.Increment_ID) as Increment_ID,IE.Emp_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER Join
																							(
																								SELECT	Emp_ID,MAX(Increment_Effective_Date) as Effective_Date
																									FROM	T0095_INCREMENT WITH (NOLOCK)
																									Where	Increment_Effective_Date <= @To_Date And Cmp_ID = @Cmp_ID and Branch_ID = @Branch_Id_Cur 																					
																								GROUP BY Emp_ID
																							)as inn_Qry ON IE.Emp_ID = inn_Qry.Emp_ID AND IE.Increment_Effective_Date = inn_Qry.Effective_Date
																					GROUP BY IE.Emp_ID
																				) as Qry ON I.Increment_ID = Qry.Increment_ID and I.Emp_ID = Qry.Emp_ID
																	WHERE I.Branch_ID <> @Branch_Id_Cur and (EM.Emp_Left ='N' or (EM.Emp_Left='Y' and EM.Emp_Left_Date >= @To_Date))
																)
																Where Branch_Id = @Branch_Id_Cur
											--ended

											Update TT 
											set Present_Month_Emp = Inn_Qry.EMPID
											,CTC_Curr_Month = Inn_Qry.CTC
											From #Monthly_Attrition_Report TT Inner Join
											(Select COUNT(I.Emp_ID) as EMPID,SUM(I.CTC) as CTC,I.Branch_ID as BranchID 
																	 From T0080_EMP_MASTER EM WITH (NOLOCK) Inner JOIN T0095_INCREMENT I WITH (NOLOCK) ON EM.Emp_ID = I.Emp_ID
																	 Inner JOIN(
																			   SELECT MAX(Increment_ID) as Increment_ID,IE.Emp_ID From T0095_INCREMENT IE WITH (NOLOCK) 
																				   Inner JOIN
																					(	
																						SELECT MAX(Increment_Effective_Date) as Effective_Date,Emp_ID FROM T0095_INCREMENT WITH (NOLOCK)
																						Where Increment_Effective_Date <= @To_Date AND Cmp_ID = @Cmp_ID
																						Group By Emp_ID
																					) as Inn_Qry On IE.Increment_Effective_Date = Inn_Qry.Effective_Date and IE.Emp_ID = Inn_Qry.Emp_ID
																				Group By IE.Emp_ID
																				) as Qry
																	 on I.Increment_ID = Qry.Increment_ID and I.Emp_ID = Qry.Emp_ID
																	 Where I.Branch_ID = @Branch_Id_Cur and (EM.Emp_Left ='N' or (EM.Emp_Left='Y' and EM.Emp_Left_Date >= @To_Date))
																	 Group By I.Branch_ID
											) as Inn_Qry On TT.Branch_Id = Inn_Qry.BranchID
													Where Branch_Id = @Branch_Id_Cur
										
													
										update #Monthly_Attrition_Report
										Set Attrition_analysis = CASE WHEN Isnull(Exit_Curr_Month,0) > 0 THEN (Isnull(Exit_Curr_Month,0)/(isnull(Total_Beging_HeadCount,0) + ISNULL(New_join_Curr_Month,0)))*1200 Else 0 End
										Where Branch_Id = @Branch_Id_Cur
										
									fetch next from Allow_Dedu_Cursor1 into @Branch_Id_Cur,@Branch_name 
								End
								
						close Allow_Dedu_Cursor1	
						deallocate Allow_Dedu_Cursor1

						if @Flag = 0 
							Begin 
								Select BM.Branch_Name,@From_Date as From_Date,@To_Date as To_Date,-- MAR.*
									MAR.Cmp_ID,MAR.Branch_Id,Total_Beging_HeadCount,New_join_Curr_Month,Exit_Curr_Month,Transfered_from,
									Transfered_to,Present_Month_Emp,CTC_Prev_Month,CTC_Curr_Month,Attrition_analysis,BM.Branch_Address,Cm.Cmp_Name,Cm.Cmp_Address From #Monthly_Attrition_Report MAR 
									Inner JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On MAR.Branch_Id = BM.Branch_ID
									Inner JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) On Cm.Cmp_Id = MAR.Cmp_ID
									where Total_Beging_HeadCount <> 0
								Union ALL
								Select 'Total' as Branch_Name,'' as From_Date,'' as To_Date,-- MAR.*
									0 as Cmp_ID,9999 as Branch_Id,SUM(Total_Beging_HeadCount) as Total_Beging_HeadCount,SUM(New_join_Curr_Month) as New_join_Curr_Month,SUM(Exit_Curr_Month) as Exit_Curr_Month,
									SUM(Transfered_from) as Transfered_from,SUM(Transfered_to) as Transfered_to,SUM(Present_Month_Emp) as Present_Month_Emp,SUM(CTC_Prev_Month) as CTC_Prev_Month,SUM(CTC_Curr_Month) as CTC_Curr_Month,
									0  as Attrition_analysis,'' as Branch_Address,'' as Cmp_Name,'' as Cmp_Address 
									From #Monthly_Attrition_Report MAR 
									Inner JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On MAR.Branch_Id = BM.Branch_ID
									Inner JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) On Cm.Cmp_Id = MAR.Cmp_ID
									where Total_Beging_HeadCount <> 0
							End 
						Else
							Begin
								Select BM.Branch_Name as 'Branch Name' ,Total_Beging_HeadCount as 'Total Begining Count(Prev)',
									New_join_Curr_Month as 'New Joning',Exit_Curr_Month as 'Exit Month',Transfered_from as 'Transfered From',
									Transfered_to as 'Transfered To',Present_Month_Emp as 'Present Month Employee',CTC_Prev_Month as 'CTC(Previous Month)',CTC_Curr_Month as 'CTC(Present Month)',
									Attrition_analysis as 'Attrition analysis' From #Monthly_Attrition_Report MAR 
									Inner JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On MAR.Branch_Id = BM.Branch_ID
									Inner JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) On Cm.Cmp_Id = MAR.Cmp_ID
									where Total_Beging_HeadCount <> 0
								Union ALL
								Select 'Total' as 'Branch Name',SUM(Total_Beging_HeadCount) as 'Total Begining Count(Prev)',SUM(New_join_Curr_Month) as 'New Joning',
									SUM(Exit_Curr_Month) as 'Exit Month',
									SUM(Transfered_from) as 'Transfered From',SUM(Transfered_to) as 'Transfered To',SUM(Present_Month_Emp) as 'Present Month Employee',
									SUM(CTC_Prev_Month) as 'CTC(Previous Month)',SUM(CTC_Curr_Month) as 'CTC(Present Month)'
									,0 as 'Attrition analysis' 
									From #Monthly_Attrition_Report MAR 
									Inner JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On MAR.Branch_Id = BM.Branch_ID
									Inner JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) On Cm.Cmp_Id = MAR.Cmp_ID
									where Total_Beging_HeadCount <> 0
							End
				END
	ELSE IF @Report_Name = 0		------For Man Power	
		BEGIN
				
		
	
	IF Object_ID('tempdb..#Man_Power_Details_Report') is not null
		drop TABLE #Man_Power_Details_Report

			CREATE table #Man_Power_Details_Report
			(
				Group_Name			Varchar(50),				
				ON_Roll_Budgeted_strength Numeric default 0,
				ON_Roll_Actual_Strength numeric,
				OFF_Roll_Budgeted_strength Numeric default 0,
				OFF_Roll_Actual_Strength numeric default 0,
				Total_Budgeted_strength Numeric default 0, 
				Total_Actual_Strength numeric default 0
			)
	
		
	
		IF @SUMMARY = -1
			BEGIN 
					INSERT Into #Man_Power_Details_Report(Group_Name,ON_Roll_Actual_Strength)
					SELECT	Bm.Branch_Name,Count(Ec.Emp_ID) as ON_Roll_Actual_Strength
					from	#Emp_Cons Ec INNER JOIN
							T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
							T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
							T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
							(SELECT	I.Emp_Id,I.Branch_ID,Desig_ID,Dept_ID,I.Vertical_ID,I.SubVertical_ID
							 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
							 )I_Q ON I_Q.Emp_ID = EM.Emp_ID LEFT JOIN
							 T0030_BRANCH_MASTER Bm WITH (NOLOCK) On Bm.BRANCH_ID = I_Q.BRANCH_ID								
					WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y'	
					GROUP BY Ec.BRANCH_ID,Branch_Name
					
										
				
			END
		ELSE IF @SUMMARY = 1
			BEGIN 
				INSERT Into #Man_Power_Details_Report(Group_Name,ON_Roll_Actual_Strength)
				SELECT	GM.Grd_Name,Count(Ec.Emp_ID) as ON_Roll_Actual_Strength
				from	#Emp_Cons Ec INNER JOIN
						T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
						T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
						T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
							(SELECT	I.Emp_Id,I.Grd_ID
							 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
							 )I_Q ON I_Q.Emp_ID = EM.Emp_ID LEFT JOIN
						 T0040_GRADE_MASTER GM WITH (NOLOCK) On GM.Grd_ID = I_Q.Grd_ID								
				WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y'	
				GROUP BY Gm.grd_Id,GM.Grd_Name				
						
			END	
		ELSE IF @SUMMARY = 2
			BEGIN 
				 INSERT Into #Man_Power_Details_Report(Group_Name,ON_Roll_Actual_Strength)
					SELECT	c.Cat_Name,Count(Ec.Emp_ID) as ON_Roll_Actual_Strength
					from	#Emp_Cons Ec INNER JOIN
							T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
							T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
							T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
								(SELECT	I.Emp_Id,I.Cat_ID
								 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
								 )I_Q ON I_Q.Emp_ID = EM.Emp_ID LEFT JOIN
							 T0030_CATEGORY_MASTER C WITH (NOLOCK) On C.Cat_ID = I_Q.Cat_ID								
					WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y'	
					GROUP BY c.cat_ID,c.cat_Name
					
					
			END						
		ELSE IF @SUMMARY = 3
			BEGIN 
				 INSERT Into #Man_Power_Details_Report(Group_Name,ON_Roll_Actual_Strength)
					SELECT	Dm.Dept_Name,Count(Ec.Emp_ID) as ON_Roll_Actual_Strength
					from	#Emp_Cons Ec INNER JOIN
							T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
							T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
							T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
								(SELECT	I.Emp_Id,I.Dept_Id
								 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
								 )I_Q ON I_Q.Emp_ID = EM.Emp_ID LEFT JOIN
							 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) On Dm.Dept_Id = I_Q.Dept_Id								
					WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y'	
					GROUP BY Dm.Dept_Id,Dm.Dept_Name
												
			END		
		ELSE IF @SUMMARY = 4
			BEGIN 
				 INSERT Into #Man_Power_Details_Report(Group_Name,ON_Roll_Actual_Strength)
					SELECT	Dm.Desig_Name,Count(Ec.Emp_ID) as ON_Roll_Actual_Strength
					from	#Emp_Cons Ec INNER JOIN
							T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
							T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
							T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
								(SELECT	I.Emp_Id,I.Desig_Id
								 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
								 )I_Q ON I_Q.Emp_ID = EM.Emp_ID LEFT JOIN
							 T0040_DESIGNATION_MASTER DM WITH (NOLOCK) On Dm.Desig_ID = I_Q.Desig_Id								
					WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y'	
					GROUP BY Dm.Desig_Id,Dm.Desig_Name
												
			END
		ELSE IF @SUMMARY = 5
			BEGIN 
				 INSERT Into #Man_Power_Details_Report(Group_Name,ON_Roll_Actual_Strength)
					SELECT	Tm.[Type_Name],Count(Ec.Emp_ID) as ON_Roll_Actual_Strength
					from	#Emp_Cons Ec INNER JOIN
							T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
							T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
							T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
								(SELECT	I.Emp_Id,I.[Type_ID]
								 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
								 )I_Q ON I_Q.Emp_ID = EM.Emp_ID LEFT JOIN
							 T0040_TYPE_MASTER TM WITH (NOLOCK) On Tm.[Type_ID] = I_Q.[Type_ID]								
					WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y'	
					GROUP BY Tm.[Type_ID],Tm.[Type_Name]
												
			END	
		ELSE IF @SUMMARY = 6
			BEGIN 
				 INSERT Into #Man_Power_Details_Report(Group_Name,ON_Roll_Actual_Strength)
					SELECT	V.Vertical_Name,Count(Ec.Emp_ID) as ON_Roll_Actual_Strength
					from	#Emp_Cons Ec INNER JOIN
							T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
							T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
							T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
								(SELECT	I.Emp_Id,I.Vertical_ID
								 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
								 )I_Q ON I_Q.Emp_ID = EM.Emp_ID LEFT JOIN
							 T0040_Vertical_Segment V WITH (NOLOCK) On V.Vertical_ID = I_Q.Vertical_ID								
					WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y'	
					GROUP BY V.Vertical_ID,V.Vertical_Name
												
			END
		ELSE IF @SUMMARY = 7
			BEGIN 
						 INSERT Into #Man_Power_Details_Report(Group_Name,ON_Roll_Actual_Strength)
							SELECT	SV.SubVertical_Name,Count(Ec.Emp_ID) as ON_Roll_Actual_Strength
							from	#Emp_Cons Ec INNER JOIN
									T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
									T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
									T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
										(SELECT	I.Emp_Id,I.SubVertical_ID
										 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
										 )I_Q ON I_Q.Emp_ID = EM.Emp_ID LEFT JOIN
									 T0050_SubVertical SV WITH (NOLOCK) On SV.SubVertical_ID = I_Q.SubVertical_ID								
							WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y'	
							GROUP BY SV.SubVertical_ID,SV.SubVertical_Name
														
					END
		ELSE IF @SUMMARY = 8
			BEGIN 
				 INSERT Into #Man_Power_Details_Report(Group_Name,ON_Roll_Actual_Strength)
					SELECT	SB.SubBranch_Name,Count(Ec.Emp_ID) as ON_Roll_Actual_Strength
					from	#Emp_Cons Ec INNER JOIN
							T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
							T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
							T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
								(SELECT	I.Emp_Id,I.SubBranch_ID
								 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
								 )I_Q ON I_Q.Emp_ID = EM.Emp_ID LEFT JOIN
							 T0050_SubBranch SB WITH (NOLOCK) On SB.SubBranch_ID = I_Q.SubBranch_ID								
					WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y'	
					GROUP BY SB.SubBranch_ID,SB.SubBranch_Name
														
					END
	ELSE IF @SUMMARY = 9
			BEGIN 
				 INSERT Into #Man_Power_Details_Report(Group_Name,ON_Roll_Actual_Strength)
					SELECT	CA.Cat_Name ,Count(Ec.Emp_ID) as ON_Roll_Actual_Strength
					from	#Emp_Cons Ec INNER JOIN
							T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
							T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
							T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
								(SELECT	I.Emp_Id,I.Cat_ID
								 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
								 )I_Q ON I_Q.Emp_ID = EM.Emp_ID LEFT JOIN
							 T0030_CATEGORY_MASTER CA WITH (NOLOCK) On CA.cat_Id = I_Q.cat_Id								
					WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y'	
					GROUP BY CA.Cat_ID,Ca.Cat_Name
														
					END				
		ELSE IF @SUMMARY = 10
			BEGIN 
				 INSERT Into #Man_Power_Details_Report(Group_Name,ON_Roll_Actual_Strength)
					SELECT	Cc.Center_Name,Count(Ec.Emp_ID) as ON_Roll_Actual_Strength
					from	#Emp_Cons Ec INNER JOIN
							T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
							T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
							T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
								(SELECT	I.Emp_Id,I.Center_ID
								 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
								 )I_Q ON I_Q.Emp_ID = EM.Emp_ID LEFT JOIN
							 T0040_Cost_center_Master CC WITH (NOLOCK) On CC.Center_ID = I_Q.Center_ID								
					WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y'	
					GROUP BY CC.Center_ID,Cc.Center_Name
														
					END
		
		
		SELECT	GROUP_NAME,ON_ROLL_BUDGETED_STRENGTH,ON_ROLL_ACTUAL_STRENGTH,
				OFF_ROLL_BUDGETED_STRENGTH,OFF_ROLL_ACTUAL_STRENGTH,(ON_ROLL_BUDGETED_STRENGTH + OFF_ROLL_BUDGETED_STRENGTH) AS TOTAL_BUDGETED_STRENGTH,
				(ON_ROLL_ACTUAL_STRENGTH + OFF_ROLL_ACTUAL_STRENGTH) AS TOTAL_ACTUAL_STRENGTH
		FROM 	#MAN_POWER_DETAILS_REPORT
		UNION ALL	
		SELECT	'TOTAL' AS GROUP_NAME,SUM(ON_ROLL_BUDGETED_STRENGTH) AS ON_ROLL_BUDGETED_STRENGTH,SUM(ON_ROLL_ACTUAL_STRENGTH) AS ON_ROLL_ACTUAL_STRENGTH,
				SUM(OFF_ROLL_BUDGETED_STRENGTH) AS OFF_ROLL_BUDGETED_STRENGTH,SUM(OFF_ROLL_ACTUAL_STRENGTH) AS OFF_ROLL_ACTUAL_STRENGTH,
				(SUM(ON_ROLL_BUDGETED_STRENGTH) + SUM(OFF_ROLL_BUDGETED_STRENGTH)) AS TOTAL_BUDGETED_STRENGTH,
				(SUM(ON_ROLL_ACTUAL_STRENGTH) + SUM(OFF_ROLL_ACTUAL_STRENGTH)) AS TOTAL_BUDGETED_STRENGTH
		FROM 	#MAN_POWER_DETAILS_REPORT	
			
						
		END
	ELSE IF @Report_Name = 2   ------For Man Power Age_Analysis
		BEGIN
			
			
			IF Object_ID('tempdb..#Man_Power_Age_Analysis_Report') is not null
			drop TABLE #Man_Power_Age_Analysis_Report

				CREATE table #Man_Power_Age_Analysis_Report
				(
					Age_Band			Varchar(50),									
					Total				NUMERIC
				)
			
			
			
			INSERT INTO #Man_Power_Age_Analysis_Report(Age_Band,Total)
			SELECT 'Upto 20 Years',count(EC.EMP_ID)
			FROM	#Emp_Cons Ec INNER JOIN
					T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
					T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
					T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
						(SELECT	I.Emp_Id,I.Center_ID
						 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
						 )I_Q ON I_Q.Emp_ID = EM.Emp_ID 								
			WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y' and dbo.Age(EM.Date_Of_Birth,getdate(),'y') <= 20
			UNION ALL
			SELECT '21 to 30 Years',count(EC.EMP_ID)
			FROM	#Emp_Cons Ec INNER JOIN
					T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
					T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
					T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
						(SELECT	I.Emp_Id,I.Center_ID
						 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
						 )I_Q ON I_Q.Emp_ID = EM.Emp_ID 								
			WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y' and dbo.Age(EM.Date_Of_Birth,getdate(),'y') BETWEEN 20 and 31
			UNION ALL
			SELECT '31 to 40 Years',count(EC.EMP_ID)
			FROM	#Emp_Cons Ec INNER JOIN
					T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
					T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
					T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
						(SELECT	I.Emp_Id,I.Center_ID
						 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
						 )I_Q ON I_Q.Emp_ID = EM.Emp_ID 								
			WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y' and dbo.Age(EM.Date_Of_Birth,getdate(),'y') BETWEEN 30 and 41
			UNION ALL
			SELECT '41 to 50 Years',count(EC.EMP_ID)
			FROM	#Emp_Cons Ec INNER JOIN
					T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
					T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
					T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
						(SELECT	I.Emp_Id,I.Center_ID
						 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
						 )I_Q ON I_Q.Emp_ID = EM.Emp_ID 								
			WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y' and dbo.Age(EM.Date_Of_Birth,getdate(),'y') BETWEEN 40 and 51
			UNION ALL
			SELECT '51 to 60 Years',count(EC.EMP_ID)
			FROM	#Emp_Cons Ec INNER JOIN
					T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
					T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
					T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
						(SELECT	I.Emp_Id,I.Center_ID
						 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
						 )I_Q ON I_Q.Emp_ID = EM.Emp_ID 								
			WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y' and dbo.Age(EM.Date_Of_Birth,getdate(),'y') BETWEEN 50 and 61
			UNION ALL
			SELECT 'above 60 Years',count(EC.EMP_ID)
			FROM	#Emp_Cons Ec INNER JOIN
					T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
					T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
					T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
						(SELECT	I.Emp_Id,I.Center_ID
						 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
						 )I_Q ON I_Q.Emp_ID = EM.Emp_ID 								
			WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y' and dbo.Age(EM.Date_Of_Birth,getdate(),'y') > 60
			UNION ALL
			SELECT 'Total',COUNT(EC.Emp_ID)
			FROM	#Emp_Cons Ec INNER JOIN
					T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
					T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
					T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
						(SELECT	I.Emp_Id,I.Center_ID
						 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
						 )I_Q ON I_Q.Emp_ID = EM.Emp_ID 								
			WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y' 
			UNION ALL
			SELECT 'Avg',(COUNT(EC.Emp_ID)/6)
			FROM	#Emp_Cons Ec INNER JOIN
					T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
					T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
					T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
						(SELECT	I.Emp_Id,I.Center_ID
						 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
						 )I_Q ON I_Q.Emp_ID = EM.Emp_ID 								
			WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y' 
			
			
			
			SELECT * FROM #Man_Power_Age_Analysis_Report
			
		END
	ELSE IF @Report_Name = 3    ------For Man Power Gender_Analysis
		BEGIN
			IF Object_ID('tempdb..#Man_Power_Gender_Analysis_Report') is not null
			drop TABLE #Man_Power_Gender_Analysis_Report

				CREATE table #Man_Power_Gender_Analysis_Report
				(
					Gender			Varchar(50),									
					Total				NUMERIC
				)	
				
			INSERT INTO #Man_Power_Gender_Analysis_Report(Gender,Total)
			SELECT 'Male',count(EC.EMP_ID)
			FROM	#Emp_Cons Ec INNER JOIN
					T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
					T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
					T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
						(SELECT	I.Emp_Id,I.Center_ID
						 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
						 )I_Q ON I_Q.Emp_ID = EM.Emp_ID 								
			WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y' and EM.Gender = 'M'
			UNION ALL
			SELECT 'Female',count(EC.EMP_ID)
			FROM	#Emp_Cons Ec INNER JOIN
					T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
					T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
					T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
						(SELECT	I.Emp_Id,I.Center_ID
						 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
						 )I_Q ON I_Q.Emp_ID = EM.Emp_ID 								
			WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y' and EM.Gender = 'F'	
			UNION ALL
			SELECT 'Total',count(EC.EMP_ID)
			FROM	#Emp_Cons Ec INNER JOIN
					T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
					T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
					T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
						(SELECT	I.Emp_Id,I.Center_ID
						 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
						 )I_Q ON I_Q.Emp_ID = EM.Emp_ID 								
			WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y' --and EM.Gender = 'F'	
			
			
			SELECT * FROM #Man_Power_Gender_Analysis_Report		
		END
	ELSE IF @Report_Name = 4   ------For Man Power Cost_Analysis
		BEGIN
			IF Object_ID('tempdb..#Man_Power_Cost_Analysis_Report') is not null
			drop TABLE #Man_Power_Cost_Analysis_Report

				CREATE table #Man_Power_Cost_Analysis_Report
				(
					Grade			Varchar(50),									
					Nos				NUMERIC,
					Cost			Numeric(18,2),
					Avgerage		NUMERIC default 0,
					Age				NUMERIC default 0
				)	
				
			INSERT INTO #Man_Power_Cost_Analysis_Report(Grade,Nos,Cost)
			SELECT	GM.Grd_Name,Count(Ec.Emp_ID),SUM(I_Q.CTC)
				from	#Emp_Cons Ec INNER JOIN
						T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID INNER JOIN  
						T0010_company_master Cm WITH (NOLOCK) ON EM.Cmp_ID = Cm.Cmp_ID LEFT OUTER JOIN 
						T0100_LEFT_EMP EL WITH (NOLOCK) ON Em.Emp_Id = EL.Emp_Id INNER JOIN
							(SELECT	I.Emp_Id,I.Grd_ID,I.CTC
							 FROM	T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons IEC ON I.Increment_ID = IEC.Increment_ID
							 )I_Q ON I_Q.Emp_ID = EM.Emp_ID LEFT JOIN
						 T0040_GRADE_MASTER GM WITH (NOLOCK) On GM.Grd_ID = I_Q.Grd_ID								
				WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y'
				GROUP BY Gm.grd_Id,GM.Grd_Name--,I_Q.CTC
					
			
			SELECT	Grade,Nos,Cost,Avgerage,Age
			FROM	#Man_Power_Cost_Analysis_Report
			UNION ALL
			SELECT	'Total',Sum(Nos),SUM(CosT),SUM(Avgerage),SUM(Age)
			FROM	#Man_Power_Cost_Analysis_Report
			
					
			
		END
	ELSE IF @Report_Name = 5   ------For New_Joining_Details
		BEGIN
		
		IF Object_ID('tempdb..#New_Joining_Details_Report') is not null
		drop TABLE #New_Joining_Details_Report
		
		CREATE table #New_Joining_Details_Report
			(
				Emp_Id						Numeric,
				Emp_Code					Varchar(50),
				Name_Of_Employee			Varchar(250),
				Designation					Varchar(50),
				Department					Varchar(50),
				Grade						Varchar(50),
				Location					Varchar(50),
				Source_Of_Recruitment		Varchar(50),
				Reason_of_Hiring			Varchar(50),
				Position_Requisition_Date	Varchar(50),
				Date_Of_Offer				Varchar(50),
				Date_Of_Join				VARCHAR(50),
				agency_Consultant_Fee		Varchar(50),
				other_hiring_cost			Varchar(50),
				Induction_Feedback_Taken	Varchar(50),
				Remarks						Varchar(50)						
			)				
		
		Insert	Into #New_Joining_Details_Report(Emp_Id,Emp_Code,Date_Of_Join,Name_Of_Employee,Designation,Department,Grade,Location)
		SELECT	Ec.EMP_ID,EM.Alpha_Emp_Code,cONVERT(varchar(30),EM.Date_Of_Join,103),EM.Emp_Full_Name,DGM.Desig_Name,DM.Dept_Name,GM.Grd_Name,BM.Branch_Name
		FROM	#Emp_Cons Ec
				INNER JOIN		T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EC.Emp_ID 
				INNER JOIN		T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = Ec.INCREMENT_ID and I.Emp_ID = Ec.EMP_ID 
				LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_ID = GM.Grd_ID
				LEFT OUTER JOIN	T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I.Type_ID = ETM.Type_ID			
				LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.Desig_Id = DGM.Desig_Id 
				LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.Dept_Id = DM.Dept_Id		
				INNER JOIN 		T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.BRANCH_ID = BM.BRANCH_ID 
				Left OUTER JOIN T0040_Vertical_Segment Vs WITH (NOLOCK) on vs.Vertical_ID = I.Vertical_ID 	 
				Left Outer JOIN T0050_SubVertical Sv WITH (NOLOCK) On sv.SubVertical_ID = I.SubVertical_ID  
				Left Outer JOIN T0040_Cost_center_Master CCM WITH (NOLOCK) On ccm.center_id = I.Center_ID	 								
		WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left <> 'Y'
				and	EM.Date_Of_Join >= @From_DAte and EM.Date_Of_Join <= @To_Date		
		
		SELECT	ROW_NUMBER() OVER(ORDER BY  Emp_Id   ASC) AS SR_NO,* 
		INTO	#New_Joining_Details_Report1
		FROM	#New_Joining_Details_Report
		
		
		ALter TABLE  #New_Joining_Details_Report1 DROP COLUMN Emp_Id
		
		SELECT	* From	#New_Joining_Details_Report1 	
					
		
		
		END
	ELSE IF @Report_Name = 6   ------For Transfer_Employee_Details
		BEGIN
			IF Object_ID('tempdb..#Transfer_Employee_Details_Report') is not null
		drop TABLE #Transfer_Employee_Details_Report
		
		CREATE table #Transfer_Employee_Details_Report
			(
				Emp_Id						Numeric,
				Emp_Code					Varchar(50),
				Name_Of_Employee			Varchar(250),
				Designation					Varchar(50),
				Department					Varchar(50),
				Grade						Varchar(50),
				DOJ_Transfer_In_Location	Varchar(50),				
				Reason_Of_Transfer_In		Varchar(50),
				Transfer_From_Location		Varchar(50),
				Transfer_In_Company_Location Varchar(50),				
				Remarks						Varchar(50)						
			)				
		
		Create Table #Emp_Cons1 
		 (      
		   Emp_ID numeric ,     
		   Branch_ID numeric,
		   Increment_ID numeric    
		 )      
		
		
		
		print @Branch_ID
		if @Constraint <> ''
			begin
				Insert Into #Emp_Cons1
				Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
			end
		else 
			begin
				Insert Into #Emp_Cons1      
				  select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons where 
				  cmp_id=@Cmp_ID 
				 and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
			   and Isnull(Branch_ID,0) = isnull(@Branch_ID ,Isnull(Branch_ID,0))      
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
							or (@To_Date >= left_date  and  @From_Date <= left_date )) 
							order by Emp_ID
							
				delete  from #emp_cons1 where Increment_ID not in (select max(Increment_ID) from T0095_Increment WITH (NOLOCK)
					where  Increment_effective_Date <= @to_date
					group by emp_ID)
			end
		
		
		Insert	Into #Transfer_Employee_Details_Report(Emp_Id,Emp_Code,Name_Of_Employee,Designation,Department,Grade,DOJ_Transfer_In_Location,Transfer_From_Location,Transfer_In_Company_Location)
		SELECT	Ec.EMP_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DGM.Desig_Name,DM.Dept_Name,GM.Grd_Name,
				cm1.Cmp_Name,bm.Branch_Name,bm1.Branch_Name
		FROM	T0095_EMP_COMPANY_TRANSFER ECM WITH (NOLOCK)				
				INNER JOIN		T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = ECM.Old_Emp_Id
				Inner join		#Emp_Cons1 Ec On ECM.Old_EMP_ID = EC.EMP_ID
				INNER JOIN		T0010_COMPANY_MASTER Cm WITH (NOLOCK) On Cm.Cmp_Id = ECM.Old_Cmp_ID
				INNER JOIN		T0010_COMPANY_MASTER Cm1 WITH (NOLOCK) On Cm1.Cmp_Id = ECM.NEW_Cmp_ID
				--INNER JOIN		T0095_INCREMENT I ON I.Increment_ID = Ec.INCREMENT_ID and I.Emp_ID = Ec.EMP_ID 
				LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON ECM.New_Grd_ID = GM.Grd_ID
				LEFT OUTER JOIN	T0040_TYPE_MASTER ETM WITH (NOLOCK) ON ECM.New_Type_ID = ETM.Type_ID			
				LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON ECM.New_Desig_Id = DGM.Desig_Id 
				LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON ECM.New_Dept_Id = DM.Dept_Id				
				Left OUTER JOIN T0040_Vertical_Segment Vs WITH (NOLOCK) on ECM.New_Client_Id = Vs.Vertical_ID 	 
				Left Outer JOIN T0050_SubVertical Sv WITH (NOLOCK) On ECM.New_SubVertical_ID = sv.SubVertical_ID  
				--Left Outer JOIN T0040_Cost_center_Master CCM On ECM.New_center_id = I.Center_ID								 												
				INNER JOIN 		T0030_BRANCH_MASTER BM WITH (NOLOCK) ON ecm.OLd_BRANCH_ID = BM.BRANCH_ID and ecm.Old_Branch_Id = bm.Branch_ID
				INNER JOIN 		T0030_BRANCH_MASTER BM1 WITH (NOLOCK) ON ecm.New_BRANCH_ID = BM1.BRANCH_ID and ecm.New_Branch_Id = bm1.Branch_ID							 								
		WHERE	ECM.Old_Cmp_Id = @Cmp_Id 
				and	ECM.Effective_Date >= @From_DAte and ECM.Effective_Date <= @To_Date		
		
		SELECT	ROW_NUMBER() OVER(ORDER BY  Emp_Id   ASC) AS SR_NO,* 
		INTO	#Transfer_Employee_Details_Report1
		FROM	#Transfer_Employee_Details_Report
		
		
		ALter TABLE  #Transfer_Employee_Details_Report1 DROP COLUMN Emp_Id
		
		SELECT	* From	#Transfer_Employee_Details_Report1 
		
		END
	ELSE IF @Report_Name = 7    ------For Left_Details
		BEGIN
			
			declare @string as varchar(max)
			
			IF Object_ID('tempdb..#Left_Details_Report') is not null
			drop TABLE #Left_Details_Report
		
			CREATE table #Left_Details_Report
			(
				Emp_Id						Numeric,
				Emp_Code					Varchar(50),
				Name_Of_Employee			Varchar(250),
				Designation					Varchar(50),
				Department					Varchar(50),
				Grade						Varchar(50),
				AGE							VARCHAR(50),
				DOJ							VARCHAR(50),
				DOL							VARCHAR(50),
				Company_Location					Varchar(50),
				Manager_Name				Varchar(50),
				FnF_Status					Varchar(50)									
			)	
			
			set @string = 'ALter table  #Left_Details_Report Add FnF_Current_Stage Varchar(50);
						   ALter table  #Left_Details_Report Add Main_Reason_For_Separation Varchar(50);
						   ALter table  #Left_Details_Report Add Remarks Varchar(50);
						   ALter table  #Left_Details_Report Add New_Assig_Industry Varchar(50);
						   ALter table  #Left_Details_Report Add New_Assig_Designation Varchar(50);
						   ALter table  #Left_Details_Report Add Rise_In_Salary Varchar(50);
						   ALter table  #Left_Details_Report Add Exit_Interview_Taken_By Varchar(50);
						   ALter table  #Left_Details_Report Add Company_Culture Varchar(50);
						   ALter table  #Left_Details_Report Add Decision_Making_Process Varchar(50);
						   ALter table  #Left_Details_Report Add Transparency Varchar(50);
						   ALter table  #Left_Details_Report Add Communication Varchar(50);
						   ALter table  #Left_Details_Report Add Job_Profile Varchar(50);
						   ALter table  #Left_Details_Report Add Empowerment Varchar(50);
						   ALter table  #Left_Details_Report Add Job_rotation Varchar(50);
						   ALter table  #Left_Details_Report Add Job_enrichment Varchar(50);
						   ALter table  #Left_Details_Report Add Department_set_up Varchar(50);
						   ALter table  #Left_Details_Report Add Reporting_system Varchar(50);
						   ALter table  #Left_Details_Report Add Pattern_of_communication Varchar(50);
						   ALter table  #Left_Details_Report Add Cooperation_within_department Varchar(50);
						   ALter table  #Left_Details_Report Add Working_Condition Varchar(50);
						   ALter table  #Left_Details_Report Add Salary_structure Varchar(50);
						   ALter table  #Left_Details_Report Add Increment_pattern Varchar(50);
						   ALter table  #Left_Details_Report Add Leave_facility Varchar(50);
						   ALter table  #Left_Details_Report Add Welfare_facilities Varchar(50);
						   ALter table  #Left_Details_Report Add Reward_recognition Varchar(50);
						   ALter table  #Left_Details_Report Add Career_growth_prospects Varchar(50);
						   ALter table  #Left_Details_Report Add Training_development Varchar(50);
						   ALter table  #Left_Details_Report Add Work_life_balance Varchar(50);
						   ALter table  #Left_Details_Report Add Additional_assignments Varchar(50);
						   ALter table  #Left_Details_Report Add HOD Varchar(50);
						   ALter table  #Left_Details_Report Add Immediate_superior Varchar(50);
						   ALter table  #Left_Details_Report Add Subordinates Varchar(50);
						   ALter table  #Left_Details_Report Add Colleagues Varchar(50);
						   ALter table  #Left_Details_Report Add Peers Varchar(50);'
						   
			print @string
			exec(@string)
			
			
		   --select * from #Emp_Cons where emp_Id in (17028,15214,16480)
			--Select @From_DAte,@To_Date
			
			Insert	Into #Left_Details_Report(Emp_Id,Emp_Code,Name_Of_Employee,Designation,Department,Grade,Company_Location,Age,DOJ,DOL,Manager_Name,FnF_Status)
			SELECT	EM.EMP_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DGM.Desig_Name,DM.Dept_Name,GM.Grd_Name,BM.Branch_Name
					,dbo.Age(EM.Date_Of_Birth,GETDATE(),'Y'),EM.Date_Of_Join,EM.Emp_Left_Date,
					(SELECT DISTINCT REM.EMP_FULL_NAME + ' , '  
						FROM T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK)
						INNER JOIN  ( 
										SELECT EMP_ID , MAX(EFFECT_DATE) AS EFFECT_DATE 
										FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
										WHERE	 EFFECT_DATE <= GETDATE()
										GROUP BY Emp_ID	
									)MAX_RPT ON MAX_RPT.Emp_ID = RD.Emp_ID AND MAX_RPT.EFFECT_DATE = RD.Effect_Date
						INNER JOIN T0080_EMP_MASTER REM WITH (NOLOCK) ON REM.EMP_ID = RD.R_EMP_ID
						INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON REM.CMP_ID = CM.CMP_ID
						WHERE RD.EMP_ID = EM.EMP_ID
						FOR XML PATH('')
					) AS REPORTING_MANAGER,
					(CASE when EM.IS_Emp_FNF = 1 then 'yes' else 'no' end)
			FROM	T0080_EMP_MASTER EM	WITH (NOLOCK)
					inner join ( select I.Emp_Id , Grd_ID,Branch_ID,Desig_ID,Dept_ID,Type_ID,I.Cat_ID,I.Vertical_ID,I.SubVertical_ID,I.Center_ID  from t0095_Increment I WITH (NOLOCK) inner join 
										( select max(Increment_ID) as Increment_ID , Emp_ID from t0095_Increment WITH (NOLOCK)	
										  where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
										 group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q on EM.Emp_ID = I_Q.Emp_ID 								
					LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
					LEFT OUTER JOIN	T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID			
					LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
					LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id		
					INNER JOIN 		T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
					Left OUTER JOIN T0040_Vertical_Segment Vs WITH (NOLOCK) on vs.Vertical_ID = I_Q.Vertical_ID 	 
					Left Outer JOIN T0050_SubVertical Sv WITH (NOLOCK) On sv.SubVertical_ID = I_Q.SubVertical_ID  
					Left Outer JOIN T0040_Cost_center_Master CCM WITH (NOLOCK) On ccm.center_id = I_Q.Center_ID
					LEFT outer join T0100_LEFT_EMP Ecm WITH (NOLOCK) On Ecm.Emp_Id = EM.Emp_ID
					--Inner join		T0080_EMP_MASTER EM1 On Em1.Emp_ID = Ec.EMP_ID
					--left OUTER JOIN T0090_EMP_REPORTING_DETAIL RM On rm.R_Emp_ID = Em1.Emp_ID 												
			WHERE	EM.Cmp_ID = @Cmp_Id and EM.Emp_Left = 'Y' and ecm.Left_Reason <> 'Default Company Transfer'
					and	EM.Emp_Left_Date >= @From_DAte and EM.Emp_Left_Date <= @To_Date
							
					
			SELECT	ROW_NUMBER() OVER(ORDER BY  Emp_Id   ASC) AS SR_NO,* 
			INTO	#Left_Details_Report1
			FROM	#Left_Details_Report
			
			select * from 	#Left_Details_Report1					
			
		END
	ELSE IF @Report_Name = 8       ------For Attrition_Report
		BEGIN
				IF Object_ID('tempdb..#Attrition_Report') is not null
				drop TABLE #Attrition_Report

				CREATE table #Attrition_Report
				(
					Cmp_ID				 NUMERIC,										
					Financial_Year		 varchar(20),
					Opening_HeadCount	 NUMERIC,
					New_joinees			 NUMERIC,
					Employee_Left		 NUMERIC,
					Closing_headcount	 NUMERIC,
					Attrition_Percentage NUMERIC(18,2)
				)
		
	
			declare @Temp_Date datetime
			declare @TempEnd_Date datetime
			Declare @count numeric 
			Declare @Month numeric 
			Declare @Year numeric 
			
			set @Temp_Date = @From_Date 
			set @TempEnd_Date = dateadd(mm,1,@From_Date ) - 1 
			set @count = 1 
						
				DECLARE @EmpId NUMERIC
			
				WHILE @Temp_Date <= @To_Date 
					Begin						
						set @Month = month(@TempEnd_Date)
						set @Year = year(@TempEnd_Date)
						
						Insert INTO #Attrition_Report(cmp_Id,Financial_Year)
						SELECT	@Cmp_Id,dbo.F_GET_MONTH_NAME(@Month) + ' - ' + CONVERT(varchar(20),@Year)
							
				Update #Attrition_Report
				set Opening_HeadCount = (Select count(EM.emp_id) as EmpID from T0080_EMP_MASTER EM WITH (NOLOCK)
										inner JOIN(
											Select I.Emp_ID,I.Branch_ID,I.CTC From T0095_INCREMENT I WITH (NOLOCK) Inner Join
											(
												SELECT MAX(Increment_ID) as Increment_Id,IE.Emp_ID From T0095_INCREMENT IE WITH (NOLOCK)
												Inner JOIN (
															Select MAX(Increment_Effective_Date) as Effective_Date,Emp_ID FROM T0095_INCREMENT WITH (NOLOCK)
															Where Increment_Effective_Date < @Temp_Date and Cmp_ID = @Cmp_ID 
															GROUP By Emp_ID
														   ) as Inn_Qry
												ON IE.Increment_Effective_Date = Inn_Qry.Effective_Date and IE.Emp_ID = Inn_Qry.Emp_ID
												GROUP BY IE.Emp_ID
											) as Qry On I.Emp_ID = Qry.Emp_ID AND I.Increment_Id = Qry.Increment_Id
										) As Qry_1 ON EM.Emp_ID = Qry_1.Emp_ID
										where EM.cmp_id = @Cmp_ID  and  EM.Date_Of_Join < @Temp_Date
										and (EM.Emp_Left ='N' or (EM.Emp_Left='Y' and EM.Emp_Left_Date >= @Temp_Date)))
				where 			Financial_Year = dbo.F_GET_MONTH_NAME(@Month) + ' - ' + CONVERT(varchar(20),@Year)							
			 
				Update #Attrition_Report 
				set New_joinees = 
								(Select COUNT(Emp_ID) from T0080_EMP_MASTER WITH (NOLOCK)
								Where Cmp_ID = @Cmp_ID and Date_Of_Join >= @Temp_Date and Date_Of_Join <= @TempEnd_date) 
				Where Financial_Year = dbo.F_GET_MONTH_NAME(@Month) + ' - ' + CONVERT(varchar(20),@Year) 
				
				Update #Attrition_Report 
				set Employee_Left = (SELECT COUNT(Emp_ID) FROM T0080_EMP_MASTER WITH (NOLOCK)
									 Where Emp_Left='Y' and Emp_Left_Date >= @Temp_Date AND Emp_Left_Date <= @TempEnd_date  And Cmp_ID = @Cmp_ID)
				Where Financial_Year = dbo.F_GET_MONTH_NAME(@Month) + ' - ' + CONVERT(varchar(20),@Year) 
				
				Update #Attrition_Report 
				set Closing_headcount = ISNULL(Opening_HeadCount,0) - (ISNULL(New_joinees,0) + ISNULL(Employee_Left,0))
				Where Financial_Year = dbo.F_GET_MONTH_NAME(@Month) + ' - ' + CONVERT(varchar(20),@Year)
				
				Update #Attrition_Report 
				set Attrition_Percentage = ((IsNULL(Employee_Left,0))/((IsNULL(Opening_HeadCount,0) + IsNULL(Closing_headcount,0))/2))
				Where Financial_Year = dbo.F_GET_MONTH_NAME(@Month) + ' - ' + CONVERT(varchar(20),@Year) 
					
					
					
						set @Temp_Date = dateadd(m,1,@Temp_date)
						set @TempEnd_date = dateadd(m,1,@TempEnd_date)
						set @count = @count + 1							
					end 
			Select * from #Attrition_Report
		
		
	END
		
RETURN 


