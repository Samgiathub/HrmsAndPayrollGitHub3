




--Created By Girish On 06-OCT-2009
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[Set_Emp_Sal_Structure_Lable]
 @Cmp_ID as numeric
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
	
	CREATE table #Temp_report_Label
	(
	Row_ID numeric,
	Label_NAme varchar(100)
	)
	
	INSERT INTO #Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (1,'Code')
	
	INSERT INTO #Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (2,'Emp_ID')

	INSERT INTO #Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (3,'Basic')
	
	
	set @Row_id = 4
	
	Declare @Sorting_No as numeric
	declare Cur_Allow   cursor for
	 
	  	select Distinct  Ad_Sort_Name ,Ad_level from t0100_emp_earn_deduction WITH (NOLOCK) inner join
			t0050_ad_master WITH (NOLOCK) on t0100_emp_earn_deduction.Ad_ID = t0050_ad_master.Ad_ID inner join
			(select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where  Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					t0100_emp_earn_deduction.Emp_ID = Qry.Emp_ID
		where t0100_emp_earn_deduction.Cmp_ID= @Cmp_ID and t0100_emp_earn_deduction.Cmp_ID = t0050_ad_master.Cmp_ID
		and Ad_Active = 1 and AD_Flag = 'I' and ad_not_effect_salary <> 1
		order by Ad_level 
	open cur_allow
	fetch next from cur_allow  into @Label_Name,@Sorting_No
	while @@fetch_status = 0
		begin
			
			INSERT INTO #Temp_report_Label
								  (Row_ID, Label_Name)
			VALUES     (@row_ID,@Label_Name)
			set @row_ID = @row_ID + 1
			fetch next from cur_allow  into @Label_Name,@Sorting_No
		end
	close cur_Allow
	deallocate Cur_Allow
	
		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Gross')
		set @Row_ID = @Row_ID + 1

	declare Cur_Dedu   cursor for
		 select Distinct  Ad_Sort_Name ,Ad_level from t0100_emp_earn_deduction WITH (NOLOCK) inner join
			t0050_ad_master WITH (NOLOCK) on t0100_emp_earn_deduction.Ad_ID = t0050_ad_master.Ad_ID inner join
			(select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where  Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					t0100_emp_earn_deduction.Emp_ID = Qry.Emp_ID
		where t0100_emp_earn_deduction.Cmp_ID= @Cmp_ID and t0100_emp_earn_deduction.Cmp_ID = t0050_ad_master.Cmp_ID
		and Ad_Active = 1 and AD_Flag = 'D' and ad_not_effect_salary <> 1
		order by Ad_level 
	open Cur_Dedu
	fetch next from Cur_Dedu into @Label_Name,@Sorting_No
	while @@fetch_status = 0
		begin
			
			INSERT INTO #Temp_report_Label
								  (Row_ID, Label_Name)
			VALUES     (@row_ID,@Label_Name)
			set @row_ID = @row_ID + 1
			fetch next from Cur_Dedu into @Label_Name,@Sorting_No
		end
	close Cur_Dedu
	deallocate Cur_Dedu

		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'PT')
		set @Row_ID = @Row_ID + 1

		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Dedu')
		set @Row_ID = @Row_ID + 1

		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name)
		VALUES (@row_ID,'Net')
		

	
	RETURN
	



