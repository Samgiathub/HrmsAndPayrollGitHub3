-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 06/09/2023
-- Description:	Insert Live Tracking Data From Mobile
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_LiveTracking_Insert]
	@Cmp_ID NUMERIC(18,0),
	@Emp_ID NUMERIC(18,0),
	@LiveTracking_Details XML,
	@Type char(1),
	@Result varchar(100) OUTPUT
AS
BEGIN
	IF @Type = 'I' -- For Template Insert
	BEGIN
		DECLARE @Distance_Km nvarchar(50)		
		DECLARE @Origin_Location nVARCHAR(MAX)
		DECLARE @Destination_Location nVARCHAR(MAX)
		Declare @LT_Id numeric(18,0)
		--DECLARE @Flag int
		--Declare @Field_Type nvarchar(100)
		DECLARE @Status AS TINYINT
		
		SET @STATUS = 0
		SET @LT_Id = 0		
		DECLARE @CURRENTDATETIME DATETIME
		SET @CURRENTDATETIME  = GETDATE()

		
		SELECT --Table1.value('(SurveyEmp_ID/text())[1]','numeric(18,0)') AS SurveyEmpID,
		Table1.value('(Distance_Km/text())[1]','nvarchar(50)') AS Distance_Km,		
		Table1.value('(Origin_Location/text())[1]','nvarchar(MAX)') AS Origin_Location,
		Table1.value('(Destination_Location/text())[1]','nvarchar(MAX)') AS Destination_Location		
		INTO #Template FROM @LiveTracking_Details.nodes('/NewDataSet/Table1') as Temp(Table1)
				
		DECLARE @Dis_Km numeric(16, 2)
		DECLARE @Origin_Loc nVARCHAR(MAX)
		DECLARE @Destination_Loc nVARCHAR(MAX)		
		
		SET @Dis_Km = '0'		
		Set @Origin_Loc = ''
		Set @Destination_Loc = ''		
		
		--SELECT Distance_Km,Origin_Location,Destination_Location FROM #Template
		--return

		DECLARE LiveTracking_CURSOR CURSOR FAST_FORWARD FOR
		SELECT Distance_Km,Origin_Location,Destination_Location FROM #Template
		--SELECT F_ID,Field_Type,Answer,ETR_ID FROM #Template
		OPEN LiveTracking_CURSOR
		FETCH NEXT FROM LiveTracking_CURSOR INTO @Distance_Km,@Origin_Location,@Destination_Location
		--FETCH NEXT FROM TEMPLATE_CURSOR INTO @F_ID,@Field_Type,@Answer,@ETR_ID
		WHILE @@FETCH_STATUS = 0
			BEGIN
				BEGIN TRY
					
					--Set @Distance_Km = REPLACE(@Distance_Km,' km','')					
					Set @Origin_Location = REPLACE(@Origin_Location,'~', ',')
					Set @Destination_Location = REPLACE(@Destination_Location,'~', ',')

					SET @Dis_Km = @Dis_Km + @Distance_Km
					Set @Origin_Loc = @Origin_Location
					Set @Destination_Loc = @Destination_Location 

					--select @ANS, @Answer
					--IF EXISTS(SELECT * FROM T0100_Employee_Template_Response WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND T_Id = @T_ID AND F_Id = @F_ID and Cmp_Id = @Cmp_ID)
					--BEGIN
						EXEC P0060_Live_Tracking @LT_Id OUTPUT,@Cmp_Id = @Cmp_ID,@Emp_Id = @Emp_ID,
						@Origin_Location = @Origin_Loc,@Destination_Location = @Destination_Loc,
						@Distance_Km = @Dis_Km,@tran_type = @Type
					--END
					--else
					--begin
						SET @Status = 0
					--end

					FETCH NEXT FROM LiveTracking_CURSOR INTO @Distance_Km,@Origin_Location,@Destination_Location
				END TRY
				BEGIN CATCH
					SET @Status = 1
				END CATCH
			END
		CLOSE LiveTracking_CURSOR
		DEALLOCATE LiveTracking_CURSOR
		
		--Select @Status
		--return
		
		IF @Status = 0
			BEGIN
				SET @Result = 'Record Insert Successfully#True#'
				SELECT @Result
			END
		ELSE
			BEGIN
				SET @Result = 'Already Reference Exists #False#'
				SELECT @Result
			END
	END
END
