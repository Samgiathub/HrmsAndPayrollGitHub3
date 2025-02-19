
CREATE PROCEDURE [dbo].[Mobile_HRMS_TRAVEL_APPROVAL_DETAIL_LEVEL_APR]
	 @Cmp_ID				 NUMERIC(18,0)
	,@Travel_App_ID			 NUMERIC(18,0)
	,@Instruct_Emp_ID		 NUMERIC(18,0)
	,@Tran_Type				 CHAR(1) 
	,@User_Id				 NUMERIC(18,0) = 0
	,@IP_Address			 varchar(30) = '' 
	,@TravelTypeId			 NUMERIC(18,0)
	,@Travel_Details		 XML
	,@Half_Leave_Date		 Datetime = Null 
	,@Night_Day				 NUMERIC(18,0) = 0 
	,@Row_ID				 NUMERIC(18,0) = 0 	
	,@Tran_ID			     NUMERIC(18,0)
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
	DECLARE @Period NUMERIC(18,0)= 0
	DECLARE @Remarks VARCHAR(100) 

	DECLARE @Leave_Approval_ID  NUMERIC(18,0)
	DECLARE @Leave_ID           NUMERIC(18,0)
	DECLARE @LeaveType			 VARCHAR(50) = '' 
	------------------------------------------------------------
	DECLARE @Result varchar(300) 

	if @Half_Leave_Date = '01-01-1990' 
		set @Half_Leave_Date = NULL
		

	If (UPPER(@Tran_Type) = 'I')
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
						Table2.value('(Leave_Approval_ID/text())[1]','NUMERIC(18,0)') AS Leave_Approval_ID,
						Table2.value('(Leave_ID/text())[1]','NUMERIC(18,0)') AS Leave_ID,
						Table2.value('(LeaveType/text())[1]','VARCHAR(100)') AS LeaveType,
						Table2.value('(Night_Day/text())[1]','NUMERIC(18,0)') AS Night_Day
					INTO #MyTeamDetailsTemp2 FROM @Travel_Details.nodes('/NewDataSet/TravelDetails') AS Temp(Table2)
				
					IF (@Project_ID=0)
					BEGIN
						SET @Project_ID=null;
					END

					DECLARE @COUNT int = 1

					SELECT @COUNT = count(tvl_app_detail_Id) FROM #MyTeamDetailsTemp2  

					Declare @Cnt as int = 0

					WHILE(@Cnt < @COUNT)
					BEGIN
						
						SET @Cnt = @Cnt + 1

						SELECT top(1)
						 @Travel_Mode_ID = Travel_Mode_ID
						,@Travel_Purpose = Travel_Purpose,@From_Date = From_Date,@To_Date = To_Date
						,@State_ID = State_ID,@City_ID = City_ID ,@Loc_ID =Loc_ID,@Project_ID=Project_ID
						,@Place_Of_Visit = Place_Of_Visit,@Remarks = Remarks,@Period = Period
						,@Leave_Approval_ID = Leave_Approval_ID, @Leave_ID = Leave_ID,@LeaveType = LeaveType,@Night_Day = Night_Day
						 FROM #MyTeamDetailsTemp2 where Rownum = @Cnt

						Select @Row_ID = ISNULL(MAX(Row_ID),0) + 1 From T0115_TRAVEL_APPROVAL_DETAIL_LEVEL WITH (NOLOCK)
						
					IF NOT EXISTS(select Row_ID from T0115_TRAVEL_APPROVAL_DETAIL_LEVEL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Instruct_Emp_ID = @Instruct_Emp_ID
						and Leave_ID = @Leave_ID
						and Travel_Application_Id=@Travel_App_ID AND Place_Of_Visit = @Place_Of_Visit and Remarks = @Remarks
						and Travel_Purpose=@Travel_Purpose and from_date=@From_Date and Period =@Period
						and To_Date=@To_Date and State_ID=@State_ID and City_ID= @City_ID)
						BEGIN		

						  INSERT INTO T0115_TRAVEL_APPROVAL_DETAIL_LEVEL
							(   Row_ID,Tran_ID, Cmp_ID, Travel_Application_Id, Place_Of_Visit, Travel_Purpose, Instruct_Emp_ID, Travel_Mode_ID, 
								From_Date, Period, To_Date, Remarks,Leave_Approval_ID,Leave_ID,State_ID,City_ID,Loc_ID,Project_ID,Half_Leave_Date,
								Leavetype,Night_Day
							)
							VALUES 
							(   @Row_ID,@Tran_ID, @Cmp_ID, @Travel_App_ID, @Place_Of_Visit, @Travel_Purpose, @Instruct_Emp_ID, @Travel_Mode_ID,
								@From_Date, @Period, @To_Date, @Remarks,@Leave_Approval_ID,@Leave_ID,@State_ID,@City_ID,@Loc_ID,@Project_ID,@Half_Leave_Date,
								@Leavetype,@Night_Day
							)
						END

					Else
					Begin
								UPDATE T0115_TRAVEL_APPROVAL_DETAIL_LEVEL set
								Tran_ID = @Tran_ID, Cmp_ID = @Cmp_ID, Travel_Application_Id = @Travel_App_ID, Place_Of_Visit = @Place_Of_Visit
							    ,Travel_Purpose = @Travel_Purpose, Instruct_Emp_ID = @Instruct_Emp_ID, Travel_Mode_ID = @Travel_Mode_ID, 
								From_Date = @From_Date, Period = @Period, To_Date = @To_Date, Remarks = @Remarks,Leave_Approval_ID =@Leave_Approval_ID,
								Leave_ID = @Leave_ID,State_ID = @State_ID,City_ID = @City_ID,Loc_ID = @Loc_ID,Project_ID = @Project_ID,
								Half_Leave_Date = @Half_Leave_Date,Leavetype = @Leavetype,Night_Day = @Night_Day
								where Travel_Application_Id = @Travel_App_ID and Row_ID = @Row_ID and Cmp_ID = @Cmp_ID 
						END

				    END
				END 
			
		END

END

