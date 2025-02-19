
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[sp_mobile_inout]

	@Cmp_Id  numeric(18,0),
    @Str varchar(20),
    @Emp_ID  numeric = null,
    @in_lat varchar(50),
    @in_long varchar(50),
    @out_lat varchar(50),
    @out_long varchar(50),
    @IMEI varchar(50),
    @Location varchar(MAX),
    @result varchar(100) output
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @IO_Tran_ID as numeric(18,0) --= NULL
	Declare @In_Time As DateTime
	Declare @Out_Time As DateTime
	Declare @IPAdd   varchar(50)
	Declare @Duration   varchar(10) 
	DECLARE @Duration_Sec varchar(20)
	SET @IPAdd = 'Mobile(' + @IMEI + ')'
	
	--changed jimit 19042016
	SET @IO_Tran_ID = NULL
	--ended
	
	
	IF @IMEI = 'Check_in_out'
		BEGIN
			SELECT @IO_Tran_ID = IO_Tran_Id,@In_Time = In_Time,@Out_Time = Out_Time 
			FROM T0150_emp_inout_Record WITH (NOLOCK) WHERE In_Time = (
			SELECT MAX(In_Time) FROM T0150_emp_inout_Record WITH (NOLOCK)
			WHERE Emp_ID= @Emp_ID AND Cmp_id= @Cmp_Id AND Convert(varchar(10),For_Date,120) = Convert(varchar(10),GETDATE(),120)
			)
			
			IF @IO_Tran_ID IS NULL
				BEGIN
					SET @result = 'In'
					RETURN
				END
			ELSE IF @In_Time IS NOT NULL AND @Out_Time IS NULL
				BEGIN
					SET @result = 'Out'
					RETURN
				END 
			ELSE IF @Out_Time IS NOT NULL
				BEGIN
					SET @result = 'In'
					RETURN
				END
		END
	ELSE
		BEGIN
			IF @Str = 'Intime'
				BEGIN
					IF @in_lat is null OR @in_lat = '' OR @in_long is null OR @in_long = '' 
						BEGIN
							SET @result = 'Please Enable GPS Setting'
							RETURN
						END
					ELSE
						BEGIN
							INSERT INTO T9999_MOBILE_INOUT_DETAIL(IO_Tran_ID,Cmp_ID,Emp_ID,IO_Datetime,IMEI_No,In_Out_Flag,Latitude,Longitude,Location)
							VALUES(@IO_Tran_ID,@Cmp_Id,@Emp_Id,GetDate(),@IPAdd,'I',@in_lat,@in_long,@Location)
							
							--EXEC SP_EMP_INOUT_SYNCHRONIZATION_WITH_INOUT_FLAG @EMP_ID,@CMP_ID,GetDate,@IPAdd,0,0
							
							SET @result = 'Intime Inserted'
						END
				END
			ELSE
				BEGIN
					IF @out_lat is null OR @out_lat = '' OR @out_long is null OR @out_long = ''
						BEGIN
							SET @result = 'Please Enable GPS Setting'
							RETURN
						END
					ELSE
						BEGIN
							INSERT INTO T9999_MOBILE_INOUT_DETAIL(IO_Tran_ID,Cmp_ID,Emp_ID,IO_Datetime,IMEI_No,In_Out_Flag,Latitude,Longitude,Location)
							VALUES(@IO_Tran_ID,@Cmp_Id,@Emp_Id,GetDate(),@IPAdd,'O',@out_lat,@out_long,@Location)
							
							--EXEC SP_EMP_INOUT_SYNCHRONIZATION_WITH_INOUT_FLAG @EMP_ID,@CMP_ID,GetDate,@IPAdd,1,0
							
							SET @result = 'Outtime Inserted'
						END
				END
			END
	--IF @Str = 'Intime'
	--	BEGIN
						
	--		IF Not Exists(SELECT IO_Tran_Id FROM dbo.T0150_emp_inout_Record WHERE Emp_ID=@Emp_ID And Cmp_id=@Cmp_ID and Convert(varchar(10),For_Date,120) = Convert(varchar(10),GETDATE(),120))
	--			BEGIN
	--				SELECT @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 FROM dbo.T0150_emp_inout_Record
	--				INSERT INTO dbo.T0150_emp_inout_Record (IO_Tran_Id,Emp_Id,Cmp_Id,For_date,In_Time,IP_Address,Reason)
	--				VALUES(@IO_Tran_ID,@Emp_Id,@Cmp_Id,Convert(varchar(10),GETDATE(),120),GetDate(),@IPAdd,'')
					
	--				IF @in_lat <> ' '
	--					INSERT INTO TB_in_out_location(IO_Tran_Id,latitude,longitude,in_out)
	--					VALUES(@IO_Tran_ID,@in_lat,@in_long,1)
						
	--					INSERT INTO T9999_MOBILE_INOUT_DETAIL(IO_Tran_ID,Cmp_ID,Emp_ID,IO_Datetime,IMEI_No,In_Out_Flag,Latitude,Longitude,Location)
	--					VALUES(@IO_Tran_ID,@Cmp_Id,@Emp_Id,GetDate(),@IPAdd,'I',@in_lat,@in_long,@Location)
						
	--				SET @result = 'Intime Inserted'
	--			END
	--		ELSE
	--			BEGIN
	--				SELECT @Out_Time = Out_Time FROM T0150_emp_inout_Record WHERE Emp_ID=@Emp_ID And Cmp_id=@Cmp_ID and Convert(varchar(10),For_Date,120) = Convert(varchar(10),GETDATE(),120)
					
	--				IF @Out_Time is not null
	--					SET @result = 'You have done with outtime'
	--				ELSE
	--					SET @result = 'Intime already Inserted'
	--			END
	--	END
	
	--IF @Str = 'Outtime'
	--	BEGIN
	--		SELECT @In_Time = In_time, @Out_time = Out_Time FROM dbo.T0150_EMP_INOUT_RECORD WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_Id And Convert(varchar(10),For_Date,120) = Convert(varchar(10),GETDATE(),120)
	--			--print(@In_Time)
		
	--		IF @Out_time is null
	--			BEGIN
	--				IF @In_Time IS NULL
	--					BEGIN
	--						SELECT @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 FROM dbo.T0150_emp_inout_Record
	--						INSERT INTO T0150_emp_inout_Record(IO_Tran_Id,Emp_Id,Cmp_Id,For_date,Out_Time,IP_Address,Reason)
	--						VALUES(@IO_Tran_ID,@Emp_Id,@Cmp_Id,Convert(varchar(10),GETDATE(),120),GetDate(),@IPAdd,'')
							
	--						IF @out_lat <> ' '
	--							INSERT INTO TB_in_out_location(IO_Tran_Id,latitude,longitude,in_out)
	--							VALUES(@IO_Tran_ID,@out_lat,@out_long,2)
	--						--else
	--							--Insert Into dbo.TB_in_out_location(IO_Tran_Id) values(@IO_Tran_ID)
							
	--						SET @result = 'Outtime inserted, You have not inserted In Time'
	--					END
	--				ELSE
	--					BEGIN
	--							SET @Out_time = GetDate()
	--					--	SET @Duration = dbo.F_Return_Hours(datediff(s,@In_Time,@Out_time))  
	--						SET @Duration_Sec =isnull(datediff(s,@In_Time,@Out_time),0)
	--						SET @Duration = dbo.F_Return_Hours(@Duration_Sec)   
							
	--						UPDATE T0150_emp_inout_Record set Out_Time = GETDATE(),Duration = @Duration 
	--						WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_Id And Convert(varchar(10),For_Date,120) = Convert(varchar(10),GETDATE(),120)
				
	--						SELECT @IO_Tran_ID = IO_Tran_ID FROM dbo.T0150_emp_inout_Record WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_Id And Convert(varchar(10),For_Date,120) = Convert(varchar(10),GETDATE(),120)
				
	--						IF @out_lat <> ' '
	--							BEGIN
	--								--Update dbo.TB_in_out_location set lat_long = geometry::STGeomFromText('POINT('+@out_long+' '+@out_lat+')',4326) where IO_Tran_Id = @IO_Tran_ID
	--								INSERT INTO TB_in_out_location(IO_Tran_Id,latitude,longitude,in_out)VALUES(@IO_Tran_ID,@out_lat,@out_long,2)
									
	--								INSERT INTO T9999_MOBILE_INOUT_DETAIL(IO_Tran_ID,Cmp_ID,Emp_ID,IO_Datetime,IMEI_No,In_Out_Flag,Latitude,Longitude,Location)
	--								VALUES(@IO_Tran_ID,@Cmp_Id,@Emp_Id,GetDate(),@IPAdd,'O',@out_lat,@out_long,@Location)
	--							END
								
	--							SET @result = 'Outtime Inserted'
	--						END
	--					END
	--		ELSE
	--			BEGIN			
	--				SET @result = 'Outtime already Inserted'
	--			END
	--END

