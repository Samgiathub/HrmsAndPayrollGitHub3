
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Set_Salary_Wages_register_Lable_With_Late_Format18]
 @Cmp_ID as numeric
,@Month as numeric 
,@Year as numeric
,@From_Date as datetime
,@To_Date as Datetime 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	Declare @Emp_code as numeric
	Declare @Dept_Code as numeric
	Declare @Row_id as numeric
	Declare @Label_Name as varchar(100)
	Declare @Total_Allowance as numeric 
	Declare @Is_Search as varchar(50)
	Declare @Basic_salary as numeric(22,2)
	Declare @Total_Allow as numeric (22,2)
	
	
	DECLARE @ProductionBonus_Ad_Def_Id as NUMERIC 
	
	Set @ProductionBonus_Ad_Def_Id=20 -- for Production Bonus
	
	
	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (2,'Present')

	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (3,'Absent')
	
	--INSERT INTO dbo.#Temp_report_Label
	--					  (Row_ID, Label_Name)
	--VALUES     (4,'Late')
	

				--Set @Row_id = 5
				--DECLARE Cur_Leave  CURSOR FOR        
				--	SELECT DISTINCT LM.Leave_Code
				--	FROM T0210_MONTHLY_LEAVE_DETAIL ML Inner join
				--			T0040_LEAVE_MASTER LM On LM.Leave_ID = ML.Leave_ID
				--	WHERE Isnull(LM.Display_leave_balance,0) = 1 and LM.Cmp_ID= @Cmp_Id 
				--		 and ML.For_Date = @From_Date AND LM.Leave_Paid_Unpaid = 'P' And ML.Leave_Days>0
				--OPEN Cur_Leave        
				--FETCH NEXT FROM Cur_Leave INTO @Label_Name       
				--WHILE @@FETCH_STATUS = 0        
				--	BEGIN       
					
				--		 INSERT INTO dbo.#Temp_report_Label
				--			(Row_ID, Label_Name)        
				--		 VALUES
				--			(@Row_id,@Label_Name)        
						 
				--		 SET @Row_id = @Row_id + 1        
				                  
				--		FETCH NEXT FROM Cur_Leave INTO @Label_Name      
				--	END
				--CLOSE Cur_Leave        
				--DEALLOCATE Cur_Leave
	   
	   
				SELECT  (ROW_NUMBER() OVER (ORDER BY LABEL_NAME)) + 3 AS ROW_ID,T.LABEL_NAME
				INTO	DBO.#TEMP_REPORT_LABEL_LEAVE
				FROM	(SELECT DISTINCT CONVERT(VARCHAR(15),LM.LEAVE_CODE) AS LABEL_NAME  
						FROM	T0210_MONTHLY_LEAVE_DETAIL ML WITH (NOLOCK) INNER JOIN
										 T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.LEAVE_ID = ML.LEAVE_ID
						WHERE			 ISNULL(LM.DISPLAY_LEAVE_BALANCE,0) = 1 AND LM.CMP_ID= @CMP_ID 
										 AND ML.FOR_DATE = @FROM_DATE AND LM.LEAVE_PAID_UNPAID = 'P' AND ML.LEAVE_DAYS > 0
										 
						UNION
						SELECT	DISTINCT CONVERT(VARCHAR(15),LM.LEAVE_CODE) AS LABEL_NAME   
						FROM	T0040_LEAVE_MASTER LM WITH (NOLOCK)
									INNER JOIN T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) ON LT.Leave_ID=LM.Leave_ID
						WHERE	ISNULL(LT.Leave_Adj_L_Mark,0) > 0 
								AND LT.FOR_DATE BETWEEN @FROM_DATE AND @To_Date
						)T
				GROUP BY T.LABEL_NAME

				INSERT INTO DBO.#TEMP_REPORT_LABEL(Row_ID, Label_Name)
				SELECT * FROM DBO.#TEMP_REPORT_LABEL_LEAVE
				--SELECT * FROM DBO.#TEMP_REPORT_LABEL
				--RETURN	
	 
	
				--INSERT INTO dbo.#Temp_report_Label
				--					  (Row_ID, Label_Name)
				--VALUES     (5,'Early')
					
				--INSERT INTO dbo.#Temp_report_Label
				--					  (Row_ID, Label_Name)
				--VALUES     (6,'Leave')
	
				Select @Row_id= Max(Row_id) + 1 FROM #Temp_report_Label
				--SET @Row_id = @Row_id + 1
	
				INSERT INTO dbo.#Temp_report_Label
									  (Row_ID, Label_Name)
				VALUES     (@Row_id,'Holiday')
				SET @Row_id = @Row_id + 1
				
				INSERT INTO dbo.#Temp_report_Label
									  (Row_ID, Label_Name)
				VALUES     (@Row_id,'Week Off')
				SET @Row_id = @Row_id + 1
				
				INSERT INTO dbo.#Temp_report_Label
									  (Row_ID, Label_Name)
				VALUES     (@Row_id,'Sal.Days')
				SET @Row_id = @Row_id + 1

				INSERT INTO dbo.#Temp_report_Label
									  (Row_ID, Label_Name)
				VALUES     (@Row_id,'Arrear Days')
				SET @Row_id = @Row_id + 1

				--INSERT INTO dbo.#Temp_report_Label
				--					  (Row_ID, Label_Name)
				--VALUES     (@Row_id,'M.W.')
				--SET @Row_id = @Row_id + 1
				
				INSERT INTO dbo.#Temp_report_Label
									  (Row_ID, Label_Name)
				VALUES     (@Row_id,'Basic')
				SET @Row_id = @Row_id + 1

				--INSERT INTO dbo.#Temp_report_Label
				--					  (Row_ID, Label_Name)
				--VALUES     (@Row_id,'Wages')
				--SET @Row_id = @Row_id + 1

			--INSERT INTO dbo.#Temp_report_Label
	--					  (Row_ID, Label_Name)
	--VALUES     (15,'OT Hrs.')

	--INSERT INTO dbo.#Temp_report_Label
	--					  (Row_ID, Label_Name)
	--VALUES     (16,'W OT Hrs.')

	--INSERT INTO dbo.#Temp_report_Label
	--					  (Row_ID, Label_Name)
	--VALUES     (17,'H OT Hrs.')

	--INSERT INTO dbo.#Temp_report_Label
	--					  (Row_ID, Label_Name)
	--VALUES     (18,'OT Amt')

	--INSERT INTO dbo.#Temp_report_Label
	--					  (Row_ID, Label_Name)
	--VALUES     (19,'W OT Amt')

	--INSERT INTO dbo.#Temp_report_Label
	--					  (Row_ID, Label_Name)
	--VALUES     (20,'H OT Amt')
	
	
	--set @Row_id = 30
	
			--Declare @Sorting_No as numeric
			--declare Cur_Allow   cursor for
	  --			select Distinct  Ad_Sort_Name ,Ad_level from t0210_monthly_ad_detail inner join
			--		t0050_ad_master on t0210_monthly_ad_detail.Ad_ID = t0050_ad_master.Ad_ID
			--		and t0210_monthly_ad_detail.Cmp_ID = t0050_ad_master.Cmp_ID
			--	where 
			--	t0210_monthly_ad_detail.Cmp_ID= @Cmp_ID 
			--	and month(t0210_monthly_ad_detail.To_date) =  @Month and Year(t0210_monthly_ad_detail.To_date) = @Year
			--	and Ad_Active = 1 and AD_Flag = 'I' and ad_not_effect_salary = 0
			--	order by Ad_level 
				
			--open cur_allow
			--fetch next from cur_allow  into @Label_Name,@Sorting_No
			--while @@fetch_status = 0
			--	begin
					
			--		INSERT INTO dbo.#Temp_report_Label
			--							  (Row_ID, Label_Name)
			--		VALUES     (@row_ID,@Label_Name)
			--		set @row_ID = @row_ID + 1
			--		fetch next from cur_allow  into @Label_Name,@Sorting_No
			--	end
			--close cur_Allow
			--deallocate Cur_Allow

		SET @ROW_ID = 100
		SELECT  (ROW_NUMBER() OVER (ORDER BY LABEL_NAME,AD_LEVEL)) + @Row_id AS ROW_ID,T.LABEL_NAME
		INTO	DBO.#TEMP_REPORT_LABEL_EARN FROM(
		select Distinct  Ad_Sort_Name AS LABEL_NAME ,Ad_level from t0210_monthly_ad_detail WITH (NOLOCK) inner join
			t0050_ad_master WITH (NOLOCK) on t0210_monthly_ad_detail.Ad_ID = t0050_ad_master.Ad_ID
			and t0210_monthly_ad_detail.Cmp_ID = t0050_ad_master.Cmp_ID
		where 
		t0210_monthly_ad_detail.Cmp_ID= @Cmp_ID 
		and month(t0210_monthly_ad_detail.To_date) =  @Month and Year(t0210_monthly_ad_detail.To_date) = @Year
		and Ad_Active = 1 and AD_Flag = 'I' and ad_not_effect_salary = 0 and AD_DEF_ID <> @ProductionBonus_Ad_Def_Id
		)T
		
		
		INSERT INTO DBO.#TEMP_REPORT_LABEL(Row_ID, Label_Name)
		SELECT * FROM DBO.#TEMP_REPORT_LABEL_EARN
		
		SElect @Row_id = Max(Row_Id) + 1 FROM DBO.#TEMP_REPORT_LABEL
		
		
		INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
		VALUES     (@Row_id,'Prod.Bonus')

		SET @Row_id = @Row_id + 1
		
	--- REIMBURSEMENT


			--	declare CUR_REIMB   cursor for
			--	SELECT DISTINCT RIMB_NAME FROM T0100_RIMBURSEMENT_DETAIL INNER JOIN
			--	T0055_REIMBURSEMENT ON T0055_REIMBURSEMENT.RIMB_ID = T0100_RIMBURSEMENT_DETAIL.RIMB_ID AND
			--	T0055_REIMBURSEMENT.Cmp_ID = T0055_REIMBURSEMENT.Cmp_ID
			--	WHERE T0100_RIMBURSEMENT_DETAIL.Cmp_ID =@Cmp_ID
			--	AND month(T0100_RIMBURSEMENT_DETAIL.For_Date) = @MONTH
			--	AND year(T0100_RIMBURSEMENT_DETAIL.For_Date) = @YEAR
			--	AND T0055_REIMBURSEMENT.RIMB_FLAG = 'I'
			--open CUR_REIMB
			--fetch next from CUR_REIMB into @Label_Name
			--while @@fetch_status = 0
			--	begin
					
			--		INSERT INTO #Temp_Report_Label
			--							  (Row_ID, Label_Name)
			--		VALUES     (@row_ID,@Label_Name)
			--		set @row_ID = @row_ID + 1
			--		fetch next from CUR_REIMB into @Label_Name
			--	end
			--close CUR_REIMB
			--deallocate CUR_REIMB
	
	
		SELECT  (ROW_NUMBER() OVER (ORDER BY LABEL_NAME)) + @Row_id AS ROW_ID,T.LABEL_NAME
		INTO	DBO.#TEMP_REPORT_LABEL_REIM_EARN FROM(
				SELECT DISTINCT RIMB_NAME AS LABEL_NAME
				FROM	T0100_RIMBURSEMENT_DETAIL WITH (NOLOCK) INNER JOIN
						T0055_REIMBURSEMENT WITH (NOLOCK) ON T0055_REIMBURSEMENT.RIMB_ID = T0100_RIMBURSEMENT_DETAIL.RIMB_ID AND
						T0055_REIMBURSEMENT.Cmp_ID = T0055_REIMBURSEMENT.Cmp_ID
				WHERE	T0100_RIMBURSEMENT_DETAIL.Cmp_ID =@Cmp_ID
						AND month(T0100_RIMBURSEMENT_DETAIL.For_Date) = @MONTH AND year(T0100_RIMBURSEMENT_DETAIL.For_Date) = @YEAR
						AND T0055_REIMBURSEMENT.RIMB_FLAG = 'I')T
	
			
		INSERT INTO DBO.#TEMP_REPORT_LABEL(Row_ID, Label_Name)
		SELECT * FROM #TEMP_REPORT_LABEL_REIM_EARN
		
		SELECT @ROW_ID = MAX(ROW_ID) + 1 FROM DBO.#TEMP_REPORT_LABEL
			
			
	
		/*INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Oth A')
		set @Row_ID = @Row_ID + 1*/

		--INSERT INTO dbo.#Temp_report_Label
		--		(Row_ID, Label_Name)
		--VALUES (@row_ID,'CO A')
		--set @Row_ID = @Row_ID + 1
		
		INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@Row_id,'Leave Amt')
		set @Row_id = @Row_id + 1
		
		INSERT INTO dbo.#Temp_report_Label		--Alpesh 3-Aug-2012
				(Row_ID, Label_Name)
		VALUES (@Row_id,'Arrear Amt')
		set @Row_id = @Row_id + 1

		INSERT INTO dbo.#Temp_report_Label		--Hardik 03/06/2013
				(Row_ID, Label_Name)
		VALUES (@Row_id,'Settl Amt')
		set @Row_id = @Row_id + 1

		INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@Row_id,'Gross')
		set @Row_id = @Row_id + 1

		-- Ankit 17072014 --
		DECLARE @ROUNDING Numeric
		Set @ROUNDING = 2
		Declare @Net_Salary_Round NUMERIC(18,2)
		SET @Net_Salary_Round = 0
		  
		select Top 1 @ROUNDING =Ad_Rounding , @Net_Salary_Round = Net_Salary_Round
		from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
		and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID)    
		
		IF @ROUNDING = 0
			Begin
				INSERT INTO dbo.#Temp_report_Label
						(Row_ID, Label_Name)
				VALUES (@row_ID,'Gross Round')
				set @Row_ID = @Row_ID + 1
				
				INSERT INTO dbo.#Temp_report_Label
						(Row_ID, Label_Name)
				VALUES (@row_ID,'Total Gross')
				set @Row_ID = @Row_ID + 1
			End
			
		-- Ankit 17072014 --		
 
 
		/*INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'PF Salary')
		set @Row_ID = @Row_ID + 1*/

		/*INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'ESIC Salary')
		set @Row_ID = @Row_ID + 1*/
		


	--declare Cur_Dedu   cursor for
	--	  select  distinct Ad_Sort_Name ,Ad_level  from t0210_monthly_ad_detail inner join
	--		t0050_ad_master on t0210_monthly_ad_detail.Ad_Id = t0050_ad_master.Ad_ID
	--		and t0210_monthly_ad_detail.Cmp_ID = t0050_ad_master.Cmp_ID
	--		where t0210_monthly_ad_detail.Cmp_ID = @Cmp_ID 
	--		and month(t0210_monthly_ad_detail.To_date) =  @Month 
	--			and Year(t0210_monthly_ad_detail.To_date) = @Year
	--			and Ad_Active = 1 and AD_Flag = 'D' and ad_not_effect_salary=0 And t0050_ad_master.AD_DEF_ID <> 1 --ADDED BY Falak 0n 30-MAR-2011
	--	order by Ad_level 
	--open Cur_Dedu
	--fetch next from Cur_Dedu into @Label_Name,@Sorting_No
	--while @@fetch_status = 0
	--	begin
			
	--		INSERT INTO dbo.#Temp_report_Label
	--							  (Row_ID, Label_Name)
	--		VALUES     (@row_ID,@Label_Name)
	--		set @row_ID = @row_ID + 1
	--		fetch next from Cur_Dedu into @Label_Name,@Sorting_No
	--	end
	--close Cur_Dedu
	--deallocate Cur_Dedu
		
		
		SELECT  (ROW_NUMBER() OVER (ORDER BY LABEL_NAME,AD_LEVEL)) + @Row_id AS Row_id,T.LABEL_NAME
		INTO	DBO.#TEMP_REPORT_LABEL_DED FROM(
				SELECT  DISTINCT AD_SORT_NAME AS LABEL_NAME,AD_LEVEL  FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) INNER JOIN
								T0050_AD_MASTER WITH (NOLOCK) ON T0210_MONTHLY_AD_DETAIL.AD_ID = T0050_AD_MASTER.AD_ID
								AND T0210_MONTHLY_AD_DETAIL.CMP_ID = T0050_AD_MASTER.CMP_ID
				WHERE	T0210_MONTHLY_AD_DETAIL.CMP_ID = @CMP_ID 
						AND MONTH(T0210_MONTHLY_AD_DETAIL.TO_DATE) =  @MONTH 
						AND YEAR(T0210_MONTHLY_AD_DETAIL.TO_DATE) = @YEAR
						AND AD_ACTIVE = 1 AND AD_FLAG = 'D' AND AD_NOT_EFFECT_SALARY=0 AND T0050_AD_MASTER.AD_DEF_ID <> 1
						
						)T
				
		
		INSERT INTO DBO.#TEMP_REPORT_LABEL(Row_ID, Label_Name)
		SELECT * FROM DBO.#TEMP_REPORT_LABEL_DED
		
		
		
		SELECT @ROW_ID = MAX(ROW_ID) + 1 FROM DBO.#TEMP_REPORT_LABEL
		
		
		INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'PT')
		set @Row_ID = @Row_ID + 1

		--INSERT INTO dbo.#Temp_report_Label
		--		(Row_ID, Label_Name)
		--VALUES (@row_ID,'Loan')
		--set @Row_ID = @Row_ID + 1

		--INSERT INTO dbo.#Temp_report_Label
		--	(Row_ID, Label_Name)
		--VALUES (@row_ID,'Loan Int')
		--set @Row_ID = @Row_ID + 1
		
		SET @ROW_ID = 200
		--	DECLARE CUR_LOAN   CURSOR FOR        
		--	SELECT DISTINCT LOAN_SHORT_NAME
		--	FROM V0210_MONTHLY_LOAN_PAYMENT       
		--	WHERE   CMP_ID = @CMP_ID AND MONTH(LOAN_PAYMENT_DATE) = @MONTH AND YEAR(LOAN_PAYMENT_DATE) = @YEAR 
		--			--and (LOAN_SHORT_NAME <> '' OR LOAN_SHORT_NAME IS NOT NULL)
		--		OPEN CUR_LOAN        
		--			FETCH NEXT FROM CUR_LOAN  INTO @LABEL_NAME      
		--				WHILE @@FETCH_STATUS = 0        
		--					BEGIN  
									
									
		--							INSERT INTO DBO.#TEMP_REPORT_LABEL
		--											  (ROW_ID, LABEL_NAME)
		--							VALUES     (@ROW_ID,@LABEL_NAME)
		--							SET @ROW_ID = @ROW_ID + 1  
							
		--			FETCH NEXT FROM CUR_LOAN INTO @LABEL_NAME   
		--			END							        
		--	CLOSE CUR_LOAN        
		--DEALLOCATE CUR_LOAN       
		
		SELECT  (ROW_NUMBER() OVER (ORDER BY T.LABEL_NAME)) + @Row_id AS Row_id,T.LABEL_NAME
		INTO	DBO.#TEMP_REPORT_LABEL_LOAN FROM(		
					SELECT	DISTINCT LOAN_SHORT_NAME AS LABEL_NAME						
					FROM	V0210_MONTHLY_LOAN_PAYMENT       
					WHERE   CMP_ID = @CMP_ID AND MONTH(LOAN_PAYMENT_DATE) = @MONTH AND YEAR(LOAN_PAYMENT_DATE) = @YEAR 
							AND LOAN_SHORT_NAME <> ''	AND LOAN_PAY_AMOUNT >0		
				) T
		
		INSERT INTO DBO.#TEMP_REPORT_LABEL(Row_ID, Label_Name)
		SELECT * FROM DBO.#TEMP_REPORT_LABEL_LOAN
		
		--SELECT	@ROW_ID = MAX(ROW_ID) + 1 FROM DBO.#TEMP_REPORT_LABEL
		SET @ROW_ID = 250
		
		SELECT  (ROW_NUMBER() OVER (ORDER BY T.LABEL_NAME)) + @Row_id AS Row_id,T.LABEL_NAME
		INTO	DBO.#TEMP_REPORT_LABEL_LOAN_INT FROM(		
					SELECT	DISTINCT (LOAN_SHORT_NAME + ' Int') AS LABEL_NAME						
					FROM	V0210_MONTHLY_LOAN_PAYMENT       
					WHERE   CMP_ID = @CMP_ID AND MONTH(LOAN_PAYMENT_DATE) = @MONTH AND YEAR(LOAN_PAYMENT_DATE) = @YEAR 
							AND LOAN_SHORT_NAME <> ''	AND Interest_Amount >0		
				) T
		
		INSERT INTO DBO.#TEMP_REPORT_LABEL(Row_ID, Label_Name)
		SELECT * FROM DBO.#TEMP_REPORT_LABEL_LOAN_INT
		
		
		SET @ROW_ID = 299
		
		
		
		
		
		INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Advance')
		set @Row_ID = @Row_ID + 1

		--INSERT INTO dbo.#Temp_report_Label
		--		(Row_ID, Label_Name)
		--VALUES (@row_ID,'Revenue')
		--set @Row_ID = @Row_ID + 1

		INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'LWF')
		set @Row_ID = @Row_ID + 1
		
		INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'TDS')
		set @Row_ID = @Row_ID + 1

		--INSERT INTO dbo.#Temp_report_Label
		--		(Row_ID, Label_Name)
		--VALUES (@row_ID,'Fine')
		--set @Row_ID = @Row_ID + 1

		--INSERT INTO dbo.#Temp_report_Label
		--		(Row_ID, Label_Name)
		--VALUES (@row_ID,'Loss or Damage')
		--set @Row_ID = @Row_ID + 1


			--declare CUR_REIMB   cursor for
 		--		SELECT DISTINCT RIMB_NAME FROM T0100_RIMBURSEMENT_DETAIL INNER JOIN
			--	T0055_REIMBURSEMENT ON T0055_REIMBURSEMENT.RIMB_ID = T0100_RIMBURSEMENT_DETAIL.RIMB_ID AND
			--	T0055_REIMBURSEMENT.Cmp_ID = T0055_REIMBURSEMENT.Cmp_ID
			--	WHERE T0100_RIMBURSEMENT_DETAIL.Cmp_ID =@Cmp_ID
			--	AND month(T0100_RIMBURSEMENT_DETAIL.For_Date) = @MONTH
			--	AND year(T0100_RIMBURSEMENT_DETAIL.For_Date) = @YEAR
			--	AND T0055_REIMBURSEMENT.RIMB_FLAG = 'D'
			--open CUR_REIMB
			--fetch next from CUR_REIMB into @Label_Name
			--while @@fetch_status = 0
			--	begin
					
			--		INSERT INTO dbo.#Temp_report_Label
			--							  (Row_ID, Label_Name)
			--		VALUES     (@row_ID,@Label_Name)
			--		set @row_ID = @row_ID + 1
			--		fetch next from CUR_REIMB into @Label_Name
			--	end
			--close CUR_REIMB
			--deallocate CUR_REIMB

		SELECT  (ROW_NUMBER() OVER (ORDER BY LABEL_NAME)) + @Row_id AS Row_id,T.LABEL_NAME
		INTO	DBO.#TEMP_REPORT_LABEL_REIM_DED FROM(
				SELECT DISTINCT RIMB_NAME AS LABEL_NAME FROM T0100_RIMBURSEMENT_DETAIL WITH (NOLOCK) INNER JOIN
								T0055_REIMBURSEMENT WITH (NOLOCK) ON T0055_REIMBURSEMENT.RIMB_ID = T0100_RIMBURSEMENT_DETAIL.RIMB_ID AND
								T0055_REIMBURSEMENT.Cmp_ID = T0055_REIMBURSEMENT.Cmp_ID
						WHERE	T0100_RIMBURSEMENT_DETAIL.Cmp_ID =@Cmp_ID
								AND month(T0100_RIMBURSEMENT_DETAIL.For_Date) = @MONTH	AND year(T0100_RIMBURSEMENT_DETAIL.For_Date) = @YEAR
								AND T0055_REIMBURSEMENT.RIMB_FLAG = 'D')T

			
		INSERT INTO DBO.#TEMP_REPORT_LABEL(Row_ID, Label_Name)
		SELECT * FROM DBO.#TEMP_REPORT_LABEL_REIM_DED
		
		
		
		SELECT @ROW_ID = MAX(ROW_ID) + 1 FROM DBO.#TEMP_REPORT_LABEL
			
		--SET @Row_ID = 25
		INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Oth De')
		set @Row_ID = @Row_ID + 1

		INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Deficit Amt')
		set @Row_ID = @Row_ID + 1
		
		INSERT INTO dbo.#Temp_report_Label	 -- Added by Gadriwala Muslim 09012015
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Gate Pass')
		set @Row_ID = @Row_ID + 1

		INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Dedu')
		set @Row_ID = @Row_ID + 1

		INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Net')
		
		IF @Net_Salary_Round <> -1--@ROUNDING = 0
			Begin
				set @Row_ID = @Row_ID + 1
				
				INSERT INTO dbo.#Temp_report_Label
						(Row_ID, Label_Name)
				VALUES (@row_ID,'Net Round')
				set @Row_ID = @Row_ID + 1
				
				INSERT INTO dbo.#Temp_report_Label
						(Row_ID, Label_Name)
				VALUES (@row_ID,'Total Net')
	
			End			
			
			
			
			
RETURN
	






