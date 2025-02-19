


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE  PROCEDURE [dbo].[Set_Salary_Wages_register_Lable_With_Late]
 @Cmp_ID as numeric
,@Month as numeric 
,@Year as numeric 
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
	
	
	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (2,'Present')

	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (3,'Absent')
	
	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (4,'Late')
	
	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (5,'Early')
		
	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (6,'Leave')
	
	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (7,'Holiday')
	
	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (8,'Week Off')
	
	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (9,'T.Days')

	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (10,'Arrear Days')

	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (11,'M.W.')
	
	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (12,'Basic')

	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (14,'Wages')

	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (15,'OT Hrs.')

	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (16,'W OT Hrs.')

	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (17,'H OT Hrs.')

	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (18,'OT Amt')

	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (19,'W OT Amt')

	INSERT INTO dbo.#Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (20,'H OT Amt')
	
	
	set @Row_id = 30
	
	Declare @Sorting_No as numeric
	declare Cur_Allow   cursor for
	 
	  	select Distinct  Ad_Sort_Name ,Ad_level from t0210_monthly_ad_detail WITH (NOLOCK) inner join
			t0050_ad_master WITH (NOLOCK) on t0210_monthly_ad_detail.Ad_ID = t0050_ad_master.Ad_ID
			and t0210_monthly_ad_detail.Cmp_ID = t0050_ad_master.Cmp_ID
		where 
		t0210_monthly_ad_detail.Cmp_ID= @Cmp_ID 
		and month(t0210_monthly_ad_detail.To_date) =  @Month and Year(t0210_monthly_ad_detail.To_date) = @Year
		and Ad_Active = 1 and AD_Flag = 'I' and ad_not_effect_salary = 0
		order by Ad_level 
		
	open cur_allow
	fetch next from cur_allow  into @Label_Name,@Sorting_No
	while @@fetch_status = 0
		begin
			
			INSERT INTO dbo.#Temp_report_Label
								  (Row_ID, Label_Name)
			VALUES     (@row_ID,@Label_Name)
			set @row_ID = @row_ID + 1
			fetch next from cur_allow  into @Label_Name,@Sorting_No
		end
	close cur_Allow
	deallocate Cur_Allow


	--- REIMBURSEMENT


	declare CUR_REIMB   cursor for
 		SELECT DISTINCT RIMB_NAME FROM T0100_RIMBURSEMENT_DETAIL WITH (NOLOCK) INNER JOIN
		T0055_REIMBURSEMENT WITH (NOLOCK) ON T0055_REIMBURSEMENT.RIMB_ID = T0100_RIMBURSEMENT_DETAIL.RIMB_ID AND
		T0055_REIMBURSEMENT.Cmp_ID = T0055_REIMBURSEMENT.Cmp_ID
		WHERE T0100_RIMBURSEMENT_DETAIL.Cmp_ID =@Cmp_ID
		AND month(T0100_RIMBURSEMENT_DETAIL.For_Date) = @MONTH
		AND year(T0100_RIMBURSEMENT_DETAIL.For_Date) = @YEAR
		AND T0055_REIMBURSEMENT.RIMB_FLAG = 'I'
	open CUR_REIMB
	fetch next from CUR_REIMB into @Label_Name
	while @@fetch_status = 0
		begin
			
			INSERT INTO #Temp_Report_Label
								  (Row_ID, Label_Name)
			VALUES     (@row_ID,@Label_Name)
			set @row_ID = @row_ID + 1
			fetch next from CUR_REIMB into @Label_Name
		end
	close CUR_REIMB
	deallocate CUR_REIMB
	
	
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
		VALUES (@row_ID,'Leave Amt')
		set @Row_ID = @Row_ID + 1
		
		INSERT INTO dbo.#Temp_report_Label		--Alpesh 3-Aug-2012
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Arrear Amt')
		set @Row_ID = @Row_ID + 1

		INSERT INTO dbo.#Temp_report_Label		--Hardik 03/06/2013
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Settl Amt')
		set @Row_ID = @Row_ID + 1

		INSERT INTO dbo.#Temp_report_Label -- Added by Mukti 23052017
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Uni.Refund Inst.')
		set @Row_ID = @Row_ID + 1
		
		INSERT INTO dbo.#Temp_report_Label -- Added by Mukti 28062017
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Claim Amt')
		set @Row_ID = @Row_ID + 1
		
		INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Gross')
		set @Row_ID = @Row_ID + 1

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
		


	declare Cur_Dedu   cursor for
		  select  distinct Ad_Sort_Name ,Ad_level  from t0210_monthly_ad_detail WITH (NOLOCK) inner join
			t0050_ad_master WITH (NOLOCK) on t0210_monthly_ad_detail.Ad_Id = t0050_ad_master.Ad_ID
			and t0210_monthly_ad_detail.Cmp_ID = t0050_ad_master.Cmp_ID
			where t0210_monthly_ad_detail.Cmp_ID = @Cmp_ID 
			and month(t0210_monthly_ad_detail.To_date) =  @Month 
				and Year(t0210_monthly_ad_detail.To_date) = @Year
				and Ad_Active = 1 and AD_Flag = 'D' and ad_not_effect_salary=0 And t0050_ad_master.AD_DEF_ID <> 1 --ADDED BY Falak 0n 30-MAR-2011
		order by Ad_level 
	open Cur_Dedu
	fetch next from Cur_Dedu into @Label_Name,@Sorting_No
	while @@fetch_status = 0
		begin
			
			INSERT INTO dbo.#Temp_report_Label
								  (Row_ID, Label_Name)
			VALUES     (@row_ID,@Label_Name)
			set @row_ID = @row_ID + 1
			fetch next from Cur_Dedu into @Label_Name,@Sorting_No
		end
	close Cur_Dedu
	deallocate Cur_Dedu

		INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'PT')
		set @Row_ID = @Row_ID + 1

		INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Loan')
		set @Row_ID = @Row_ID + 1

		INSERT INTO dbo.#Temp_report_Label
			(Row_ID, Label_Name)
		VALUES (@row_ID,'Loan Int')
		set @Row_ID = @Row_ID + 1
		
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

		INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Fine')
		set @Row_ID = @Row_ID + 1

		INSERT INTO dbo.#Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Loss or Damage')
		set @Row_ID = @Row_ID + 1
		
		INSERT INTO dbo.#Temp_report_Label -- Added by Mukti 23052017
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Late Deduction')
		set @Row_ID = @Row_ID + 1


	declare CUR_REIMB   cursor for
 		SELECT DISTINCT RIMB_NAME FROM T0100_RIMBURSEMENT_DETAIL WITH (NOLOCK) INNER JOIN
		T0055_REIMBURSEMENT WITH (NOLOCK) ON T0055_REIMBURSEMENT.RIMB_ID = T0100_RIMBURSEMENT_DETAIL.RIMB_ID AND
		T0055_REIMBURSEMENT.Cmp_ID = T0055_REIMBURSEMENT.Cmp_ID
		WHERE T0100_RIMBURSEMENT_DETAIL.Cmp_ID =@Cmp_ID
		AND month(T0100_RIMBURSEMENT_DETAIL.For_Date) = @MONTH
		AND year(T0100_RIMBURSEMENT_DETAIL.For_Date) = @YEAR
		AND T0055_REIMBURSEMENT.RIMB_FLAG = 'D'
	open CUR_REIMB
	fetch next from CUR_REIMB into @Label_Name
	while @@fetch_status = 0
		begin
			
			INSERT INTO dbo.#Temp_report_Label
								  (Row_ID, Label_Name)
			VALUES     (@row_ID,@Label_Name)
			set @row_ID = @row_ID + 1
			fetch next from CUR_REIMB into @Label_Name
		end
	close CUR_REIMB
	deallocate CUR_REIMB

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

		INSERT INTO dbo.#Temp_report_Label -- Added by Mukti 23052017
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Uni.Inst.')
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
	



