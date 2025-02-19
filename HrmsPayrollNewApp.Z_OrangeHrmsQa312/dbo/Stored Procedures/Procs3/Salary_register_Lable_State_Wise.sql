
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[Salary_register_Lable_State_Wise]
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
	Declare @FLAG as varchar(1)
	
	INSERT INTO #Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (1,'Code')
	
	INSERT INTO #Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (2,'Employee Name')

	
	
	set @Row_id = 6
	
	Declare @Sorting_No as numeric
	declare Cur_Allow   cursor for	 
	  		select Distinct  Ad_Sort_Name,Ad_level
			from	t0210_monthly_ad_detail MAD WITH (NOLOCK)
					inner join	t0050_ad_master WITH (NOLOCK) on MAD.Ad_ID = t0050_ad_master.Ad_ID
					and MAD.Cmp_ID = t0050_ad_master.Cmp_ID
			where	MAD.Cmp_ID= @Cmp_ID and Ad_Active = 1 and AD_Flag = 'I' and ad_not_effect_salary = 0 And sal_type=1
			order by Ad_level 		
	open cur_allow
	fetch next from cur_allow  into @Label_Name,@Sorting_No
	while @@fetch_status = 0
		begin
			
			INSERT INTO #Temp_report_Label (Row_ID, Label_Name,FLAG)
			VALUES     (@row_ID,@Label_Name,'I')
			set		@row_ID = @row_ID + 1

			fetch next from cur_allow  into @Label_Name,@Sorting_No
		end
	close cur_Allow
	deallocate Cur_Allow


	--- REIMBURSEMENT


	declare CUR_REIMB   cursor for
 		SELECT DISTINCT RIMB_NAME 
		FROM	T0100_RIMBURSEMENT_DETAIL WITH (NOLOCK)
				INNER JOIN	T0055_REIMBURSEMENT WITH (NOLOCK) ON T0055_REIMBURSEMENT.RIMB_ID = T0100_RIMBURSEMENT_DETAIL.RIMB_ID AND
				T0055_REIMBURSEMENT.Cmp_ID = T0055_REIMBURSEMENT.Cmp_ID
		WHERE	T0100_RIMBURSEMENT_DETAIL.Cmp_ID =@Cmp_ID
				AND month(T0100_RIMBURSEMENT_DETAIL.For_Date) = @MONTH
				AND year(T0100_RIMBURSEMENT_DETAIL.For_Date) = @YEAR
				AND T0055_REIMBURSEMENT.RIMB_FLAG = 'I'
	open CUR_REIMB
	fetch next from CUR_REIMB into @Label_Name
	while @@fetch_status = 0
		begin
			
			INSERT INTO #Temp_Report_Label (Row_ID, Label_Name,Flag)
			VALUES     (@row_ID,@Label_Name,'R')
			set @row_ID = @row_ID + 1

			fetch next from CUR_REIMB into @Label_Name
		end
	close CUR_REIMB
	deallocate CUR_REIMB
	
	
		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name,Flag)
		VALUES (@row_ID,'Oth A','I')
		set @Row_ID = @Row_ID + 1

		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name,Flag)
		VALUES (@row_ID,'CO A','I')
		set @Row_ID = @Row_ID + 1


		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name,Flag)
		VALUES (@row_ID,'OT Amount','I')
		set @Row_ID = @Row_ID + 1


		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name,Flag)
		VALUES (@row_ID,'Advance','I')
		set @Row_ID = @Row_ID + 1

		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name,Flag)
		VALUES (@row_ID,'Leave Encashment','I')
		set @Row_ID = @Row_ID + 1

		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name,Flag)
		VALUES (@row_ID,'LTA Claim','R')
		set @Row_ID = @Row_ID + 1

		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name,Flag)
		VALUES (@row_ID,'Gross','G')
		set @Row_ID = @Row_ID + 1


		declare Cur_Allow_Not_Effect   cursor for
	  		select Distinct  Ad_Sort_Name ,Ad_level
			from	t0210_monthly_ad_detail WITH (NOLOCK) inner join
					t0050_ad_master WITH (NOLOCK) on t0210_monthly_ad_detail.Ad_ID = t0050_ad_master.Ad_ID
					and t0210_monthly_ad_detail.Cmp_ID = t0050_ad_master.Cmp_ID
			where	t0210_monthly_ad_detail.Cmp_ID= @Cmp_ID 		
					and Ad_Active = 1 and AD_Flag = 'I' and ad_not_effect_salary = 1 And sal_type=1
			order by Ad_level 
			
		open Cur_Allow_Not_Effect
		fetch next from Cur_Allow_Not_Effect  into @Label_Name,@Sorting_No
		while @@fetch_status = 0
			begin
				
				INSERT INTO #Temp_report_Label
									  (Row_ID, Label_Name,Flag)
				VALUES     (@row_ID,@Label_Name,'I')
				set @row_ID = @row_ID + 1
				fetch next from Cur_Allow_Not_Effect  into @Label_Name,@Sorting_No
			end
		close Cur_Allow_Not_Effect
		deallocate Cur_Allow_Not_Effect
		
		set @Row_ID = @Row_ID + 1
		


		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name,Flag)
		VALUES (@row_ID,'Total Earn','E')
		set @Row_ID = @Row_ID + 1

		declare Cur_DEdu   cursor for	 
	  		select Distinct Ad_Sort_Name,Ad_level
			from	t0210_monthly_ad_detail MAD WITH (NOLOCK)
					inner join	t0050_ad_master AM WITH (NOLOCK) on MAD.Ad_ID = AM.Ad_ID
					and MAD.Cmp_ID = AM.Cmp_ID
			where 	MAD.Cmp_ID= @Cmp_ID 
					and Ad_Active = 1 and AD_Flag = 'D' and ad_not_effect_salary = 0 And sal_type=1
			order by Ad_level
	open Cur_DEdu
	fetch next from Cur_DEdu  into @Label_Name,@Sorting_No
	while @@fetch_status = 0
		begin			
				INSERT INTO #Temp_report_Label
									  (Row_ID, Label_Name,Flag)
				VALUES     (@row_ID,@Label_Name,'D')
				set @row_ID = @row_ID + 1
			fetch next from Cur_DEdu  into @Label_Name,@Sorting_No
		end
	close Cur_DEdu
	deallocate Cur_DEdu

	
		INSERT INTO #Temp_report_Label(Row_ID, Label_Name,Flag)
		VALUES (@row_ID,'PT','D')
		set @Row_ID = @Row_ID + 1

		INSERT INTO #Temp_report_Label(Row_ID, Label_Name,Flag)
		VALUES (@row_ID,'Loan\Advance','D')
		set @Row_ID = @Row_ID + 1

		INSERT INTO #Temp_report_Label(Row_ID, Label_Name,Flag)
		VALUES (@row_ID,'Revenue','D')
		set @Row_ID = @Row_ID + 1

		INSERT INTO #Temp_report_Label(Row_ID, Label_Name,Flag)
		VALUES (@row_ID,'LWF','D')
		set @Row_ID = @Row_ID + 1



		--INSERT INTO #Temp_report_Label(Row_ID, Label_Name,Flag)
		--VALUES (@row_ID,'TDS','D')
		--set @Row_ID = @Row_ID + 1

	declare CUR_REIMB   cursor for
 		SELECT DISTINCT RIMB_NAME 
		FROM	T0100_RIMBURSEMENT_DETAIL WITH (NOLOCK) INNER JOIN
				T0055_REIMBURSEMENT WITH (NOLOCK) ON T0055_REIMBURSEMENT.RIMB_ID = T0100_RIMBURSEMENT_DETAIL.RIMB_ID AND
				T0055_REIMBURSEMENT.Cmp_ID = T0055_REIMBURSEMENT.Cmp_ID
		WHERE	T0100_RIMBURSEMENT_DETAIL.Cmp_ID =@Cmp_ID
				AND month(T0100_RIMBURSEMENT_DETAIL.For_Date) = @MONTH
				AND year(T0100_RIMBURSEMENT_DETAIL.For_Date) = @YEAR
				AND T0055_REIMBURSEMENT.RIMB_FLAG = 'D'
	open CUR_REIMB
	fetch next from CUR_REIMB into @Label_Name
	while @@fetch_status = 0
		begin
			
			INSERT INTO #Temp_report_Label
								  (Row_ID,Label_Name,Flag)
			VALUES     (@row_ID,@Label_Name,'R')
			set @row_ID = @row_ID + 1
			fetch next from CUR_REIMB into @Label_Name
		end
	close CUR_REIMB
	deallocate CUR_REIMB

		--SET @Row_ID = 25

		
		
		-- Added by rohit for allowance which effect net salary but not add in gross salary on 08072016
		
		
		
	declare Cur_Allow   cursor for	 
	  	select Distinct  Ad_Sort_Name ,Ad_level 
		from	t0210_monthly_ad_detail WITH (NOLOCK) inner join
				t0050_ad_master WITH (NOLOCK) on t0210_monthly_ad_detail.Ad_ID = t0050_ad_master.Ad_ID
				and t0210_monthly_ad_detail.Cmp_ID = t0050_ad_master.Cmp_ID
		where	t0210_monthly_ad_detail.Cmp_ID= @Cmp_ID 
				and Ad_Active = 1 and AD_Flag = 'I' and ad_not_effect_salary = 1 And sal_type=1 and effect_net_salary = 1 
		order by Ad_level 
		
	open cur_allow
	fetch next from cur_allow  into @Label_Name,@Sorting_No
	while @@fetch_status = 0
		begin
			INSERT INTO #Temp_report_Label (Row_ID, Label_Name,Flag)
			VALUES     (@row_ID,@Label_Name,'I')
			set @row_ID = @row_ID + 1
			fetch next from cur_allow  into @Label_Name,@Sorting_No
		end
	close cur_Allow
	deallocate Cur_Allow


      declare Cur_Allow   cursor for
	 
	  	select Distinct  Ad_Sort_Name ,Ad_level 
		from	t0210_monthly_ad_detail WITH (NOLOCK) inner join
				t0050_ad_master WITH (NOLOCK) on t0210_monthly_ad_detail.Ad_ID = t0050_ad_master.Ad_ID
				and t0210_monthly_ad_detail.Cmp_ID = t0050_ad_master.Cmp_ID
		where 	t0210_monthly_ad_detail.Cmp_ID= @Cmp_ID 
				and Ad_Active = 1 and AD_Flag = 'D' and ad_not_effect_salary = 1 And sal_type=1 and effect_net_salary = 1 
		order by Ad_level 
		
	open cur_allow
	fetch next from cur_allow  into @Label_Name,@Sorting_No
	while @@fetch_status = 0
		begin			
			INSERT INTO #Temp_report_Label (Row_ID, Label_Name,Flag)
			VALUES     (@row_ID,@Label_Name,'D')
			set @row_ID = @row_ID + 1
			fetch next from cur_allow  into @Label_Name,@Sorting_No
		end
	close cur_Allow
	deallocate Cur_Allow


		
		declare Cur_Allow_Not_Effect_Ded   cursor for
	  		select Distinct  Ad_Sort_Name ,Ad_level 
			from	t0210_monthly_ad_detail WITH (NOLOCK) inner join
					t0050_ad_master WITH (NOLOCK) on t0210_monthly_ad_detail.Ad_ID = t0050_ad_master.Ad_ID
					and t0210_monthly_ad_detail.Cmp_ID = t0050_ad_master.Cmp_ID
			where 	t0210_monthly_ad_detail.Cmp_ID= @Cmp_ID 
					and Ad_Active = 1 and AD_Flag = 'D' and ad_not_effect_salary = 1 And sal_type=1
			order by Ad_level 
			
		open Cur_Allow_Not_Effect_Ded
		fetch next from Cur_Allow_Not_Effect_Ded  into @Label_Name,@Sorting_No
		while @@fetch_status = 0
			begin
				
				INSERT INTO #Temp_report_Label
									  (Row_ID, Label_Name,Flag)
				VALUES     (@row_ID,@Label_Name,'D')
				set @row_ID = @row_ID + 1
				fetch next from Cur_Allow_Not_Effect_Ded  into @Label_Name,@Sorting_No
			end
		close Cur_Allow_Not_Effect_Ded
		deallocate Cur_Allow_Not_Effect_Ded
	
		
		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name,flag)
		VALUES (@row_ID,'Deduction','D')
		set @Row_ID = @Row_ID + 1
		
		INSERT INTO #Temp_report_Label
				(Row_ID, Label_Name,flag)
		VALUES (@row_ID,'Net','N')
		
	
		
	RETURN
	



