


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Fill_Appraisal_Other_Details]
	  @cmp_id	 numeric(18,0)
	 ,@init_id numeric(18,0)	
	 ,@emp_id  numeric(18,0)
	 ,@flag char(10)	 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if @flag='Final'	
	BEGIN
	
		 if exists(select 1 from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where InitiateId=@init_id and Approval_Level='Final' 
					and Cmp_ID=@cmp_id and Emp_ID=@emp_id)
			BEGIN			
				SELECT hao.AO_ID as Action_ID,HAO_Id,Emp_ID,InitiateId,Justification,TimeFrame_Id,Promo_Desig,from_date,to_date,
					Approval_Level,ao.AO_Id,ao.Action,ao.Desig_Required,ao.From_Date_Required,ao.To_Date_Required 
				from T0030_Appraisal_OtherDetails ao  WITH (NOLOCK)
				left join T0110_HRMS_Appraisal_OtherDetails hao WITH (NOLOCK) on hao.AO_Id=ao.AO_Id and hao.cmp_id=ao.cmp_id and 
				hao.InitiateId=@init_id and hao.Approval_Level='Final' where ao.Cmp_ID =@cmp_id and ao.Active=1
			END
		ELSE if exists(select HAO_Id from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where InitiateId=@init_id and Approval_Level='GH' 
					and Cmp_ID=@cmp_id and Emp_ID=@emp_id)
			BEGIN			
				SELECT hao.AO_ID as Action_ID,HAO_Id,Emp_ID,InitiateId,Justification,TimeFrame_Id,Promo_Desig,from_date,to_date,
					Approval_Level,ao.AO_Id,ao.Action,ao.Desig_Required,ao.From_Date_Required,ao.To_Date_Required 
				from T0030_Appraisal_OtherDetails ao WITH (NOLOCK)
				left join T0110_HRMS_Appraisal_OtherDetails hao WITH (NOLOCK) on hao.AO_Id=ao.AO_Id and hao.cmp_id=ao.cmp_id and 
				hao.InitiateId=@init_id and hao.Approval_Level='GH' where ao.Cmp_ID =@cmp_id and ao.Active=1
			END
		ELSE if exists(select 1 from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where InitiateId=@init_id and Approval_Level='HOD' 
					and Cmp_ID=@cmp_id and Emp_ID=@emp_id)
			BEGIN
				SELECT hao.AO_ID as Action_ID,HAO_Id,Emp_ID,InitiateId,Justification,TimeFrame_Id,Promo_Desig,from_date,to_date,
					Approval_Level,ao.AO_Id,ao.Action,ao.Desig_Required,ao.From_Date_Required,ao.To_Date_Required 
				from T0030_Appraisal_OtherDetails ao WITH (NOLOCK)
				left join T0110_HRMS_Appraisal_OtherDetails hao WITH (NOLOCK) on hao.AO_Id=ao.AO_Id and hao.cmp_id=ao.cmp_id and 
				hao.InitiateId=@init_id and hao.Approval_Level='HOD' where ao.Cmp_ID =@cmp_id and ao.Active=1
			END
			
		ELSE 
			BEGIN
				SELECT hao.AO_ID as Action_ID,HAO_Id,Emp_ID,InitiateId,Justification,TimeFrame_Id,Promo_Desig,from_date,to_date,
					Approval_Level,ao.AO_Id,ao.Action,ao.Desig_Required,ao.From_Date_Required,ao.To_Date_Required 
				from T0030_Appraisal_OtherDetails ao WITH (NOLOCK)
				left join T0110_HRMS_Appraisal_OtherDetails hao WITH (NOLOCK) on hao.AO_Id=ao.AO_Id and hao.cmp_id=ao.cmp_id and 
				hao.InitiateId=@init_id and hao.Approval_Level='RM' where ao.Cmp_ID =@cmp_id and ao.Active=1
			END
		
		if EXISTS(select 1 from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='Final')
			BEGIN
				select * from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='Final'
			END	
		else if EXISTS(select 1 from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='GH')
			BEGIN
				select * from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='GH'
			END
		else if	EXISTS(select 1 from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='HOD')
			BEGIN
				select * from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='HOD'
			END	
		else if	EXISTS(select 1 from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='RM')
			BEGIN
				select * from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='RM'
			END	
		else if	EXISTS(select 1 from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='Emp')
			BEGIN
				select * from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='Emp'
			END				
	END
	
	if @flag='GH'	
	BEGIN
		 if exists(select 1 from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where InitiateId=@init_id and Approval_Level='GH' 
					and Cmp_ID=@cmp_id and Emp_ID=@emp_id)
			BEGIN
				SELECT hao.AO_ID as Action_ID,HAO_Id,Emp_ID,InitiateId,Justification,TimeFrame_Id,Promo_Desig,from_date,to_date,
					Approval_Level,ao.AO_Id,ao.Action,ao.Desig_Required,ao.From_Date_Required,ao.To_Date_Required 
				from T0030_Appraisal_OtherDetails ao WITH (NOLOCK)
				left join T0110_HRMS_Appraisal_OtherDetails hao WITH (NOLOCK) on hao.AO_Id=ao.AO_Id and hao.cmp_id=ao.cmp_id and 
				hao.InitiateId=@init_id and hao.Approval_Level='GH' where ao.Cmp_ID =@cmp_id and ao.Active=1
			END
		ELSE if exists(select 1 from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where InitiateId=@init_id and Approval_Level='HOD' 
					and Cmp_ID=@cmp_id and Emp_ID=@emp_id)
			BEGIN
				SELECT hao.AO_ID as Action_ID,HAO_Id,Emp_ID,InitiateId,Justification,TimeFrame_Id,Promo_Desig,from_date,to_date,
					Approval_Level,ao.AO_Id,ao.Action,ao.Desig_Required,ao.From_Date_Required,ao.To_Date_Required 
				from T0030_Appraisal_OtherDetails ao WITH (NOLOCK)
				left join T0110_HRMS_Appraisal_OtherDetails hao WITH (NOLOCK) on hao.AO_Id=ao.AO_Id and hao.cmp_id=ao.cmp_id and 
				hao.InitiateId=@init_id and hao.Approval_Level='HOD' where ao.Cmp_ID =@cmp_id and ao.Active=1
			END
		ELSE 
			BEGIN
				SELECT hao.AO_ID as Action_ID,HAO_Id,Emp_ID,InitiateId,Justification,TimeFrame_Id,Promo_Desig,from_date,to_date,
					Approval_Level,ao.AO_Id,ao.Action,ao.Desig_Required,ao.From_Date_Required,ao.To_Date_Required 
				from T0030_Appraisal_OtherDetails  ao WITH (NOLOCK)
				left join T0110_HRMS_Appraisal_OtherDetails hao WITH (NOLOCK) on hao.AO_Id=ao.AO_Id and hao.cmp_id=ao.cmp_id and 
				hao.InitiateId=@init_id and hao.Approval_Level='RM' where ao.Cmp_ID =@cmp_id and ao.Active=1
			END
			
		if EXISTS(select 1 from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='GH')
			BEGIN
				select * from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='GH'
			END
		else if	EXISTS(select 1 from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='HOD')
			BEGIN
				select * from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='HOD'
			END	
		else if	EXISTS(select 1 from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='RM')
			BEGIN
				select * from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='RM'
			END	
		else if	EXISTS(select 1 from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='Emp')
			BEGIN
				select * from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='Emp'
			END	
	END
	
	if @flag='HOD'	
	BEGIN
	print 'ff'
	if exists(select 1 from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where InitiateId=@init_id and Approval_Level='HOD' 
					and Cmp_ID=@cmp_id and Emp_ID=@emp_id)
			BEGIN
			PRINT 'm'
				SELECT hao.AO_ID as Action_ID,HAO_Id,Emp_ID,InitiateId,Justification,TimeFrame_Id,Promo_Desig,from_date,to_date,
					Approval_Level,ao.AO_Id,ao.Action,ao.Desig_Required,ao.From_Date_Required,ao.To_Date_Required 
				from T0030_Appraisal_OtherDetails ao WITH (NOLOCK) 
				left join T0110_HRMS_Appraisal_OtherDetails hao WITH (NOLOCK) on hao.AO_Id=ao.AO_Id and hao.cmp_id=ao.cmp_id and 
				hao.InitiateId=@init_id and hao.Approval_Level='HOD' where ao.Cmp_ID =@cmp_id and ao.Active=1
			END
			
		ELSE if exists(select 1 from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where InitiateId=@init_id and Approval_Level='RM' 
					and Cmp_ID=@cmp_id and Emp_ID=@emp_id)
			BEGIN
			PRINT 'k'
				SELECT hao.AO_ID as Action_ID,HAO_Id,Emp_ID,InitiateId,Justification,TimeFrame_Id,Promo_Desig,from_date,to_date,
					Approval_Level,ao.AO_Id,ao.Action,ao.Desig_Required,ao.From_Date_Required,ao.To_Date_Required 
				from T0030_Appraisal_OtherDetails ao WITH (NOLOCK)
				left join T0110_HRMS_Appraisal_OtherDetails hao WITH (NOLOCK) on hao.AO_Id=ao.AO_Id and hao.cmp_id=ao.cmp_id and 
				hao.InitiateId=@init_id and hao.Approval_Level='RM' where ao.Cmp_ID =@cmp_id and ao.Active=1
			END
		ELSE
			BEGIN
				SELECT hao.AO_ID as Action_ID,HAO_Id,Emp_ID,InitiateId,Justification,TimeFrame_Id,Promo_Desig,from_date,to_date,
					Approval_Level,ao.AO_Id,ao.Action,ao.Desig_Required,ao.From_Date_Required,ao.To_Date_Required 
				from T0030_Appraisal_OtherDetails ao WITH (NOLOCK)
				left join T0110_HRMS_Appraisal_OtherDetails hao WITH (NOLOCK) on hao.AO_Id=ao.AO_Id and hao.cmp_id=ao.cmp_id and 
				hao.InitiateId=@init_id and hao.Approval_Level='RM' where ao.Cmp_ID =@cmp_id and ao.Active=1	
			END
			
		if	EXISTS(select 1 from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='HOD')
			BEGIN
				select * from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='HOD'
			END	
		else if	EXISTS(select 1 from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='RM')
			BEGIN
				select * from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='RM'
			END	
		else if	EXISTS(select 1 from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='Emp')
			BEGIN
				select * from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='Emp'
			END	
	END
	
	if @flag='RM'	
	BEGIN
			SELECT hao.AO_ID as Action_ID,HAO_Id,Emp_ID,InitiateId,Justification,TimeFrame_Id,Promo_Desig,from_date,to_date,
				Approval_Level,ao.AO_Id,ao.Action,ao.Desig_Required,ao.From_Date_Required,ao.To_Date_Required 
			from T0030_Appraisal_OtherDetails ao WITH (NOLOCK)
			left join T0110_HRMS_Appraisal_OtherDetails hao WITH (NOLOCK) on hao.AO_Id=ao.AO_Id and hao.cmp_id=ao.cmp_id and 
			hao.InitiateId=@init_id and hao.Approval_Level='RM' where ao.Cmp_ID =@cmp_id and ao.Active=1	 		
		
			if	EXISTS(select 1 from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='RM')
				BEGIN
					select * from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='RM'
				END	
			ELSE
				BEGIN
					select * from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id and Approval_Level='Emp'
				END
	END
	
	if @flag='Emp'	
	BEGIN
		select * from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and initiateid=@init_id 
		and Approval_Level='Emp'
	END
END	

