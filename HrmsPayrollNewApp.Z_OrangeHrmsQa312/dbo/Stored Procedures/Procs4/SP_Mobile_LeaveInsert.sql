

CREATE PROCEDURE [dbo].[SP_Mobile_LeaveInsert]
	@Emp_ID  numeric,
	@Cmp_ID  numeric,
	@Leave_ID numeric,
	@From_Date DATETIME,
	@To_Date DATETIME,
	@Leave_Period numeric(18,2),    
	@Leave_Assign_As  varchar(15),    
	@Application_Comments varchar(250),           
	@Login_ID numeric,
	@Half_Leave_Date DATETIME = '',
	@InTime DATETIME = '',
	@OutTime DATETIME = '',
	@Result varchar(250) output,
	@Type char(1),
	@Attachment varchar(100)= '',
	@strLeaveCompOff_Dates varchar(max) = ''
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
 
--DECLARE @Company_ID as numeric       
DECLARE @S_Emp_ID  numeric        
DECLARE @ApplicatioDate datetime        
DECLARE @Leave_Application_ID numeric 
DECLARE @IsBackdate numeric  
DECLARE @EMPPROBATION INT
DECLARE @From_DateFE datetime
DECLARE @To_DateFE datetime
DECLARE @From_DateLE datetime
DECLARE @To_DateLE datetime
DECLARE @IS_Leave_Clubbed int


DECLARE @Leave_Min numeric(18,2)
DECLARE @Leave_Max numeric(18,2)
DECLARE @Date datetime
DECLARE @Leave_Closing numeric(18,2)
DECLARE @Leave_Negative_Allow int
DECLARE @Can_Apply_Fraction int
DECLARE @Leave_Negative_Max_Limit numeric(18,0)
DECLARE @Days int
DECLARE @SettingValue int
DECLARE @msg varchar(255)
DECLARE @RowID numeric(18,0)
DECLARE @GradeID numeric(18,0)


SET @Leave_Application_ID = 0
SET  @IsBackdate = 0

IF @Type = 'I'
	BEGIN
		
		IF @Half_Leave_Date = ''
			BEGIN
				SET @Half_Leave_Date = '1900-01-01 00:00:00'
			END
		IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE (@From_Date BETWEEN Month_St_Date AND ISNULL(CutOff_Date, Month_End_Date) OR @To_Date BETWEEN Month_St_Date AND ISNULL(CutOff_Date, Month_End_Date)) AND Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID)
			BEGIN
				SET	@IsBackdate = 1
			END
			
		
			SET @From_DateFE = DATEADD(d, -1, @From_Date)
			SET @To_DateFE = DATEADD(d, 1, @From_Date)
			SET @From_DateLE = DATEADD(d, -1, @From_Date)
			SET @To_DateLE = DATEADD(d, 1, @From_Date)

			CREATE table #LeaveClubbDetails
			(
				Leave_ID numeric(18,0),
				For_Date datetime,
				App_ID numeric(18,0),
				Apr_ID numeric(18,0),
				Assign_AS varchar(50)
			)  

			INSERT INTO #LeaveClubbDetails 
			EXEC Check_Leave_Clubbing @Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_Id,@From_DateFE = @From_DateFE,@To_DateFE = @To_DateFE,@From_DateLE = @From_DateLE,@To_DateLE = @To_DateLE,
			@Tag = 'LP',@Leave_Id = @Leave_ID,@Leave_App_Id = 0,@Leave_Period = @Leave_Period,@Leave_Day = @Leave_Assign_As,@Leave_Half_Date = @Half_Leave_Date

			SELECT @IS_Leave_Clubbed = COUNT(*) FROM #LeaveClubbDetails
			
			IF @IS_Leave_Clubbed = 1
				BEGIN
					SET @Result = 'Selected Leave Cannot Club With Previous Applied Leave'
					SELECt @Result
					RETURN 
				END
			
		SET @ApplicatioDate = (select cast(getdate()as varchar(11)))   
		
		CREATE TABLE #EMPPROBATION (EMPPROBATION INT)

		INSERT INTO #EMPPROBATION EXEC SP_EMP_PROBATION_GET @Cmp_ID = @Cmp_ID,@Leave_ID = @Leave_ID,@Emp_ID = @Emp_Id,@App_Date = @ApplicatioDate,@From_Date = @From_Date	
		--SELECT * FROM #EMPPROBATION
		IF EXISTS (SELECT * FROM #EMPPROBATION WHERE EMPPROBATION = 0)
			BEGIN
				SET @Result = 'You can not apply this Leave during Probation Period'
				RETURN
			END
			
		BEGIN TRY
			BEGIN TRANSACTION LA
		
			
				EXEC P_Check_Leave_Notice_Period @CMP_ID = @Cmp_ID,@LEAVE_ID = @Leave_ID,@APP_DATE = @ApplicatioDate,@LEAVE_PERIOD = @Leave_Period,
				@FROM_DATE = @From_Date,@LEAVE_TYPE = @Leave_Assign_As,@Emp_Id = @Emp_Id,@TO_DATE = @To_Date,@Rais_Error = 1
				
				EXEC P_Check_Leave_Availability @Cmp_Id = @Cmp_ID,@Emp_Id = @Emp_Id,@From_Date = @From_Date,@To_Date=@To_Date,
				@Half_Date=@Half_Leave_Date,@Leave_Type=@Leave_Assign_As,@Leave_Application_Id=@Leave_Application_ID,@Raise_Error = 1,
				@From_Time=@InTime,@To_Time=@OutTime,@Leave_Period = @Leave_Period
			  print 99
				SET @S_Emp_ID = (select Emp_Superior from T0080_Emp_master WITH (NOLOCK) where Emp_ID = @Emp_ID)      

				--EXEC P0100_LEAVE_APPLICATION @Leave_Application_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@S_Emp_ID = @S_Emp_ID,@Application_Date = @ApplicatioDate,
				--@Application_Code = 0,@Application_Status = 'P',@Application_Comments = @Application_Comments,@Login_ID = @Login_ID,@System_Date = @ApplicatioDate,
				--@tran_type = 'Insert',@is_backdated_application = @IsBackdate,@is_Responsibility_pass = 0,@Responsible_Emp_id = 0,@M_Cancel_WO_HO = 0,@Apply_From_AttReg = 0

				
				--EXEC P0110_Leave_Application_Detail @Leave_Application_ID = @Leave_Application_ID,@Emp_Id = @EMP_ID,@Cmp_ID = @Cmp_ID,@Leave_ID = @Leave_ID,
				--@From_Date = @From_Date,@To_Date = @To_Date,@Leave_Period = @Leave_Period,@Leave_Assign_As = @Leave_Assign_As,@Leave_Reason = @Application_Comments,
				--@Row_ID = 0,@Login_ID = @Login_ID,@System_Date = @ApplicatioDate,@tran_type = 'Insert',@Half_Leave_Date = @Half_Leave_Date,@Leave_App_Docs = @Attachment,@User_Id = @Login_ID,
				--@IP_Address = 'Mobile',@Leave_Out_Time = @InTime,@Leave_In_Time = @OutTime,@NightHalt = 0,@strLeaveCompOff_Dates = @strLeaveCompOff_Dates,@Half_Payment = 0,@Warning_flag = 0,@Rules_Violate = 0
				
				CREATE TABLE #LeaveBalance
			(
				Leave_Opening numeric(18,2),
				Leave_Used numeric(18,2),
				Leave_Credit numeric(18,2),
				Leave_Closing numeric(18,2),
				Leave_Code varchar(50),
				Leave_Name varchar(50),
				Leave_ID numeric(18,0),
				Display_LeaveBalance int,
				Actual_Leave_Closing numeric(18,2),
				Leave_Type varchar(50)
			)
			INSERT INTO #LeaveBalance EXEC SP_LEAVE_CLOSING_AS_ON_DATE_ALL @CMP_ID = @Cmp_ID,@EMP_ID = @Emp_ID,@FOR_DATE = @Date,@Leave_Application = 0,@Leave_Encash_App_ID = 0,@Leave_ID = @Leave_ID
			
			--SELECT * from #LeaveBalance
			
			SELECT @Leave_Closing = Leave_Closing  FROM #LeaveBalance WHERE Leave_ID = @Leave_ID
			
			CREATE TABLE #LeaveDetail
			(
				Leave_Min numeric(18,2),
				Leave_Max numeric(18,2),
				Leave_Notice_Period int,
				Leave_Applicable int,
				Leave_Nagative_Allow int,
				Leave_Paid_Unpaid varchar(20),
				Is_Document_required int,
				Apply_Hourly int,
				Can_Apply_Fraction int,
				Default_Short_Name varchar(50),
				Leave_Name varchar(50),
				AllowNightHalt int,
				Half_Paid int,
				Leave_Negative_Max_Limit numeric(18,2),
				Min_Leave_Not_Mandatory int,
				Attachment_Days numeric(18,0)
			)
		
			INSERT INTO #LeaveDetail EXEC P0050_Leave_Details_Get @Cmp_Id = @Cmp_ID,@Emp_Id = @Emp_ID,@Leave_Id = @Leave_ID
			
			SELECT @Leave_Min = Leave_Min,@Leave_Max = Leave_Max,@Leave_Negative_Allow =Leave_Nagative_Allow, @Can_Apply_Fraction = Can_Apply_Fraction,@Leave_Negative_Max_Limit=Leave_Negative_Max_Limit  FROM #LeaveDetail
			
			SELECT @SettingValue = Setting_Value FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name = 'Auto LWP Leave'
			
			--SELECT * from #LeaveDetail
			
			DECLARE @LWPPeriod numeric(18,2)
			DECLARE @LWPFromdate datetime
			DECLARE @LWPTodate datetime
			DECLARE @LWPAssignAs varchar(50) = 'Full Day'
			
			DECLARE @LWPDays int 
			DECLARE @LWPHalf_Leave_Date datetime	
			SET @LWPHalf_Leave_Date =  @Half_Leave_Date
			SET @LWPPeriod = 0.0
			
			DECLARE @LWPHalfPeriod numeric(18,2)
			DECLARE @LWPHalfFromdate datetime
			DECLARE @LWPHalfTodate datetime
			DECLARE @LWPHalfAssignAs varchar(50) = 'Full Day'
			
			DECLARE @ID varchar(50)
			
			SET @LWPHalfPeriod = 0.0
			
			--SELECt @Leave_Period,@Leave_Closing,@SettingValue,@Leave_Negative_Allow
			
			
			IF @Leave_Period > @Leave_Closing
				BEGIN
					IF @Leave_Negative_Allow = 0 AND @SettingValue = 1
						BEGIN
							IF @Leave_Negative_Max_Limit - @Leave_Period - @Leave_Closing < 0
								BEGIN
									SET @LWPPeriod = @Leave_Period - @Leave_Closing
								
							
							
									SET @Leave_Period = @Leave_Period - @LWPPeriod
									
									SET @Days = @Leave_Period
									
									--SELECT @Leave_Period,(@Leave_Period - @Days) ,@Leave_Assign_As
									
									IF (@Leave_Period - @Days) = 0.5
										BEGIN
											SET @Leave_Assign_As = 'First Half'
											SET @Half_Leave_Date = @From_Date
											--SET @LWPAssignAs  = 'Second Half'
										END
									ELSE
										BEGIN
											SET @Leave_Assign_As = 'Full Day'
											SET @Half_Leave_Date = '1900-01-01'
										END
									--SELECT @Leave_Period,(@Leave_Period - @Days) ,@Leave_Assign_As
									
									IF @Leave_Period > 1
										BEGIN
											SET @To_Date =  DATEADD(d, @Leave_Period, @From_Date)
										END
									ELSE
										BEGIN
											SET @To_Date = @From_Date
										END
										--@Leave_Assign_As
										
									SET @LWPDays = @LWPPeriod
									
									SET @LWPFromdate = DATEADD(d, 1, @To_Date)
									
									--SET @LWPPeriod = @LWPPeriod + (@LWPPeriod - @Days)
									
									--SELECT (@LWPPeriod - @LWPDays)
									
									
									SET @LWPTodate = DATEADD(d,(@LWPPeriod + (@LWPPeriod - @LWPDays)), @To_Date)
									
									IF (@LWPPeriod - @LWPDays) = 0.50 AND @Leave_Assign_As = 'First Half'
										BEGIN
											SET @LWPAssignAs = 'Second Half'
											SET @LWPFromdate = @To_Date	
											SET @LWPHalf_Leave_Date = @To_Date
										END
									ELSE IF (@LWPPeriod - @LWPDays) = 0 AND @Leave_Assign_As = 'First Half'
										BEGIN
											SET @LWPAssignAs = 'First Half'
											SET @LWPFromdate = DATEADD(d, 1, @To_Date)
											SET @LWPPeriod = @LWPPeriod - 0.50
											SET @LWPTodate = DATEADD(d,(@LWPPeriod + (@LWPDays - @LWPPeriod)), @To_Date)
											SET @LWPHalf_Leave_Date = @LWPTodate
											
											SET @LWPHalfPeriod = 0.50
											SET @LWPHalfFromdate = @To_Date
											SET @LWPHalfTodate = @To_Date
											SET @LWPHalfAssignAs = 'Second Half'
										END
									ELSE IF (@LWPPeriod - @LWPDays) = 0.50
										BEGIN
											SET @LWPAssignAs = 'First Half'
										END
									ELSE
										BEGIN
											SET @LWPAssignAs = 'Full Day'
											SET @LWPHalf_Leave_Date = '1900-01-01'
										END
							--SELECT @LWPTodate	
								END
						END
					ELSE IF @Leave_Negative_Allow = 1 AND @SettingValue = 1 AND @Leave_Negative_Max_Limit <> 0
						BEGIN
							--SET @LWPPeriod = @Leave_Negative_Max_Limit - (@Leave_Period - @Leave_Closing) 
							
							SELECT @Leave_Negative_Max_Limit ,@Leave_Period , @Leave_Closing,((@Leave_Negative_Max_Limit + @Leave_Closing) - @Leave_Period ) 
							
							IF @Leave_Negative_Max_Limit >= (@Leave_Period - @Leave_Closing) 
								BEGIN
									SET @Leave_Period = @Leave_Period
									
									
								END
							ELSE IF ((@Leave_Negative_Max_Limit + @Leave_Closing) - @Leave_Period)  < 0
								BEGIN
								
									SET @LWPPeriod = @Leave_Period - @Leave_Negative_Max_Limit - @Leave_Closing
									
									--SELECT @LWPPeriod
							
									SET @Leave_Period = @Leave_Period - @LWPPeriod
									
									SET @Days = @Leave_Period
									
									--SELECT @Leave_Period,(@Leave_Period - @Days) ,@Leave_Assign_As
									--SELECT @Leave_Period,(@Leave_Period - @Days)
									IF (@Leave_Period - @Days) = 0.5
										BEGIN
											SET @Leave_Assign_As = 'First Half'
											SET @Half_Leave_Date = DATEADD(d,(@Leave_Period - (@Leave_Period - @Days)), @From_Date)
											--SET @LWPAssignAs  = 'Second Half'
										END
									ELSE
										BEGIN
											SET @Leave_Assign_As = 'Full Day'
											SET @Half_Leave_Date = '1900-01-01'
										END
									--SELECT @Leave_Period,(@Leave_Period - @Days) ,@Leave_Assign_As
									
									IF @Leave_Period > 1
										BEGIN
											SET @To_Date =  DATEADD(d, @Leave_Period, @From_Date)
										END
									ELSE
										BEGIN
											SET @To_Date = @From_Date
										END
										--@Leave_Assign_As
										
									SET @LWPDays = @LWPPeriod
									
									SET @LWPFromdate = DATEADD(d, 1, @To_Date)
									
									--SET @LWPPeriod = @LWPPeriod + (@LWPPeriod - @Days)
									
									--SELECT (@LWPPeriod - @LWPDays)
									
									
									SET @LWPTodate = DATEADD(d,(@LWPPeriod + (@LWPPeriod - @LWPDays)), @To_Date)
									
									IF (@LWPPeriod - @LWPDays) = 0.50 AND @Leave_Assign_As = 'First Half'
										BEGIN
											SET @LWPAssignAs = 'Second Half'
											SET @LWPFromdate = @To_Date	
											SET @LWPHalf_Leave_Date = @To_Date
										END
									ELSE IF (@LWPPeriod - @LWPDays) = 0 AND @Leave_Assign_As = 'First Half'
										BEGIN
											SET @LWPAssignAs = 'First Half'
											SET @LWPFromdate = DATEADD(d, 1, @To_Date)
											SET @LWPPeriod = @LWPPeriod - 0.50
											SET @LWPTodate = DATEADD(d,(@LWPPeriod + (@LWPDays - @LWPPeriod)), @To_Date)
											SET @LWPHalf_Leave_Date = @LWPTodate
											
											SET @LWPHalfPeriod = 0.50
											SET @LWPHalfFromdate = @To_Date
											SET @LWPHalfTodate = @To_Date
											SET @LWPHalfAssignAs = 'Second Half'
										END
									ELSE IF (@LWPPeriod - @LWPDays) = 0.50
										BEGIN
											SET @LWPAssignAs = 'First Half'
										END
									ELSE
										BEGIN
											SET @LWPAssignAs = 'Full Day'
											SET @LWPHalf_Leave_Date = '1900-01-01'
										END
								END
							ELSE --IF @Leave_Closing < 0
								BEGIN
									
									SET @LWPPeriod = @Leave_Period 
									SET @LWPAssignAs = @Leave_Assign_As
									SET @LWPHalf_Leave_Date = @Half_Leave_Date
									SET @LWPFromdate = @From_Date
									SET @LWPTodate = @To_Date
									
									SET @Leave_Period = 0.0
									--select @LWPPeriod,@LWPAssignAs,@LWPHalf_Leave_Date
								END
							--SELECT @LWPTodate	
							
						END
				END
		
			SET @ApplicatioDate = (select cast(getdate()as varchar(11)))       
		  
			SET @S_Emp_ID = (select Emp_Superior from T0080_Emp_master WITH (NOLOCK) where Emp_ID = @Emp_ID)   
			
			IF @Leave_Period <> 0.0
				BEGIN
					EXEC P0100_LEAVE_APPLICATION @Leave_Application_ID = @Leave_Application_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,
					@S_Emp_ID = @S_Emp_ID,@Application_Date = @ApplicatioDate,@Application_Code = 0,@Application_Status = 'P',@Application_Comments = @Application_Comments,
					@Login_ID = @Login_ID,@System_Date = @ApplicatioDate,@tran_type = 'I',@is_backdated_application = @IsBackdate,
					@is_Responsibility_pass = 0,@Responsible_Emp_id = 0,@M_Cancel_WO_HO = 0   
					
					SET @ID = @Leave_Application_ID
					
					EXEC P0110_Leave_Application_Detail @Leave_Application_ID = @Leave_Application_ID,@Emp_Id = @EMP_ID,@Cmp_ID = @Cmp_ID,
					@Leave_ID = @Leave_ID,@From_Date = @From_Date,@To_Date = @To_Date,@Leave_Period = @Leave_Period,@Leave_Assign_As = @Leave_Assign_As,
					@Leave_Reason = @Application_Comments,@Row_ID = @RowID OUTPUT,@Login_ID = @Login_ID,@System_Date = @ApplicatioDate,@tran_type = 'I',@Half_Leave_Date = @Half_Leave_Date,
					@Leave_App_Docs = '',@User_Id = @Login_ID,@IP_Address = 'Mobile',@Leave_Out_Time = @InTime,@Leave_In_Time = @OutTime,@NightHalt = 0,
					@strLeaveCompOff_Dates = @strLeaveCompOff_Dates,@Half_Payment = 0,@Warning_flag = 0,@Rules_Violate = 0
				END         
			
			SELECT @GradeID = ISNULL(Grd_ID,0) FROM  V0080_Employee_Master WHERE Emp_ID = @Emp_ID
		
			SELECT @Leave_ID = Leave_ID 
			FROM V0040_LEAVE_DETAILS 
			WHERE (1=(CASE ISNULL(Leave_Status,0) WHEN 0 THEN (CASE WHEN ISNULL(InActive_Effective_Date,GETDATE())> GETDATE() THEN 1 ELSE 0 END) ELSE 1 END)) AND Grd_ID = @GradeID AND Cmp_ID = @Cmp_ID AND Leave_Name = 'LWP'
			
			IF @LWPHalfPeriod <> 0.0
				BEGIN
					EXEC P0100_LEAVE_APPLICATION @Leave_Application_ID = @Leave_Application_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,
					@S_Emp_ID = @S_Emp_ID,@Application_Date = @ApplicatioDate,@Application_Code = 0,@Application_Status = 'P',@Application_Comments = @Application_Comments,
					@Login_ID = @Login_ID,@System_Date = @ApplicatioDate,@tran_type = 'I',@is_backdated_application = @IsBackdate,
					@is_Responsibility_pass = 0,@Responsible_Emp_id = 0,@M_Cancel_WO_HO = 0
					
					EXEC P0110_Leave_Application_Detail @Leave_Application_ID = @Leave_Application_ID,@Emp_Id = @EMP_ID,@Cmp_ID = @Cmp_ID,
					@Leave_ID = @Leave_ID,@From_Date = @LWPHalfFromdate,@To_Date = @LWPHalfTodate,@Leave_Period = @LWPHalfPeriod,@Leave_Assign_As = @LWPHalfAssignAs,
					@Leave_Reason = @Application_Comments,@Row_ID = @RowID OUTPUT,@Login_ID = @Login_ID,@System_Date = @ApplicatioDate,@tran_type = 'I',@Half_Leave_Date = @LWPHalfFromdate,
					@Leave_App_Docs = '',@User_Id = @Login_ID,@IP_Address = 'Mobile',@Leave_Out_Time = @InTime,@Leave_In_Time = @OutTime,@NightHalt = 0,
					@strLeaveCompOff_Dates = @strLeaveCompOff_Dates,@Half_Payment = 0,@Warning_flag = 0,@Rules_Violate = 0     
					
					SET @ID = @ID +','+ CAST(@Leave_Application_ID AS varchar(10))
				END
			
			IF @LWPPeriod <> 0.0
				BEGIN
					EXEC P0100_LEAVE_APPLICATION @Leave_Application_ID = @Leave_Application_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,
					@S_Emp_ID = @S_Emp_ID,@Application_Date = @ApplicatioDate,@Application_Code = 0,@Application_Status = 'P',@Application_Comments = @Application_Comments,
					@Login_ID = @Login_ID,@System_Date = @ApplicatioDate,@tran_type = 'I',@is_backdated_application = @IsBackdate,
					@is_Responsibility_pass = 0,@Responsible_Emp_id = 0,@M_Cancel_WO_HO = 0
					
					EXEC P0110_Leave_Application_Detail @Leave_Application_ID = @Leave_Application_ID,@Emp_Id = @EMP_ID,@Cmp_ID = @Cmp_ID,
					@Leave_ID = @Leave_ID,@From_Date = @LWPFromdate,@To_Date = @LWPTodate,@Leave_Period = @LWPPeriod,@Leave_Assign_As = @LWPAssignAs,
					@Leave_Reason = @Application_Comments,@Row_ID = @RowID OUTPUT,@Login_ID = @Login_ID,@System_Date = @ApplicatioDate,@tran_type = 'I',@Half_Leave_Date = @LWPHalf_Leave_Date,
					@Leave_App_Docs = '',@User_Id = @Login_ID,@IP_Address = 'Mobile',@Leave_Out_Time = @InTime,@Leave_In_Time = @OutTime,@NightHalt = 0,
					@strLeaveCompOff_Dates = @strLeaveCompOff_Dates,@Half_Payment = 0,@Warning_flag = 0,@Rules_Violate = 0     
					
				END
				
				SET @Result = 'Leave Application Done:True'
				
			COMMIT TRANSACTION LA
			
		END TRY
		BEGIN CATCH
			SET @Result = REPLACE(ERROR_MESSAGE(),'@@','')
			IF @Result = 'Leave on particular date already exists.'
				SET @Result = 'Duplicate Date:false'
			RAISERROR(@Result,16,2)		
			ROLLBACK TRANSACTION LA
			RETURN
		END CATCH
		
		DROP TABLE #EMPPROBATION
	END
ELSE IF @Type = 'S'
	BEGIN
		SELECT VL.Leave_Application_ID, VL.Application_Status,(CASE WHEN VL.Application_Status = 'A' THEN 'Approved' ELSE (CASE WHEN VL.Application_Status = 'P' THEN 'Pending' ELSE 'Rejected' END )END) AS 'AppStatus' ,
		VL.Cmp_ID,VL.Leave_ID,VL.From_Date,VL.To_Date,VL.Application_Date,VL.Leave_Period,LM.Leave_Code,VL.Leave_Assign_As,VL.Leave_Reason,VL.Leave_Name,
		VL.Senior_Employee,VL.Emp_Full_Name,VL.Emp_Superior,LM.Leave_Type
		FROM V0110_LEAVE_APPLICATION_DETAIL VL 
		LEFT JOIN 
		( 
			SELECT MAX(Tran_ID) AS 'Tran_ID' ,Emp_ID,Leave_Application_ID 
			FROM T0115_Leave_Level_Approval WITH (NOLOCK)
            GROUP BY Emp_ID,Leave_Application_ID 
		) AS LL ON VL.Leave_Application_ID = LL.Leave_Application_ID 
		INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON VL.Leave_ID = LM.Leave_ID
		WHERE VL.Cmp_ID = @Cmp_ID AND VL.Emp_ID = @Emp_ID AND VL.From_Date >= convert(datetime, @From_Date,103) AND VL.To_Date <= convert(datetime, @To_Date,103)  
	END

ELSE IF @Type = 'B' --For Leave Bind
	BEGIN
		--DECLARE @GradeID numeric(18,0)
		
		SELECT @GradeID = ISNULL(Grd_ID,0) FROM V0080_Employee_master WHERE Emp_ID = @Emp_ID
		
		
		SELECT Leave_ID,Leave_Name 
		FROM V0040_LEAVE_DETAILS 
		WHERE (1=(CASE ISNULL(leave_Status,0) WHEN 0 THEN (CASE WHEN ISNULL(InActive_Effective_Date,GETDATE())>GETDATE() THEN 1 ELSE 0 END ) ELSE  1 END )) AND Grd_ID = @GradeID AND Cmp_ID = @Cmp_ID
		--AND Leave_Name <> 'Comp-Off Leave'
	
	END
ELSE IF @Type = 'R' --For Leave Balance
	BEGIN
		CREATE TABLE #LeaveMonthlyBalance
		(
			Cmp_ID NUMERIC(18,0),
			Emp_ID NUMERIC(18,0),
			For_Date datetime,
			Leave_Opening NUMERIC(5,2),
			Leave_Credit NUMERIC(5,2),
			Leave_Used NUMERIC(5,2),
			Leave_Closing NUMERIC(5,2),
			Leave_ID NUMERIC(18,0),
			Leave_Type varchar(50),
			Leave_Name varchar(50),
			Emp_Full_Name varchar(50),
			Emp_Code NUMERIC(18,0),
			Alpha_Emp_Code varchar(50),
			Emp_First_Name varchar(50),
			Grd_Name varchar(50),
			Branch_Address varchar(255),
			Comp_Name varchar(100),
			Branch_Name varchar(50),
			Dept_Name varchar(50),
			Desig_Name varchar(50),
			Cmp_Name varchar(100),
			Cmp_Address varchar(255),
			P_From_Date datetime,
			P_To_Date datetime,
			Branch_Id numeric(18,0),
			Type_Name varchar(50),
			Desig_Dis_No int,
			Vertical_Name varchar(50),
			SubVertical_Name varchar(50),
			SubBranch_Name varchar(50),
			Leave_Code varchar(50),
			Gender varchar(50)
		)
		
		INSERT INTO #LeaveMonthlyBalance
		EXEC SP_RPT_MONTHLY_LEAVE_BALANCE_GET @Cmp_ID = @Cmp_ID,@From_Date = @From_Date,
		@To_Date = @To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_Id=0,@Desig_Id=0,
		@Emp_ID = @Emp_ID,@Leave_ID = '',@Constraint = ''
		
		
		SELECT LB.* 
		FROM #LeaveMonthlyBalance LB
		INNER JOIN T0040_LEAVE_MASTER LM ON LB.Leave_ID = LM.Leave_ID
		WHERE LM.Display_leave_balance = 1
		ORDER BY LB.Leave_Name
		
		DROP TABLE #LeaveMonthlyBalance
 
	
	END
ELSE IF @Type = 'C' -- COMP_OFF BALANCE
	BEGIN
	
		EXEC GET_COMPOFF_DETAILS @FOR_DATE=@FROM_DATE,@CMP_ID=@CMP_ID,@EMP_ID=@EMP_ID,@LEAVE_ID=@LEAVE_ID,@LEAVE_APPLICATION_ID=0
		
	END

