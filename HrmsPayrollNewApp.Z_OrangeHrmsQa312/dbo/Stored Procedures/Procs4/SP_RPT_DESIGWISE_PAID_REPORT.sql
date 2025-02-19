



---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_DESIGWISE_PAID_REPORT]  
	 @Cmp_ID		numeric
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
	As  
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	Declare @test numeric
	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
		 
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	--If @Desig_ID = 0
	--	set @Desig_ID = null
		
	
	
	Declare @Desig_Cons Table
	(
		Desig_ID	numeric
	)
	
	if @Desig_ID = 0
		begin
			Insert Into @Desig_Cons
			select  DEsig_ID from t0040_Designation_master WITH (NOLOCK) where cmp_id=@Cmp_ID
		end
	else
		begin
			Insert Into @Desig_Cons values(@desig_id)
		end
	DEclare @Final_Data_Table table
		 (
		 Desig_ID numeric,
		 dept_ID numeric,
		 Grd_ID numeric,
		 NO_OF_emp numeric,
		 CTC  numeric,
		 Actual_Paid numeric
		 )
	
	dECLARE @Total_ctc NUMERIC
	dECLARE @Total_Paid NUMERIC
		
	 declare @Data_Table table  
	  (  
		  Ad_ID  Numeric,  
		  Cmp_Id Numeric,  
		  Emp_ID Numeric,  
		  CTC    Numeric,  
		  For_Date Datetime,
		  IS_CTC numeric,
		  DEsig_ID numeric,
		  Grd_ID numeric,
		  Dept_ID numeric,
		  AD_Flag char(1)
	  )   
	  
	
	  
  Insert into @Data_Table  
  
	  select AM.Ad_ID,EEM.cmp_id,EEM.Emp_ID,EEM.E_Ad_Amount,EEM.For_Date,1,i.Desig_ID,i.grd_id,i.Dept_ID,am.AD_Flag 
		  from t0050_ad_master am WITH (NOLOCK) Left outer join   
                       t0100_emp_earn_deduction EEM WITH (NOLOCK) on am.Ad_ID = EEM.Ad_ID Inner join   
		       t0080_emp_master EM WITH (NOLOCK) on EEM.Emp_ID = EM.Emp_ID inner join  
		       t0095_increment I WITH (NOLOCK) on EM.Increment_ID = I.Increment_Id   
	  where am.cmp_id=@CMP_ID   And am.ad_effect_on_ctc=1  and i.Increment_Effective_Date = EEM.For_Date and i.desig_id in(select Desig_ID From @Desig_Cons)   
   
	  Insert into @Data_Table  
	  Select 0,I.Cmp_Id,EM.Emp_ID,I.Basic_Salary,I.Increment_Effective_Date,1,i.Desig_ID,i.grd_id,i.Dept_ID,'I' from t0095_Increment I WITH (NOLOCK) Left outer join t0080_emp_master EM WITH (NOLOCK) On I.Increment_ID = EM.Increment_ID where  EM.Cmp_Id = @Cmp_ID   and i.desig_id in(select Desig_ID From @Desig_Cons)



  Insert into @Data_Table  
  
	  select AM.Ad_ID,EEM.cmp_id,EEM.Emp_ID,EEM.E_Ad_Amount,EEM.For_Date,0,i.Desig_ID,i.grd_id,i.Dept_ID,AD_Flag   
		  from t0050_ad_master am WITH (NOLOCK) Left outer join   
                       t0100_emp_earn_deduction EEM WITH (NOLOCK) on am.Ad_ID = EEM.Ad_ID Inner join   
		       t0080_emp_master EM WITH (NOLOCK) on EEM.Emp_ID = EM.Emp_ID inner join  
		       t0095_increment I WITH (NOLOCK) on EM.Increment_ID = I.Increment_Id   
	  where am.cmp_id=@CMP_ID And  am.ad_not_effect_salary=0 and i.Increment_Effective_Date = EEM.For_Date  and i.desig_id in(select Desig_ID From @Desig_Cons) 
   
   Insert into @Data_Table  
	  Select 0,I.Cmp_Id,EM.Emp_ID,I.Basic_Salary,I.Increment_Effective_Date,0,i.Desig_ID,i.grd_id,i.Dept_ID,'I' from t0095_Increment I WITH (NOLOCK) Left outer join t0080_emp_master EM WITH (NOLOCK) On I.Increment_ID = EM.Increment_ID where EM.Cmp_Id = @Cmp_ID   and i.desig_id in(select Desig_ID From @Desig_Cons)
	  
	--	select dt.*,desig_name,grd_name,dept_name from @data_table  dt 
	--	inner join t0040_designation_master as dm on dt.desig_id =  dm.desig_id 
		--inner join t0040_grade_master as gm on dt.grd_id = gm.grd_id
	--	inner join t0040_department_master as dpm on dt.dept_id = dpm.dept_id
		
		
	--	Select @Total_Ctc=Sum(CTC) from @Data_Table   where is_ctc=1
	--	Select @Total_Paid=Sum(CTC) from @Data_Table   where is_ctc=0

		
		
	declare @cur_Desig_ID numeric
	declare	 @cur_dept_ID numeric
	declare	 @cur_Grd_ID numeric
	declare	 @cur_NO_OF_emp numeric
	declare	 @cur_CTC  numeric
	declare	 @cur_Actual_Paid numeric
	declare @is_ctc numeric
	declare @ad_Falg char
	
	
	Declare Cur_Desig cursor for 
		select Desig_id,dept_id,grd_id,ad_id,CTC,0,is_ctc,AD_Flag from @data_table 
		order by Desig_id 
	open Cur_Desig
		fetch next from Cur_Desig into @cur_desig_id,@cur_dept_ID,@cur_Grd_ID,@cur_NO_OF_emp,@cur_CTC,@cur_Actual_Paid,@is_ctc,@ad_Falg
		While @@Fetch_Status=0
		begin 
			if @is_ctc=1
				begin
						if exists(select desig_id from @Final_Data_Table where desig_id = @cur_desig_id)
								begin 
									if @cur_NO_OF_emp =0
										begin 
											update @Final_Data_Table set 
											CTC = CTC + @cur_CTC ,
											NO_OF_emp = NO_OF_emp +1 where desig_id = @cur_desig_id
										end
									else
										begin
											update @Final_Data_Table set 
											CTC = CTC + @cur_CTC where desig_id = @cur_desig_id
										end	
					        	end 
					 else
								begin 
											insert into @Final_Data_Table values(@cur_Desig_ID,@cur_dept_ID,@cur_Grd_ID,0,@cur_CTC,0)
								end	
				end				
			else if @is_ctc=0
				begin			
								if exists(select desig_id from @Final_Data_Table where desig_id = @cur_desig_id)
										begin 
												if @ad_Falg = 'I'
													begin 
															update @Final_Data_Table set 
												   	Actual_Paid = Actual_Paid +@cur_CTC where desig_id = @cur_desig_id
													end
												else if @ad_Falg = 'D'
													begin 
														update @Final_Data_Table set 
															Actual_Paid = Actual_Paid -@cur_CTC where desig_id = @cur_desig_id
													end
										end 
								 else
										begin 
											if @ad_Falg = 'I'
													begin 
														insert into @Final_Data_Table values(@cur_Desig_ID,@cur_dept_ID,@cur_Grd_ID,0,0,@cur_CTC)
													end
											else if @ad_Falg = 'D'
													begin 
														Declare @amt numeric
															set @amt=0
															set	@amt = @amt - @cur_CTC
														insert into @Final_Data_Table values(@cur_Desig_ID,@cur_dept_ID,@cur_Grd_ID,0,0,@amt)
													end
										end	
				end		
			fetch next from Cur_Desig into @cur_desig_id,@cur_dept_ID,@cur_Grd_ID,@cur_NO_OF_emp,@cur_CTC,@cur_Actual_Paid,@is_ctc,@ad_Falg
		end
	close Cur_Desig
	Deallocate Cur_Desig 
		
		select FDT.*,dm.desig_name,gm.grd_name,dpm.dept_name from @Final_Data_Table as  FDT
		inner join t0040_designation_master as dm WITH (NOLOCK) on FDT.desig_id =  dm.desig_id 
		inner join t0040_grade_master as gm WITH (NOLOCK) on FDT.grd_id = gm.grd_id
		inner join t0040_department_master as dpm WITH (NOLOCK) on FDT.dept_id = dpm.dept_id
		
 RETURN  




