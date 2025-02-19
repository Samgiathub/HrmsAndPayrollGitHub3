CREATE PROCEDURE [dbo].[Mobile_HRMS_P0110_TRAVEL_APPLICATION_DETAIL]
	 @Travel_App_Detail_ID	 NUMERIC(18,0) output
	,@Cmp_ID				 NUMERIC(18,0)
	,@Travel_App_ID			 NUMERIC(18,0)
	,@Instruct_Emp_ID		 NUMERIC(18,0)
	,@Tran_Type				 CHAR(1) 
	,@User_Id				 NUMERIC(18,0) = 0
	,@IP_Address			 varchar(30) = '' 
	,@TravelTypeId			 NUMERIC(18,0)
	,@Travel_Details		 XML

AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	


	DECLARE @OldValue as  varchar(max)
	Declare @String_val as varchar(max)
	set @String_val=''
	set @OldValue =''

	------------------------------------------------------------
	DECLARE @Project_ID	VARCHAR(300) 
	DECLARE @Loc_ID NUMERIC(18,0)
	
	DECLARE @Travel_Purpose	VARCHAR(300) 
	DECLARE @Travel_Mode_ID NUMERIC(18,0)
	
	DECLARE @From_Date	VARCHAR(300) 
	DECLARE @State_ID NUMERIC(18,0)
	
	DECLARE @To_Date VARCHAR(300) 
	DECLARE @City_ID NUMERIC(18,0)
	
	DECLARE @Place_Of_Visit VARCHAR(300) 
	DECLARE @Period NUMERIC(18,0)
	DECLARE @Remarks VARCHAR(100) 
	------------------------------------------------------------


	DECLARE @Result varchar(300) 

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
			IF (@Travel_Details.exist('/NewDataSet/TravelDetails') = 1)
				BEGIN
					SELECT
						(ROW_NUMBER() OVER(ORDER BY Table2.value('(Travel_App_Detail_ID/text())[1]','NUMERIC(18,0)'))) AS Rownum,
						Table2.value('(Travel_App_Detail_ID/text())[1]','NUMERIC(18,0)') AS tvl_app_detail_Id,
						Table2.value('(Place_Of_Visit/text())[1]','VARCHAR(150)') AS Place_Of_Visit,
						Table2.value('(Travel_Purpose/text())[1]','VARCHAR(150)') AS Travel_Purpose,
						Table2.value('(Travel_Mode_ID/text())[1]','NUMERIC(18,0)') AS Travel_Mode_ID,
						Table2.value('(From_Date/text())[1]','VARCHAR(100)') AS From_Date,
						Table2.value('(To_Date/text())[1]','VARCHAR(100)') AS To_Date, 
						Table2.value('(Period/text())[1]','NUMERIC(18,0)') AS Period, 
						Table2.value('(State_ID/text())[1]','NUMERIC(18,0)') AS State_ID,
						Table2.value('(City_ID/text())[1]','NUMERIC(18,0)') AS City_ID,
						Table2.value('(Remarks/text())[1]','VARCHAR(100)') AS Remarks,
						Table2.value('(Loc_ID/text())[1]','NUMERIC(18,0)') AS Loc_ID,
						Table2.value('(Project_ID/text())[1]','NUMERIC(18,0)') AS Project_ID,
						Table2.value('(Instruct_Emp_ID/text())[1]','NUMERIC(18,0)') AS Instruct_Emp_ID
					INTO #MyTeamDetailsTemp2 FROM @Travel_Details.nodes('/NewDataSet/TravelDetails') AS Temp(Table2)
				
				
					select * into #tmp from #MyTeamDetailsTemp2 -- Prapti
												
					DECLARE @COUNT int = 1
					Declare @Cnt as int = 0

					SELECT @COUNT = count(tvl_app_detail_Id) FROM #tmp
					WHILE(@Cnt < @COUNT)
					BEGIN
							  SET @Cnt = @Cnt + 1

							   SELECT top(1)
							   @Travel_Mode_ID = Travel_Mode_ID
							  ,@Travel_Purpose = Travel_Purpose,@From_Date = From_Date,@To_Date = To_Date
							  ,@State_ID = State_ID,@City_ID = City_ID ,@Loc_ID =Loc_ID,@Project_ID=Project_ID
							  ,@Place_Of_Visit = Place_Of_Visit,@Remarks = Remarks,@Period = Period
							  ,@Travel_Purpose = Travel_Purpose,@Instruct_Emp_ID = Instruct_Emp_ID
							   FROM #tmp
							   where Rownum = @Cnt			
						
							
					IF NOT EXISTS(SELECT Travel_App_Detail_ID FROM T0110_TRAVEL_APPLICATION_DETAIL WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and 
								Travel_App_ID=@Travel_App_ID and Travel_Purpose=@Travel_Purpose and From_Date=@From_Date 
								and To_Date=@To_Date and State_ID=@State_ID and City_ID=@City_ID)
				
						BEGIN

								Select @Travel_App_Detail_ID = ISNULL(MAX(Travel_App_Detail_ID),0) + 1 From T0110_TRAVEL_APPLICATION_DETAIL WITH (NOLOCK)
				
								INSERT INTO  T0110_TRAVEL_APPLICATION_DETAIL
								(
									Travel_App_Detail_ID,Cmp_ID,Travel_App_ID,Place_Of_Visit,Travel_Purpose,Instruct_Emp_ID,
									Travel_Mode_ID,From_Date,Period,To_Date,Remarks,State_ID,City_ID,Loc_ID	,Project_ID,TravelTypeId
								)
								VALUES 
								(
									@Travel_App_Detail_ID, @Cmp_ID, @Travel_App_ID,@Place_Of_Visit,@Travel_Purpose,@Instruct_Emp_ID,
									@Travel_Mode_ID,@From_Date,@Period,@To_Date,@Remarks,@State_ID,@City_ID,@Loc_ID,@Project_ID,@TravelTypeId
								)
						END
				ELSE
				Begin
						select  'update'
				end
						
						INSERT INTO #TravelHyScheme
						SELECT isnull(max(Rpt_Level),0) as RPT_max_level,Scheme_Id,Dyn_Hier_Id,Leave as TravelTypeId,@Instruct_Emp_ID 
						as App_Emp, @Travel_App_ID as AppId,Dy.DynHierColValue as RptEmp,GetDate() as CreatedDate 
						FROM T0050_Scheme_Detail SD
						inner join T0080_DynHierarchy_Value Dy on sd.Dyn_Hier_Id = DY.DynHierColId and Dy.Emp_ID = @Instruct_Emp_ID  
						where Scheme_Id = (
								SELECT DISTINCT T.Scheme_Id from T0095_EMP_SCHEME T Inner Join T0050_Scheme_Detail T1 ON T.Scheme_ID = T1.Scheme_Id 
								WHERE Emp_ID = @Instruct_Emp_ID And Type = 'Travel'
								AND Effective_Date = (SELECT max(Effective_Date) 
													  from T0095_EMP_SCHEME where Emp_ID = @Instruct_Emp_ID And Type = 'Travel' 
													  AND Effective_Date <= getdate()) 
								AND (SELECT distinct Travel_Type_Id from V0110_TRAVEL_APPLICATION_DETAIL where Travel_Application_ID = @Travel_App_ID) 
								IN (select data from dbo.split(leave,'#'))
						) 
						AND (SELECT distinct Travel_Type_Id from V0110_TRAVEL_APPLICATION_DETAIL where Travel_Application_ID = @Travel_App_ID) 
							IN (select data from dbo.split(leave,'#')) 
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
								
							exec P9999_Audit_get @table = 'T0110_TRAVEL_APPLICATION_DETAIL' ,@key_column='Travel_App_Detail_ID',@key_Values=@Travel_App_Detail_ID,@String=@String_val output
							set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
					
				END
				END 
			
		END
		
		IF (@Loc_ID != 0)
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

	--Else if UPPER(@Tran_Type)='U'
	--	begin
		
	--		Select @Travel_App_Detail_ID = ISNULL(MAX(Travel_App_Detail_ID),0) + 1 From T0110_TRAVEL_APPLICATION_DETAIL
	--		if not Exists(select Travel_App_Detail_ID from T0110_TRAVEL_APPLICATION_DETAIL where Cmp_ID=@Cmp_ID and Travel_App_ID=@Travel_App_ID and Travel_Mode_ID=@Travel_Mode_ID and Travel_Purpose=@Travel_Purpose and From_Date=@From_Date and To_Date=@To_Date and State_ID=@State_ID and City_ID=@City_ID)
	--		Begin
	--			Insert Into T0110_TRAVEL_APPLICATION_DETAIL 
	--				(Travel_App_Detail_ID, Cmp_ID, Travel_App_ID, Place_Of_Visit, Travel_Purpose, Instruct_Emp_ID, Travel_Mode_ID, 
	--				 From_Date, Period, To_Date, Remarks,State_ID,City_ID,Loc_ID)
	--			Values (@Travel_App_Detail_ID, @Cmp_ID, @Travel_App_ID, @Place_Of_Visit, @Travel_Purpose, @Instruct_Emp_ID, @Travel_Mode_ID,
	--					@From_Date, @Period, @To_Date, @Remarks,@State_ID,@City_ID,@Loc_ID)
	--		End			
	--	End	

	exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Travel Application Details',@OldValue,@Travel_App_Detail_ID,@User_Id,@IP_Address
		

END

