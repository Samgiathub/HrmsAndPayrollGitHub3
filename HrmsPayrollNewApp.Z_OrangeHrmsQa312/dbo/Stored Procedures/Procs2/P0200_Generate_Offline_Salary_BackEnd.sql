


---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0200_Generate_Offline_Salary_BackEnd]
    --@cmp_id NUMERIC ,
    --@from_date DATETIME ,
    --@to_date DATETIME ,
    --@is_manual NUMERIC = 1 ,
    --@branch_id NUMERIC = 0 ,
    --@Cat_ID NUMERIC = 0 ,
    --@grd_id NUMERIC = 0 ,
    --@Type_id NUMERIC = 0 ,
    --@dept_ID NUMERIC = 0 ,
    --@desig_ID NUMERIC = 0 ,
    --@emp_id NUMERIC = 0 ,
    --@Salary_Cycle_id NUMERIC = 0 ,
    --@Branch_Constraint NVARCHAR(1000) = '' ,
    --@Segment_ID NUMERIC = 0 ,
    --@Vertical NUMERIC = 0 ,
    --@SubVertical NUMERIC = 0 ,
    --@SubBranch NUMERIC = 0 ,
    --@ID VARCHAR(100) = ''
	
--WITH RECOMPILE
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	BEGIN

		DECLARE @cmp_id NUMERIC 
		DECLARE @from_date DATETIME 
		DECLARE @to_date DATETIME 
		DECLARE @is_manual NUMERIC 
		DECLARE @ID VARCHAR(100) 
		DECLARE @sal_gen_date DATETIME 
	

		IF EXISTS ( SELECT 1
						FROM dbo.t0200_Pre_Salary_Data WITH (NOLOCK)
						WHERE is_processed = 0 )
			BEGIN
				SET @is_manual = 1
				SELECT TOP 1000
                        @cmp_id = Cmp_ID, @id = Batch_id, @from_date = Month_St_Date, @to_date = Month_End_Date, @sal_gen_date = Sal_Generate_Date
					FROM dbo.t0200_Pre_Salary_Data WITH (NOLOCK)
					WHERE is_processed = 0
					GROUP BY Cmp_ID, Batch_id, Month_St_Date, Month_End_Date, Sal_Generate_Date
					ORDER BY Sal_Generate_Date 
			END
		ELSE
			IF EXISTS ( SELECT 1
							FROM dbo.t0200_Pre_Salary_Data_monthly WITH (NOLOCK)
							WHERE is_processed = 0 )
				BEGIN
					SET @is_manual = 0
					SELECT TOP 1000
                            @cmp_id = Cmp_ID, @id = Batch_id, @from_date = Month_St_Date, @to_date = Month_End_Date, @sal_gen_date = Sal_Generate_Date
						FROM dbo.t0200_Pre_Salary_Data_monthly WITH (NOLOCK)
						WHERE is_processed = 0
						GROUP BY Cmp_ID, Batch_id, Month_St_Date, Month_End_Date, Sal_Generate_Date
						ORDER BY Sal_Generate_Date 
				END
		

	 
	--print CONVERT( VARCHAR(24), GETDATE(), 113)	
	
	
		CREATE TABLE #Pre_Salary_Data_Exe
			(
				Row_ID NUMERIC(18, 0) ,
				Tran_id NUMERIC(18, 0) ,
				Type NVARCHAR(50) ,
				M_Sal_Tran_ID NVARCHAR(50) ,
				Emp_Id NUMERIC ,
				Cmp_ID NUMERIC ,
				Sal_Generate_Date NVARCHAR(50) ,
				Month_St_Date NVARCHAR(50) ,
				Month_End_Date NVARCHAR(50) ,
				Present_Days NUMERIC(18, 2) ,
				M_OT_Hours NUMERIC(18, 2) ,
				Areas_Amount NUMERIC(18, 2) ,
				M_IT_Tax NUMERIC(18, 2) ,
				Other_Dedu NUMERIC(18, 2) ,
				M_LOAN_AMOUNT NUMERIC ,
				M_ADV_AMOUNT NUMERIC ,
				IS_LOAN_DEDU NUMERIC ,
				Login_ID NUMERIC ,
				ErrRaise VARCHAR(100) ,
				Is_Negetive VARCHAR(1) ,
				Status VARCHAR(10) ,
				IT_M_ED_Cess_Amount NUMERIC(18, 2) ,
				IT_M_Surcharge_Amount NUMERIC(18, 2) ,
				Allo_On_Leave NUMERIC(18, 0) ,
				User_Id NUMERIC(18, 0) ,
				IP_Address VARCHAR(30) ,
				Is_processed TINYINT ,
				Batch_id VARCHAR(100)
			)
	
	
		CREATE TABLE #Pre_Salary_Data_monthly_Exe
			(
				Row_ID NUMERIC(18, 0) ,
				Tran_id NUMERIC(18, 0) ,
				Type NVARCHAR(50) ,
				M_Sal_Tran_ID NVARCHAR(50) ,
				Emp_Id NUMERIC ,
				Cmp_ID NUMERIC ,
				Sal_Generate_Date NVARCHAR(50) ,
				Month_St_Date NVARCHAR(50) ,
				Month_End_Date NVARCHAR(50) ,
				M_OT_Hours NUMERIC(18, 2) ,
				Areas_Amount NUMERIC(18, 2) ,
				M_IT_Tax NUMERIC(18, 2) ,
				Other_Dedu NUMERIC(18, 2) ,
				M_LOAN_AMOUNT NUMERIC ,
				M_ADV_AMOUNT NUMERIC ,
				IS_LOAN_DEDU NUMERIC ,
				Login_ID NUMERIC ,
				ErrRaise VARCHAR(100) ,
				Is_Negetive VARCHAR(1) ,
				Status VARCHAR(10) ,
				IT_M_ED_Cess_Amount NUMERIC(18, 2) ,
				IT_M_Surcharge_Amount NUMERIC(18, 2) ,
				Allo_On_Leave NUMERIC(18, 0) ,
				W_OT_Hours NUMERIC(18, 2) ,
				H_OT_Hours NUMERIC(18, 2) ,
				User_Id NUMERIC(18, 0) ,
				IP_Address VARCHAR(30) ,
				Is_processed TINYINT ,
				Batch_id VARCHAR(100)
			) 
	
		DECLARE @cur_Tran_id AS NUMERIC(18, 0)
		DECLARE @cur_Type AS NVARCHAR(50)
		DECLARE @cur_M_Sal_Tran_ID AS NVARCHAR(50) 
		DECLARE @cur_Emp_Id AS NUMERIC      
		DECLARE @cur_Cmp_ID AS NUMERIC      
		DECLARE @cur_Sal_Generate_Date AS NVARCHAR(50) 
		DECLARE @cur_Month_St_Date AS NVARCHAR(50)
		DECLARE @cur_Month_End_Date AS NVARCHAR(50)
		DECLARE @cur_Present_Days AS NUMERIC(18, 2)      
		DECLARE @cur_M_OT_Hours AS NUMERIC(18, 2)      
		DECLARE @cur_Areas_Amount AS NUMERIC(18, 2)       
		DECLARE @cur_M_IT_Tax AS NUMERIC(18, 2)      
		DECLARE @cur_Other_Dedu AS NUMERIC(18, 2)      
		DECLARE @cur_M_LOAN_AMOUNT AS NUMERIC      
		DECLARE @cur_M_ADV_AMOUNT AS NUMERIC      
		DECLARE @cur_IS_LOAN_DEDU AS NUMERIC      
		DECLARE @cur_Login_ID AS NUMERIC    
		DECLARE @cur_ErrRaise AS VARCHAR(100) 
		DECLARE @cur_Is_Negetive AS VARCHAR(1)  
		DECLARE @cur_Status AS VARCHAR(10)  
		DECLARE @cur_IT_M_ED_Cess_Amount AS NUMERIC(18, 2)
		DECLARE @cur_IT_M_Surcharge_Amount AS NUMERIC(18, 2)
		DECLARE @cur_Allo_On_Leave AS NUMERIC(18, 0) 
		DECLARE @cur_User_Id AS NUMERIC(18, 0) 	
		DECLARE @cur_IP_Address AS VARCHAR(30)	  
		DECLARE @Cur_Is_processed AS TINYINT
	
	
		DECLARE @cur_mon_Tran_id AS NUMERIC(18, 0)
		DECLARE @Cur_mon_Type AS NVARCHAR(50)
		DECLARE @Cur_mon_M_Sal_Tran_ID AS NVARCHAR(50) 
		DECLARE @Cur_mon_Emp_Id AS NUMERIC      
		DECLARE @Cur_mon_Cmp_ID AS NUMERIC      
		DECLARE @Cur_mon_Sal_Generate_Date AS NVARCHAR(50) 
		DECLARE @Cur_mon_Month_St_Date AS NVARCHAR(50)
		DECLARE @Cur_mon_Month_End_Date AS NVARCHAR(50)
		DECLARE @Cur_mon_M_OT_Hours AS NUMERIC(18, 2)      
		DECLARE @Cur_mon_Areas_Amount AS NUMERIC(18, 2)       
		DECLARE @Cur_mon_M_IT_Tax AS NUMERIC(18, 2)      
		DECLARE @Cur_mon_Other_Dedu AS NUMERIC(18, 2)      
		DECLARE @Cur_mon_M_LOAN_AMOUNT AS NUMERIC      
		DECLARE @Cur_mon_M_ADV_AMOUNT AS NUMERIC      
		DECLARE @Cur_mon_IS_LOAN_DEDU AS NUMERIC      
		DECLARE @Cur_mon_Login_ID AS NUMERIC    
		DECLARE @Cur_mon_ErrRaise AS VARCHAR(100) 
		DECLARE @Cur_mon_Is_Negetive AS VARCHAR(1)  
		DECLARE @Cur_mon_Status AS VARCHAR(10)  
		DECLARE @Cur_mon_IT_M_ED_Cess_Amount AS NUMERIC(18, 2)
		DECLARE @Cur_mon_IT_M_Surcharge_Amount AS NUMERIC(18, 2)
		DECLARE @Cur_mon_Allo_On_Leave AS NUMERIC(18, 0) 
		DECLARE @Cur_mon_W_OT_Hours AS NUMERIC(18, 2)
		DECLARE @Cur_mon_H_OT_Hours AS NUMERIC(18, 2)
		DECLARE @Cur_mon_User_Id AS NUMERIC(18, 0) 	
		DECLARE @Cur_mon_IP_Address AS VARCHAR(30) 
		DECLARE @Cur_mon_Is_processed AS TINYINT
	
		
		DECLARE @Emp_cons_list AS VARCHAR(MAX)
		SET @Emp_cons_list = ''
	
	
		CREATE TABLE #tblWoHo
			(
				Emp_id NUMERIC(18) ,
				Cmp_id NUMERIC(18) ,
				Branch_id NUMERIC(18) ,
				WO_date NVARCHAR(MAX) ,
				HO_date NVARCHAR(MAX) ,
				WO_Count NUMERIC(18, 0) ,
				HO_Count NUMERIC(18, 0) ,
				mid_WO_date NVARCHAR(MAX) ,
				mid_WO_Count NUMERIC(18, 0)
			)
	
	
		--CREATE TABLE #tblAllow
		--	(
		--		 row_id NUMERIC(18) IDENTITY(1,1) ,
		--		Emp_id NUMERIC(18) ,
		--		Increment_id NUMERIC(18) ,
		--		AD_ID NUMERIC(18) ,
		--		M_AD_Percentage NUMERIC(12, 5) ,
		--		M_AD_Amount NUMERIC(12, 5) ,
		--		M_AD_Flag VARCHAR(1) ,
		--		Max_Upper NUMERIC(27, 5) ,
		--		varCalc_On VARCHAR(50) ,
		--		AD_DEF_ID INT ,
		--		M_AD_NOT_EFFECT_ON_PT NUMERIC(1, 0) ,
		--		M_AD_NOT_EFFECT_SALARY NUMERIC(1, 0) ,
		--		M_AD_EFFECT_ON_OT NUMERIC(1, 0) ,
		--		M_AD_EFFECT_ON_EXTRA_DAY NUMERIC(1, 0) ,
		--		AD_Name VARCHAR(50) ,
		--		M_AD_effect_on_Late INT ,
		--		AD_Effect_Month VARCHAR(50) ,
		--		AD_CAL_TYPE VARCHAR(10) ,
		--		AD_EFFECT_FROM VARCHAR(15) ,
		--		IS_NOT_EFFECT_ON_LWP NUMERIC(1, 0) ,
		--		Allowance_type VARCHAR(10) ,
		--		AutoPaid TINYINT,
		--		AD_LEVEL NUMERIC(18, 0)
		--	)      
		 
	
		DECLARE @wo_date VARCHAR(1000) 
		DECLARE @wo_count NUMERIC(12, 2)
		DECLARE @ho_date VARCHAR(1000) 
		DECLARE @ho_count NUMERIC(12, 2)
		DECLARE @wo_date_mid VARCHAR(1000)
		DECLARE @wo_count_mid NUMERIC(12, 2) 
	
		SET @wo_date = ''
		SET @wo_count = 0
		SET @ho_date = ''
		SET @ho_count = 0
		SET @wo_date_mid = ''
		SET @wo_count_mid = 0
	
		IF @is_manual = 1
			BEGIN
				INSERT INTO #Pre_Salary_Data_Exe
						SELECT TOP 1000 ROW_NUMBER() OVER ( ORDER BY Emp_ID DESC ) AS Row, *
							FROM dbo.t0200_Pre_Salary_Data WITH (NOLOCK)
							WHERE is_processed = 0
								AND ISNULL(batch_id, '') = @ID
				
				--and emp_ID in (2171)--2122 ,2123,2124,2125,2126,2127,2129,2130,2131,2132)
				
			
			
				SELECT  @Emp_cons_list = REPLACE(REPLACE(STUFF((SELECT '#' + QUOTENAME(CAST(Emp_ID AS VARCHAR(MAX)))
																	FROM #Pre_Salary_Data_Exe AS a
																		CROSS APPLY ( SELECT 'Emp_ID' col, 1 so
																					) c
																	GROUP BY a.Emp_ID
																	ORDER BY a.Emp_ID
															FOR	XML PATH('') ,
																	TYPE ).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), '[', ''), ']', '')
				
				--INSERT INTO #tblAllow
				--		SELECT ROW_NUMBER() OVER ( PARTITION BY EMP_ID, EED.INCREMENT_ID ORDER BY AD_LEVEL, EED.AD_ID
				--								--,EED.INCREMENT_ID ,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,                    
				--								-- AD_NOT_EFFECT_ON_PT , AD_NOT_EFFECT_SALARY , AD_EFFECT_ON_OT , AD_EFFECT_ON_EXTRA_DAY                     
				--								--,AD_Name, AD_effect_on_Late  , AD_Effect_Month , AD_CAL_TYPE , AD_EFFECT_FROM , ADM.AD_NOT_EFFECT_ON_LWP 
				--								--, ADM.Allowance_Type  ,  ADM.auto_paid 
				--									), EED.EMP_ID, EED.INCREMENT_ID, EED.AD_ID, E_AD_Percentage, E_AD_Amount, E_AD_Flag, E_AD_Max_Limit, AD_Calculate_On, AD_DEF_ID, ISNULL(AD_NOT_EFFECT_ON_PT, 0), ISNULL(AD_NOT_EFFECT_SALARY, 0), ISNULL(AD_EFFECT_ON_OT, 0), ISNULL(AD_EFFECT_ON_EXTRA_DAY, 0), AD_Name, ISNULL(AD_effect_on_Late, 0), ISNULL(AD_Effect_Month, ''), ISNULL(AD_CAL_TYPE, ''), ISNULL(AD_EFFECT_FROM, ''), ISNULL(ADM.AD_NOT_EFFECT_ON_LWP, 0), ISNULL(ADM.Allowance_Type, 'A') AS Allowance_Type, ISNULL(ADM.auto_paid, 0) AS AutoPaid
				--			FROM dbo.T0100_EMP_EARN_DEDUCTION EED
				--				INNER JOIN dbo.T0050_AD_MASTER ADM ON EEd.AD_ID = ADM.AD_ID
				--			WHERE emp_id IN ( SELECT data
				--									FROM dbo.Split(@Emp_cons_list, '#') )
				--				AND Adm.AD_ACTIVE = 1
				--			ORDER BY AD_LEVEL, E_AD_Flag DESC  
			

				--INSERT  INTO #tblAllow
				--SELECT *
				--FROM 
				--	(
				--		SELECT  
				--		        EED.EMP_ID ,
    --                            EED.INCREMENT_ID ,
    --                            EED.AD_ID ,
    --                            Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End As E_AD_Percentage,
				--				Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End As E_AD_Amount,
    --                            E_AD_Flag ,
    --                            E_AD_Max_Limit ,
    --                            AD_Calculate_On ,
    --                            AD_DEF_ID ,
    --                            ISNULL(AD_NOT_EFFECT_ON_PT, 0) As AD_NOT_EFFECT_ON_PT ,
    --                            ISNULL(AD_NOT_EFFECT_SALARY, 0) As AD_NOT_EFFECT_SALARY ,
    --                            ISNULL(AD_EFFECT_ON_OT, 0) As AD_EFFECT_ON_OT ,
    --                            ISNULL(AD_EFFECT_ON_EXTRA_DAY, 0) As AD_EFFECT_ON_EXTRA_DAY ,
    --                            AD_Name ,
    --                            ISNULL(AD_effect_on_Late, 0) As AD_effect_on_Late ,
    --                            ISNULL(AD_Effect_Month, '')  As AD_Effect_Month,
    --                            ISNULL(AD_CAL_TYPE, '') As AD_CAL_TYPE ,
    --                            ISNULL(AD_EFFECT_FROM, '') As AD_EFFECT_FROM ,
    --                            ISNULL(ADM.AD_NOT_EFFECT_ON_LWP, 0) As AD_NOT_EFFECT_ON_LWP ,
    --                            ISNULL(ADM.Allowance_Type, 'A') AS Allowance_Type ,
    --                            ISNULL(ADM.auto_paid, 0) AS AutoPaid,
    --                            AD_LEVEL
    --                    FROM    dbo.T0100_EMP_EARN_DEDUCTION EED
    --                            INNER JOIN dbo.T0050_AD_MASTER ADM ON EEd.AD_ID = ADM.AD_ID LEFT OUTER JOIN
				--				( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE 
				--					From T0110_EMP_Earn_Deduction_Revised EEDR INNER JOIN
				--					( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
				--						Where Emp_Id IN ( SELECT data FROM dbo.Split(@Emp_cons_list, '#') )
				--						And For_date <= @to_date 
				--					 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
				--				) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID
    --                    WHERE   EEd.emp_id IN (
    --                            SELECT  data
    --                            FROM    dbo.Split(@Emp_cons_list, '#') )
    --                            AND Adm.AD_ACTIVE = 1
    --                            And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
    --                            --And INCREMENT_ID IN (Select INCREMENT_ID From T0080_EMP_MASTER Where Emp_id In (SELECT data FROM dbo.Split(@Emp_cons_list, '#') ))
				--				 And INCREMENT_ID IN (select I.Increment_ID From T0095_Increment I inner join     
				--				   (select max(Increment_Id) as Increment_Id, Emp_ID from T0095_Increment    
				--				   where Increment_Effective_date <= @to_date and Cmp_ID = @Cmp_ID and Emp_id In (SELECT data FROM dbo.Split(@Emp_cons_list, '#')) And Increment_Type <>'Transfer' And Increment_Type <>'Deputation'
				--				   group by emp_ID) Qry on    
				--				   I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id Where I.Emp_id In (SELECT data FROM dbo.Split(@Emp_cons_list, '#')) )                              
                                
                        
    --                    Union ALL
                        
    --                    SELECT  
				--		        EED.EMP_ID ,
    --                            EM.INCREMENT_ID ,
    --                            EED.AD_ID ,
    --                            E_AD_Percentage ,
    --                            E_AD_Amount ,
    --                            E_AD_Flag ,
    --                            E_AD_Max_Limit ,
    --                            AD_Calculate_On ,
    --                            AD_DEF_ID ,
    --                            ISNULL(AD_NOT_EFFECT_ON_PT, 0) As AD_NOT_EFFECT_ON_PT ,
    --                            ISNULL(AD_NOT_EFFECT_SALARY, 0) As AD_NOT_EFFECT_SALARY ,
    --                            ISNULL(AD_EFFECT_ON_OT, 0) As AD_EFFECT_ON_OT ,
    --                            ISNULL(AD_EFFECT_ON_EXTRA_DAY, 0) As AD_EFFECT_ON_EXTRA_DAY ,
    --                            AD_Name ,
    --                            ISNULL(AD_effect_on_Late, 0) As AD_effect_on_Late ,
    --                            ISNULL(AD_Effect_Month, '')  As AD_Effect_Month,
    --                            ISNULL(AD_CAL_TYPE, '') As AD_CAL_TYPE ,
    --                            ISNULL(AD_EFFECT_FROM, '') As AD_EFFECT_FROM ,
    --                            ISNULL(ADM.AD_NOT_EFFECT_ON_LWP, 0) As AD_NOT_EFFECT_ON_LWP ,
    --                            ISNULL(ADM.Allowance_Type, 'A') AS Allowance_Type ,
    --                            ISNULL(ADM.auto_paid, 0) AS AutoPaid,
    --                            AD_LEVEL
    --                    FROM    dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED
				--				INNER JOIN ( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
				--						Where Emp_Id IN ( SELECT data FROM dbo.Split(@Emp_cons_list, '#') ) And For_date <= @to_date 
				--						Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id 
    --                            INNER JOIN dbo.T0050_AD_MASTER ADM ON EEd.AD_ID = ADM.AD_ID
    --                            INNER JOIN dbo.T0080_EMP_MASTER AS EM ON EED.Emp_ID = EM.Emp_ID
                        
    --                    WHERE   EED.EMP_ID IN (SELECT data FROM dbo.Split(@Emp_cons_list, '#'))
    --                            AND Adm.AD_ACTIVE = 1
    --                            And EEd.ENTRY_TYPE = 'A'
    --                ) Qry
                    
    --            ORDER BY AD_LEVEL ,E_AD_FLAG DESC
				
				--select * from #tblAllow order by row_id
				--return
				
				 
					 															
				--INSERT INTO #tblWoHo
				--		EXEC SP_RPT_EMP_ATTENDANCE_MUSTER_IN_EXCEL_NEW @cmp_id, @from_date, @to_date, 0, 0, 0, 0, 0, 0, 0, @Emp_cons_list, 'WHO', 'EXCEL'
					 

	 
				DECLARE @Count_emp AS NUMERIC
				DECLARE @Temp_emp_Id NUMERIC(18, 0)
				DECLARE @intFlag AS NUMERIC(18, 0)	
				SET @intFlag = 1
	  	  
				SELECT  @Count_emp = COUNT(row_ID)
					FROM #Pre_Salary_Data_Exe 
				
				DECLARE @LogDesc NVARCHAR(MAX)
				DECLARE @Error NVARCHAR(MAX)
		
				SET @intFlag = 1
				WHILE ( @intFlag <= @Count_emp )
					BEGIN
						SET @LogDesc = ''
						SET @Error = ''
				--		BEGIN TRY
								 
						SELECT  @cur_Tran_id = Tran_id, @cur_Type = Type, @cur_Cmp_ID = Cmp_ID, @cur_M_Sal_Tran_ID = M_Sal_Tran_ID, @cur_Emp_Id = Emp_Id, @cur_Sal_Generate_Date = Sal_Generate_Date, @cur_Month_St_Date = Month_St_Date, @cur_Month_End_Date = Month_End_Date, @cur_Present_Days = Present_Days, @cur_M_OT_Hours = M_OT_Hours, @cur_Areas_Amount = Areas_Amount, @cur_M_IT_Tax = M_IT_Tax, @cur_Other_Dedu = Other_Dedu, @cur_M_LOAN_AMOUNT = M_LOAN_AMOUNT, @cur_M_ADV_AMOUNT = M_ADV_AMOUNT, @cur_IS_LOAN_DEDU = IS_LOAN_DEDU, @cur_Login_ID = Login_ID, @cur_ErrRaise = ErrRaise, @cur_Is_Negetive = Is_Negetive, @cur_Status = Status, @cur_IT_M_ED_Cess_Amount = IT_M_ED_Cess_Amount, @cur_IT_M_Surcharge_Amount = IT_M_Surcharge_Amount, @cur_Allo_On_Leave = Allo_On_Leave, @cur_User_Id = User_Id, @cur_IP_Address = IP_Address, @Cur_Is_processed = Is_processed
							FROM #Pre_Salary_Data_Exe
							WHERE Row_ID = @intFlag
					      
						SELECT  @wo_date = WO_date, @wo_count = WO_Count, @ho_date = HO_date, @ho_count = HO_Count, @wo_date_mid = mid_WO_date, @wo_count_mid = mid_WO_Count
							FROM #tblWoHo
							WHERE Emp_ID = @cur_Emp_Id 
					   
					   
						EXEC P0200_MONTHLY_SALARY_GENERATE_MANUAL @cur_M_Sal_Tran_ID, @cur_Emp_Id, @cur_Cmp_ID, @cur_Sal_Generate_Date, @cur_Month_St_Date, @cur_Month_End_Date, @cur_Present_Days, @cur_M_OT_Hours, @cur_Areas_Amount, @cur_M_IT_Tax, @cur_Other_Dedu, @cur_M_LOAN_AMOUNT, @cur_M_ADV_AMOUNT, @cur_IS_LOAN_DEDU, @cur_Login_ID, @cur_ErrRaise, @cur_Is_Negetive, @cur_Status, @cur_IT_M_ED_Cess_Amount, @cur_IT_M_Surcharge_Amount, @cur_Allo_On_Leave, @cur_User_Id, @cur_IP_Address, @wo_date, @wo_count, @ho_date, @ho_count, @wo_date_mid, @wo_count_mid
						
						
						UPDATE dbo.t0200_Pre_Salary_Data
							SET	is_processed = 1
							WHERE Tran_ID = @cur_Tran_id		

					----		END TRY
			
					--		BEGIN CATCH
					--			 update dbo.t0200_Pre_Salary_Data SET is_processed = 2 where Tran_ID = @cur_Tran_id
					--			set @LogDesc = 'Emp_ID='+@cur_Emp_Id+', Month='+cast(MONTH(@cur_Month_End_Date) as varchar)+', Year='+cast(year(@cur_Month_End_Date) as varchar)
					--			set @Error = ERROR_MESSAGE()
					--Commented by Gadriwala Muslim 17012017
					--	EXEC Event_Logs_Insert 0, @cur_Cmp_ID, @cur_Emp_Id, @cur_User_Id, 'Salary Manual#', @Error, @LogDesc, 1, ''			 		
					--		END CATCH
		
						SET @intFlag = @intFlag + 1
						IF @intFlag > @Count_emp + 1
							BREAK;
					END
			
				DROP TABLE #Pre_Salary_Data_Exe  
			END
		ELSE
			BEGIN
			--insert INTO #Pre_Salary_Data_monthly_Exe 
			--select TOP 1000 * from dbo.t0200_Pre_Salary_Data_monthly where is_processed = 0

			
				INSERT INTO #Pre_Salary_Data_monthly_Exe
						SELECT TOP 1000 ROW_NUMBER() OVER ( ORDER BY Emp_ID DESC ) AS Row, *
							FROM dbo.t0200_Pre_Salary_Data_monthly WITH (NOLOCK)
							WHERE is_processed = 0
								AND ISNULL(batch_id, '') = @ID
				
				--and emp_ID in (2171)--2122 ,2123,2124,2125,2126,2127,2129,2130,2131,2132)
				
			
			
				SELECT  @Emp_cons_list = REPLACE(REPLACE(STUFF((SELECT '#' + QUOTENAME(CAST(Emp_ID AS VARCHAR(MAX)))
																	FROM #Pre_Salary_Data_monthly_Exe AS a
																		CROSS APPLY ( SELECT 'Emp_ID' col, 1 so
																					) c
																	GROUP BY a.Emp_ID
																	ORDER BY a.Emp_ID
															FOR	XML PATH('') ,
																	TYPE ).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), '[', ''), ']', '')
				
				--INSERT INTO #tblAllow
				--		SELECT ROW_NUMBER() OVER ( PARTITION BY EMP_ID, EED.INCREMENT_ID ORDER BY AD_LEVEL, EED.AD_ID
				--								--,EED.INCREMENT_ID ,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,                    
				--								-- AD_NOT_EFFECT_ON_PT , AD_NOT_EFFECT_SALARY , AD_EFFECT_ON_OT , AD_EFFECT_ON_EXTRA_DAY                     
				--								--,AD_Name, AD_effect_on_Late  , AD_Effect_Month , AD_CAL_TYPE , AD_EFFECT_FROM , ADM.AD_NOT_EFFECT_ON_LWP 
				--								--, ADM.Allowance_Type  ,  ADM.auto_paid 
				--									), EED.EMP_ID, EED.INCREMENT_ID, EED.AD_ID, E_AD_Percentage, E_AD_Amount, E_AD_Flag, E_AD_Max_Limit, AD_Calculate_On, AD_DEF_ID, ISNULL(AD_NOT_EFFECT_ON_PT, 0), ISNULL(AD_NOT_EFFECT_SALARY, 0), ISNULL(AD_EFFECT_ON_OT, 0), ISNULL(AD_EFFECT_ON_EXTRA_DAY, 0), AD_Name, ISNULL(AD_effect_on_Late, 0), ISNULL(AD_Effect_Month, ''), ISNULL(AD_CAL_TYPE, ''), ISNULL(AD_EFFECT_FROM, ''), ISNULL(ADM.AD_NOT_EFFECT_ON_LWP, 0), ISNULL(ADM.Allowance_Type, 'A') AS Allowance_Type, ISNULL(ADM.auto_paid, 0) AS AutoPaid
				--			FROM dbo.T0100_EMP_EARN_DEDUCTION EED
				--				INNER JOIN dbo.T0050_AD_MASTER ADM ON EEd.AD_ID = ADM.AD_ID
				--			WHERE emp_id IN ( SELECT data
				--									FROM dbo.Split(@Emp_cons_list, '#') )
				--				AND Adm.AD_ACTIVE = 1
				--			ORDER BY AD_LEVEL, E_AD_Flag DESC  


				--INSERT  INTO #tblAllow
				--SELECT *
				--FROM 
				--	(
				--		SELECT  
				--		        EED.EMP_ID ,
    --                            EED.INCREMENT_ID ,
    --                            EED.AD_ID ,
    --                            Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End As E_AD_Percentage,
				--				Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End As E_AD_Amount,
    --                            E_AD_Flag ,
    --                            E_AD_Max_Limit ,
    --                            AD_Calculate_On ,
    --                            AD_DEF_ID ,
    --                            ISNULL(AD_NOT_EFFECT_ON_PT, 0) As AD_NOT_EFFECT_ON_PT ,
    --                            ISNULL(AD_NOT_EFFECT_SALARY, 0) As AD_NOT_EFFECT_SALARY ,
    --                            ISNULL(AD_EFFECT_ON_OT, 0) As AD_EFFECT_ON_OT ,
    --                            ISNULL(AD_EFFECT_ON_EXTRA_DAY, 0) As AD_EFFECT_ON_EXTRA_DAY ,
    --                            AD_Name ,
    --                            ISNULL(AD_effect_on_Late, 0) As AD_effect_on_Late ,
    --                            ISNULL(AD_Effect_Month, '')  As AD_Effect_Month,
    --                            ISNULL(AD_CAL_TYPE, '') As AD_CAL_TYPE ,
    --                            ISNULL(AD_EFFECT_FROM, '') As AD_EFFECT_FROM ,
    --                            ISNULL(ADM.AD_NOT_EFFECT_ON_LWP, 0) As AD_NOT_EFFECT_ON_LWP ,
    --                            ISNULL(ADM.Allowance_Type, 'A') AS Allowance_Type ,
    --                            ISNULL(ADM.auto_paid, 0) AS AutoPaid,
    --                            AD_LEVEL
    --                    FROM    dbo.T0100_EMP_EARN_DEDUCTION EED
    --                            INNER JOIN dbo.T0050_AD_MASTER ADM ON EEd.AD_ID = ADM.AD_ID LEFT OUTER JOIN
				--				( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE 
				--					From T0110_EMP_Earn_Deduction_Revised EEDR INNER JOIN
				--					( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
				--						Where Emp_Id IN ( SELECT data FROM dbo.Split(@Emp_cons_list, '#') )
				--						And For_date <= @to_date
				--					 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
				--				) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID
    --                    WHERE   EEd.emp_id IN (
    --                            SELECT  data
    --                            FROM    dbo.Split(@Emp_cons_list, '#') )
    --                            AND Adm.AD_ACTIVE = 1
    --                            And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
    --                            --And INCREMENT_ID In (Select INCREMENT_ID From T0080_EMP_MASTER Where Emp_id In (SELECT data FROM dbo.Split(@Emp_cons_list, '#') ))
				--				 And INCREMENT_ID IN (select I.INCREMENT_ID From T0095_Increment I inner join     
				--				   (select max(Increment_Id) as Increment_Id, Emp_ID from T0095_Increment    
				--				   where Increment_Effective_date <= @to_date and Cmp_ID = @Cmp_ID and Emp_id In (SELECT data FROM dbo.Split(@Emp_cons_list, '#')) And Increment_Type <>'Transfer' And Increment_Type <>'Deputation'
				--				   group by emp_ID) Qry on    
				--				   I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id Where I.Emp_id In (SELECT data FROM dbo.Split(@Emp_cons_list, '#')) )                              
                        
    --                    Union ALL
                        
    --                    SELECT  
				--		        EED.EMP_ID ,
    --                            EM.INCREMENT_ID ,
    --                            EED.AD_ID ,
    --                            E_AD_Percentage ,
    --                            E_AD_Amount ,
    --                            E_AD_Flag ,
    --                            E_AD_Max_Limit ,
    --                            AD_Calculate_On ,
    --                            AD_DEF_ID ,
    --                            ISNULL(AD_NOT_EFFECT_ON_PT, 0) As AD_NOT_EFFECT_ON_PT ,
    --                            ISNULL(AD_NOT_EFFECT_SALARY, 0) As AD_NOT_EFFECT_SALARY ,
    --                            ISNULL(AD_EFFECT_ON_OT, 0) As AD_EFFECT_ON_OT ,
    --                            ISNULL(AD_EFFECT_ON_EXTRA_DAY, 0) As AD_EFFECT_ON_EXTRA_DAY ,
    --                            AD_Name ,
    --                            ISNULL(AD_effect_on_Late, 0) As AD_effect_on_Late ,
    --                            ISNULL(AD_Effect_Month, '')  As AD_Effect_Month,
    --                            ISNULL(AD_CAL_TYPE, '') As AD_CAL_TYPE ,
    --                            ISNULL(AD_EFFECT_FROM, '') As AD_EFFECT_FROM ,
    --                            ISNULL(ADM.AD_NOT_EFFECT_ON_LWP, 0) As AD_NOT_EFFECT_ON_LWP ,
    --                            ISNULL(ADM.Allowance_Type, 'A') AS Allowance_Type ,
    --                            ISNULL(ADM.auto_paid, 0) AS AutoPaid,
    --                            AD_LEVEL
    --                    FROM    dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED
				--				INNER JOIN ( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
				--						Where Emp_Id IN ( SELECT data FROM dbo.Split(@Emp_cons_list, '#') ) And For_date <= @to_date 
				--						Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id 
    --                            INNER JOIN dbo.T0050_AD_MASTER ADM ON EEd.AD_ID = ADM.AD_ID
    --                            INNER JOIN dbo.T0080_EMP_MASTER AS EM ON EED.Emp_ID = EM.Emp_ID
                        
    --                    WHERE   EED.EMP_ID IN (SELECT data FROM dbo.Split(@Emp_cons_list, '#'))
    --                            AND Adm.AD_ACTIVE = 1
    --                            And EEd.ENTRY_TYPE = 'A'
    --                ) Qry
                    
  --            ORDER BY AD_LEVEL ,E_AD_FLAG DESC 
				
                --DECLARE curExecSalarMon CURSOR
                --FOR
                --    SELECT  *
                --    FROM    #Pre_Salary_Data_monthly_Exe
                --OPEN curExecSalarMon                      
                --FETCH NEXT FROM curExecSalarMon INTO @cur_mon_Tran_id,
                --    @Cur_mon_Type, @Cur_mon_M_Sal_Tran_ID, @Cur_mon_Emp_Id,
                --    @Cur_mon_Cmp_ID, @Cur_mon_Sal_Generate_Date,
                --    @Cur_mon_Month_St_Date, @Cur_mon_Month_End_Date,
                --    @Cur_mon_M_OT_Hours, @Cur_mon_Areas_Amount,
                --    @Cur_mon_M_IT_Tax, @Cur_mon_Other_Dedu,
                --    @Cur_mon_M_LOAN_AMOUNT, @Cur_mon_M_ADV_AMOUNT,
                --    @Cur_mon_IS_LOAN_DEDU, @Cur_mon_Login_ID,
                --    @Cur_mon_ErrRaise, @Cur_mon_Is_Negetive, @Cur_mon_Status,
                --    @Cur_mon_IT_M_ED_Cess_Amount,
                --    @Cur_mon_IT_M_Surcharge_Amount, @Cur_mon_Allo_On_Leave,
                --    @Cur_mon_W_OT_Hours, @Cur_mon_H_OT_Hours, @Cur_mon_User_Id,
                --    @Cur_mon_IP_Address, @Cur_mon_Is_processed
                --WHILE @@fetch_status = 0

				DECLARE @Count_emp_monthly AS NUMERIC
				DECLARE @intFlag_monthly AS NUMERIC(18, 0)	
              
	  	  
				SELECT  @Count_emp_monthly = COUNT(row_ID)
					FROM #Pre_Salary_Data_monthly_Exe 

				SET @intFlag_monthly = 1
				WHILE ( @intFlag_monthly <= @Count_emp_monthly )
					BEGIN


						SELECT  @cur_mon_Tran_id = Tran_id, @cur_mon_Type = Type, @cur_mon_Cmp_ID = Cmp_ID, @cur_mon_M_Sal_Tran_ID = M_Sal_Tran_ID, @cur_mon_Emp_Id = Emp_Id, @cur_mon_Sal_Generate_Date = Sal_Generate_Date, @cur_mon_Month_St_Date = Month_St_Date, @cur_mon_Month_End_Date = Month_End_Date, @cur_mon_M_OT_Hours = M_OT_Hours, @cur_mon_Areas_Amount = Areas_Amount, @cur_mon_M_IT_Tax = M_IT_Tax, @cur_mon_Other_Dedu = Other_Dedu, @cur_mon_M_LOAN_AMOUNT = M_LOAN_AMOUNT, @cur_mon_M_ADV_AMOUNT = M_ADV_AMOUNT, @cur_mon_IS_LOAN_DEDU = IS_LOAN_DEDU, @cur_mon_Login_ID = Login_ID, @cur_mon_ErrRaise = ErrRaise, @cur_mon_Is_Negetive = Is_Negetive, @cur_mon_Status = Status, @cur_mon_IT_M_ED_Cess_Amount = IT_M_ED_Cess_Amount, @cur_mon_IT_M_Surcharge_Amount = IT_M_Surcharge_Amount, @cur_mon_Allo_On_Leave = Allo_On_Leave, @cur_mon_User_Id = User_Id, @cur_mon_IP_Address = IP_Address, @Cur_mon_Is_processed = Is_processed
							FROM #Pre_Salary_Data_monthly_Exe
							WHERE Row_ID = @intFlag_monthly

						
				 
						EXEC P0200_MONTHLY_SALARY_GENERATE_PRORATA @Cur_mon_M_Sal_Tran_ID, @cur_mon_Emp_Id, @Cur_mon_Cmp_ID, @Cur_mon_Sal_Generate_Date, @Cur_mon_Month_St_Date, @Cur_mon_Month_End_Date, @Cur_mon_M_OT_Hours, @Cur_mon_Areas_Amount, @Cur_mon_M_IT_Tax, @Cur_mon_Other_Dedu, @Cur_mon_M_LOAN_AMOUNT, @Cur_mon_M_ADV_AMOUNT, @Cur_mon_IS_LOAN_DEDU, @Cur_mon_Login_ID, @Cur_mon_ErrRaise, @Cur_mon_Is_Negetive, @Cur_mon_Status, @Cur_mon_IT_M_ED_Cess_Amount, @Cur_mon_IT_M_Surcharge_Amount, @Cur_mon_Allo_On_Leave, @Cur_mon_W_OT_Hours, @Cur_mon_H_OT_Hours, @Cur_mon_User_Id, @Cur_mon_IP_Address
					 
						UPDATE t0200_Pre_Salary_Data_monthly
							SET	is_processed = 1
							WHERE Tran_ID = @cur_mon_Tran_id
					 
                        --FETCH NEXT FROM curExecSalarMon INTO @cur_mon_Tran_id,
                        --    @Cur_mon_Type, @Cur_mon_M_Sal_Tran_ID,
                        --    @Cur_mon_Emp_Id, @Cur_mon_Cmp_ID,
                        --    @Cur_mon_Sal_Generate_Date, @Cur_mon_Month_St_Date,
                        --    @Cur_mon_Month_End_Date, @Cur_mon_M_OT_Hours,
                        --    @Cur_mon_Areas_Amount, @Cur_mon_M_IT_Tax,
                        --    @Cur_mon_Other_Dedu, @Cur_mon_M_LOAN_AMOUNT,
                        --    @Cur_mon_M_ADV_AMOUNT, @Cur_mon_IS_LOAN_DEDU,
                        --    @Cur_mon_Login_ID, @Cur_mon_ErrRaise,
                        --    @Cur_mon_Is_Negetive, @Cur_mon_Status,
                        --    @Cur_mon_IT_M_ED_Cess_Amount,
                        --    @Cur_mon_IT_M_Surcharge_Amount,
                        --    @Cur_mon_Allo_On_Leave, @Cur_mon_W_OT_Hours,
                        --    @Cur_mon_H_OT_Hours, @Cur_mon_User_Id,
                        --    @Cur_mon_IP_Address, @Cur_mon_Is_processed
						SET @intFlag_monthly = @intFlag_monthly + 1
						IF @intFlag_monthly > @Count_emp_monthly + 1
							BREAK;
					END

                --CLOSE curExecSalarMon        
                --DEALLOCATE curExecSalarMon
				
				DROP TABLE #Pre_Salary_Data_monthly_Exe
	
			END
	
	 
	
	--select * from T0200_MONTHLY_SALARY where Emp_ID in (SELECT data from dbo.Split(@Emp_cons_list,'#')) and month(Month_End_Date) = month(@to_date) and year(Month_End_Date) = year(@to_date) 
	--select  * from t0200_Pre_Salary_Data where is_processed = 0
	
		DROP TABLE #tblWoHo	
		--DROP TABLE #tblAllow

	END

  
	--print CONVERT( VARCHAR(24), GETDATE(), 113)

