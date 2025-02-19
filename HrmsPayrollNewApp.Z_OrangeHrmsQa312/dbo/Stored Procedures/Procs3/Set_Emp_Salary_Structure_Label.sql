




-- =============================================
-- Author:		<Author,,Falak>
-- ALTER date: <ALTER Date,,24-JAN-2011>
-- Description:	<Description,,Emp_Salary_Structure>
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Set_Emp_Salary_Structure_Label] 
	@Cmp_ID as numeric
,@From_Date		datetime
,@To_Date		datetime 
,@Branch_ID		numeric   = 0
,@Cat_ID		numeric  = 0
,@Grd_ID		numeric = 0
,@Type_ID		numeric  = 0
,@Dept_ID		numeric  = 0
,@Desig_ID		numeric = 0
,@Emp_ID		numeric  = 0
,@Constraint	varchar(5000) = ''
--,@Year as numeric 
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
	
	Declare @Month numeric 
	Declare @Year numeric 
	
	set @Month =0
	set @year = 0
	
	INSERT INTO #Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (1,'Code')
	
	INSERT INTO #Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (2,'Employee Name')

	/*INSERT INTO #Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (3,'P Days')
	
	INSERT INTO #Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (4,'A Days')
	*/
	INSERT INTO #Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (3,'Basic')
	
	INSERT INTO #Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (4,'Other')
	
	
	INSERT INTO #Temp_report_Label_N
						  (Row_ID, Label_Name)
	VALUES     (1,'Basic')
	
	set @Row_id = 5
	
	Declare @Sorting_No as numeric
	declare Cur_Allow   cursor for
	 
	  	select Distinct  Ad_Sort_Name ,Ad_level from t0100_Emp_Earn_Deduction EM WITH (NOLOCK) inner join
			t0050_ad_master WITH (NOLOCK) on EM.Ad_ID = t0050_ad_master.Ad_ID inner join
			( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)        
		where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID        
		group by emp_ID  ) Qry on EM.Emp_ID = Qry.Emp_ID and EM.For_date = Qry.For_Date
		where 
		EM.Cmp_ID= @Cmp_ID 
		and Ad_Active = 1 and AD_Flag = 'I' and ad_not_effect_salary = 0 and EM.E_AD_AMOUNT >0
		order by Ad_level 
		
	open cur_allow
	fetch next from cur_allow  into @Label_Name,@Sorting_No
	while @@fetch_status = 0
		begin
			
			INSERT INTO #Temp_report_Label
								  (Row_ID, Label_Name)
			VALUES     (@row_ID,@Label_Name)
			
			INSERT INTO #Temp_report_Label_N
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
			
			INSERT INTO #Temp_report_Label_N
								  (Row_ID, Label_Name)
			VALUES     (@row_ID,@Label_Name)
			
			set @row_ID = @row_ID + 1
			fetch next from CUR_REIMB into @Label_Name
		end
	close CUR_REIMB
	deallocate CUR_REIMB
	
	
		/*INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Oth A')
		set @Row_ID = @Row_ID + 1

		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'CO A')
		set @Row_ID = @Row_ID + 1*/


		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Gross')
		
		
		INSERT INTO #Temp_report_Label_N
						  (Row_ID, Label_Name)
			VALUES     (@row_ID,'Gross')
			
		set @Row_ID = @Row_ID + 1

		/*INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'PF Salary')
		set @Row_ID = @Row_ID + 1*/

		/*INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'ESIC Salary')
		set @Row_ID = @Row_ID + 1*/

	declare Cur_Dedu   cursor for
		  select  distinct Ad_Sort_Name ,Ad_level  from T0100_Emp_Earn_Deduction EM WITH (NOLOCK) inner join
			t0050_ad_master WITH (NOLOCK) on EM.Ad_Id = t0050_ad_master.Ad_ID
			and EM.Cmp_ID = t0050_ad_master.Cmp_ID inner join
			( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)       
		where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID        
		group by emp_ID  ) Qry on EM.Emp_ID = Qry.Emp_ID and EM.For_date = Qry.For_Date
			where Ad_Active = 1 and AD_Flag = 'D' and ad_not_effect_salary=0
		order by Ad_level 
	open Cur_Dedu
	fetch next from Cur_Dedu into @Label_Name,@Sorting_No
	while @@fetch_status = 0
		begin
			
			INSERT INTO #Temp_report_Label
								  (Row_ID, Label_Name)
			VALUES     (@row_ID,@Label_Name)
			
			INSERT INTO #Temp_report_Label_N
						  (Row_ID, Label_Name)
			VALUES     (@row_ID,@Label_Name)
			
			set @row_ID = @row_ID + 1
			fetch next from Cur_Dedu into @Label_Name,@Sorting_No
		end
	close Cur_Dedu
	deallocate Cur_Dedu

		/*
		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'PT')
		set @Row_ID = @Row_ID + 1

		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Loan')
		set @Row_ID = @Row_ID + 1
		
		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Advnc')
		set @Row_ID = @Row_ID + 1

		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Revenue')
		set @Row_ID = @Row_ID + 1

		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'LWF')
		set @Row_ID = @Row_ID + 1
		
		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'TDS')
		set @Row_ID = @Row_ID + 1
		*/



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
			
			INSERT INTO #Temp_report_Label
								  (Row_ID, Label_Name)
			VALUES     (@row_ID,@Label_Name)
			
			INSERT INTO #Temp_report_Label_N
						  (Row_ID, Label_Name)
			VALUES     (@row_ID,@Label_Name)
			
			set @row_ID = @row_ID + 1
			fetch next from CUR_REIMB into @Label_Name
		end
	close CUR_REIMB
	deallocate CUR_REIMB

		--SET @Row_ID = 25
		/*
		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Oth De')
		set @Row_ID = @Row_ID + 1

		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Dedu')
		set @Row_ID = @Row_ID + 1

		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Net')
		*/



	RETURN




