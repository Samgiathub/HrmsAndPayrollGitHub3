

CREATE  PROCEDURE [dbo].[P_GET_PROBATION_TRAINEE_LIST]
     @Cmp_ID numeric,
     @flag  varchar(10),
     @condition varchar(max),
     @Type varchar(30)='' 
AS
BEGIN
	SET NOCOUNT ON; 
	
	DECLARE @Review_Month numeric(18,0)
	DECLARE	@Completed_Month  numeric(18,0)
	DECLARE @Emp_ID  numeric(18,0)
	DECLARE @Review_Type  varchar(15)
	DECLARE @Date_Of_Join  DATETIME
	Declare @SqlQuery  NVarchar(max)
	DECLARE @ctr_Trainee_probation numeric(18,0)	
	DECLARE @new_Probation_date  DATETIME
	DECLARE @month numeric(18,0)
	DECLARE @Extend_Period NUMERIC(18,0)
	DECLARE @New_Probation_EndDate DATETIME
	DECLARE @Maxflag VARCHAR(15)
	DECLARE @Review_Total_month as NUMERIC(18,0)
	DECLARE @FinalExtend_Probation_EndDate DATETIME
	DECLARE @Is_Month_Days AS TINYINT
	
				SELECT    e.Alpha_Emp_Code,e.Emp_Full_Name,e.Emp_First_Name,e.Date_Of_Join, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, TM.Type_Name,
						  dbo.T0040_DESIGNATION_MASTER.Desig_Name, i.Emp_ID, i.Cmp_ID, i.Branch_ID, i.Cat_ID, i.Grd_ID, i.Dept_ID, i.Desig_Id, i.Type_ID, e.Emp_Left, 
						  e.Work_Email,cast('1900-01-01' as datetime) AS Probation_Date,'' as Review_By, 
						  --CASE WHEN @flag = 'Trainee' THEN Qry.Training_Month else Qry.Probation end as Completed_Month,
						  --CASE WHEN @flag = 'Trainee' THEN Qry.Trainee_Review else Qry.Probation_Review end as Review_Type
						 
						  CASE WHEN @flag = 'Trainee' THEN 
							   CASE WHEN ISNULL(e.Training_Month,0) > 0 THEN e.Training_Month else Qry.Training_Month END
						  ELSE CASE WHEN ISNULL(e.Probation,0) > 0 THEN e.Probation else Qry.Probation END
						  end as Completed_Month,
						  
						  CASE WHEN @flag = 'Trainee' THEN Qry.Trainee_Review else Qry.Probation_Review end as Review_Type,
						  
						  CASE WHEN @flag = 'Trainee' THEN 
							   CASE WHEN ISNULL(e.Training_Month,0) > 0 THEN e.Is_Trainee_Month_Days else Qry.Is_Trainee_Month_Days END
						  ELSE CASE WHEN ISNULL(e.Probation,0) > 0 THEN e.Is_Probation_Month_Days else Qry.Is_Probation_Month_Days END
						  end as Is_Month_Days,Qry.Probation_Review				  
				INTO  #PROBATION_TRAINEE_DETAILS	  		            
				FROM    dbo.T0080_EMP_MASTER AS e WITH (NoLock) INNER JOIN
						dbo.T0095_INCREMENT AS i  WITH (NoLock) ON e.Increment_ID = i.Increment_ID And e.Emp_id = I.Emp_Id INNER JOIN
							( SELECT G.Training_Month, G.Branch_Id , G.Probation,g.Trainee_Review,g.Probation_Review,Is_Probation_Month_Days ,Is_Trainee_Month_Days
								FROM T0040_General_Setting G  WITH (NoLock) INNER JOIN
									  (SELECT     MAX(For_Date) AS for_date, Branch_ID
										FROM          dbo.T0040_GENERAL_SETTING AS gs  WITH (NoLock) Where Cmp_ID = @Cmp_ID
										GROUP BY Branch_ID ) AS qry1 ON qry1.Branch_ID = g.Branch_ID AND qry1.For_Date=G.For_Date
							 ) AS Qry ON Qry.Branch_ID = i.Branch_ID LEFT OUTER JOIN
						dbo.T0030_BRANCH_MASTER  WITH (NoLock) ON i.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER  WITH (NoLock) ON i.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
						dbo.T0040_DESIGNATION_MASTER  WITH (NoLock) ON i.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
						dbo.T0040_TYPE_MASTER TM  WITH (NoLock) ON i.Type_ID = TM.Type_ID 
				WHERE  CASE WHEN @flag = 'Trainee' THEN e.Is_On_Training  else e.Is_On_Probation  end = 1
				and e.Cmp_ID=@Cmp_ID --and e.Emp_ID=21933
---select * from #PROBATION_TRAINEE_DETAILS--	where emp_id=21947

		DECLARE PROBATION_TRAINEE_DETAILS CURSOR FOR
				   SELECT Emp_ID,Completed_Month,Date_Of_Join,Review_Type,Is_Month_Days FROM #PROBATION_TRAINEE_DETAILS --where emp_id=21947
			OPEN PROBATION_TRAINEE_DETAILS
			FETCH NEXT FROM PROBATION_TRAINEE_DETAILS into @Emp_ID,@Completed_Month,@Date_Of_Join,@Review_Type,@Is_Month_Days
			while @@fetch_status = 0
				BEGIN	
				--select @Emp_ID,@Completed_Month,@Date_Of_Join,@Review_Type
					set @Extend_Period = 0	
					set @Review_Total_month =0	
						
					SELECT	@Extend_Period=ISNULL(Extend_Period,0),@New_Probation_EndDate=New_Probation_EndDate,@Maxflag=EM.Flag	
					FROM dbo.T0095_EMP_PROBATION_MASTER EM WITH (NoLock) 
					inner join 
						(SELECT MAX(Probation_Evaluation_ID) AS Probation_Evaluation_Id FROM  dbo.T0095_EMP_PROBATION_MASTER WITH (NoLock) 
						        WHERE Emp_ID = @Emp_ID GROUP BY Emp_ID)as qry on EM.Probation_Evaluation_ID=qry.Probation_Evaluation_Id --Flag = @flag and 
					WHERE  Emp_ID = @Emp_ID  --and Flag = @flag  
					--PRINT @Extend_Period
					IF @Review_Type = 'Quarterly'
						set @month = 3
					else if @Review_Type = 'Six Monthly'
						set @month = 6
						
						--PRINT @Review_Type 	
						--PRINT @New_Probation_EndDate 
						--PRINT @Maxflag
						--PRINT @flag
					 IF (@Extend_Period > 0) --and @Maxflag = @flag
						BEGIN
							update #PROBATION_TRAINEE_DETAILS set Probation_Date=@New_Probation_EndDate,Review_Type='Final' where Emp_ID=@Emp_ID
							--select * from #PROBATION_TRAINEE_DETAILS
						END
						
					--else IF (@Extend_Period > 0 and @Maxflag <> @flag)
					--	BEGIN
					--		print 's'
					--		update #PROBATION_TRAINEE_DETAILS set Probation_Date=@New_Probation_EndDate,Review_Type=@Review_Type where Emp_ID=@Emp_ID
					--	END
					 ELSE
						BEGIN
							if EXISTS(SELECT New_Probation_EndDate FROM dbo.T0095_EMP_PROBATION_MASTER EM WITH (NoLock) 
										inner join (SELECT MAX(Probation_Evaluation_ID) AS Probation_Evaluation_Id FROM  dbo.T0095_EMP_PROBATION_MASTER WITH (NoLock) 
													WHERE Emp_ID = @Emp_ID and Flag='Trainee' and Final_Review=1 and Approval_Period_Type='Probation' GROUP BY Emp_ID)as qry on EM.Probation_Evaluation_ID=qry.Probation_Evaluation_Id --Flag = @flag and 
										WHERE  Emp_ID = @Emp_ID and Flag='Trainee' and Final_Review=1 and Approval_Period_Type='Probation')
										
							--SELECT New_Probation_EndDate FROM dbo.T0095_EMP_PROBATION_MASTER WHERE  Emp_ID = @Emp_ID and Flag='Trainee' and Final_Review=1 and Approval_Period_Type='Probation')
								BEGIN		
									SELECT @FinalExtend_Probation_EndDate=EM.New_Probation_EndDate,@New_Probation_EndDate=EM.Old_Probation_EndDate 
									FROM dbo.T0095_EMP_PROBATION_MASTER EM WITH (NoLock) 
									inner join (SELECT MAX(Probation_Evaluation_ID) AS Probation_Evaluation_Id FROM  dbo.T0095_EMP_PROBATION_MASTER WITH (NoLock) 
														WHERE Emp_ID = @Emp_ID and Flag='Trainee' and Final_Review=1 and Approval_Period_Type='Probation' GROUP BY Emp_ID)as qry on EM.Probation_Evaluation_ID=qry.Probation_Evaluation_Id --Flag = @flag and 
									WHERE  Emp_ID = @Emp_ID and Flag='Trainee' and Final_Review=1 and Approval_Period_Type='Probation'	
											
									SELECT @ctr_Trainee_probation=count(Probation_Evaluation_ID) from T0095_EMP_PROBATION_MASTER  WITH (NoLock) 
									where Emp_ID=@Emp_ID and Flag = @flag 
									
									IF @ctr_Trainee_probation > 0	
										BEGIN	
											SELECT @New_Probation_EndDate=New_Probation_EndDate FROM dbo.T0095_EMP_PROBATION_MASTER  WITH (NoLock) 
											WHERE  Emp_ID = @Emp_ID and Flag=@flag 																			
											SET @Review_Total_month=(@month + (@ctr_Trainee_probation * @month)) 	
											--(@month * @ctr_Trainee_probation * 2)
										END
									--ELSE		
									--	BEGIN	
									--		set @New_Probation_EndDate=@New_Probation_EndDate
									--	END
											
									SET @Review_month= @month		
									SET @new_Probation_date=DATEADD(dd, - 1, DATEADD(mm, @Review_month, ISNULL(@New_Probation_EndDate,@Date_Of_Join)))-- commented  by Deepali= 09052023

								--	SET @new_Probation_date=DATEADD(dd, 0, DATEADD(mm, @Review_month, ISNULL(@New_Probation_EndDate,@Date_Of_Join)))--	--changed by deepali - Bug 30050 - 09052023
								
									
									--select @New_Probation_EndDate,@FinalExtend_Probation_EndDate,@new_Probation_date,@Review_month,@Review_Total_month,@Completed_Month,@ctr_Trainee_probation
									--IF @Completed_Month = @Review_Total_month 
									--	update #PROBATION_TRAINEE_DETAILS set Review_Type='Final',Probation_Date= @new_Probation_date where Emp_ID=@Emp_ID
									--ELSE IF @Completed_Month > @Review_Total_month 
									--	update #PROBATION_TRAINEE_DETAILS set Probation_Date= @new_Probation_date where Emp_ID=@Emp_ID
									--ELSE
									--	update #PROBATION_TRAINEE_DETAILS set Probation_Date=DATEADD(dd, - 1, DATEADD(mm,@Completed_Month,ISNULL(@New_Probation_EndDate,@Date_Of_Join))),Review_Type='Final' where Emp_ID=@Emp_ID											
									if @FinalExtend_Probation_EndDate < @new_Probation_date									
										update #PROBATION_TRAINEE_DETAILS set Review_Type='Final',Probation_Date= @FinalExtend_Probation_EndDate where Emp_ID=@Emp_ID
									ELSE	
										update #PROBATION_TRAINEE_DETAILS set Probation_Date= @new_Probation_date where Emp_ID=@Emp_ID
								END								
							ELSE									
								BEGIN				
									IF @Review_Type <> ''
										BEGIN
											SELECT @ctr_Trainee_probation=count(Probation_Evaluation_ID) from T0095_EMP_PROBATION_MASTER  WITH (NoLock) 
											where Emp_ID=@Emp_ID and Flag = @flag 
											
											IF @Is_Month_Days=0	--for Month Completion Period	
												BEGIN
													IF @ctr_Trainee_probation > 0																						
															SET @Review_month=(@month + (@ctr_Trainee_probation * @month)) 												
													ELSE												
															SET @Review_month= @month
															
															
													SET @new_Probation_date=DATEADD(dd, - 1, DATEADD(mm, @Review_month, @Date_Of_Join))
													IF @Completed_Month > @Review_month
															update #PROBATION_TRAINEE_DETAILS set Probation_Date= @new_Probation_date where Emp_ID=@Emp_ID												
													ELSE									
															update #PROBATION_TRAINEE_DETAILS set Probation_Date=DATEADD(dd, - 1, DATEADD(mm,@Completed_Month,@Date_Of_Join)),Review_Type='Final' where Emp_ID=@Emp_ID 																											
												END
											ELSE --for Days Completion Period	
												BEGIN
													if @month = 3
														set @month=90
													else if @month = 6 
														set @month=180
														
													IF @ctr_Trainee_probation > 0																						
															SET @Review_month=(@month + (@ctr_Trainee_probation * @month)) 												
													ELSE												
															SET @Review_month= @month
															
														SET @new_Probation_date=DATEADD(dd, 0, DATEADD(DAY, @Review_month, @Date_Of_Join)) 
													--PRINT @new_Probation_date													
													--set @Review_month= DAY(DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,-1,@Review_month),0)))
													IF @Completed_Month > @Review_month
															update #PROBATION_TRAINEE_DETAILS set Probation_Date= @new_Probation_date where Emp_ID=@Emp_ID												
													ELSE	
													--Deepali
															update #PROBATION_TRAINEE_DETAILS set Probation_Date=DATEADD(dd, 0, DATEADD(DAY,@Completed_Month,@Date_Of_Join)),Review_Type='Final' where Emp_ID=@Emp_ID   --Deepali	--for Days period												
End
										END
									ELSE
										BEGIN
											--update #PROBATION_TRAINEE_DETAILS set Probation_Date=DATEADD(dd, - 1, DATEADD(mm,@Completed_Month,@Date_Of_Join)),Review_Type='Final' where Emp_ID=@Emp_ID											
											IF @Is_Month_Days=0											
												update #PROBATION_TRAINEE_DETAILS set Probation_Date=DATEADD(dd, 0, DATEADD(mm,@Completed_Month,@Date_Of_Join)),Review_Type='Final' where Emp_ID=@Emp_ID	--for Month Period											
											ELSE
												--update #PROBATION_TRAINEE_DETAILS set Probation_Date=DATEADD(dd, 0, DATEADD(DAY,@Completed_Month,@Date_Of_Join)),Review_Type='Final' where Emp_ID=@Emp_ID	--for Days period											
											--changed by deepali - Bug 30050
												update #PROBATION_TRAINEE_DETAILS set Probation_Date=DATEADD(dd, 0, DATEADD(DAY,@Completed_Month,@Date_Of_Join)),Review_Type='Final' where Emp_ID=@Emp_ID	--for Days period											
											
											--select * from #PROBATION_TRAINEE_DETAILS
										END
								END
						END					
				--END
				FETCH NEXT FROM PROBATION_TRAINEE_DETAILS into @Emp_ID,@Completed_Month,@Date_Of_Join,@Review_Type,@Is_Month_Days
			End
		close PROBATION_TRAINEE_DETAILS 
		deallocate PROBATION_TRAINEE_DETAILS
	--insert into #PROBATION_TRAINEE	
	--select * from #PROBATION_TRAINEE_DETAILS
	DECLARE @DAYS_REMINDER as numeric(18,0)
	if @condition <> ''
		BEGIN
			if @Type ='HomePage'
				BEGIN
					SELECT @DAYS_REMINDER=Setting_Value FROM T0040_SETTING  WITH (NoLock) WHERE Cmp_ID=@CMP_ID and Setting_Value > 0 and Setting_Name ='Set days to fill Self Assessment Probation Details'
					
					--set @SqlQuery ='SELECT * FROM #PROBATION_TRAINEE_DETAILS where (Getdate() between DateAdd(DAY,'+ cast(@DAYS_REMINDER as VARCHAR(5)) +',Probation_date) and Probation_date) and Cmp_ID='+ cast(@cmp_id as VARCHAR(5)) + @condition + ' order by Probation_Date desc'
					SELECT TOP 0 * INTO #FINAL FROM #PROBATION_TRAINEE_DETAILS 
					
					set @SqlQuery ='INSERT INTO #FINAL
									SELECT * FROM #PROBATION_TRAINEE_DETAILS where Cmp_ID='+ cast(@cmp_id as VARCHAR(5)) + @condition + ' 
									and (Getdate() between DateAdd(DAY,-'+ cast(@DAYS_REMINDER as VARCHAR(5)) +',Probation_date) and (Probation_date+1)) and
									Probation_Date not in(select Old_Probation_EndDate from T0115_EMP_PROBATION_MASTER_LEVEL  WITH (NoLock) where Probation_Status=0 and Is_Self_Rating=1 and Cmp_ID='+ cast(@cmp_id as VARCHAR(5)) + @condition +')'
					--print @SqlQuery
					exec (@SqlQuery)		

					IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
						BEGIN
							TRUNCATE TABLE #Notification_Value
							INSERT INTO #Notification_Value
							SELECT COUNT(1)  FROM #FINAL 
						END
					ELSE
						SELECT * FROM #FINAL
				END
			ELSE IF @Type ='Self_ProbationForm'
				BEGIN				
					set @SqlQuery ='SELECT * FROM #PROBATION_TRAINEE_DETAILS where Getdate() >Probation_date and Cmp_ID='+ cast(@cmp_id as VARCHAR(5)) + @condition + ' order by Probation_Date desc'
					exec (@SqlQuery)						
				END
			ELSE	
				BEGIN
					set @SqlQuery ='SELECT * FROM #PROBATION_TRAINEE_DETAILS where Cmp_ID='+ cast(@cmp_id as VARCHAR(5)) + @condition + ' order by Probation_Date desc'
					exec (@SqlQuery)		
				END
		END
	ELSE
		BEGIN
		
			SELECT * FROM #PROBATION_TRAINEE_DETAILS order by Probation_Date desc
		END	
		
		if object_id('tempdb..#Emp_Probation') is not NULL	
			INSERT INTO #Emp_Probation
			SELECT Emp_ID,probation_date,Review_Type from #PROBATION_TRAINEE_DETAILS
END


