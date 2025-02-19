

---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_TRAVEl_APP_Detail]
	 @Travel_App_Detail_ID	NUMERIC(18,0) 
	,@Cmp_ID				NUMERIC(18,0)
	,@Travel_App_ID			NUMERIC(18,0)
	,@Place_Of_Visit		Varchar(100)
	,@Travel_Purpose		Varchar(200)
	,@Instruct_Emp_ID		NUMERIC(18,0)
	,@Travel_Mode_ID		NUMERIC(18,0)
	,@From_Date				Datetime
	,@Period				NUMERIC(18,2)
	,@To_Date				Datetime
	,@Remarks				Nvarchar(500)
	,@State_ID				numeric(18,0)=0
	,@City_ID				numeric(18,0)=0
	,@Loc_ID				numeric(18,0)=0
	,@Project_ID			numeric(18,0)=0
	,@Tran_Type				CHAR(1) 
	,@User_Id				NUMERIC(18,0) = 0
	,@IP_Address			varchar(30) = '192.168.1.94' 
	,@TravelTypeId			NUMERIC(18,0)
	,@Result				varchar(100) OUTPUT
	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
-- Add By Mukti 11072016(start)
	declare @OldValue as  varchar(max)
	Declare @String_val as varchar(max)
	set @String_val=''
	set @OldValue =''
-- Add By Mukti 11072016(end)	

	if (@Project_ID=0)
		Begin
			set @Project_ID=null;
		End

	
		IF OBJECT_ID(N'tempdb..#TravelHyScheme') IS NOT NULL
		BEGIN
			DROP TABLE #TravelHyScheme
		END
		
		Create table #TravelHyScheme
		(
			RptLevel numeric(18,0),
			Scheme_id numeric(18,0),
			DynHierId numeric(18,0),
			TravelTypeId varchar(50),
			AppEmp numeric(18,0),
			AppId numeric(18,0),
			RptEmp numeric(18,0),
			CreateDate DateTime
  		)
	
	If (UPPER(@Tran_Type) = 'I' or UPPER(@Tran_Type) = 'U' or UPPER(@Tran_Type) = 'M')
		Begin
			Select @Travel_App_Detail_ID = ISNULL(MAX(Travel_App_Detail_ID),0) + 1 From T0110_TRAVEL_APPLICATION_DETAIL WITH (NOLOCK)
			--Select  @Travel_App_ID= ISNULL(MAX(Travel_Application_ID),0)  from T0100_TRAVEL_APPLICATION 
			if not Exists(select Travel_App_Detail_ID from T0110_TRAVEL_APPLICATION_DETAIL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Travel_App_ID=@Travel_App_ID and Travel_Mode_ID=@Travel_Mode_ID and Travel_Purpose=@Travel_Purpose and From_Date=@From_Date and To_Date=@To_Date and State_ID=@State_ID and City_ID=@City_ID)
				Begin
					Insert Into T0110_TRAVEL_APPLICATION_DETAIL 
						(Travel_App_Detail_ID, Cmp_ID, Travel_App_ID, Place_Of_Visit, Travel_Purpose, Instruct_Emp_ID, Travel_Mode_ID, 
						 From_Date, Period, To_Date, Remarks,State_ID,City_ID,Loc_ID,Project_ID,TravelTypeId)
					Values (@Travel_App_Detail_ID, @Cmp_ID, @Travel_App_ID, @Place_Of_Visit, @Travel_Purpose, @Instruct_Emp_ID, @Travel_Mode_ID,
							@From_Date, @Period, @To_Date, @Remarks,@State_ID,@City_ID,@Loc_ID,@Project_ID,@TravelTypeId)
					
					INSERT INTO #TravelHyScheme
					SELECT isnull(max(Rpt_Level),0) as RPT_max_level,Scheme_Id,Dyn_Hier_Id,Leave as TravelTypeId,@Instruct_Emp_ID as App_Emp, @Travel_App_ID as AppId,Dy.DynHierColValue as RptEmp,GetDate() as CreatedDate 
					FROM T0050_Scheme_Detail SD
					inner join T0080_DynHierarchy_Value Dy on sd.Dyn_Hier_Id = DY.DynHierColId and Dy.Emp_ID = @Instruct_Emp_ID  
					where Scheme_Id = (
							SELECT DISTINCT T.Scheme_Id from T0095_EMP_SCHEME T Inner Join T0050_Scheme_Detail T1 ON T.Scheme_ID = T1.Scheme_Id 
							WHERE Emp_ID = @Instruct_Emp_ID And Type = 'Travel'
							AND Effective_Date = (SELECT max(Effective_Date) 
												  from T0095_EMP_SCHEME where Emp_ID = @Instruct_Emp_ID And Type = 'Travel' 
												  AND Effective_Date <= getdate()) 
							AND (SELECT Travel_Type_Id from V0110_TRAVEL_APPLICATION_DETAIL where Travel_Application_ID = @Travel_App_ID) IN (select data from dbo.split(leave,'#'))
					) 
					AND (SELECT Travel_Type_Id from V0110_TRAVEL_APPLICATION_DETAIL where Travel_Application_ID = @Travel_App_ID) IN (select data from dbo.split(leave,'#')) 
					GROUP BY Scheme_Id,Dyn_Hier_Id,Leave,DynHierColValue
					
						If ((Select Count(1) from T0080_Travel_HycScheme_Email) > 0)	
							Truncate table T0080_Travel_HycScheme_Email

						insert into T0080_Travel_HycScheme_Email
						select * from #TravelHyScheme

						MERGE T0080_Travel_HycScheme AS Target
						USING #TravelHyScheme	AS Source
						ON	Source.RptLevel = Target.RptLevel and 
							Source.Scheme_id = Target.SchemeIId and
							Source.DynHierId = target.DynHierId and
							Source.TravelTypeId = target.TravelTypeId and 
							source.AppEmp = target.AppEmp and 
							source.AppId = target.AppId and
							source.RptEmp = target.RptEmp
						WHEN NOT MATCHED BY Target THEN
							INSERT (RptLevel,SchemeIId, DynHierId,TravelTypeId,AppEmp,AppId,RptEmp,CreateDate) 
							VALUES (Source.RptLevel,Source.Scheme_id, Source.DynHierId,source.TravelTypeId,source.AppEmp,source.AppId,source.RptEmp,getdate())
						WHEN MATCHED THEN 
							UPDATE SET
							Target.RptLevel	= Source.RptLevel,
							Target.SchemeIId = Source.Scheme_id,
							Target.DynHierId = Source.DynHierId,
							Target.TravelTypeId = Source.TravelTypeId,
							Target.AppEmp = Source.AppEmp,
							Target.AppId = Source.AppId,
							Target.RptEmp = Source.RptEmp,
							Target.CreateDate = GetDate();

							
					-- Add By Mukti 11072016(start)
						exec P9999_Audit_get @table = 'T0110_TRAVEL_APPLICATION_DETAIL' ,@key_column='Travel_App_Detail_ID',@key_Values=@Travel_App_Detail_ID,@String=@String_val output
						set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
				-- Add By Mukti 11072016(end)
				End		
				
				IF(@Travel_App_Detail_ID > 0)
				Begin
					set @Result = cast(@Travel_App_ID as varchar(10))
				SELECT @Result
				End
			
		End
		if (@Loc_ID != 0)
		Begin
			update T0100_TRAVEL_APPLICATION set Chk_International=1
				where Travel_Application_ID=@Travel_App_ID and Cmp_ID=@Cmp_ID
		End	
		
		
		
	Else
		Begin
			update T0100_TRAVEL_APPLICATION set Chk_International=0
				where Travel_Application_ID=@Travel_App_ID and Cmp_ID=@Cmp_ID
		End	
	if (@Loc_ID != 0)
		Begin
			update T0100_TRAVEL_APPLICATION set Chk_International=1
				where Travel_Application_ID=@Travel_App_ID and Cmp_ID=@Cmp_ID
		End	
	Else if UPPER(@Tran_Type)='U'
		begin
			Select @Travel_App_Detail_ID = ISNULL(MAX(Travel_App_Detail_ID),0) + 1 From T0110_TRAVEL_APPLICATION_DETAIL
			if not Exists(select Travel_App_Detail_ID from T0110_TRAVEL_APPLICATION_DETAIL where Cmp_ID=@Cmp_ID and Travel_App_ID=@Travel_App_ID and Travel_Mode_ID=@Travel_Mode_ID and Travel_Purpose=@Travel_Purpose and From_Date=@From_Date and To_Date=@To_Date and State_ID=@State_ID and City_ID=@City_ID)
			Begin
				Insert Into T0110_TRAVEL_APPLICATION_DETAIL 
					(Travel_App_Detail_ID, Cmp_ID, Travel_App_ID, Place_Of_Visit, Travel_Purpose, Instruct_Emp_ID, Travel_Mode_ID, 
					 From_Date, Period, To_Date, Remarks,State_ID,City_ID,Loc_ID)
				Values (@Travel_App_Detail_ID, @Cmp_ID, @Travel_App_ID, @Place_Of_Visit, @Travel_Purpose, @Instruct_Emp_ID, @Travel_Mode_ID,
						@From_Date, @Period, @To_Date, @Remarks,@State_ID,@City_ID,@Loc_ID)
			End			
		End	
	exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Travel Application Details',@OldValue,@Travel_App_Detail_ID,@User_Id,@IP_Address
END


