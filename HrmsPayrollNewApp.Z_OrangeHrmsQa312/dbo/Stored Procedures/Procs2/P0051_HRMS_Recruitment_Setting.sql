
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0051_HRMS_Recruitment_Setting]
	   @Rec_SettingId			numeric(18,0) output
      ,@RecApplicationId		numeric(18,0)
      ,@CmpId					numeric(18,0)
      ,@PostVacancy_CmpId		numeric(18,0)
      ,@PostVacancy_EmpId		numeric(18,0)
      ,@Shortlist_CmpId			numeric(18,0)
      ,@Shortlist_EmpId			numeric(18,0)
      ,@BusinessHead_CmpId		numeric(18,0)
      ,@BusinessHead_EmpId		numeric(18,0)
      ,@CreatedBy				numeric(18,0)
      ,@tran_type				char(1)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if @PostVacancy_CmpId= 0
		set @PostVacancy_CmpId = null
	if @PostVacancy_EmpId = 0
		set @PostVacancy_EmpId = null
	if @Shortlist_CmpId = 0
		set @Shortlist_CmpId = null
	if @Shortlist_EmpId = 0
		set @Shortlist_EmpId = null
	if @BusinessHead_CmpId = 0
		set @BusinessHead_CmpId = null
	if @BusinessHead_EmpId = 0
		set @BusinessHead_EmpId = null
	
	
	
	If @tran_type = 'I'
		Begin
			if @Rec_SettingId = 0
				begin
					select @Rec_SettingId = isnull(max(Rec_SettingId),0) + 1 from T0051_HRMS_Recruitment_Setting WITH (NOLOCK)
					
					if exists( select 1 from T0051_HRMS_Recruitment_Setting WITH (NOLOCK) where RecApplicationId = @RecApplicationId)
					begin 
					
					Update T0051_HRMS_Recruitment_Setting Set
					  PostVacancy_CmpId	= @PostVacancy_CmpId
					  ,PostVacancy_EmpId	= @PostVacancy_EmpId
					  ,Shortlist_CmpId		= @Shortlist_CmpId
					  ,Shortlist_EmpId		= @Shortlist_EmpId
					  ,BusinessHead_CmpId	= @BusinessHead_CmpId
					  ,BusinessHead_EmpId	= @BusinessHead_EmpId
					Where RecApplicationId		= @RecApplicationId
					
					end
					else
					begin
					insert into T0051_HRMS_Recruitment_Setting
					(
						   Rec_SettingId
						  ,RecApplicationId
						  ,CmpId
						  ,PostVacancy_CmpId
						  ,PostVacancy_EmpId
						  ,Shortlist_CmpId
						  ,Shortlist_EmpId
						  ,BusinessHead_CmpId
						  ,BusinessHead_EmpId
						  ,CreatedBy
						  ,CreatedDate
					)
					values
					(
						   @Rec_SettingId
						  ,@RecApplicationId
						  ,@CmpId
						  ,@PostVacancy_CmpId
						  ,@PostVacancy_EmpId
						  ,@Shortlist_CmpId
						  ,@Shortlist_EmpId
						  ,@BusinessHead_CmpId
						  ,@BusinessHead_EmpId
						  ,@CreatedBy
						  ,GETDATE()
					)
					end
				End
		End
	Else if @tran_type = 'U'
		Begin
			if exists(select 1 from T0051_HRMS_Recruitment_Setting WITH (NOLOCK) where Rec_SettingId=@Rec_SettingId)
				Begin
					Update T0051_HRMS_Recruitment_Setting Set
					   RecApplicationId		= @RecApplicationId
					  ,PostVacancy_CmpId	= @PostVacancy_CmpId
					  ,PostVacancy_EmpId	= @PostVacancy_EmpId
					  ,Shortlist_CmpId		= @Shortlist_CmpId
					  ,Shortlist_EmpId		= @Shortlist_EmpId
					  ,BusinessHead_CmpId	= @BusinessHead_CmpId
					  ,BusinessHead_EmpId	= @BusinessHead_EmpId
					Where Rec_SettingId = @Rec_SettingId
				End
		End
	Else if @tran_type ='D'
		Begin
			delete  from T0051_HRMS_Recruitment_Setting where Rec_SettingId=@Rec_SettingId
		End
END


