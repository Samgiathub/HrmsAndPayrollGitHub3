

-- =============================================
-- Author:		<Ankit>
-- ALTER date: <20062014>
-- Description:	<Description,,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
create PROCEDURE [dbo].[P0115_TRAVEL_LEVEL_APPROVAL_before_SynTravelType]
	 @Tran_ID				NUMERIC(18,0)	OUTPUT
	,@Travel_Application_ID NUMERIC(18,0)
	,@Cmp_ID				NUMERIC(18,0)
	,@Emp_ID				NUMERIC(18,0)
	,@S_Emp_ID				NUMERIC(18,0)
	,@Approval_Date			Datetime
	,@Approval_Status		Char(1)
	,@Approval_Comments		Varchar(250)
	,@Login_ID				NUMERIC(18,0)
	,@Rpt_Level				TinyInt
	,@Total					Numeric(18,2)
	,@Tran_Type				Char(1) 
	,@chk_Adv				tinyint
	,@chk_Agenda			tinyint
	,@Tour_Agenda			nvarchar(Max)
	,@IMP_Business_Appoint  nvarchar(Max)
	,@KRA_Tour				nvarchar(max)
	,@Attached_Doc_File		nvarchar(max)
AS

BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	Declare @Create_Date As Datetime
	
	Set @Create_Date = GETDATE()
	
	If @S_Emp_ID = 0
	Begin 
		Set @S_Emp_ID = NULL

		Declare @SchemeId as numeric(18,0)	  = 0
		Declare @ReportLevel as numeric(18,0) = 0

		SELECT @SchemeId = Scheme_ID 
		FROM T0095_EMP_SCHEME S
		INNER JOIN (
			SELECT max(Effective_Date) as EffDate,Tran_ID 
			FROM T0095_EMP_SCHEME S1 
			WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'
			group by Tran_id
		) Q1 on s.Effective_Date = Q1.EffDate and s.Tran_ID  = Q1.Tran_ID 
		WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'

		Select @ReportLevel = Rpt_Level  from T0115_TRAVEL_LEVEL_APPROVAL where  Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID 
		 
		IF @ReportLevel = 0
		Begin
			Select @S_Emp_ID = S_Emp_ID  from T0100_TRAVEL_APPLICATION where  Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID 
			
			SELECT @ReportLevel = 
			sd.Rpt_Level 
			FROM T0050_SCHEME_DETAIL SD 
			INNER JOIN  T0080_DynHierarchy_Value DV on SD.Dyn_Hier_Id = DV.DynHierColId
			INNER JOIN T0095_INCREMENT I on I.Increment_ID = DV.IncrementId
			WHERE sd.Scheme_Id = @SchemeId and DV.DynHierColValue = @S_Emp_ID and Dv.Emp_ID = @Emp_ID and Dv.Cmp_ID = @Cmp_ID


			SELECT @ReportLevel = @ReportLevel + 1 
			set @S_Emp_ID = 0	
		END
		ELSE
		IF @ReportLevel > 0
		Begin
			Select @S_Emp_ID = S_Emp_ID  from T0115_TRAVEL_LEVEL_APPROVAL where  Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID order by Tran_Id desc
			
			SELECT @ReportLevel = 
			sd.Rpt_Level 
			FROM T0050_SCHEME_DETAIL SD 
			INNER JOIN  T0080_DynHierarchy_Value DV on SD.Dyn_Hier_Id = DV.DynHierColId
			INNER JOIN T0095_INCREMENT I on I.Increment_ID = DV.IncrementId
			WHERE sd.Scheme_Id = @SchemeId and DV.DynHierColValue = @S_Emp_ID and Dv.Emp_ID = @Emp_ID and Dv.Cmp_ID = @Cmp_ID

			SELECT @ReportLevel = @ReportLevel + 1 
			set @S_Emp_ID = 0	
		END
		ELSE
		BEGIN 
			SET @ReportLevel = @ReportLevel + 1
		END

		if @ReportLevel > 0
		Begin 
			if isnull(@S_Emp_ID,0) = 0	
				select @S_Emp_ID = DynHierColValue from T0050_Scheme_Detail SD
				Inner join T0080_DynHierarchy_Value Dy
				on SD.Dyn_Hier_Id = DY.DynHierColId and sd.Scheme_Id = @SchemeId 
				and dy.Emp_ID = @Emp_ID and Rpt_Level = @ReportLevel
		END
	END
	If UPPER(@Tran_Type) = 'I'
		Begin
			
			IF Exists(Select 1 From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK) Where Emp_ID=@Emp_ID and Travel_Application_ID=@Travel_Application_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)
				Begin
					Set @Tran_ID = 0
					Select @Tran_ID
					Return 
				End
		
			Select @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
			
			Insert Into T0115_TRAVEL_LEVEL_APPROVAL
					(Tran_ID,Travel_Application_ID, Cmp_ID, Emp_ID, S_Emp_ID, Approval_Date, Approval_Status,Approval_Comments, Login_ID,Total, System_date,Rpt_Level,chk_Adv,chk_Agenda,Tour_Agenda,IMP_Business_Appoint,KRA_Tour,Attached_Doc_File)
			Values (@Tran_ID, @Travel_Application_ID, @Cmp_ID, @Emp_ID, @S_Emp_ID, @Approval_Date,@Approval_Status, @Approval_Comments, @Login_ID, @Total, @Create_Date,@Rpt_Level,@chk_Adv,@chk_Agenda,@Tour_Agenda,@IMP_Business_Appoint,@KRA_Tour,@Attached_Doc_File)
			
		End
END


