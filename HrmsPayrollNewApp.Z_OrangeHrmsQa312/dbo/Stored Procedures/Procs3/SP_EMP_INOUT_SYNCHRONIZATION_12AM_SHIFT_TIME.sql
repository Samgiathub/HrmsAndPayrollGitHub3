

---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_INOUT_SYNCHRONIZATION_12AM_SHIFT_TIME]
	@EMP_ID			NUMERIC ,    
	@CMP_ID			NUMERIC ,    
	@IO_DATETIME	DATETIME ,    
	@IP_ADDRESS		VARCHAR(50)    ,
	@In_Out_flag	NUMERIC = 0, 
	@Flag			INT = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF
	 
	DECLARE @In_Time DATETIME     
	DECLARE @Out_Time DATETIME     
	DECLARE @For_Date DATETIME     
	DECLARE @varFor_Date VARCHAR(22)     
	DECLARE @F_In_Time DATETIME     
	DECLARE @F_Out_Time DATETIME     
	DECLARE @S_In_Time DATETIME     
	DECLARE @S_Out_Time DATETIME     
	DECLARE @T_In_Time DATETIME     
	DECLARE @T_Out_Time DATETIME     
	
	
	DECLARE @Shift_st_Time  DATETIME     
	DECLARE @Shift_End_Time  DATETIME     
	DECLARE @F_Shift_In_Time DATETIME     
	DECLARE @F_Shift_End_Time DATETIME     
	DECLARE @S_Shift_in_Time DATETIME     
	DECLARE @S_shift_end_Time DATETIME     
	DECLARE @T_Shift_In_Time DATETIME     
	DECLARE @T_Shift_End_Time DATETIME 
 
	DECLARE @Shift_st_Time_P  DATETIME     
	DECLARE @Shift_End_Time_P  DATETIME     
	DECLARE @F_Shift_In_Time_P DATETIME     
	DECLARE @F_Shift_End_Time_P DATETIME     
	DECLARE @S_Shift_in_Time_P DATETIME     
	DECLARE @S_shift_end_Time_P DATETIME     
	DECLARE @T_Shift_In_Time_P DATETIME     
	DECLARE @T_Shift_End_Time_P DATETIME  
	DECLARE @For_Date_P DATETIME    
  
  
	DECLARE @IO_Tran_ID   NUMERIC     
	DECLARE @Last_Entry NUMERIC(18,0)
	DECLARE @MinutDiff NUMERIC(22,0)
	SET @For_Date = CAST(@IO_DATETIME AS VARCHAR(11))    
	SET @varFor_Date = CAST(@IO_DATETIME AS VARCHAR(11)) 
	SET @For_Date_P = DateAdd(d,-1,@For_Date)



	--------------------- Add by jigensh 30-Apr-2015---- For Canteen Entry Client:- Apollo ----
	IF  @IP_ADDRESS='Canteen'
		BEGIN
			RETURN
		END
	
	IF  EXISTS(SELECT IP_Address FROM T0040_IP_MASTER WITH (NOLOCK) WHERE IP_Address=@IP_Address AND Device_No > 200)
		BEGIN
			RETURN
		END
	------------------------------- End ------------------------	
	
	
	DECLARE @Max_Date DATETIME
	--changes done by Falak on 04-jan-2011 
	-- for blocking of updating the entry of inout records
	SET @Max_Date = null
	-- SELECT @In_Time = max(In_time) , @Out_Time =max(Out_Time) FROM T0150_emp_inout_Record WHERE emp_ID=@emp_ID
	-- Added by Gadriwala Muslim 02012015 - Start
	IF Len(@Ip_Address) <=3
		BEGIN
			IF EXISTS(SELECT 1 FROM T0040_IP_MASTER WITH (NOLOCK) WHERE Device_No = @IP_ADDRESS AND Cmp_ID = @CMP_ID AND Is_Gate_Pass = 1)	
				BEGIN
					EXEC SP_EMP_INOUT_SYNCHRONIZATION_GATE_PASS @EMP_ID,@CMP_ID,@IO_DATETIME,@IP_ADDRESS,@In_Out_flag,@Flag
					RETURN
				END
			--added by sneha on 21 july 2015 -start
		 ELSE IF EXISTS(SELECT 1 FROM T0040_IP_MASTER WITH (NOLOCK) WHERE Device_No = @IP_ADDRESS AND Cmp_ID = @CMP_ID AND Is_Training = 1)	
			BEGIN		 		
				EXEC SP_EMP_INOUT_SYNCHRONIZATION_TRAINING @EMP_ID,@CMP_ID,@IO_DATETIME,@IP_ADDRESS,@In_Out_flag,@Flag
				RETURN
			END	--added by sneha on 21 july 2015 -end
		End
	-- Added by Gadriwala Muslim 02012015 - End
	IF @Flag = 0
		BEGIN
			SELECT @In_Time = max(In_time) , @Out_Time =max(Out_Time) FROM T0150_emp_inout_Record WITH (NOLOCK) WHERE emp_ID=@emp_ID
		END
	ELSE
		BEGIN
			SELECT	@In_Time = MAX(In_time)  
			FROM	T0150_emp_inout_Record WITH (NOLOCK)
			WHERE	Cmp_ID = @CMP_ID  AND emp_ID=@emp_ID AND CAST(In_time AS VARCHAR(11)) = CAST(@IO_DATETIME AS VARCHAR(11))
		
			SELECT	@Out_Time = MAX(Out_Time) 
			FROM	T0150_emp_inout_Record WITH (NOLOCK)
			WHERE	Cmp_ID = @CMP_ID  AND emp_ID=@emp_ID AND CAST(Out_Time AS VARCHAR(11)) = CAST(@IO_DATETIME AS VARCHAR(11))
		END
	
 
 
    SELECT @Max_Date = MAX(for_date) 
	FROM	T0150_EMP_INOUT_RECORD  E WITH (NOLOCK)
	WHERE	Emp_ID = @EMP_ID  
			AND NOT EXISTS(SELECT 1 FROM T0150_EMP_INOUT_RECORD E1 WITH (NOLOCK)
							WHERE	E1.Emp_ID = @EMP_ID  
									AND (IsNull(E1.Reason,'') <> '' --AND IsNull(E1.Chk_By_Superior,0) = 0
									OR IsNull(E1.ManualEntryFlag,'N') <> 'N')  ---- Add by jignesh 19-Jul-2018----
									AND E1.For_Date= E.FOR_DATE)
  
	----SELECT @In_Time = max(In_time) , @Out_Time =max(Out_Time) FROM T0150_emp_inout_Record WHERE emp_ID=@emp_ID  

	DECLARE @InOut_duration_Gap NUMERIC    --Added by Mihir 06/03/2012
	SELECT	@InOut_duration_Gap = IsNull(Inout_Duration,300) 
	FROM	T0010_COMPANY_MASTER WITH (NOLOCK)
	WHERE	Cmp_Id = @CMP_ID   --Added by Mihir 06/03/2012
	
	

	IF IsNull(@In_Out_flag,0) = 0
		BEGIN
			IF @Flag = 0
				BEGIN	
					IF @IO_DATETIME < @Max_Date 						
						RETURN					  
				END
				
			IF EXISTS(SELECT IO_Tran_ID FROM t0150_emp_inout_record WITH (NOLOCK) WHERE 
				Emp_Id=@Emp_Id And(In_time = @IO_DATETIME OR Out_Time = @IO_DATETIME ))
				RETURN
										
			IF	NOT @In_time IS NULL 
				AND @In_Time > IsNull(@Out_Time,'01-01-1900') 
				AND DateDiff(s,@In_Time,@IO_DATETIME) < @InOut_duration_Gap 
				AND DateDiff(s,@In_Time,@IO_DATETIME) >0    --@InOut_duration_Gap Added by Mihir 06/03/2012
				BEGIN   					
					UPDATE	T0150_emp_inout_Record     
					SET		In_Time = @IO_DATETIME,
							Duration = dbo.F_Return_Hours (DateDiff(s,@IO_DATETIME,Out_Time))      
					WHERE	In_Time = @In_Time AND Emp_ID=@emp_ID    			   
					
					GOTO UpdtFormDate			     
				END    
			ELSE IF	NOT @Out_Time IS NULL 
					AND @Out_Time > IsNull(@In_Time,'01-01-1900')
					AND DateDiff(s,@Out_Time,@IO_DATETIME) < @InOut_duration_Gap 
					AND DateDiff(s,@Out_Time,@IO_DATETIME) >0    
				BEGIN
					UPDATE	T0150_emp_inout_Record     
					SET		Out_Time = @IO_DATETIME,
							Duration = dbo.F_Return_Hours (DateDiff(s,In_Time,@IO_DATETIME))      
					WHERE	Out_Time = @Out_Time AND Emp_ID=@emp_ID    
					
					GOTO UpdtFormDate     
				END

			---- Added by rohit on 31122013 for Auto Shift			
			DECLARE @in_time_temp AS DATETIME
			DECLARE @out_time_temp AS DATETIME
			DECLARE @Pre_IO_Date AS DATETIME
			DECLARE @Pre_IO_Flag AS VARCHAR
			
			SELECT	TOP 1 @in_time_temp=in_time,@out_time_temp=out_time 
			FROM	T0150_EMP_INOUT_RECORD WITH (NOLOCK)
			WHERE	Emp_Id=@Emp_Id AND cmp_id =@cmp_id AND For_Date < @IO_DATETIME 
			ORDER	BY For_Date DESC
			
			IF IsNull(@out_time,'1900-01-01 00:00:00.000')='1900-01-01 00:00:00.000'
				BEGIN
					SET @Pre_IO_Date =@in_time_temp
					SET @Pre_IO_Flag='I'
				END
			ELSE
				BEGIN
					SET @Pre_IO_Date =@out_time_temp
					SET @Pre_IO_Flag='O'
				END
			
			DECLARE @Shift_St_Time1 AS VARCHAR(10)
			DECLARE @Shift_End_Time1 AS VARCHAR(10)
				
			EXEC Get_Emp_Curr_Shift_New @emp_id,@cmp_id,@IO_DATETIME,@Pre_IO_Flag,@Pre_IO_Date,@Shift_St_Time1 output ,@Shift_End_Time1 output

			IF NOT @Shift_St_Time1 IS NULL AND @Shift_St_Time1 <> ''
				BEGIN
					SET @F_Shift_In_Time = @Shift_St_Time1 
					SET @F_Shift_End_Time = @Shift_End_Time1
				End
		
			IF @Shift_St_Time1 IS NULL OR @Shift_St_Time1 = ''
				EXEC SP_SHIFT_DETAIL_GET @Emp_ID,@Cmp_ID,@For_Date,null,@F_Shift_In_Time output ,@F_Shift_End_Time output,@S_Shift_in_Time output ,@S_shift_end_Time output,@T_Shift_In_Time output ,@T_Shift_End_Time output , @Shift_st_Time output ,@Shift_end_Time output
				   
			EXEC Get_Emp_Curr_Shift_New @emp_id,@cmp_id,@For_Date_P,@Pre_IO_Flag,@Pre_IO_Date,@F_Shift_In_Time_P output ,@F_Shift_End_Time_P output
			
			IF @S_Shift_in_Time ='1900-01-01 00:00:00.000'    
				SET @S_Shift_in_Time = NULL    
			IF @S_Shift_End_Time ='1900-01-01 00:00:00.000'    
				SET @S_Shift_End_Time = NULL    
				  
			IF @T_Shift_In_Time ='1900-01-01 00:00:00.000'    
				SET @T_Shift_In_Time = NULL    
				
			IF @T_Shift_End_Time ='1900-01-01 00:00:00.000'    
				SET @T_Shift_End_Time = NULL    
			   
			IF @S_Shift_in_Time_P ='1900-01-01 00:00:00.000'    
				SET @S_Shift_in_Time_P = NULL    
			IF @S_Shift_End_Time_P ='1900-01-01 00:00:00.000'    
				SET @S_Shift_End_Time_P = NULL    
				  
			IF @T_Shift_In_Time_P ='1900-01-01 00:00:00.000'    
				SET @T_Shift_In_Time_P = NULL    
				
			IF @T_Shift_End_Time_P ='1900-01-01 00:00:00.000'    
				SET @T_Shift_End_Time_P = NULL    
					  
			SET @F_Shift_In_Time =  @varFor_Date + ' ' + @F_Shift_In_Time    
			SET @F_Shift_End_Time = @varFor_Date + ' ' + @F_Shift_End_Time    
			SET @S_Shift_in_Time = @varFor_Date + ' ' + @S_Shift_in_Time    
			SET @S_shift_end_Time = @varFor_Date + ' ' + @S_shift_end_Time    
			SET @T_Shift_In_Time = @varFor_Date + ' ' + @T_Shift_In_Time     
			SET @T_Shift_End_Time = @varFor_Date + ' ' + @T_Shift_End_Time    
			SET @Shift_end_Time = @varFor_Date + ' ' + @Shift_end_Time    
			SET @Shift_st_Time = @varFor_Date + ' ' + @Shift_st_Time 
			  
			 
			SELECT @IO_Tran_ID = IsNull(max(IO_Tran_ID),0)+ 1 FROM T0150_emp_inout_Record WITH (NOLOCK)  

			IF EXISTS(SELECT 1  FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK)
					  WHERE emp_ID=@emp_ID AND Out_Time IS NULL AND In_time <  @IO_DATETIME AND  ((For_Date=@For_Date)  OR (For_Date=DateAdd(d,-1,@For_Date))))  
				BEGIN
					DECLARE @Diff NUMERIC(22,0)
					SET @Diff = IsNull(DateDiff(s,@F_Shift_In_Time,@IO_DATETIME),0)
					
					IF @IO_DATETIME BETWEEN DateAdd(HOUR,-2,@F_Shift_In_Time) AND DateAdd(hour,2,@F_Shift_In_Time) --Added by hardik 21/05/2015 AS when shift IS changed for night then it will NOT consider new Punch AS IN
						BEGIN				
							SELECT	@In_Time=Max(In_time)  
							FROM	T0150_EMP_INOUT_RECORD WITH (NOLOCK)
							WHERE	emp_ID=@emp_ID And Out_Time IS NULL AND In_time <  @IO_DATETIME     
									AND  ((For_Date=@For_Date)  OR (For_Date=DateAdd(d,-1,@For_Date)))
											
							IF @In_Time IS NOT NULL  
								BEGIN									
									DECLARE @varFor_Date_P VARCHAR(22)    
									SET @varFor_Date_P = CAST(@In_Time AS VARCHAR(11))
													
									IF DatePart(hh,@F_Shift_In_Time_P)=0 AND DatePart(hh,@In_Time) <>0
										SET @varFor_Date_P = DateAdd(dd,1,@varFor_Date_P)

									SET @F_Shift_In_Time_P =  @varFor_Date_P + ' ' + @F_Shift_In_Time_P  
									SET @MinutDiff = IsNull(DateDiff(s,@F_Shift_In_Time_P,@IO_DATETIME),0)
													
									
									
									IF @MinutDiff > =  54000  --75600
										BEGIN
										 /*Added StatusFlag By Deepali07102021 for device inout entry*/
											INSERT INTO T0150_EMP_INOUT_RECORD    
													(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App,StatusFlag)    
											VALUES	
													(@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0,'D')			
											GOTO UpdtFormDate
										END	
									ELSE IF @MinutDiff <0 AND DateDiff(s,@In_Time,@Io_DATETIME) >= 43200--12 Hours --39000 --32400 --9 hours --Added by Hardik 21/05/2015
										BEGIN
										 /*Added StatusFlag By Deepali07102021 for device inout entry*/
											INSERT INTO T0150_EMP_INOUT_RECORD 
													(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App, StatusFlag)    
											VALUES
													(@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0,'D')			
											GOTO UpdtFormDate
										END	
														
								END
						END					
				END

			IF EXISTS(SELECT 1  FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK)
					  WHERE	emp_ID=@emp_ID  AND Out_Time IS NULL AND In_time <  @IO_DATETIME AND  ((For_Date=@For_Date)  OR (For_Date=DateAdd(d,-1,@For_Date))))  
				BEGIN 
					--Condition added by Hardik on 05/04/2014 for below case going wrong
					/* Sample case
						EXEC [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '01-apr-2014 10:00AM', '192.168.1.1',0, 0
						EXEC [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '01-apr-2014 12:01PM', '192.168.1.1',0, 0
						EXEC [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '01-apr-2014 06:59PM', '192.168.1.1',0, 0
						EXEC [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '02-apr-2014 10:01AM', '192.168.1.1',0, 0
					*/
							
					IF @F_Shift_In_Time_P > @F_Shift_End_Time_P --or @F_Shift_In_Time > @F_Shift_End_Time
						BEGIN
							SELECT	@In_Time=Max(In_time)  
							FROM	T0150_EMP_INOUT_RECORD WITH (NOLOCK)
							WHERE	Emp_ID=@emp_ID And Out_Time IS NULL AND In_time <  @IO_DATETIME
									AND  ((For_Date=@For_Date)  OR (For_Date=DateAdd(d,-1,@For_Date)))
						END
					ELSE
						BEGIN
							--SELECT @In_Time=Max(In_time)  FROM T0150_EMP_INOUT_RECORD WHERE emp_ID=@emp_ID  
							--And Out_Time IS NULL 
							--And In_time <  @IO_DATETIME    
							--and  For_Date=@For_Date
							--------- jignesh  21-OCt-2015-------
							--Commented by Hardik 
							--( DatePart(hh,@IO_DATETIME)=0)and
							IF   (DatePart(hh,@F_Shift_In_Time_P)=0 or DatePart(hh,@F_Shift_In_Time)=0)
								BEGIN
									SELECT	@In_Time=Max(In_time)  
									FROM	T0150_EMP_INOUT_RECORD WITH (NOLOCK)
									WHERE	Emp_ID=@emp_ID And Out_Time IS NULL And In_time <  @IO_DATETIME    
											AND  ((For_Date=@For_Date)  OR (For_Date=DateAdd(d,-1,@For_Date)))
								END
							ELSE
								BEGIN
									SELECT	@In_Time=Max(In_time)  
									FROM	T0150_EMP_INOUT_RECORD WITH (NOLOCK)
									WHERE	Emp_ID=@emp_ID AND Out_Time IS NULL And In_time <  @IO_DATETIME AND  For_Date=@For_Date
								END
							--------- end------- 
						END
					IF @In_Time IS NULL  
						BEGIN  
							--SELECT Shift_ID FROM T0100_Emp_Shift_Detail WHERE Emp_ID=@Emp_ID AND For_Date in(SELECT max(for_date) FROM T0100_Emp_Shift_Detail WHERE Emp_ID=@Emp_ID AND For_Date <= @For_Date) AND Shift_type <> 1	
							 /*Added StatusFlag By Deepali07102021 for device inout entry*/
							INSERT INTO T0150_EMP_INOUT_RECORD    
									(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App,StatusFlag)    
							VALUES  
									(@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0,'D')			
							
							GOTO UpdtFormDate
						END  
					ELSE  
						BEGIN 
							DECLARE @Sec_Diff NUMERIC(22,0) 
							SET @Sec_Diff = IsNull(DateDiff(s,@In_Time,@IO_DATETIME),0)
							 
							--IF @Sec_Diff <= 126000,57600
							--IF @Sec_Diff <= 72000
							
							DECLARE @Diff_sec_Temp NUMERIC(22,0)	--Ankit 26062015
							SET @Diff_sec_Temp = 0
							 
							 
							IF CONVERT(VARCHAR(5), @Shift_St_Time1, 108) < CONVERT(VARCHAR(5), @Shift_End_Time1, 108)
								BEGIN
									SET @Diff_sec_Temp = 64800--61200
							    END
							ELSE
							    BEGIN
									SET @Diff_sec_Temp = 59000--50400--46800
								END
							----SELECT @IO_DATETIME,@Sec_Diff,@Diff_sec_Temp

							DECLARE @BetweenShift BIT
							SET @BetweenShift = 0
							IF DatePart(hh,@Shift_St_Time1) IN (0,1,11) AND (DatePart(hh,@in_time) BETWEEN 21 AND 24 OR DatePart(hh,@in_time) BETWEEN 0 AND 2)
								SET @BetweenShift = 1
							ELSE IF abs(datepart(hh,@in_time) - datepart(hh,@Shift_St_Time1)) < 3
								SET @BetweenShift = 1
							IF @Sec_Diff <= @Diff_sec_Temp--46800 --54000 ------modify by jignesh 14-May-2015---
								and  @BetweenShift = 1 --Added By Nimesh On 25-Feb-2019 (For multiple punch in 00:00 Shift - Golcha)
								BEGIN
									UPDATE	T0150_EMP_INOUT_RECORD  
									SET		Out_Time = @IO_DATETIME  ,IP_Address=@Ip_Address
									WHERE	Emp_ID =@Emp_ID AND  ((For_Date=@For_Date) OR (For_Date=DateAdd(d,-1,@For_Date))) 
											AND in_Time  = @In_Time 
										
									UPDATE	T0150_emp_inout_Record     
									SET		Duration = dbo.F_Return_Hours (DateDiff(s,In_time,Out_Time))      
									WHERE	Emp_ID =@Emp_ID AND (For_Date =@For_Date OR (For_Date=DateAdd(d,-1,@For_Date))) AND NOT in_time  IS NULL 
											AND NOT out_Time IS NULL   
				
									GOTO UpdtFormDate
								END
								 /*Added StatusFlag By Deepali07102021 for device inout entry*/
								
							INSERT INTO T0150_EMP_INOUT_RECORD
									(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App,StatusFlag)    
							VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0,'D')				
							  --return
							GOTO UpdtFormDate
						END  
				END 
			IF NOT EXISTS (SELECT 1  FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE emp_ID=@emp_ID  AND Out_Time IS NULL AND In_time <  @IO_DATETIME AND  ((For_Date=@For_Date)  OR (For_Date=DateAdd(d,-1,@For_Date))))  
				BEGIN
					 /*Added StatusFlag By Deepali07102021 for device inout entry*/
					INSERT INTO T0150_EMP_INOUT_RECORD    
							(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App,StatusFlag)    
					VALUES
							(@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0,'D')			
						
				END
		END
		---------------- Add jignesh 22-Oct-2015-------------
UpdtFormDate:
	IF  ( DatePart(hh,@IO_DATETIME) BETWEEN 0 AND 2)and (DatePart(hh,@F_Shift_In_Time_P)=0 or DatePart(hh,@F_Shift_In_Time)=0)
		BEGIN
			UPDATE	T0150_EMP_INOUT_RECORD  
			SET		For_date = For_date-1 
			WHERE	Emp_ID =@Emp_ID AND in_Time  = @IO_DATETIME
		END
	------------------------- End -------------------------
	ELSE
		BEGIN
			IF @In_Out_flag = 2 
				BEGIN
					SELECT	@IO_Tran_ID = IsNull(max(IO_Tran_ID),0)+ 1 
					FROM	T0150_emp_inout_Record WITH (NOLOCK)
				/*Added StatusFlag By Deepali07102021 for device inout entry*/
				INSERT INTO T0150_EMP_INOUT_RECORD 
							(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App,Cmp_prp_out_flag,is_Cmp_purpose,StatusFlag)    
					VALUES
							(@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,null,@IO_DATETIME,'','',@Ip_Address,null,null, 0, 0,@In_Out_flag,1,'D')			
				END
			IF @In_Out_flag = 3
				BEGIN
					SELECT @IO_Tran_ID = IsNull(max(IO_Tran_ID),0)+ 1 FROM T0150_emp_inout_Record WITH (NOLOCK)
				
					UPDATE	T0150_emp_inout_Record     
					SET		In_Time = @IO_DATETIME,
							Cmp_prp_in_flag = @In_Out_flag,
							Duration = dbo.F_Return_Hours (DateDiff(s,@IO_DATETIME,Out_Time))      
					WHERE	Emp_ID=@emp_ID AND is_Cmp_purpose = 1 AND Cmp_prp_in_flag = 0 AND Cmp_prp_out_flag > 0 AND For_Date = @For_Date
				END
		END
RETURN




