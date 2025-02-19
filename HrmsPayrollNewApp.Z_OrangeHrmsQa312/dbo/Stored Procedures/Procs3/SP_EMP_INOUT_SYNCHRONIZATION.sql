
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_INOUT_SYNCHRONIZATION]
    @EMP_ID         NUMERIC ,    
    @CMP_ID         NUMERIC ,    
    @IO_DATETIME    DATETIME ,    
    @IP_ADDRESS     VARCHAR(50),
    @In_Out_flag    NUMERIC = 0, 
    @Flag           INT = 0

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF
    
	
    DECLARE @Max_Early_Come_Limit_Hourly TINYINT
    SET @Max_Early_Come_Limit_Hourly = 4
     
    DECLARE @In_Time Datetime     
    DECLARE @Out_Time Datetime     
    DECLARE @For_Date Datetime     
    DECLARE @varFor_Date VARCHAR(22)     
    DECLARE @F_In_Time datetime     
    DECLARE @F_Out_Time Datetime     
    DECLARE @S_In_Time datetime     
    DECLARE @S_Out_Time Datetime     
    DECLARE @T_In_Time datetime     
    DECLARE @T_Out_Time Datetime     


    DECLARE @Shift_st_Time  Datetime     
    DECLARE @Shift_End_Time  datetime     
    DECLARE @F_Shift_In_Time Datetime     
    DECLARE @F_Shift_End_Time datetime     
    --DECLARE @S_Shift_in_Time datetime     
    --DECLARE @S_shift_end_Time datetime     
    --DECLARE @T_Shift_In_Time datetime     
    --DECLARE @T_Shift_End_Time datetime 


    DECLARE @Shift_st_Time_P  Datetime     
    DECLARE @Shift_End_Time_P  datetime     
    DECLARE @F_Shift_In_Time_P Datetime     
    DECLARE @F_Shift_End_Time_P datetime     
    DECLARE @S_Shift_in_Time_P datetime     
    DECLARE @S_shift_end_Time_P datetime     
    DECLARE @T_Shift_In_Time_P datetime     
    DECLARE @T_Shift_End_Time_P datetime  
    DECLARE @For_Date_P Datetime    


    DECLARE @IO_Tran_ID   numeric     
    DECLARE @Last_Entry numeric(18,0)
    DECLARE @minutdiff numeric(22,0)
    SET @For_Date = CAST(@IO_DATETIME as VARCHAR(11))    
    SET @varFor_Date = CAST(@IO_DATETIME as VARCHAR(11)) 
    SET @For_Date_P = Dateadd(d,-1,@For_Date)

    SET @IO_DATETIME = CAST(@IO_DATETIME as VARCHAR(11)) + ' ' + dbo.F_GET_AMPM(@IO_DATETIME)

	If @IO_DATETIME > GetDate() -- Added by Hardik 28/11/2018
		RETURN	

    --------------------- Add by jigensh 30-Apr-2015---- For Canteen Entry Client:- Apollo ----
    IF  @IP_ADDRESS='Canteen'
    BEGIN
         return
    end

    IF  exists(select IP_Address from T0040_IP_MASTER WITH (NOLOCK) where IP_Address=@IP_Address AND Device_No > 200)
        BEGIN
            return
        end
    ------------------------------- End ------------------------    

    SELECT @Flag = CASE Flag WHEN 'In' Then 0 When 'Out' Then 1 Else 0 End FROM T0040_IP_MASTER WITH (NOLOCK) Where IP_ADDRESS=@IP_ADDRESS
    
    IF IsNull(@Flag,0)=0 
        SET @Flag = 0
    
    DECLARE @Max_Date datetime
    --changes done by Falak on 04-jan-2011 
    -- for blocking of updating the entry of inout records
    SET @Max_Date = null
    -- select @In_Time = max(In_time) , @Out_Time =max(Out_Time) from T0150_emp_inout_Record where emp_ID=@emp_ID
    -- Added by Gadriwala Muslim 02012015 - Start
        
    DECLARE @HasGatePassSetting INT
    SET @HasGatePassSetting  = 0
    
    IF (Len(@Ip_Address) <= 3 AND EXISTS(SELECT 1 FROM T0010_Gate_Pass_Settings WITH (NOLOCK) WHERE CMP_ID=@CMP_ID))
        SET @HasGatePassSetting  = 1
    IF EXISTS(SELECT 1 FROM T0040_IP_MASTER WITH (NOLOCK) WHERE IsNumeric(@IP_ADDRESS) = 1  AND Device_No = @IP_ADDRESS AND Cmp_ID = @CMP_ID AND Is_Gate_Pass = 1)    --Length Condition Added For Wonder
        SET @HasGatePassSetting  = 2
    IF EXISTS(SELECT 1 FROM T0040_IP_MASTER WITH (NOLOCK) WHERE IP_Address = @IP_ADDRESS AND Cmp_ID = @CMP_ID AND Is_Gate_Pass = 1)   --Length Condition Added For Wonder
        SET @HasGatePassSetting  = 3
    
    IF @HasGatePassSetting <> 0
        BEGIN
            Exec SP_EMP_INOUT_SYNCHRONIZATION_GATE_PASS @EMP_ID,@CMP_ID,@IO_DATETIME,@IP_ADDRESS,@In_Out_flag,@Flag
            RETURN
        END

        --added by sneha on 21 july 2015 -start     --commented By Ramiz on 09/01/2015
        --else IF exists(select 1 from T0040_IP_MASTER where Device_No = @IP_ADDRESS AND Cmp_ID = @CMP_ID AND Is_Training = 1)  
        --BEGIN             
        --  Exec SP_EMP_INOUT_SYNCHRONIZATION_TRAINING @EMP_ID,@CMP_ID,@IO_DATETIME,@IP_ADDRESS,@In_Out_flag,@Flag
        --  return
        --end   --added by sneha on 21 july 2015 -end

    --Commented from Above AND Added here By Ramiz on 09/01/2015 ----
    IF EXISTS(SELECT 1 FROM T0040_IP_MASTER WITH (NOLOCK) WHERE IP_ADDRESS = @IP_ADDRESS AND Cmp_ID = @CMP_ID AND Is_Training = 1)    
        BEGIN               
            EXEC SP_EMP_INOUT_SYNCHRONIZATION_TRAINING @EMP_ID,@CMP_ID,@IO_DATETIME,@IP_ADDRESS,@In_Out_flag,@Flag
            RETURN
        END
        --Ended By Ramiz on 09/01/2015 ----
    
    -- Added by Gadriwala Muslim 02012015 - End
    IF @Flag = 0
        BEGIN
            SELECT @In_Time = max(In_time) , @Out_Time =max(Out_Time) from T0150_emp_inout_Record WITH (NOLOCK) where emp_ID=@emp_ID
        END
    ELSE
        BEGIN
            SELECT @In_Time = MAX(In_time)  FROM 
            T0150_emp_inout_Record WITH (NOLOCK) WHERE  Cmp_ID = @CMP_ID  AND emp_ID=@emp_ID AND CAST(In_time AS VARCHAR(11)) = CAST(@IO_DATETIME AS VARCHAR(11))
            SELECT @Out_Time = MAX(Out_Time) FROM 
            T0150_emp_inout_Record WITH (NOLOCK) WHERE  Cmp_ID = @CMP_ID  AND emp_ID=@emp_ID AND CAST(Out_Time AS VARCHAR(11)) = CAST(@IO_DATETIME AS VARCHAR(11))
        END

    SELECT @Max_Date = MAX(for_date) 
	FROM	T0150_EMP_INOUT_RECORD  E WITH (NOLOCK)
	WHERE	Emp_ID = @EMP_ID  
			AND NOT EXISTS(SELECT 1 FROM T0150_EMP_INOUT_RECORD E1 WITH (NOLOCK)
							WHERE	E1.Emp_ID = @EMP_ID  
									AND IsNull(E1.Reason,'') <> '' --AND IsNull(E1.Chk_By_Superior,0) = 0
									AND E1.For_Date= E.FOR_DATE)
			AND NOT EXISTS(SELECT 1 FROM T0150_EMP_INOUT_RECORD E1 WITH (NOLOCK)
							WHERE	E1.Emp_ID = @EMP_ID  
									and IsNull(E1.ManualEntryFlag,'N') <> 'N'  ---- Add by jignesh 19-Jul-2018----
									AND E1.For_Date= E.FOR_DATE)
  
    ----  select @In_Time = max(In_time) , @Out_Time =max(Out_Time) from T0150_emp_inout_Record where emp_ID=@emp_ID  

    DECLARE @InOut_duration_Gap numeric    --Added by Mihir 06/03/2012
    select @InOut_duration_Gap = IsNull(Inout_Duration,300) from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @CMP_ID   --Added by Mihir 06/03/2012

    IF IsNull(@In_Out_flag,0) = 0
        BEGIN
            IF @Flag = 0
                BEGIN   
                    IF @IO_DATETIME < @Max_Date 
                        BEGIN   							
                            Return
                        end   
                end
                
                 IF Exists(select IO_Tran_ID from t0150_emp_inout_record WITH (NOLOCK) where 
                 Emp_Id=@Emp_Id And(In_time = @IO_DATETIME OR Out_Time = @IO_DATETIME ))
                BEGIN   
                    Return
                End 
                            
            --DECLARE @minInTime datetime
            --DECLARE @maxOutTime datetime


            --select @minInTime=min(In_Time),@maxOutTime=max(Out_Time) from t0150_emp_inout_record where Emp_Id=@Emp_Id And(day(For_Date) = day(@IO_DATETIME) AND month(For_Date) = month(@IO_DATETIME) AND year(For_Date) = year(@IO_DATETIME) )
			--IF Exists(select IO_Tran_ID from t0150_emp_inout_record where Emp_Id=@Emp_Id AND day(For_Date) = day(@IO_DATETIME) AND month(For_Date) = month(@IO_DATETIME) AND year(For_Date) = year(@IO_DATETIME) AND In_Time IS not NULL AND Out_Time IS not NULL) OR (@minInTime IS not NULL AND @maxOutTime IS not NULL)
            --BEGIN         
            --  Return
            --End 
            
             IF not @In_time IS NULL AND @In_Time > IsNull(@Out_Time,'01-01-1900') AND DateDiff(s,@In_Time,@IO_DATETIME) < @InOut_duration_Gap AND DateDiff(s,@In_Time,@IO_DATETIME) >0    --@InOut_duration_Gap Added by Mihir 06/03/2012
              BEGIN   
              --PRINT 'y' 
               --Update T0150_emp_inout_Record     
               --set  In_Time = @IO_DATETIME    
               --  ,Duration = dbo.F_Return_Hours (DateDiff(s,@IO_DATETIME,Out_Time))      
               --where In_Time = @In_Time AND Emp_ID=@emp_ID    
               return     
              end    
             ELSE IF not @Out_Time IS NULL AND @Out_Time > IsNull(@In_Time,'01-01-1900')   AND DateDiff(s,@Out_Time,@IO_DATETIME) < @InOut_duration_Gap AND DateDiff(s,@Out_Time,@IO_DATETIME) >0    
              BEGIN    
              --PRINT 'N'
               Update T0150_emp_inout_Record     
               SET  Out_Time = @IO_DATETIME    
                 ,Duration = dbo.F_Return_Hours (DateDiff(s,In_Time,@IO_DATETIME))      
               WHERE Out_Time = @Out_Time AND Emp_ID=@emp_ID    
               RETURN     
              end    

            ---- Added by rohit on 31122013 for Auto Shift
            
              DECLARE @in_time_temp as datetime
              DECLARE @out_time_temp as datetime
              DECLARE @Pre_IO_Date as datetime
              DECLARE @Pre_IO_Flag as VARCHAR

			--- Added by Hardik 04/01/2020 for RMP Client as they have issue in Night Shift, 4th Date punch inserted in Mispunch of 3rd Date.
			DECLARE @Max_IO_Tran_Id NUMERIC
			SET @Max_IO_Tran_Id=0
            
            SELECT  TOP 1 @in_time_temp=in_time,@out_time_temp=out_time 
            from    T0150_EMP_INOUT_RECORD WITH (NOLOCK)
            WHERE   Emp_Id=@Emp_Id AND cmp_id =@cmp_id AND For_Date < @IO_DATETIME ORDER BY For_Date DESC
            
            if isnull(@out_time_temp,'1900-01-01 00:00:00.000')='1900-01-01 00:00:00.000'
            BEGIN
                SET @Pre_IO_Date =@in_time_temp
                SET @Pre_IO_Flag='I'
            END
            ELSE
            BEGIN
                SET @Pre_IO_Date =@out_time_temp
                SET @Pre_IO_Flag='O'
            END
            
                DECLARE @Shift_St_Time1 as VARCHAR(10)
                DECLARE @Shift_End_Time1 as VARCHAR(10)
				DECLARE @Shift_ID NUMERIC

			-- ADDED BY HARDIK 24/09/2020 FOR POLYCAB
			IF DATEDIFF(DD,@Pre_IO_Date,@IO_DATETIME) >1
				SET @Pre_IO_Flag = 'O'

           EXEC Get_Emp_Curr_Shift_New @emp_id,@cmp_id,@IO_DATETIME,@Pre_IO_Flag,@Pre_IO_Date,@Shift_St_Time1 output ,@Shift_End_Time1 output, Null, Null, Null, Null, Null, Null, Null,@Shift_ID Output ---- ADDED BY HARDIK 24/09/2020 FOR POLYCAB

            IF not @Shift_St_Time1 IS NULL AND @Shift_St_Time1 <> ''
                BEGIN
                    SET @F_Shift_In_Time = @Shift_St_Time1 
                    SET @F_Shift_End_Time = @Shift_End_Time1
                End
                        

            
            DECLARE @Shift_ID_N NUMERIC
            DECLARE @Shift_ID_P NUMERIC
        
            IF @Shift_St_Time1 IS NULL OR @Shift_St_Time1 = ''
            BEGIN   
                exec SP_SHIFT_DETAIL_GET @Emp_ID,@Cmp_ID,@For_Date,@Shift_ID OUTPUT,@F_Shift_In_Time output ,@F_Shift_End_Time output,NULL ,NULL,NULL ,NULL, @Shift_st_Time output ,@Shift_end_Time output
            End     
                   
            
            exec SP_SHIFT_DETAIL_GET @Emp_ID,@Cmp_ID,@For_Date_P,@Shift_ID_P OUTPUT,@F_Shift_In_Time_P output ,@F_Shift_End_Time_P output,@S_Shift_in_Time_P output ,@S_shift_end_Time_P output,@T_Shift_In_Time_P output ,@T_Shift_End_Time_P output , @Shift_st_Time_P output ,@Shift_end_Time_P output
             --Ended by rohit on 31-dec-2013 for auto shift                
            
            DECLARE @F_Shift_In_Time_N  DATETIME
            DECLARE @F_Shift_End_Time_N DATETIME
            DECLARE @For_Date_N DATETIME
            SET @For_Date_N = @FOR_DATE + 1
             
            --NEXT DAY SHIFT
            EXEC SP_SHIFT_DETAIL_GET @Emp_ID,@Cmp_ID,@For_Date_N,@Shift_ID_N OUTPUT,@F_Shift_In_Time_N output ,@F_Shift_End_Time_N output,NULL ,NULL,NULL,NULL, NULL,NULL
            
                    
              --IF @S_Shift_in_Time ='1900-01-01 00:00:00.000'    
              -- SET @S_Shift_in_Time = NULL    
              --IF @S_Shift_End_Time ='1900-01-01 00:00:00.000'    
              -- SET @S_Shift_End_Time = NULL    
                  
              --IF @T_Shift_In_Time ='1900-01-01 00:00:00.000'    
              -- SET @T_Shift_In_Time = NULL    
                
              --IF @T_Shift_End_Time ='1900-01-01 00:00:00.000'    
              -- SET @T_Shift_End_Time = NULL    
               
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
              --SET @S_Shift_in_Time = @varFor_Date + ' ' + @S_Shift_in_Time    
              --SET @S_shift_end_Time = @varFor_Date + ' ' + @S_shift_end_Time    
              --SET @T_Shift_In_Time = @varFor_Date + ' ' + @T_Shift_In_Time     
              --SET @T_Shift_End_Time = @varFor_Date + ' ' + @T_Shift_End_Time    
              SET @Shift_end_Time = @varFor_Date + ' ' + @Shift_end_Time    
              SET @Shift_st_Time = @varFor_Date + ' ' + @Shift_st_Time 
              
               
            select @IO_Tran_ID = IsNull(max(IO_Tran_ID),0)+ 1 from T0150_emp_inout_Record WITH (NOLOCK)  
    
                
                --select @F_Shift_In_Time
                --select @F_Shift_In_Time_P,8000    
                --select @IO_DATETIME,@F_Shift_In_Time,@F_Shift_In_Time_P,9000
                -------------- Add by jignesh 14-Oct-2015-------------
                
                --DECLARE @iOutTime int =0
                --IF datepart(hh,@IO_DATETIME)=0 AND (datepart(hh,@F_Shift_In_Time_P)=0 or datepart(hh,@F_Shift_In_Time)=0)
                --BEGIN
                --   SET @For_date = @for_date-1
                --end

                --IF datepart(hh,@In_Time)=0 AND (datepart(hh,@F_Shift_In_Time_P)=0 or datepart(hh,@F_Shift_In_Time)=0)
                --BEGIN
                ----select 2
                --SET @iOutTime =1
                --  goto OutTime
                --end
                -------------------- End------------------

                
                /*Code Added By Nimesh For Night Shift (00:01 Shift Time) Scenario (IF Employee came before 00:00 AND after 00:00 then date should be taken accordingly shift time)*/
                IF DATEPART(HH,@IO_DATETIME) IN (0,23)
                    BEGIN 
                        IF DATEPART(HH,@F_Shift_In_Time) IN (0, 23) 
                            BEGIN
                                IF DATEPART(HH,@F_Shift_In_Time) = 0 AND DATEPART(HH,@IO_DATETIME) = 23
                                    SET @FOR_DATE = CONVERT(DATETIME, CONVERT(VARCHAR(10), @F_Shift_In_Time, 103),103) + 1
                                ELSE IF DATEPART(HH,@F_Shift_In_Time) = 23 AND DATEPART(HH,@IO_DATETIME) = 0
                                    SET @FOR_DATE = CONVERT(DATETIME, CONVERT(VARCHAR(10), @F_Shift_In_Time, 103),103) - 1
                            END
                        ELSE IF DATEPART(HH,@F_Shift_In_Time_N) IN (0, 23) 
                            BEGIN
                                IF DATEPART(HH,@F_Shift_In_Time_N) = 0 AND DATEPART(HH,@IO_DATETIME) = 23
                                    SET @FOR_DATE = CONVERT(DATETIME, CONVERT(VARCHAR(10), @F_Shift_In_Time, 103),103) + 1
                                ELSE IF DATEPART(HH,@F_Shift_In_Time_N) = 23 AND DATEPART(HH,@IO_DATETIME) = 0
                                    SET @FOR_DATE = CONVERT(DATETIME, CONVERT(VARCHAR(10), @F_Shift_In_Time, 103),103) - 1
                            END
                    END
                
                /*Following Code added By Nimesh for Continuous Shift (If employee came in regular shift and works till next day)
                  The Following Code verifies that if employee came 4 hours before shift in time then the punch should be considered in previous day shift                
                */
                DECLARE @Is_ContinueOrNightShift BIT
                IF DATEDIFF(HH,@IO_DateTime,DATEADD(YYYY, YEAR(@FOR_DATE) - YEAR(@F_Shift_In_Time), @F_Shift_In_Time)) > 4                  
                    AND NOT EXISTS(SELECT 1 FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE SHIFT_ID=@Shift_ID AND Inc_Auto_Shift = 0)
                    BEGIN 
                        SET @FOR_DATE = DATEADD(D, -1, CONVERT(DATETIME, CONVERT(VARCHAR(10), @IO_DATETIME, 103), 103))
                        DECLARE @FIRST_IN DATETIME
                        SELECT @FIRST_IN = MIN(IN_TIME) FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND FOR_DATE=@FOR_DATE 
                        IF DATEDIFF(HH, @FIRST_IN, @IO_DateTime) > 12
                            SET @Is_ContinueOrNightShift = 1
                    END

                                
                IF DateDiff(HH,@IO_DATETIME,@F_Shift_In_Time) > @Max_Early_Come_Limit_Hourly
                    SET @FOR_DATE = CONVERT(DATETIME, CONVERT(CHAR(10), @IO_DATETIME, 103), 103) - 1

				SELECT  @Max_IO_Tran_Id=Max(IO_Tran_Id)  
                FROM    T0150_EMP_INOUT_RECORD WITH (NOLOCK)
                WHERE   emp_ID=@emp_ID


				

				IF ABS(DATEDIFF(D,@For_Date,@For_Date_N)) > 1
					BEGIN
						SET @For_Date_N=@For_Date +1
						EXEC SP_SHIFT_DETAIL_GET @Emp_ID,@Cmp_ID,@For_Date_N,@Shift_ID_N OUTPUT,@F_Shift_In_Time_N output ,@F_Shift_End_Time_N output,NULL ,NULL,NULL,NULL, NULL,NULL
						
						SET @For_Date_P=@For_Date -1
						exec SP_SHIFT_DETAIL_GET @Emp_ID,@Cmp_ID,@For_Date_P,@Shift_ID_P OUTPUT,@F_Shift_In_Time_P output ,@F_Shift_End_Time_P output,@S_Shift_in_Time_P output ,@S_shift_end_Time_P output,@T_Shift_In_Time_P output ,@T_Shift_End_Time_P output , @Shift_st_Time_P output ,@Shift_end_Time_P output
					END        
					

                IF EXISTS (SELECT MAX(In_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) 
                            WHERE emp_ID=@emp_ID AND Out_Time IS NULL AND In_time <  @IO_DATETIME AND  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))) AND IO_Tran_Id <= @Max_IO_Tran_Id)  
                    BEGIN
                        DECLARE @Diff NUMERIC(22,0)
                        SET @Diff = IsNull(DateDiff(s,@F_Shift_In_Time,@IO_DATETIME),0)
                                    
                        --IF @Diff >=-10800
                        IF @IO_DATETIME BETWEEN DATEADD(HOUR,-2,@F_Shift_In_Time) AND DATEADD(HOUR,2,@F_Shift_In_Time) --Added by hardik 21/05/2015 as when shift IS changed for night then it will not consider new Punch as IN
                            BEGIN
							
                                SELECT  @In_Time=MAX(In_time)  
                                FROM    T0150_EMP_INOUT_RECORD WITH (NOLOCK)
                                WHERE   emp_ID=@emp_ID  And Out_Time IS NULL And In_time <  @IO_DATETIME     
                                                    AND  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))) AND IO_Tran_Id = @Max_IO_Tran_Id                                         

                                				
                                IF @In_Time IS NOT NULL  
                                    BEGIN
                                        DECLARE @varFor_Date_P VARCHAR(22)    
                                        
                                        set @varFor_Date_P = cast(@In_Time as varchar(11)) 
                                        --set @varFor_Date_P = CAST((@For_Date - 1) as varchar(11)) 
                                        
                                        SET @F_Shift_In_Time_P =  @varFor_Date_P + ' ' + @F_Shift_In_Time_P  
                                        SET @minutdiff = IsNull(DateDiff(s,@F_Shift_In_Time_P,@IO_DATETIME),0)
                                        
                                        IF @minutdiff > =  54000  --75600
                                            BEGIN
                                                PRINT 'Stage 1 : ' + CAST(@IO_DateTime As VARCHAR(20))
                                                    /*Added StatusFlag By Deepali07102021 for device inout entry*/
                                                INSERT INTO T0150_EMP_INOUT_RECORD    
                                                    (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App,StatusFlag)    
                                                VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0,'D')          
                                                    
                                                    return                      
                                            END 
                                        ELSE IF @minutdiff <0 AND DateDiff(s,@In_Time,@Io_Datetime) >= 43200--12 Hours --39000 --32400 --9 hours --Added by Hardik 21/05/2015
                                            BEGIN
                                                PRINT 'Stage 2 : ' + CAST(@IO_DateTime as VARCHAR(20))
												/*Added StatusFlag By Deepali07102021 for device inout entry*/
                                                INSERT INTO T0150_EMP_INOUT_RECORD    
                                                    (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App,StatusFlag)    
                                                VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0,'D')          
                                                RETURN
                                            END                                                         
                                    END
                            END                               
                    END




                IF EXISTS (SELECT MAX(In_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  AND Out_Time IS NULL AND In_time <  @IO_DATETIME AND  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))))  
                    BEGIN 
                        --Condition added by Hardik on 05/04/2014 for below case going wrong
                        /* Sample case
                            exec [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '01-apr-2014 10:00AM', '192.168.1.1',0, 0
                            exec [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '01-apr-2014 12:01PM', '192.168.1.1',0, 0
                            exec [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '01-apr-2014 06:59PM', '192.168.1.1',0, 0
                            exec [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '02-apr-2014 10:01AM', '192.168.1.1',0, 0
                        */
                            
                        
                        IF ((@F_Shift_In_Time_P > @F_Shift_End_Time_P) or (@F_Shift_In_Time > @F_Shift_End_Time AND @F_Shift_In_Time_P < @F_Shift_End_Time_P))
                                AND @F_Shift_End_Time_P <> '1900-01-01 00:00:00'    --"1900-01-01 00:00:00" IS to check weather shift ends at night 12:00 AM. then its not night shift
                            BEGIN
                                SELECT  @In_Time=Max(In_time)  
                                FROM    T0150_EMP_INOUT_RECORD WITH (NOLOCK)
                                WHERE   emp_ID=@emp_ID AND Out_Time IS NULL AND In_time <  @IO_DATETIME     
                                        AND  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))) AND IO_Tran_Id = @Max_IO_Tran_Id
                            END
                        ELSE
                            BEGIN
                                SELECT  @In_Time=Max(In_time)  
                                FROM    T0150_EMP_INOUT_RECORD WITH (NOLOCK)
                                WHERE   emp_ID=@emp_ID AND Out_Time IS NULL AND In_time <  @IO_DATETIME AND For_Date=@For_Date
                            END
                        

                        IF @In_Time IS NULL  
                            BEGIN  
								
                                PRINT 'Stage 3 : ' + CAST(@IO_DateTime as VARCHAR(20))
                                /*Added StatusFlag By Deepali07102021 for device inout entry*/
                                INSERT INTO T0150_EMP_INOUT_RECORD    
                                    (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App,StatusFlag)    
                                VALUES     
                                    (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0,'D')         
                                    
                                RETURN
                                     
                            END  
                        ELSE  
                            BEGIN 
                                ------------- Add jignesh 14-Oct-2015--------                           
                                --OutTime:                  

                                --          IF @iOutTime=1
                                --          BEGIN
                                --              select @In_Time=Max(In_time)  from T0150_EMP_INOUT_RECORD where emp_ID=@emp_ID  
                                --              And Out_Time IS NULL AND In_time <  @IO_DATETIME     
                                --              and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date)))
                                                
                                --          end         
                                ------------------- End-------------

                                DECLARE @Sec_Diff numeric(22,0) 
                                SET @Sec_Diff = IsNull(DateDiff(s,@In_Time,@IO_DATETIME),0)
								
                                --IF @Sec_Diff <= 126000,57600
                                --IF @Sec_Diff <= 72000

                                DECLARE @Diff_sec_Temp Numeric(22,0)    --Ankit 26062015
                                SET @Diff_sec_Temp = 0
                             

                                IF CONVERT(VARCHAR(5), @Shift_St_Time1, 108) < CONVERT(VARCHAR(5), @Shift_End_Time1, 108)
                                    OR @Is_ContinueOrNightShift =1
                                    SET @Diff_sec_Temp = (24 - @Max_Early_Come_Limit_Hourly) * 3600 --64800--61200
                                Else
									BEGIN 
										IF YEAR(@F_Shift_In_Time_N) = 1900
											SET @F_Shift_In_Time_N = @F_Shift_In_Time_N + (@For_Date+1)
										
										SET @Diff_sec_Temp  = DATEDIFF(S, @For_Date + @Shift_St_Time1, @F_Shift_In_Time_N);

										IF @Diff_sec_Temp > 72000 /*If there is same shift on next day then or the next shift start after 24 hours from current shift start time then limit should be before 4 hours next day shift start time*/
											SET @Diff_sec_Temp =  72000
										ELSE IF @Diff_sec_Temp > 43200 
											SET @Diff_sec_Temp = @Diff_sec_Temp - 7200
										--ELSE
										--	set @Diff_sec_Temp = 59000--50400--46800																
									END
								

								/*
								---------------- Add By Jignesh Patel 02-Sep-2021---------
								Declare @Min_Intime as datetime
                                select @Min_Intime=Min(In_time) from T0150_EMP_INOUT_RECORD
                                WHERE   Emp_ID =@Emp_ID AND  ((For_Date=@For_Date))

								If @For_Date + @Shift_End_Time1 < @For_Date + @Shift_St_Time1
									Begin
										SET  @Sec_Diff  = DATEDIFF(S, @For_Date + @Shift_St_Time1,@Min_Intime);
									End
								---------------------------------
								*/

                                IF @Sec_Diff <=  @Diff_sec_Temp--46800 --54000 ------modify by jignesh 14-May-2015---                                
                                    BEGIN
                                        PRINT 'Stage 4 : ' + CAST(@IO_DateTime as VARCHAR(20))                                  

                                        UPDATE  T0150_EMP_INOUT_RECORD  
                                        SET     Out_Time = @IO_DATETIME  ,IP_Address=@Ip_Address
                                        WHERE   Emp_ID =@Emp_ID AND  ((For_Date=@For_Date) OR (For_Date=dateadd(d,-1,@For_Date))) 
                                                AND in_Time  = @In_Time 
                                        
                                        UPDATE  T0150_emp_inout_Record     
                                        SET     Duration = dbo.F_Return_Hours (DateDiff(s,In_time,Out_Time))      
                                        WHERE   Emp_ID =@Emp_ID AND (For_Date =@For_Date OR (For_Date=dateadd(d,-1,@For_Date))) 
                                                AND not in_time  IS NULL AND not out_Time IS NULL 
                                      
                                        RETURN
                                    END
                                    
                                PRINT 'Stage 5 : ' + CAST(@IO_DateTime as VARCHAR(20))
                                /*Added StatusFlag By Deepali07102021 for device inout entry*/
                                INSERT INTO T0150_EMP_INOUT_RECORD    
                                    (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App,StatusFlag)    
                                VALUES     
                                    (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0,'D')             
                              
                                RETURN
                            END  
                    END 
                        
                IF NOT EXISTS(SELECT MAX(In_time) FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE emp_ID=@emp_ID  AND Out_Time IS NULL AND In_time <  @IO_DATETIME AND  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))))  
                    BEGIN
                        PRINT 'Stage 6 : ' + CAST(@IO_DateTime as VARCHAR(20))
                       /*Added StatusFlag By Deepali07102021 for device inout entry*/ 
                        INSERT INTO T0150_EMP_INOUT_RECORD    
                            (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App,StatusFlag)    
                        VALUES     
                            (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0,'D')         
                    END
            END
        ELSE
            BEGIN       
                IF @In_Out_flag = 2 
                    BEGIN                                                       
                        SELECT  @IO_Tran_ID = IsNull(MAX(IO_Tran_ID),0)+ 1 
                        FROM    T0150_emp_inout_Record WITH (NOLOCK)
                    
                        PRINT   'Stage 7 : ' + CAST(@IO_DateTime as VARCHAR(20))
                     /*Added StatusFlag By Deepali07102021 for device inout entry*/
                        INSERT INTO T0150_EMP_INOUT_RECORD    
                            (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App,Cmp_prp_out_flag,is_Cmp_purpose,StatusFlag)    
                        VALUES     
                            (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,null,@IO_DATETIME,'','',@Ip_Address,null,null, 0, 0,@In_Out_flag,1,'D')          
                    END         
                IF @In_Out_flag = 3
                    BEGIN
                        SELECT  @IO_Tran_ID = IsNull(MAX(IO_Tran_ID),0)+ 1 
                        FROM    T0150_emp_inout_Record WITH (NOLOCK)
                    
                        PRINT 'Stage 8 : ' + CAST(@IO_DateTime as VARCHAR(20))
                        
                        UPDATE  T0150_emp_inout_Record     
                        SET     In_Time = @IO_DATETIME,
                                Cmp_prp_in_flag = @In_Out_flag,
                                Duration = dbo.F_Return_Hours (DateDiff(s,@IO_DATETIME,Out_Time))      
                        WHERE   Emp_ID=@emp_ID AND is_Cmp_purpose = 1 AND Cmp_prp_in_flag = 0 AND Cmp_prp_out_flag > 0 AND For_Date = @For_Date
                    END
            END
        
RETURN
