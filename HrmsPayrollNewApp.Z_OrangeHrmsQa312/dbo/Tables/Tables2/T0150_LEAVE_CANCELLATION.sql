CREATE TABLE [dbo].[T0150_LEAVE_CANCELLATION] (
    [Tran_id]           NUMERIC (12)    NOT NULL,
    [Cmp_Id]            NUMERIC (18)    NOT NULL,
    [Emp_Id]            NUMERIC (18)    NOT NULL,
    [Leave_Approval_id] NUMERIC (12)    NULL,
    [Leave_id]          NUMERIC (12)    NOT NULL,
    [For_date]          DATETIME        NULL,
    [Leave_period]      NUMERIC (18, 2) NULL,
    [Is_Approve]        TINYINT         CONSTRAINT [DF_Table_1_is_Approve] DEFAULT ((0)) NOT NULL,
    [Comment]           NVARCHAR (200)  NULL,
    [Request_Date]      DATETIME        CONSTRAINT [DF_T0150_LEAVE_CANCELLATION_Request_Date] DEFAULT (getdate()) NOT NULL,
    [MComment]          NVARCHAR (200)  NULL,
    [A_Emp_Id]          NUMERIC (18)    CONSTRAINT [DF_T0150_LEAVE_CANCELLATION_A_Emp_Id] DEFAULT ((0)) NULL,
    [Day_type]          VARCHAR (50)    NULL,
    [Actual_Leave_Day]  NUMERIC (18, 2) NULL,
    [Compoff_Work_Date] VARCHAR (200)   NULL,
    [Backdated_Cancel]  TINYINT         CONSTRAINT [DF_T0150_LEAVE_CANCELLATION_Backdated_Cancel] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0150_LEAVE_CANCELLATION] PRIMARY KEY CLUSTERED ([Tran_id] ASC) WITH (FILLFACTOR = 80)
);


GO


CREATE TRIGGER [dbo].[Tri_T0150_LEAVE_CANCELLATION]
ON [dbo].[T0150_LEAVE_CANCELLATION]
FOR Update,Delete
AS
  SET nocount ON

  DECLARE @Cmp_ID AS NUMERIC
  DECLARE @For_Date AS DATETIME
  DECLARE @Emp_Id AS NUMERIC
  DECLARE @Count AS NUMERIC
  DECLARE @Leave_Approval_Id AS NUMERIC
  DECLARE @Leave_Id AS NUMERIC
  DECLARE @Leave_Used AS NUMERIC(18, 2) --Change Type 18,2 instead of 18,1 for part day leave transactions --Sumit 24082016
  DECLARE @Leave_Asign_As AS VARCHAR(20) --hardik 24/06/2011
  DECLARE @Leave_Asign_As_Cur AS VARCHAR(20) --hardik 24/06/2011
  DECLARE @Leave_Used_Cur AS NUMERIC(18, 2) --hardik 24/06/2011
  DECLARE @Code AS VARCHAR(50)
  DECLARE @Last_Leave_Closing AS NUMERIC(18, 2)
  DECLARE @From_Date AS DATETIME
  DECLARE @To_Date AS DATETIME
  DECLARE @ErrString AS VARCHAR(200)
  DECLARE @varFromDate AS VARCHAR(11)
  DECLARE @To_For_Date AS DATETIME
  DECLARE @Leave_Tran_ID AS NUMERIC
  DECLARE @is_approve AS TINYINT
  DECLARE @Total_Leave_used AS NUMERIC(18, 2)
  DECLARE @A_From_Date AS DATETIME
  DECLARE @A_To_Date AS DATETIME
  DECLARE @Leave_negative_Allow TINYINT
  DECLARE @IS_Import INT
  DECLARE @Emp_Code NUMERIC(18, 0)
  DECLARE @Leave_Paid_Unpaid VARCHAR(1)
  DECLARE @M_Cancel_WO_HO TINYINT

  SET @M_Cancel_WO_HO = 0
  SET @Total_Leave_used = 0
  SET @Leave_negative_Allow =0
   -- Added by Gadriwala Muslim 21092015 - Start
  Declare @Leave_Type varchar(25) 
  set @Leave_Type = '' 
  Declare @Year_Start_Date datetime
  Declare @Year_End_Date datetime
  Declare @Medical_Leave_ID numeric(18,0)
  Declare @ML_Trans_ID numeric(18,0)	
  Declare @Medical_Last_Closing numeric(18,2)
  Declare @Leave_Approval_Date datetime
  Declare @Auto_credit_ML numeric(18,0)
  declare @cur_ML_tran_ID numeric(18,0)
  declare @Cur_ML_For_Date datetime
  declare @Medical_Posting numeric(18,2)
  -- Added by Gadriwala Muslim 21092015 - End
  
  
	
  IF UPDATE (Is_Approve)
    BEGIN
		
        SELECT @Cmp_ID = ins.cmp_id,
               @Emp_Id = ins.emp_id,
               @is_approve = ins.is_approve,
               @Leave_Approval_Id = ins.leave_approval_id,
               @Leave_Id = ins.leave_id,
               @A_From_Date = for_date,
               @Leave_Used = ins.leave_period
        FROM   inserted ins
		
        SELECT @Emp_Code = emp_code
        FROM   t0080_emp_master
        WHERE  emp_id = @Emp_Id
        
        SELECT @Leave_negative_Allow = Isnull(leave_negative_allow, 0),
               @Leave_Paid_Unpaid = leave_paid_unpaid,
               @Leave_Type = Leave_Type -- Added by Gadriwala Muslim 21092015
        FROM   t0040_leave_master
        WHERE  leave_id = @Leave_ID
		
		
					
        IF @leave_Id > 0
          BEGIN
              IF @is_approve = 1
                BEGIN
                
                    SET @From_Date = @A_From_Date
                    SET @For_Date = @A_From_Date
                    SET @To_Date = @A_From_Date
                    SET @Leave_Used_Cur = @Leave_Used
					set @Total_leave_used = @Leave_Used
					set @A_To_Date = @A_From_Date
					
                    --declare curAsgnLeave cursor for
                    --  select from_date,to_date,Leave_Assign_As,Leave_Period from T0120_LEAVE_APPROVAL LA INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON
                    --      LA.LEAVE_APPROVAL_ID = LAD.LEAVE_APPROVAL_ID
                    --    where LA.Cmp_ID = @Cmp_ID and emp_id = @emp_Id  and LAD.Leave_Approval_Id <> @Leave_Approval_Id  And Approval_Status<>'R'                
                    --open curAsgnLeave  
                    ----Nikunj 25-Jan-2011 In Where Condition Put Approval_Status<>'R'.Because If for Same if once Your Leave is rejcet then next time it may be possible that approve.this case got from ambuja
                    --fetch next from curAsgnLeave into @From_Date,@To_Date,@Leave_Asign_As_Cur,@Leave_Used_Cur
                    --  while @@fetch_status = 0
                    --    begin
                    --select @for_Date,@From_Date,@To_Date
                    --print 'Falak;'
                    --set @To_For_Date = dateadd(d,floor(@Leave_Used),@for_Date)
                    IF @Leave_Used > 0.5
                      SET @To_For_Date = Dateadd(d, Floor(@Leave_Used),
                                         @for_Date)
                                         - 1
                    ELSE
                      SET @To_For_Date = Dateadd(d, Floor(@Leave_Used),
                                         @for_Date)
                                         
                                         

                    SET @For_Date= @A_From_Date
                    
					
						SELECT @Last_Leave_Closing = Isnull(leave_closing, 0)
						FROM   t0140_leave_transaction
						WHERE  for_date = (SELECT MAX(for_date)
										   FROM   t0140_leave_transaction
										   WHERE  for_date < @For_date
												  AND leave_id = @leave_id
												  AND cmp_id = @Cmp_ID
												  AND emp_id = @emp_Id)
							   AND cmp_id = @Cmp_ID
							   AND leave_id = @leave_Id
							   AND emp_id = @emp_Id

						IF @Last_Leave_Closing IS NULL
						  SET @Last_Leave_Closing = 0
	                 
	                    
						WHILE @For_Date <= @A_To_Date
							  AND @Total_leave_used > 0
						  BEGIN
							
							
							  --IF @Total_leave_used = 0.5
							  --  BEGIN
									
							  --      IF EXISTS(SELECT emp_id
							  --                FROM   t0140_leave_transaction
							  --                WHERE  cmp_id = @Cmp_ID
							  --                       AND leave_id = @leave_Id
							  --                       AND emp_id = @emp_Id
							  --                       AND for_date = @For_date
							  --                       AND leave_used = 0.5)
							  --        BEGIN
							  --            SET @Leave_used = 1
							  --        END
							  --      ELSE
							  --        BEGIN
							  --            SET @Leave_used = 0.5
							  --        END
	                                 
	                                
							  --  END
							  --ELSE
							  --  BEGIN
							  --      SET @Leave_used = 1
							  --      SET @Total_Leave_Used =
							  --      @Total_leave_used - @Leave_Used
							  --  END

							  SELECT @Leave_Tran_ID = Isnull(MAX(leave_tran_id), 0)
													  +
													  1
							  FROM   t0140_leave_transaction

							  DECLARE @temp_Leave_Used NUMERIC(18, 1)
							
							  --Added by Hardik 16/12/2011
							  SELECT @Last_Leave_Closing = Isnull(leave_closing, 0)
							  FROM   t0140_leave_transaction
							  WHERE  for_date = (SELECT MAX(for_date)
												 FROM   t0140_leave_transaction
												 WHERE  for_date < @For_date
														AND leave_id = @leave_id
														AND cmp_id = @Cmp_ID
														AND emp_id = @emp_Id)
									 AND cmp_id = @Cmp_ID
									 AND leave_id = @leave_Id
									 AND emp_id = @emp_Id
								
							  IF EXISTS(SELECT for_date
										FROM   t0140_leave_transaction
										WHERE  for_date = @For_date
											   AND leave_id = @leave_Id
											   AND cmp_id = @Cmp_ID
											   AND emp_id = @emp_id)
								BEGIN
									SELECT @temp_Leave_Used = leave_used
									FROM   t0140_leave_transaction
									WHERE  leave_id = @Leave_Id
										   AND for_date = @For_Date
										   AND cmp_id = @Cmp_ID
										   AND emp_id = @emp_Id

	                          
									BEGIN
											 
										UPDATE t0140_leave_transaction
										SET
										--Leave_Opening = @Last_Leave_Closing, 
										leave_used = leave_used - @Leave_Used,
										leave_closing = (leave_opening + 
														Isnull(leave_credit,0) + @Leave_Used)  - Leave_Used
	                                                   
										WHERE  leave_id = @Leave_Id
											   AND for_date = @For_Date
											   AND cmp_id = @Cmp_ID
											   AND emp_id = @emp_Id
												 And Leave_Used > 0
												 
										SET @Last_Leave_Closing =
										(SELECT Isnull(leave_closing, 0)
										 FROM   dbo.t0140_leave_transaction
										 WHERE  leave_id = @Leave_Id
												AND for_date = @For_Date
												AND cmp_id = @Cmp_ID
												AND emp_id = @emp_Id)
									END
								--update T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening - @Leave_Used
								--  ,Leave_Closing = Leave_Closing - @Leave_Used  
								--where Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
								--  and emp_Id = @emp_Id
								END
							  ELSE
								BEGIN
						--select @For_date,@leave_id,@emp_Id      
						IF Isnull(@Last_Leave_Closing, 0) = 0
						   AND @Leave_negative_Allow = 0
						  BEGIN
							  RAISERROR(
							  '@@Leave Balance Negative, Negative Not Allowed@@'
							  ,
							  16,
							  2)

							  RETURN
						  END

						INSERT INTO t0140_leave_transaction
									(emp_id,
									 leave_id,
									 cmp_id,
									 for_date,
									 leave_opening,
									 leave_used,
									 leave_closing,
									 leave_credit,
									 leave_tran_id)
						VALUES     (@emp_id,
									@leave_Id,
									@Cmp_ID,
									@for_Date,
									@last_Leave_Closing,
									@Leave_Used,
									@last_Leave_Closing - @Leave_Used,
									0,
									@Leave_Tran_ID)
								--update T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening - @Leave_Used
								--  ,Leave_Closing = Leave_Closing - @Leave_Used  
								--where Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
								--  and emp_Id = @emp_Id
						  END



							  set @For_date = dateadd(d,1,@For_date)
	                    
						End -- While 
						--      FETCH NEXT FROM curasgnleavedate INTO @For_date
						--  END

						--CLOSE curasgnleavedate

						--DEALLOCATE curasgnleavedate

						--end -- end of If @Leave_Paid_Unpaid
						---Alpesh 26-Sep-2011
						DECLARE @Chg_Tran_Id NUMERIC
						DECLARE @For_Date_Cur DATETIME
						DECLARE @Pre_Closing NUMERIC(18, 2)
						DECLARE @Leave_Posting NUMERIC(18, 2)

						SET @For_Date= @A_From_Date

						SELECT @Pre_Closing = Isnull(leave_closing, 0)
						FROM   t0140_leave_transaction
						WHERE  for_date = (SELECT MAX(for_date)
										   FROM   t0140_leave_transaction
										   WHERE  for_date <= @For_date
												  AND leave_id = @leave_id
												  AND cmp_id = @Cmp_ID
												  AND emp_id = @emp_Id)
							   AND cmp_id = @Cmp_ID
							   AND leave_id = @leave_Id
							   AND emp_id = @emp_Id

						IF @Pre_Closing IS NULL
						  SET @Pre_Closing = 0

						--Added by Jaina 06-02-2017 Start
						DECLARE @Posting_For_Date datetime
						  
						SELECT @Posting_For_Date = MIN(FOR_DATE) 
								FROM DBO.t0140_leave_transaction 
						WHERE  leave_id = @leave_Id
								AND emp_id = @emp_id
								AND cmp_id = @Cmp_ID
								AND for_date > @For_date 
								AND Leave_Posting IS NOT NULL
									
					   IF @Posting_For_Date IS NULL
							SELECT @Posting_For_Date = IsNull(MAX(FOR_DATE), GETDATE()) 
								FROM DBO.t0140_leave_transaction 
							WHERE  leave_id = @leave_Id
								   AND emp_id = @emp_id
								   AND cmp_id = @Cmp_ID
								   AND for_date > @For_date 

						--Added by Jaina 06-02-2017 End
						
						DECLARE cur1 CURSOR FOR
						  SELECT leave_tran_id,
								 for_date
						  FROM   dbo.t0140_leave_transaction
						  WHERE  leave_id = @leave_Id
								 AND emp_id = @emp_id
								 AND cmp_id = @Cmp_ID
								 AND for_date > @For_date And for_date <= @Posting_For_Date
						  ORDER  BY for_date

						OPEN cur1

						FETCH NEXT FROM cur1 INTO @Chg_Tran_Id, @For_Date_Cur

						WHILE @@FETCH_STATUS = 0
						  BEGIN
							  --select @For_date,@For_Date_Cur
							  --Added by Hardik 16/12/2011
							  IF EXISTS(SELECT leave_op_id
										FROM   t0095_leave_opening
										WHERE  cmp_id = @Cmp_ID
											   AND emp_id = @Emp_Id
											   AND leave_id = @Leave_Id
											   AND for_date = @For_Date_Cur
											   AND leave_op_days > 0)
								BEGIN
									GOTO c;
								END

							  SELECT @Leave_Posting = Isnull(leave_posting, 0)
							  FROM   dbo.t0140_leave_transaction
							  WHERE  leave_tran_id = @Chg_Tran_Id

							  --if @Leave_Posting <> 0
							  --  begin
							  --    update dbo.T0140_LEAVE_TRANSACTION set 
							  --       Leave_Opening = @Pre_Closing,
							  --       Leave_Closing = @Pre_Closing + Leave_Credit - Leave_Used, 
							  --       Leave_Posting = @Pre_Closing + Leave_Credit - Leave_Used                   
							  --    where leave_tran_id = @Chg_Tran_Id
							  --    --break
							  --  end
							  --else                    
							  BEGIN
								  --commented by hardik 16/12/2011                      
								  --                      If Not exists (select 1 from dbo.T0140_LEAVE_TRANSACTION where Leave_Posting <> 0 and leave_id = @leave_Id and emp_Id = @emp_Id And For_Date = 
								  --                          (Select MAX(For_Date) From dbo.T0140_LEAVE_TRANSACTION Where For_Date < @For_Date_Cur and leave_id = @leave_Id and emp_Id = @emp_Id ))
								  BEGIN
									  UPDATE dbo.t0140_leave_transaction
									  SET    leave_opening = @Pre_Closing,
											 leave_closing = @Pre_Closing + Isnull(
															 leave_credit, 0
																			)
															 - Isnull(
															 leave_used, 0)
									  WHERE  leave_tran_id = @Chg_Tran_Id

									  C:

									  SET @Pre_Closing = Isnull(
									  (SELECT Isnull(leave_closing, 0)
									   FROM   dbo.t0140_leave_transaction
									   WHERE  leave_tran_id = @Chg_Tran_Id
									  ), 0
														 )
								  END
	                         
							  END

							  FETCH NEXT FROM cur1 INTO @Chg_Tran_Id, @For_Date_Cur
						  END

						CLOSE cur1

						DEALLOCATE cur1
						print 'sdp'
						--- End 
						--SELECT * from T0140_LEAVE_TRANSACTION where Emp_ID =@emp_ID and Leave_ID =@Leave_ID and For_Date >=@A_To_date and Leave_Closing < 0
						IF @Leave_negative_Allow = 0
						  BEGIN
							  IF EXISTS(SELECT emp_id
										FROM   t0140_leave_transaction
										WHERE  emp_id = @emp_ID
											   AND leave_id = @Leave_ID
											   AND for_date >= @A_To_date
											   AND leave_closing < 0)
							  BEGIN
						IF @Is_Import = 1
						  BEGIN
						  
							  INSERT INTO dbo.t0080_import_log
							  VALUES      (0,
										   @Cmp_Id,
										   @Emp_Code,
							  'Leave Balance Negative Not Allowed',
							  NULL,
							  'Insufficient Balance to approve the leave',
							  Getdate(),
							  'Leave Approval'
							  ,'') --ADDED ONE PERAMETER MORE FOR KEYGUID ON 30062016 BY SUMIT
						  END
						ELSE
						  BEGIN
							
							  RAISERROR(
							  '@@Leave Balance Negative, Negative Not Allowed@@'
							  ,
							  16,
							  2)

							  RETURN
						  END
					END
						  END
					END -- Approval Flag
	         if @Leave_Type = 'ESIC Leave'  -- Added by Gadriwala Muslim 15/09/2015
						begin
										select @Auto_credit_ML = Setting_Value from T0040_SETTING 
										where Cmp_ID = @Cmp_ID 
										and  Setting_Name = 'Auto credit one medical leave when first time ESIC leave have approved in year'
																												
										if @Auto_credit_ML = 1 
											begin
												
												set @Medical_Leave_ID = 0
												set @Auto_credit_ML = 0
												set @Medical_Last_Closing = 0
												set @Year_Start_Date = dbo.GET_MONTH_ST_DATE(month(@A_From_Date),Year(@A_From_Date))
												set @Year_End_Date = dbo.GET_MONTH_END_DATE(month(@A_From_Date),Year(@A_From_date))
												
												select @Medical_Leave_ID = Leave_ID from T0040_LEAVE_MASTER 
												where cmp_ID = @cmp_ID and Medical_Leave = 1
												select @Leave_Approval_Date = Approval_Date  from T0120_LEAVE_APPROVAL where Leave_Approval_ID = @Leave_Approval_Id and Cmp_ID = @Cmp_ID
												
																	If  exists( select 1 from T0140_LEAVE_TRANSACTION where Leave_ID = @Medical_Leave_ID  and For_Date = @Leave_Approval_Date and Emp_ID = @Emp_Id and Cmp_ID = @Cmp_ID and Leave_credit > 0)						
																		begin
																			select @ML_Trans_ID = Leave_Tran_ID from T0140_LEAVE_TRANSACTION where Leave_ID = @Medical_Leave_ID  and For_Date = @Leave_Approval_Date and Emp_ID = @Emp_Id and Cmp_ID = @Cmp_ID
																			
																			update T0140_LEAVE_TRANSACTION 
																			set Leave_Credit = 0, Leave_Closing = Leave_Opening  - Leave_Used
																			where  Leave_Tran_ID = @ML_Trans_ID and Cmp_ID = @Cmp_ID  
																			
																			if exists( 
																			select 1 from T0140_LEAVE_TRANSACTION LT 
																				left outer join 
																				(
																					select For_date,LT.Leave_ID,emp_id from  T0140_LEAVE_TRANSACTION LT inner join
																					T0040_LEAVE_MASTER LM  on LT.Leave_ID = LM.Leave_ID  where 
																						LT.Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id  and LT.For_Date >= @A_From_Date and  LT.For_Date <= @A_To_Date and leave_used > 0 and Leave_Type = 'ESIC Leave'
																					) Qry  
																					on Qry.For_Date = LT.For_Date and Qry.Leave_ID = LT.Leave_ID and Qry.emp_id = LT.emp_id  
																					inner join T0040_LEAVE_MASTER LM  on LT.Leave_ID = LM.Leave_ID 
																					where LT.For_Date >= @Year_Start_Date and LT.For_Date <= @Year_End_Date 
																					and LT.Cmp_ID = @Cmp_ID and LT.Emp_ID = @Emp_Id and Leave_Used >0 
																					and Leave_Type = 'ESIC Leave' and isnull(Qry.emp_id,0) = 0
																				)
																			begin
																					declare @ML_Approval_Date as datetime
																				
																				select Top 1 @ML_Approval_Date = Approval_Date from T0120_LEAVE_APPROVAL LA inner join
																				T0130_LEAVE_APPROVAL_DETAIL LAD on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join
																				T0040_LEAVE_MASTER LM  on LAD.Leave_ID = LM.Leave_ID 
																				where From_Date >= @Year_Start_Date and From_Date <=@Year_End_Date and LA.Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id and LM. Leave_Type = 'ESIC Leave'
																				
																				If  exists( select 1 from T0140_LEAVE_TRANSACTION where Leave_ID = @Medical_Leave_ID  and For_Date = @ML_Approval_Date and Emp_ID = @Emp_Id and Cmp_ID = @Cmp_ID)						
																					begin
																						select @ML_Trans_ID = Leave_Tran_ID from T0140_LEAVE_TRANSACTION where Leave_ID = @Medical_Leave_ID  and For_Date = @ML_Approval_Date and Emp_ID = @Emp_Id and Cmp_ID = @Cmp_ID
																						update T0140_LEAVE_TRANSACTION 
																						set Leave_Credit = Leave_Credit + 1, Leave_Closing = (Leave_Opening + Leave_Credit + 1 ) - Leave_Used
																						where  Leave_Tran_ID = @ML_Trans_ID and Cmp_ID = @Cmp_ID
																					end
																				else
																					begin
																						select @ML_Trans_ID = isnull(max(Leave_Tran_ID),0) + 1 from T0140_LEAVE_TRANSACTION 
																						
																						 select @Medical_Last_Closing = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION  
																						 where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION where for_date <= @ML_Approval_Date  
																						 and leave_Id = @Medical_Leave_ID and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id)   
																						 and Cmp_ID = @Cmp_ID  
																						 and leave_id = @Medical_Leave_ID and emp_Id = @emp_Id  
																						
																						insert into T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Credit,Leave_Used,Leave_Closing,Leave_Tran_ID)  
																						values(@emp_id,@Medical_Leave_ID,@Cmp_ID,@ML_Approval_Date,@Medical_Last_Closing,1,0, @Medical_Last_Closing + 1 ,@ML_Trans_ID)  
																						
																					end
																				
																				select @Medical_Last_Closing = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION  
																				where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION where for_date <= @ML_Approval_Date  
																				and leave_Id = @Medical_Leave_ID and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id)   
																				and Cmp_ID = @Cmp_ID  
																				and leave_id = @Medical_Leave_ID and emp_Id = @emp_Id  
					                           
					  															if @Medical_Last_Closing is null  
																				 set @Medical_Last_Closing = 0          
																				     
																			 
																				declare curMedicalLeave cursor for   
																				Select leave_tran_id,For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @Medical_Leave_ID and emp_id = @emp_id   
																				 and Cmp_ID = @Cmp_ID and for_date > @ML_Approval_Date order by for_date  
																				open curMedicalLeave 
																				fetch next from curMedicalLeave into @cur_ML_tran_ID,@Cur_ML_For_Date  
																				while @@fetch_status = 0  
																				begin  
																		       
																				 If exists(Select Leave_Op_Id From T0095_LEAVE_OPENING Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Medical_Leave_ID And For_Date = @Cur_ML_For_Date And Leave_Op_Days > 0)  
																				  Begin  
																				   Goto Medical3;  
																				  End  
																		          
																				 Select @Medical_Posting = isnull(Leave_Posting,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @cur_ML_tran_ID 
																				  begin  
																					Begin  
																		  
																					 update dbo.T0140_LEAVE_TRANSACTION set   
																					   Leave_Opening = @Medical_Last_Closing,  
																					   Leave_Closing = @Medical_Last_Closing + isnull(Leave_Credit,0) - isnull(Leave_Used,0) - isnull(Leave_Encash_Days,0) - ISNULL(Back_Dated_Leave,0) - Isnull(Half_Payment_Days,0)
																					  where leave_tran_id = @cur_ML_tran_ID  
																				  Medical3:     
																					 set @Medical_Last_Closing = isnull((select isnull(Leave_Closing,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @cur_ML_tran_ID),0)  
																					End  
																				  end                  
																		          
																				 fetch next from curMedicalLeave into @cur_ML_tran_ID,@Cur_ML_For_Date  
																				end  
																				close curMedicalLeave  
																				deallocate curMedicalLeave   	
																			end
																			
																		end
																	
																				select @Medical_Last_Closing = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION  
																				where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION where for_date <= @Leave_Approval_Date  
																				and leave_Id = @Medical_Leave_ID and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id)   
																				and Cmp_ID = @Cmp_ID  
																				and leave_id = @Medical_Leave_ID and emp_Id = @emp_Id  
					                           
					  															if @Medical_Last_Closing is null  
																				 set @Medical_Last_Closing = 0          
																				     
																				
																			 
																				declare curMedicalLeave cursor for   
																				Select leave_tran_id,For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @Medical_Leave_ID and emp_id = @emp_id   
																				 and Cmp_ID = @Cmp_ID and for_date > @Leave_Approval_Date order by for_date  
																				open curMedicalLeave 
																				fetch next from curMedicalLeave into @cur_ML_tran_ID,@Cur_ML_For_Date  
																				while @@fetch_status = 0  
																				begin  
																		       
																				 If exists(Select Leave_Op_Id From T0095_LEAVE_OPENING Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Medical_Leave_ID And For_Date = @Cur_ML_For_Date And Leave_Op_Days > 0)  
																				  Begin  
																				   Goto Medical2;  
																				  End  
																		          
																				 Select @Medical_Posting = isnull(Leave_Posting,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @cur_ML_tran_ID 
																				  begin  
																					Begin  
																		  
																					 update dbo.T0140_LEAVE_TRANSACTION set   
																					   Leave_Opening = @Medical_Last_Closing,  
																					   Leave_Closing = @Medical_Last_Closing + isnull(Leave_Credit,0) - isnull(Leave_Used,0) - isnull(Leave_Encash_Days,0) - ISNULL(Back_Dated_Leave,0) - Isnull(Half_Payment_Days,0)
																					  where leave_tran_id = @cur_ML_tran_ID  
																				  Medical2:     
																					 set @Medical_Last_Closing = isnull((select isnull(Leave_Closing,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @cur_ML_tran_ID),0)  
																					End  
																				  end                  
																		          
																				 fetch next from curMedicalLeave into @cur_ML_tran_ID,@Cur_ML_For_Date  
																				end  
																				close curMedicalLeave  
																				deallocate curMedicalLeave       	
																		end
															end
			  END
		END-- END Approve
	  ELSE 
		BEGIN			
					
					DECLARE @Tran_ID AS NUMERIC
					declare @compOff_Date varchar(max)
					DECLARE @Day_Type AS VARCHAR(MAX)
					
						SELECT @Cmp_ID = ins.cmp_id,
							   @Emp_Id = ins.emp_id,
							   @is_approve = ins.is_approve,
							   @Leave_Approval_Id = ins.leave_approval_id,
							   @Leave_Id = ins.leave_id,
							   @A_From_Date = for_date,
							   @Leave_Used = ins.leave_period,
							   @compOff_Date = ins.Compoff_Work_Date,   --Added By Jaina 1-12-2015
							   @Day_Type = ins.Day_type   --Added By Jaina 1-12-2015
						FROM   deleted ins
				        
						
			--Added By Jaina 30-11-2015
					--if EXISTS (SELECT  L.Leave_ID from T0040_LEAVE_MASTER as L  inner join T0140_LEAVE_TRANSACTION as LT on L.Leave_Id=LT.Leave_ID where LT.Leave_ID = @Leave_ID AND L.Default_Short_Name='COMP')
					if EXISTS (SELECT  L.Leave_ID from T0040_LEAVE_MASTER as L 
										inner join T0140_LEAVE_TRANSACTION as LT on L.Leave_Id=LT.Leave_ID 
										INNER JOIN DELETED as C ON C.Leave_id = LT.Leave_ID
										where LT.Leave_ID = @Leave_Id AND (L.Default_Short_Name='COMP' or L.Default_Short_Name='COPH') and C.Is_Approve = 1
										 and C.Leave_Approval_id =@Leave_Approval_Id )  --Change By Jaina 9-12-2015
					BEGIN
					
					----Added By Jaina 25-11-2015 Start ( For Comp off Leave Cancellation)			    	
					DECLARE @Compoff_Credit as numeric(18,2)
					DECLARE @Compoff_Debit as  numeric (18,2)
					DECLARE @Compoff_Balance  as numeric (18,2)
					DECLARE @Compoff_Used as  numeric(18,2)	
					DECLARE @Comp_Date datetime
					DECLARE @Leaveday numeric(18,2)
					Declare @Leaveid numeric
					---DECLARE @ADD_DAY NUMERIC(18,2);
					
					IF OBJECT_ID('tempdb..#Comp_temp') IS NULL
					CREATE table #Comp_temp
					(
						comp_Date varchar(max),
						Leaveday varchar(max)
					)
					Insert into #Comp_temp (comp_Date,Leaveday)
					Select Cast(Left(DATA, 11) AS datetime) As comp_Date, Cast(RIGHT(DATA, LEN(DATA) - 12) AS numeric(18,2)) As LeaveDay
					From dbo.Split(@compOff_Date, '#') T
					
					
					
					SELECT @Comp_Date =comp_Date, @Leaveday= Leaveday FROM #Comp_temp
					
					DECLARE Cursor_date_t cursor for		
							Select Cast(Left(DATA, 11) AS datetime) As comp_Date, Cast(RIGHT(DATA, LEN(DATA) - 12) AS numeric(18,2)) As LeaveDay
							From dbo.Split(@compOff_Date, '#') T
					OPEN Cursor_date_t 					
							Fetch next from Cursor_date_t into @Comp_Date,@Leaveday
											 
					While @@fetch_status = 0                    
						Begin 
			
							SELECT   @Compoff_Credit=Compoff_Credit,
									 @Compoff_Debit=CompOff_Debit,
									 @Compoff_Balance =CompOff_Balance
									 --@Compoff_Used =CompOff_Used 
							FROM T0140_LEAVE_TRANSACTION WHERE Emp_ID=@Emp_id AND For_Date=@Comp_Date AND Leave_ID=@Leave_Id
							
							
							SELECT  @Compoff_Used =CompOff_Used 
							FROM T0140_LEAVE_TRANSACTION WHERE Emp_ID=@Emp_id AND For_Date=@A_From_Date
							
							
							--IF @Day_Type = 'Full Day'
							--Begin
							--	SET @ADD_DAY = 1
							--End
							--ElSE 
							--Begin
							--	SET @ADD_DAY = 0.5
							--End
							
							
							SET @Compoff_Credit = @Compoff_Credit 
							
							SET @Compoff_Debit = @Compoff_Debit + @Leaveday
							
							SET @Compoff_Balance = @Compoff_Credit - @Compoff_Debit
							
							--select @Compoff_Credit,@Compoff_Debit,@Compoff_Balance
							
							
							UPDATE T0140_LEAVE_TRANSACTION
							 SET  --CompOff_Credit = @Compoff_Credit,
								  CompOff_Debit = @Compoff_Debit,
								  CompOff_Balance = @Compoff_Balance
							WHERE For_Date=@Comp_Date AND Leave_ID = @Leave_Id AND Emp_ID=@Emp_ID
							 							
										
							UPDATE T0140_LEAVE_TRANSACTION
							 SET  CompOff_Used = @Compoff_Used + @Leaveday
							WHERE For_Date=@A_From_Date AND Leave_ID = @Leave_Id AND Emp_ID=@Emp_Id
							
							fetch next from Cursor_date_t into @Comp_Date,@Leaveday	
						End
					Close Cursor_date_t                    
					Deallocate Cursor_date_t
		
				--Added By Jaina 30-11-2015 End
					END
					ELSe
					Begin    
						
						SELECT @Emp_Code = emp_code
						FROM   t0080_emp_master
						WHERE  emp_id = @Emp_Id
				        
						SELECT @Leave_negative_Allow = Isnull(leave_negative_allow, 0),
							   @Leave_Paid_Unpaid = leave_paid_unpaid,
							   @Leave_Type = leave_Type
						FROM   t0040_leave_master
						WHERE  leave_id = @Leave_ID
				        
								
						IF @leave_Id > 0
						  BEGIN
								
								 if @Leave_Type = 'ESIC Leave'  -- Added by Gadriwala Muslim 15/09/2015
									begin
											select @Auto_credit_ML = Setting_Value from T0040_SETTING where Cmp_ID = @Cmp_ID 
											and  Setting_Name = 'Auto credit one medical leave when first time ESIC leave have approved in year'
											If @Auto_credit_ML = 1 
												BEGIN
													RAISERROR('@@Medical leave have credited,so ESIC leave cancelled cant deleted@@',16,2)
													  RETURN
												END
									end
							  IF @is_approve = 1
								BEGIN
									SET @From_Date = @A_From_Date
									SET @For_Date = @A_From_Date
									SET @To_Date = @A_From_Date
									SET @Leave_Used_Cur = @Leave_Used
									set @Total_leave_used = @Leave_Used
									set @A_To_Date = @A_From_Date
									
				                  
									IF @Leave_Used > 0.5
									  SET @To_For_Date = Dateadd(d, Floor(@Leave_Used),
														 @for_Date)
														 - 1
									ELSE
									  SET @To_For_Date = Dateadd(d, Floor(@Leave_Used),
														 @for_Date)
				                                         
				                                         

									SET @For_Date= @A_From_Date

									SELECT @Last_Leave_Closing = Isnull(leave_closing, 0)
									FROM   t0140_leave_transaction
									WHERE  for_date = (SELECT MAX(for_date)
													   FROM   t0140_leave_transaction
													   WHERE  for_date < @For_date
															  AND leave_id = @leave_id
															  AND cmp_id = @Cmp_ID
															  AND emp_id = @emp_Id)
										   AND cmp_id = @Cmp_ID
										   AND leave_id = @leave_Id
										   AND emp_id = @emp_Id

									IF @Last_Leave_Closing IS NULL
									  SET @Last_Leave_Closing = 0
				                 
				                    
									WHILE @For_Date <= @A_To_Date
										  AND @Total_leave_used > 0
									  BEGIN
										
										
										  --IF @Total_leave_used = 0.5
										  --  BEGIN
										  --      IF EXISTS(SELECT emp_id
										  --                FROM   t0140_leave_transaction
										  --                WHERE  cmp_id = @Cmp_ID
										  --                       AND leave_id = @leave_Id
										  --                       AND emp_id = @emp_Id
										  --                       AND for_date = @For_date
										  --                       AND leave_used = 0.5)
										  --        BEGIN
										  --            SET @Leave_used = 1
										  --        END
										  --      ELSE
										  --        BEGIN
										  --            SET @Leave_used = 0.5
										  --        END
										  --  END
										  --ELSE
										  --  BEGIN
										  --      SET @Leave_used = 1
										  --      SET @Total_Leave_Used =
										  --      @Total_leave_used - @Leave_Used
										  --  END

										  SELECT @Leave_Tran_ID = Isnull(MAX(leave_tran_id), 0)
																  +
																  1
										  FROM   t0140_leave_transaction

										  --DECLARE @temp_Leave_Used NUMERIC(18, 1)
										  set @temp_Leave_Used = 0.0
										
										  --Added by Hardik 16/12/2011
										  SELECT @Last_Leave_Closing = Isnull(leave_closing, 0)
										  FROM   t0140_leave_transaction
										  WHERE  for_date = (SELECT MAX(for_date)
															 FROM   t0140_leave_transaction
															 WHERE  for_date < @For_date
																	AND leave_id = @leave_id
																	AND cmp_id = @Cmp_ID
																	AND emp_id = @emp_Id)
												 AND cmp_id = @Cmp_ID
												 AND leave_id = @leave_Id
												 AND emp_id = @emp_Id
											
										  IF EXISTS(SELECT for_date
													FROM   t0140_leave_transaction
													WHERE  for_date = @For_date
														   AND leave_id = @leave_Id
														   AND cmp_id = @Cmp_ID
														   AND emp_id = @emp_id)
											BEGIN
												SELECT @temp_Leave_Used = leave_used
												FROM   t0140_leave_transaction
												WHERE  leave_id = @Leave_Id
													   AND for_date = @For_Date
													   AND cmp_id = @Cmp_ID
													   AND emp_id = @emp_Id

				                          
												BEGIN
													
													UPDATE t0140_leave_transaction
													SET
													--Leave_Opening = @Last_Leave_Closing, 
													leave_used = (isnull(leave_used,0) + @Leave_Used), -- changed by mitesh on 10042012
													leave_closing = leave_opening + Isnull(
																	leave_credit,
																					0
																					) 
																	- (@Leave_Used + leave_used)
													WHERE  leave_id = @Leave_Id
														   AND for_date = @For_Date
														   AND cmp_id = @Cmp_ID
														   AND emp_id = @emp_Id

													SET @Last_Leave_Closing =
													(SELECT Isnull(leave_closing, 0)
													 FROM   dbo.t0140_leave_transaction
													 WHERE  leave_id = @Leave_Id
															AND for_date = @For_Date
															AND cmp_id = @Cmp_ID
															AND emp_id = @emp_Id)
												END
											--update T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening - @Leave_Used
											--  ,Leave_Closing = Leave_Closing - @Leave_Used  
											--where Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
											--  and emp_Id = @emp_Id
											END
										  ELSE
											BEGIN
									--select @For_date,@leave_id,@emp_Id      
									IF Isnull(@Last_Leave_Closing, 0) = 0
									   AND @Leave_negative_Allow = 0
									  BEGIN
										  RAISERROR(
										  '@@Leave Balance Negative, Negative Not Allowed@@'
										  ,
										  16,
										  2)

										  RETURN
									  END

									INSERT INTO t0140_leave_transaction
												(emp_id,
												 leave_id,
												 cmp_id,
												 for_date,
												 leave_opening,
												 leave_used,
												 leave_closing,
												 leave_credit,
												 leave_tran_id)
									VALUES     (@emp_id,
												@leave_Id,
												@Cmp_ID,
												@for_Date,
												@last_Leave_Closing,
												@Leave_Used,
												@last_Leave_Closing - @Leave_Used,
												0,
												@Leave_Tran_ID)
											--update T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening - @Leave_Used
											--  ,Leave_Closing = Leave_Closing - @Leave_Used  
											--where Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
											--  and emp_Id = @emp_Id
									  END



										  set @For_date = dateadd(d,1,@For_date)
				                    
									End -- While 
									--      FETCH NEXT FROM curasgnleavedate INTO @For_date
									--  END

									--CLOSE curasgnleavedate

									--DEALLOCATE curasgnleavedate

									--end -- end of If @Leave_Paid_Unpaid
									---Alpesh 26-Sep-2011
									--DECLARE @Chg_Tran_Id NUMERIC
									--DECLARE @For_Date_Cur DATETIME
									--DECLARE @Pre_Closing NUMERIC(18, 2)
									--DECLARE @Leave_Posting NUMERIC(18, 2)
				                    
									 Set @Chg_Tran_Id = 0 
									Set @For_Date_Cur = NULL
									Set @Pre_Closing = 0.0
									Set @Leave_Posting = 0.0

									SET @For_Date= @A_From_Date

									SELECT @Pre_Closing = Isnull(leave_closing, 0)
									FROM   t0140_leave_transaction
									WHERE  for_date = (SELECT MAX(for_date)
													   FROM   t0140_leave_transaction
													   WHERE  for_date <= @For_date
															  AND leave_id = @leave_id
															  AND cmp_id = @Cmp_ID
															  AND emp_id = @emp_Id)
										   AND cmp_id = @Cmp_ID
										   AND leave_id = @leave_Id
										   AND emp_id = @emp_Id

									IF @Pre_Closing IS NULL
									  SET @Pre_Closing = 0

									DECLARE cur1 CURSOR FOR
									  SELECT leave_tran_id,
											 for_date
									  FROM   dbo.t0140_leave_transaction
									  WHERE  leave_id = @leave_Id
											 AND emp_id = @emp_id
											 AND cmp_id = @Cmp_ID
											 AND for_date > @For_date
									  ORDER  BY for_date

									OPEN cur1

									FETCH NEXT FROM cur1 INTO @Chg_Tran_Id, @For_Date_Cur

									WHILE @@FETCH_STATUS = 0
									  BEGIN
										  --select @For_date,@For_Date_Cur
										  --Added by Hardik 16/12/2011
										  IF EXISTS(SELECT leave_op_id
													FROM   t0095_leave_opening
													WHERE  cmp_id = @Cmp_ID
														   AND emp_id = @Emp_Id
														   AND leave_id = @Leave_Id
														   AND for_date = @For_Date_Cur
														   AND leave_op_days > 0)
											BEGIN
												GOTO E;
											END

										  SELECT @Leave_Posting = Isnull(leave_posting, 0)
										  FROM   dbo.t0140_leave_transaction
										  WHERE  leave_tran_id = @Chg_Tran_Id

										  --if @Leave_Posting <> 0
										  --  begin
										  --    update dbo.T0140_LEAVE_TRANSACTION set 
										  --       Leave_Opening = @Pre_Closing,
										  --       Leave_Closing = @Pre_Closing + Leave_Credit - Leave_Used, 
										  --       Leave_Posting = @Pre_Closing + Leave_Credit - Leave_Used                   
										  --    where leave_tran_id = @Chg_Tran_Id
										  --    --break
										  --  end
										  --else                    
										  BEGIN
											  --commented by hardik 16/12/2011                      
											  --                      If Not exists (select 1 from dbo.T0140_LEAVE_TRANSACTION where Leave_Posting <> 0 and leave_id = @leave_Id and emp_Id = @emp_Id And For_Date = 
											  --                          (Select MAX(For_Date) From dbo.T0140_LEAVE_TRANSACTION Where For_Date < @For_Date_Cur and leave_id = @leave_Id and emp_Id = @emp_Id ))
											  BEGIN
												  UPDATE dbo.t0140_leave_transaction
												  SET    leave_opening = @Pre_Closing,
														 leave_closing = @Pre_Closing + Isnull(
																		 leave_credit, 0
																						)
																		 - Isnull(
																		 leave_used, 0)
												  WHERE  leave_tran_id = @Chg_Tran_Id

												  E:

												  SET @Pre_Closing = Isnull(
												  (SELECT Isnull(leave_closing, 0)
												   FROM   dbo.t0140_leave_transaction
												   WHERE  leave_tran_id = @Chg_Tran_Id
												  ), 0
																	 )
											  END
				                         
										  END

										  FETCH NEXT FROM cur1 INTO @Chg_Tran_Id, @For_Date_Cur
									  END

									CLOSE cur1

									DEALLOCATE cur1

									--- End 
									--SELECT * from T0140_LEAVE_TRANSACTION where Emp_ID =@emp_ID and Leave_ID =@Leave_ID and For_Date >=@A_To_date and Leave_Closing < 0
									IF @Leave_negative_Allow = 0
									  BEGIN
										
										  IF EXISTS(SELECT emp_id
													FROM   t0140_leave_transaction
													WHERE  emp_id = @emp_ID
														   AND leave_id = @Leave_ID
														   AND for_date >= @A_To_date
														   AND leave_closing < 0)
										  BEGIN
									IF @Is_Import = 1
									  BEGIN
										  INSERT INTO dbo.t0080_import_log
										  VALUES      (0,
													   @Cmp_Id,
													   @Emp_Code,
										  'Leave Balance Negative Not Allowed',
										  NULL,
										  'Insufficient Balance to approve the leave'
										  ,
										  Getdate(),
										  'Leave Approval'
										  ,'')
									  END
									ELSE
									  BEGIN
										  RAISERROR(
										  '@@Leave Balance Negative, Negative Not Allowed@@'
										  ,
										  16,
										  2)

										  RETURN
									  END
								END
									  END
								END
								END -- Approval Flag
				         
						  END
					END
				
   


