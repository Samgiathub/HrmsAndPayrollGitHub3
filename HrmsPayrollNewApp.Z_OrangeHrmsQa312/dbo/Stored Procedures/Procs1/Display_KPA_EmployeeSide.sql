
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Display_KPA_EmployeeSide]
	 @cmp_id as numeric(18,0)
	,@emp_id as numeric(18,0)
	,@dept_id as numeric
	,@desig_id as numeric
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	declare @response as int 
		set @response = 0
	declare @kpatype as int 
		set @kpatype = 1
		
if exists(select * from T0011_module_detail WITH (NOLOCK) where Cmp_id=@cmp_id and module_name='HRMS' and module_status=1)
	begin
		if exists(Select 1 from T0011_module_detail WITH (NOLOCK) where Cmp_id=@cmp_id and module_name='Appraisal2' and module_status=1)
			begin 
				if exists(select * from T0050_AppraisalLimit_Setting WITH (NOLOCK) where cmp_id = @cmp_id)
					begin
						select @kpatype =KPA_Default from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
						if @kpatype = 1
							begin
								if exists(select * from T0040_SelfAppraisal_Master WITH (NOLOCK) where SType=2 and SDept_Id like '%'+ cast(@dept_id as varchar(18)) +'%')
									begin 
										set @response = 1
										select KPA_Default,@response as response from T0050_AppraisalLimit_Setting WITH (NOLOCK) where cmp_id = @cmp_id
										
										select SApparisal_ID as KPA_Id,SApparisal_Content as KPA_Content, null as KPA_Target from T0040_SelfAppraisal_Master k  WITH (NOLOCK) where SType=2 
										and Effective_Date = (select max(Effective_Date) from T0040_SelfAppraisal_Master S WITH (NOLOCK) where s.Ref_SID =k.Ref_SID)
										--and @dept_id  in (select data from dbo.Split(SDept_Id,'#')) --like '%'+ cast(@dept_id as varchar(18)) +'%'
										and @dept_id like '%'+ cast(@dept_id as varchar(18)) +'%'
									end
								else
									begin 
										select @response as response
									end
							end
						else
							begin
								if exists(select * from T0060_Appraisal_EmployeeKPA WITH (NOLOCK) where Cmp_Id = @cmp_id and Emp_Id = @emp_id)
									begin
										set @response = 1
										select KPA_Default,@response as response from T0050_AppraisalLimit_Setting WITH (NOLOCK) where cmp_id = @cmp_id
										select Emp_KPA_Id as KPA_Id,KPA_Content,KPA_Target from T0060_Appraisal_EmployeeKPA WITH (NOLOCK) where Cmp_Id = @cmp_id and Emp_Id = @emp_id
									end
								Else
									begin
										if exists(select * from T0051_KPA_Master WITH (NOLOCK) where Cmp_Id = @cmp_id and Desig_Id like '%'+ CAST(@desig_id as varchar(18)) + '%')
											begin
												set @response = 1
												select KPA_Default,@response as response from T0050_AppraisalLimit_Setting WITH (NOLOCK) where cmp_id = @cmp_id
												select KPA_Id ,KPA_Content,KPA_Target from T0051_KPA_Master WITH (NOLOCK) where Cmp_Id = @cmp_id and Desig_Id like '%'+ CAST(@desig_id as varchar(18)) + '%'
											end
										Else
											begin
												select @response as response
											end
									end
							end
					end
				else
					begin
						select @response as response
					end
			end
		else
			begin 
				select @response as response
			end
	end
Else
	select @response as response
END

