CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_MyTeamAttendance]
@Emp_ID Numeric(18,0),
@Details XML,
@Type CHAR(1),
@Result VARCHAR(100) OUTPUT
AS
SET NOCOUNT ON
BEGIN	
			IF (@Details.exist('/NewDataSet/Table1') = 1)
			BEGIN
						SELECT Table1.value('(EmpID/text())[1]','NUMERIC(18,0)') AS EmpID,
						Table1.value('(CmpID/text())[1]','NUMERIC(18,0)') AS CmpID,
						Table1.value('(ForDate/text())[1]','varchar(20)') AS ForDate,
						Table1.value('(IOFlage/text())[1]','Char(1)') AS IOFlag,
						Table1.value('(Reason/text())[1]','VARCHAR(100)') AS Reason,
						Table1.value('(IMEINO/text())[1]','VARCHAR(50)') AS IMEINO,
						Table1.value('(Latitude/text())[1]','VARCHAR(50)') AS Latitude,
						Table1.value('(Longitude/text())[1]','VARCHAR(50)') AS Longitude,
						Table1.value('(VerticalID/text())[1]','NUMERIC(18,0)') AS VerticalID,
						Table1.value('(SubVerticalID/text())[1]','NUMERIC(18,0)') AS SubVerticalID,
						Table1.value('(SubVerticalName/text())[1]','varchar(50)') AS SubVerticalName,
						Table1.value('(Address/text())[1]','VARCHAR(MAX)') AS Address1,
						Table1.value('(ImageName/text())[1]','varchar(255)') AS ImageName
						INTO #MyTeamDetailsTemp FROM @Details.nodes('/NewDataSet/Table1') AS Temp(Table1)
			END -- END (@Details.exist('/NewDataSet/Table1') = 1)
				
				
				--select * from #MyTeamDetailsTemp
				
				DECLARE @EmpID				NUMERIC(18,0)
				DECLARE @CmpID				NUMERIC(18,0)
				DECLARE @IO_Tran_Id			NUMERIC(18,0)
				DECLARE @Time				DATETIME
				DECLARE @IMEINO				VARCHAR(50)
				DECLARE @Latitude			VARCHAR(50)
				DECLARE @Longitude			VARCHAR(50)
				DECLARE @VerticalID			NUMERIC(18,0)
				DECLARE	@SubVerticalID		NUMERIC(18,0)
				DECLARE @SubVerticalName	VARCHAR(50)
				DECLARE	@Address			VARCHAR(MAX)
				DECLARE @ImageName			VARCHAR(255)
				DECLARE @ForDate			DATETIME
				DECLARE @Reason				VARCHAR(100)
				DECLARE @Value				VARCHAR(50)
				Declare @IOFlag				Char(1)

				

				SET @Time = CONVERT(datetime,CONVERT(varchar(11),GETDATE(),103) + ' ' + CONVERT(varchar(11),GETDATE(),108),103)

				DECLARE MyTeamAttend_CURSOR CURSOR  FAST_FORWARD FOR
				
				SELECT EmpID,CmpID,CONVERT(datetime,ForDate,103) as Fordate, 'Mobile('+ IMEINO + ')',IOFlag,Latitude,Longitude
				,CASE WHEN Address1 <> '' THEN  'In : ' + Address1 ELSE '' END as [Address],ImageName,Reason
				,VerticalID,SubVerticalID,SubVerticalName
				FROM #MyTeamDetailsTemp
				
				OPEN MyTeamAttend_CURSOR
				FETCH NEXT FROM MyTeamAttend_CURSOR INTO @EmpID,@CmpID,@ForDate,@IMEINO,@IOFlag,@Latitude,@Longitude,@Address,@ImageName
														,@Reason,@VerticalID,@SubVerticalID,@SubVerticalName
			
		select * from #MyTeamDetailsTemp
			WHILE @@FETCH_STATUS = 0
					BEGIN TRY
						--print @EmpID
						--print @CmpID
						--print @ForDate
						--print @IOFlag
						--print @IMEINO
						--print @Latitude
						--print @Longitude
						--print @Address
						--print @ImageName
						--print @Reason
						--print @VerticalID
						--print @SubVerticalID
						--print @SubVerticalName
						SELECT @Value = EC.Value FROM T0081_CUSTOMIZED_COLUMN CC  WITH (NOLOCK) INNER JOIN T0082_Emp_Column EC 
							WITH (NOLOCK)  ON CC.Tran_Id = EC.mst_Tran_Id WHERE CC.Column_Name = 'CheckIn/Checkout without Location (Mobile)' 
							AND EC.Emp_Id = Emp_ID
							

						IF ISNULL(@Value,0) <> 1
						BEGIN
							IF @Address = '' AND @Latitude = '' AND @Longitude = ''
								BEGIN
									print 'InternetError'
									SET @Result = 'Internet OR GPS Not Working#False#'
									RETURN				
								END
						END

						IF @SubVerticalName <> ''
						BEGIN
							SELECT @SubVerticalID = ISNULL(MAX(SubVertical_ID),0) + 1 FROM T0050_SubVertical WITH (NOLOCK) 
							INSERT INTO T0050_SubVertical(SubVertical_ID,Vertical_ID,SubVertical_Code,SubVertical_Name
							,SubVertical_Description,Cmp_ID)
							VALUES(@SubVerticalID,@VerticalID,'',@SubVerticalName,@SubVerticalName,@CmpID)
						END

						IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK)  where ISNULL(Cutoff_Date,Month_End_Date)>= @ForDate 
									and Emp_ID = @EmpID and Cmp_ID=@CmpID)
						BEGIN
							SET @Result = 'Salary Already Exist#False#'
							RETURN
						END
						
						SELECT @IO_Tran_Id = IO_Tran_Id   FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK)  WHERE Emp_ID= @EmpID 
						AND In_Time = ( SELECT MAX(In_Time) FROM T0150_emp_inout_Record WITH (NOLOCK)  WHERE Emp_ID= @EmpID 
						AND Cmp_id= @CmpID AND Convert(varchar(10),For_Date,103) = Convert(varchar(10),@ForDate,103))
					IF @Type = 'I' 
					BEGIN
						If @IO_Tran_Id is NULL
											BEGIN
												INSERT INTO T9999_MOBILE_INOUT_DETAIL(IO_Tran_ID,Emp_ID,Cmp_ID,IO_Datetime
												,IMEI_No,In_Out_Flag,Latitude,Longitude,Location,Emp_Image,Reason,Vertical_ID,SubVertical_ID,R_Emp_ID)
												VALUES(NULL,@EmpID,@CmpID,@Time ,@IMEINO,@IOFlag,@Latitude
												,@Longitude,@Address,@ImageName,@Reason,@VerticalID,@SubVerticalID,@Emp_ID)
											END
											ELSE
											BEGIN
												INSERT INTO T9999_MOBILE_INOUT_DETAIL(IO_Tran_ID,Emp_ID,Cmp_ID,IO_Datetime
												,IMEI_No,In_Out_Flag,Latitude,Longitude,Location,Emp_Image,Reason,Vertical_ID,SubVertical_ID,R_Emp_ID)
												VALUES(@IO_Tran_ID,@EmpID,@CmpID,@Time,@IMEINO,@IOFlag,@Latitude
												,@Longitude,@Address,@ImageName,@Reason,@VerticalID,@SubVerticalID,@Emp_ID)
											END
					END
					ELSE
					BEGIN
						If @IO_Tran_Id is NULL
											BEGIN
												INSERT INTO T9999_MOBILE_INOUT_DETAIL(IO_Tran_ID,Emp_ID,Cmp_ID,IO_Datetime
												,IMEI_No,In_Out_Flag,Latitude,Longitude,Location,Emp_Image,Reason,Vertical_ID,SubVertical_ID)
												VALUES(NULL,@EmpID,@CmpID,@Time ,@IMEINO,@IOFlag,@Latitude
												,@Longitude,@Address,@ImageName,@Reason,@VerticalID,@SubVerticalID)
											END
											ELSE
											BEGIN
												INSERT INTO T9999_MOBILE_INOUT_DETAIL(IO_Tran_ID,Emp_ID,Cmp_ID,IO_Datetime
												,IMEI_No,In_Out_Flag,Latitude,Longitude,Location,Emp_Image,Reason,Vertical_ID,SubVertical_ID)
												VALUES(@IO_Tran_ID,@EmpID,@CmpID,@Time,@IMEINO,@IOFlag,@Latitude
												,@Longitude,@Address,@ImageName,@Reason,@VerticalID,@SubVerticalID)
											END
					END
					FETCH NEXT FROM MyTeamAttend_CURSOR INTO  @EmpID,@CmpID,@ForDate,@IMEINO,@IOFlag,@Latitude,@Longitude,@Address
												,@ImageName,@Reason,@VerticalID,@SubVerticalID,@SubVerticalName

					END TRY
					BEGIN CATCH
						SET	@Result = 'Error In Data Inserted#False#'
						select @Result
						RETURN
					END CATCH

				CLOSE MyTeamAttend_CURSOR
				DEALLOCATE MyTeamAttend_CURSOR

        IF @Type = 'I' --added for the Message chnage as per the qa bug by satish on 09-Apr-2021
		BEGIN
			SET @Result = 'The Selected Users Clockin Captured Successfully#True#'
		END
		ELSE
		BEGIN
			SET @Result = 'The Selected Users ClockOut Captured Successfully#True#'
		END
		SELECT @Result

		RETURN


END
