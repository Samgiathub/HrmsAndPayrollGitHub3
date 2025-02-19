CREATE TABLE [dbo].[T0130_LEAVE_APPROVAL_DETAIL] (
    [Leave_Approval_ID]   NUMERIC (18)    NOT NULL,
    [Cmp_ID]              NUMERIC (18)    NOT NULL,
    [Leave_ID]            NUMERIC (18)    NOT NULL,
    [From_Date]           DATETIME        NOT NULL,
    [To_Date]             DATETIME        NOT NULL,
    [Leave_Period]        NUMERIC (18, 2) NOT NULL,
    [Leave_Assign_As]     VARCHAR (15)    NOT NULL,
    [Leave_Reason]        NVARCHAR (MAX)  NULL,
    [Row_ID]              NUMERIC (18)    NOT NULL,
    [Login_ID]            NUMERIC (18)    NOT NULL,
    [System_Date]         DATETIME        NOT NULL,
    [Is_Import]           INT             NULL,
    [M_Cancel_WO_HO]      TINYINT         CONSTRAINT [DF_T0130_LEAVE_APPROVAL_DETAIL_M_Cancel_WO_HO] DEFAULT ((0)) NOT NULL,
    [Half_Leave_Date]     DATETIME        NULL,
    [Leave_out_time]      DATETIME        NULL,
    [Leave_In_Time]       DATETIME        NULL,
    [NightHalt]           NUMERIC (18)    CONSTRAINT [DF_T0130_LEAVE_APPROVAL_DETAIL_NightHalt] DEFAULT ((0)) NOT NULL,
    [Leave_CompOff_Dates] VARCHAR (MAX)   NULL,
    [Half_Payment]        TINYINT         CONSTRAINT [DF_T0130_LEAVE_APPROVAL_DETAIL_Half_Payment] DEFAULT ((0)) NOT NULL,
    [Warning_Flag]        TINYINT         CONSTRAINT [DF_T0130_LEAVE_APPROVAL_DETAIL_Warning_Flag] DEFAULT ((0)) NOT NULL,
    [Rules_violate]       TINYINT         CONSTRAINT [DF_T0130_LEAVE_APPROVAL_DETAIL_Rules_violate] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [FK_T0130_LEAVE_APPROVAL_DETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0130_LEAVE_APPROVAL_DETAIL_T0040_LEAVE_MASTER] FOREIGN KEY ([Leave_ID]) REFERENCES [dbo].[T0040_LEAVE_MASTER] ([Leave_ID]),
    CONSTRAINT [FK_T0130_LEAVE_APPROVAL_DETAIL_T0120_LEAVE_APPROVAL] FOREIGN KEY ([Leave_Approval_ID]) REFERENCES [dbo].[T0120_LEAVE_APPROVAL] ([Leave_Approval_ID])
);


GO
CREATE NONCLUSTERED INDEX [T0130_Leave_Approval_Detail_New]
    ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]([Leave_Approval_ID] ASC, [Cmp_ID] ASC, [Leave_ID] ASC, [From_Date] ASC, [To_Date] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0130_LEAVE_APPROVAL_DETAIL_26_946102411__K2_K1]
    ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]([Cmp_ID] ASC, [Leave_Approval_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0130_LEAVE_APPROVAL_DETAIL_26_946102411__K1_K2_K4_K5_K6]
    ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]([Leave_Approval_ID] ASC, [Cmp_ID] ASC, [From_Date] ASC, [To_Date] ASC, [Leave_Period] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [ix_T0130_LEAVE_APPROVAL_DETAIL_From_Date_To_Date]
    ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]([From_Date] ASC, [To_Date] ASC)
    INCLUDE([Leave_Approval_ID], [Leave_Assign_As]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_T0130_LEAVE_APPROVAL_DETAIL_For_P0200_Pre_Salary]
    ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]([Leave_ID] ASC)
    INCLUDE([Leave_Approval_ID], [From_Date], [To_Date]);


GO
CREATE STATISTICS [_dta_stat_946102411_2_1_4_5_6]
    ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]([Cmp_ID], [Leave_Approval_ID], [From_Date], [To_Date], [Leave_Period]);


GO
CREATE STATISTICS [_dta_stat_946102411_4_5_6_2]
    ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]([From_Date], [To_Date], [Leave_Period], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_946102411_1_4_5]
    ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]([Leave_Approval_ID], [From_Date], [To_Date]);


GO
CREATE STATISTICS [_dta_stat_1493580359_4_5_1]
    ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]([From_Date], [To_Date], [Leave_Approval_ID]);


GO
CREATE STATISTICS [_dta_stat_1493580359_5_1]
    ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]([To_Date], [Leave_Approval_ID]);


GO
CREATE STATISTICS [_dta_stat_1493580359_13_1]
    ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]([M_Cancel_WO_HO], [Leave_Approval_ID]);


GO
CREATE STATISTICS [_dta_stat_1493580359_1_3_4]
    ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]([Leave_Approval_ID], [Leave_ID], [From_Date]);


GO
CREATE STATISTICS [_dta_stat_1493580359_1_4_5_3]
    ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]([Leave_Approval_ID], [From_Date], [To_Date], [Leave_ID]);


GO




CREATE TRIGGER [DBO].[Tri_T0130_LEAVE_APPROVAL_DETAIL_Update]
ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]
FOR  UPDATE

AS

SET NOCOUNT ON

---Commented by Hardik on 28/09/2011 because flow change for leave... On update it will delete leave and again insert new entry for Approval Detail.. So update trigger dont required now...

/*
declare @Cmp_ID as numeric
declare @For_Date as datetime
declare @Emp_Id as numeric
declare @Count as numeric

declare @Leave_Approval_Id as numeric
declare @Leave_Id as numeric
declare @Leave_Used as numeric(18,1)

declare @Code as varchar(50)
declare @Last_Leave_Closing as numeric(18,1)

declare @From_Date as datetime
declare @To_Date as datetime
declare @ErrString as varchar(200)
declare @varFromDate as varchar(11)

declare @To_For_Date as datetime
Declare @Leave_Tran_ID as numeric
Declare @Approval_Status as varchar(1)
Declare @Total_Leave_used as numeric(18,2)
Declare @A_From_Date as datetime
Declare @A_To_Date as datetime
Declare @Leave_negative_Allow	tinyint

Declare @IS_Import int
Declare @Emp_Code numeric(18,0)

set @Total_Leave_used = 0
set @Leave_negative_Allow = 0


	select  @Cmp_ID = Cmp_ID,  @Emp_Id = emp_Id ,@Approval_Status = Approval_Status
			from T0120_LEAVE_APPROVAL where leave_approval_Id in (select Distinct leave_approval_id  from deleted)
	

	Select @Emp_Code from T0080_Emp_MAster 	where emp_id = @Emp_Id
	
			if @Approval_Status ='R' -- when approval then reject 
				begin

					declare curDel cursor for
						select Leave_approval_id ,leave_Id,Leave_Period,From_Date,To_Date from deleted 
					open curDel
					fetch next from curDel into @Leave_Approval_Id,@Leave_Id , @Total_Leave_Used,@A_From_Date,@A_To_Date
					while @@fetch_status = 0
					begin 
							begin
									set @For_Date= @A_From_Date
									while @For_Date <=@A_To_Date and @Total_leave_used > 0
										Begin
												if @Total_leave_used = 0.5
													set @Leave_used =0.5
												else
													begin
														set @Leave_used = 1
														set @Total_Leave_Used = @Total_leave_used - @Leave_Used										
													end
													
														update T0140_LEAVE_TRANSACTION set Leave_Used = Leave_Used - @Leave_Used 
														--update T0140_LEAVE_TRANSACTION set Leave_Used = @Leave_Used 
															,Leave_Closing = Leave_Closing + @Leave_Used
														where leave_id = @leave_Id and emp_id = @emp_id and for_date = @for_date 
														and Cmp_ID = @Cmp_ID	
																
														update T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening + @Leave_Used
															,Leave_Closing = Leave_Closing + @Leave_Used
														where leave_id = @leave_Id and emp_id = @emp_id and for_date > @for_date 
														and Cmp_ID = @Cmp_ID	
													
												set @For_date = dateadd(d,1,@For_date)
										End
							end			
						fetch next from curDel into @Leave_Approval_Id,@Leave_Id , @Total_Leave_Used,@A_From_Date,@A_To_Date
					end 	
					close curDel
					deallocate curDel

				end
				
 		select  @Cmp_ID = Cmp_ID,  @Emp_Id = emp_Id	 ,@Approval_Status = Approval_Status 
 		From T0120_LEAVE_APPROVAL where leave_approval_Id = 
 		(select ins.leave_approval_id from inserted ins)
		

		select @Leave_Approval_Id = ins.leave_approval_id, @Leave_Id = ins.Leave_Id, @For_Date = From_Date	
		,@Leave_Used = ins.Leave_Period ,@Total_Leave_used = ins.Leave_Period  	
		,@A_From_Date = From_Date ,@A_To_date = To_Date
		From inserted ins	

		select @Leave_negative_Allow = isnull(Leave_negative_Allow,0) From T0040_leave_master where Leave_ID =@Leave_ID
		
		If @leave_Id > 0  
			begin
			
				if  @Approval_Status ='A' 
					Begin
						declare curAsgnLeave cursor for
										select from_date,to_date from T0120_LEAVE_APPROVAL LA INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON
												LA.LEAVE_APPROVAL_ID = LAD.LEAVE_APPROVAL_ID
											where LA.Cmp_ID = @Cmp_ID and emp_id = @emp_Id  and LAD.Leave_Approval_Id <> @Leave_Approval_Id And Approval_Status<>'R'
									open curAsgnLeave	
									fetch next from curAsgnLeave into @From_Date,@To_Date
										while @@fetch_status = 0
											begin
												--set @To_For_Date = dateadd(d,floor(@Leave_Used),@for_Date)
												if @Leave_Used > 0.5 
													set @To_For_Date = dateadd(d,floor(@Leave_Used),@for_Date) -1
												else
													set @To_For_Date = dateadd(d,floor(@Leave_Used),@for_Date)
																				
												if @for_Date >= @From_Date and @For_Date <= @To_Date
													begin
														--if @Is_import = 1
														--begin
														--	Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Emp_Code,'Leave Already Assign for given Date',NULL,'Enter proper Leave Period',GetDate(),'Leave Approval')
														--end
														--else
														begin
														
															set @varFromDate = cast( @for_date as varchar(11))
															close curAsgnLeave
															deallocate curAsgnLeave
															Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Emp_Code,'Leave Already Assign for given Date',NULL,'Enter proper Leave Period',GetDate(),'Leave Approval')
															set @ErrString = '@@Leave Date already assign - ' + @varFromDate + '@@'
															RAISERROR (@ErrString, 16, 2) 
															return
														end
													end
												
												if @To_For_Date >= @To_Date and @To_For_Date <= @To_Date
													begin
														--if @is_import =1
														--begin
														--	Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Emp_Code,'Leave Already Assign for given Date',NULL,'Enter proper Leave Period',GetDate(),'Leave Approval')
														--end
														--else
														begin
														
															set @varFromDate = cast( @To_For_Date as varchar(11))
															close curAsgnLeave
															deallocate curAsgnLeave
															Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Emp_Code,'Leave Already Assign for given Date',NULL,'Enter proper Leave Period',GetDate(),'Leave Approval')
															set @ErrString = '@@Leave Date already assign - ' + @varFromDate  + '@@'
															RAISERROR (@ErrString, 16, 2) 
															return
														end
													end
													
												fetch next from curAsgnLeave into @From_Date,@To_Date	
											end
									close curAsgnLeave
									deallocate curAsgnLeave
														
						set @For_Date= @A_From_Date
						while @For_Date <=@A_To_Date and @Total_leave_used > 0
							Begin
								if @Total_leave_used = 0.5
									set @Leave_used =0.5
								else
									begin
										set @Leave_used = 1
										set @Total_Leave_Used = @Total_leave_used - @Leave_Used										
									end
								
								select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) +1 From T0140_LEAVE_TRANSACTION
								
								if exists(select * from T0140_LEAVE_TRANSACTION where For_date = @For_date and leave_Id = @leave_Id  
										and Cmp_ID = @Cmp_ID and emp_id = @emp_id)
										begin
											update T0140_LEAVE_TRANSACTION set Leave_Used = Leave_Used + @Leave_Used
											--update T0140_LEAVE_TRANSACTION set Leave_Used =  @Leave_Used
												,Leave_Closing = Leave_Closing - @Leave_Used	
											where Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
												and emp_Id = @emp_Id

											update T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening - @Leave_Used
												,Leave_Closing = Leave_Closing - @Leave_Used	
											where Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
												and emp_Id = @emp_Id
										end
									else
										begin	
	    									select @Last_Leave_Closing = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION
	    										where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION 
	    												where for_date < @For_date
	    											and leave_Id = @leave_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id) 
	    											and Cmp_ID = @Cmp_ID
	    											and leave_id = @leave_Id and emp_Id = @emp_Id
							
											if @Last_Leave_Closing is null 
												set  @Last_Leave_Closing = 0

											insert T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,
												Leave_Closing,Leave_Credit,Leave_Tran_ID)
											values(@emp_id,@leave_Id,@Cmp_ID,@for_Date,@last_Leave_Closing,@Leave_Used
												,@last_Leave_Closing - @Leave_Used,0,@Leave_Tran_ID)												    		

											update T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening - @Leave_Used
												,Leave_Closing = Leave_Closing - @Leave_Used	
											where Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
												and emp_Id = @emp_Id
										
										end
									set @For_date = dateadd(d,1,@For_date)
								End -- While 
								
								if @Leave_negative_Allow = 0 
									begin
										if Exists(select emp_ID from T0140_LEAVE_TRANSACTION where Emp_ID =@emp_ID and Leave_ID =@Leave_ID and For_Date >=@A_To_date and Leave_Closing < 0)
											begin
											
												if @Is_import = 1
												begin
													Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Emp_Code,'Leave Balance Negative Not Allowed',NULL,'Insufficient Balance to approve the leave',GetDate(),'Leave Approval')
												end
												else
												begin
												
													Raiserror('@@Leave Balance Negative, Negative Not Allowed@@',16,2)
													return 
												end
											end
									end
																	
						End -- Approval Flag
						
	End
		*/





GO
  
  
CREATE TRIGGER [DBO].[Tri_T0130_LEAVE_APPROVAL_DETAIL_BAckup_Compoff_07122023]    
ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]    
FOR  INSERT,  DELETE     
AS    
    
 SET NOCOUNT ON  
    
 DECLARE @Cmp_ID as numeric    
 DECLARE @For_Date AS DATETIME    
 DECLARE @Emp_Id as numeric    
 DECLARE @Count as numeric    
 DECLARE @Leave_Approval_Id as numeric    
 DECLARE @Leave_Id as numeric    
 DECLARE @Leave_Used as numeric(18,2)    
 DECLARE @Leave_Asign_As as varchar(20) --hardik 24/06/2011    
 DECLARE @Leave_Asign_As_Cur as varchar(20) --hardik 24/06/2011    
 DECLARE @Leave_Used_Cur as numeric(18,2) --hardik 24/06/2011    
 DECLARE @Code as varchar(50)    
 DECLARE @Last_Leave_Closing as numeric(18,2)    
 DECLARE @From_Date AS DATETIME    
 DECLARE @To_Date AS DATETIME    
 DECLARE @ErrString as varchar(200)    
 DECLARE @varFromDate as varchar(11)     
 DECLARE @To_For_Date AS DATETIME    
 DECLARE @Leave_Tran_ID as numeric    
 DECLARE @Approval_Status as varchar(1)    
 DECLARE @Total_Leave_used as numeric(18,2)    
 DECLARE @A_From_Date AS DATETIME    
 DECLARE @A_To_Date AS DATETIME    
 DECLARE @Leave_negative_Allow tinyint    
 DECLARE @IS_Import int    
 DECLARE @Emp_Code numeric(18,0)    
 DECLARE @Leave_Paid_Unpaid varchar(1)    
 DECLARE @M_Cancel_WO_HO tinyint    
 DECLARE @Half_Leave_Date datetime     
 DECLARE @Apply_Hourly as numeric  
  
 DECLARE @Half_Payment as tinyint  
 DECLARE @Half_Payment_Days as Numeric(18,8)  
  
 SET @Apply_Hourly = 0  
 SET @M_Cancel_WO_HO = 0    
 SET @Total_Leave_used = 0    
 SET @Leave_negative_Allow =0    
  
 SET @Half_Payment = 0  
 SET @Half_Payment_Days = 0  
  
 DECLARE @Back_Dated_Leave as numeric(18,2)  
 DECLARE @is_backdated_application as numeric  
 DECLARE @Leave_Approval_Id_temp as numeric  
 SET @Back_Dated_Leave = 0  
 -- Added by Gadriwala Muslim  02102014 - Start  
 DECLARE @Leave_CompOFf_Dates varchar(max)  
 SET @Leave_CompOFf_Dates = ''  
 CREATE TABLE #Leave_CompOff_Approved  
 (  
  Leave_Date datetime,  
  Leave_Period numeric(18,2)  
 )  
 -- Added by Gadriwala Muslim 02102014 - End   
    
 CREATE TABLE #Leave_date    
 (     
  for_date datetime    
 )    
   
 DECLARE @Chg_Tran_Id numeric      
 DECLARE @For_Date_Cur Datetime    
 DECLARE @Pre_Closing numeric(18,2)    
 DECLARE @Leave_Posting numeric(18,2)    
 DECLARE @Leave_Short_Name varchar(25)  
 SET @Leave_Short_Name = ''  
    
 DECLARE @Leave_Type varchar(25)  -- Added by Gadriwala Muslim 15092015  
 SET @Leave_Type = '' -- Added by Gadriwala Muslim 15092015  
 DECLARE @Year_Start_Date datetime  
 DECLARE @Year_End_Date datetime  
 DECLARE @Medical_Leave_ID numeric(18,0)  
 DECLARE @ML_Trans_ID numeric(18,0)   
 DECLARE @Medical_Last_Closing numeric(18,2)  
 DECLARE @Leave_Approval_Date datetime  
 DECLARE @Auto_credit_ML numeric(18,0)  
 DECLARE @cur_ML_tran_ID numeric(18,0)  
 DECLARE @Cur_ML_For_Date datetime  
 DECLARE @Medical_Posting numeric(18,2)  
 IF  UPDATE (Leave_Approval_Id)     
  BEGIN      
   SELECT  @Cmp_ID = LA.Cmp_ID,  @Emp_Id = emp_Id  ,@Approval_Status = Approval_Status   ,@Leave_Approval_Date = Approval_Date  
   From T0120_LEAVE_APPROVAL LA  
     INNER JOIN inserted I ON la.Leave_Approval_ID=I.Leave_Approval_ID  
     
      
     
   SELECT @Emp_Code = Emp_Code   
   FROM T0080_Emp_Master   
   WHERE Emp_ID = @Emp_Id    
    
   SELECT @Leave_Approval_Id = ins.leave_approval_id, @Leave_Id = ins.Leave_Id, @For_Date = From_Date,  
     @Leave_Used = ins.Leave_Period ,@Leave_Asign_As = ins.Leave_Assign_As, @Total_Leave_used = ins.Leave_Period,  
     @A_From_Date = From_Date ,@A_To_date = To_Date, @Is_Import = Is_Import , @M_Cancel_WO_HO = M_Cancel_WO_HO,  
     @Half_Leave_Date = ins.Half_Leave_Date,@Leave_CompOFf_Dates = Leave_CompOFf_Dates,@Half_Payment=Half_Payment    
   FROM inserted ins     
        
      SELECT @Leave_negative_Allow = IsNull(Leave_negative_Allow,0), @Leave_Paid_Unpaid = Leave_Paid_Unpaid, @Apply_Hourly = Apply_Hourly,@Leave_Type = Leave_Type  
      From T0040_LEAVE_MASTER   
   WHERE Leave_ID =@Leave_ID    
      
   IF @Is_Import = 2 --Added By Nimesh on 06-12-2017 (If Leave is created FROM Attendance Import then Cancel Holiday Policy should be considered)  
    SET @M_Cancel_WO_HO  =1  
  
   SET @is_backdated_application = 0  
      
   --''Ankit - 27122014  
   --IF EXISTS(SELECT * FROM T0120_LEAVE_APPROVAL WHERE Leave_Approval_ID = @Leave_Approval_Id AND Leave_Application_ID IS NULL   
   --       AND Emp_ID = @Emp_Id AND Leave_Approval_ID IN (SELECT Leave_Approval_ID FROM T0130_LEAVE_APPROVAL_DETAIL WHERE Leave_Approval_ID = @Leave_Approval_Id)  
   --    )  
   -- BEGIN  
     SELECT @is_backdated_application = IsNull(Is_Backdated_App,0)   
     FROM T0120_LEAVE_APPROVAL   
     WHERE Leave_Approval_ID = @Leave_Approval_Id   
       AND Emp_ID = @Emp_Id   
       --AND Leave_Application_ID IS NULL   
       --AND Leave_Approval_ID IN (SELECT Leave_Approval_ID FROM T0130_LEAVE_APPROVAL_DETAIL WHERE Leave_Approval_ID = @Leave_Approval_Id)  
   -- END  
   --ELSE  
   -- BEGIN  
   --   SELECT @is_backdated_application = IsNull(is_backdated_application,0) FROM T0100_LEAVE_APPLICATION WHERE Leave_Application_ID  
   --   in (SELECT Leave_Application_ID FROM T0120_LEAVE_APPROVAL WHERE Emp_ID = @Emp_Id AND Leave_Approval_ID in (  
   --    SELECT Leave_Approval_ID FROM T0130_LEAVE_APPROVAL_DETAIL WHERE Leave_Approval_ID = @Leave_Approval_Id))  
   -- END    
      
   --''Ankit - 27122014   
     
    --SELECT @is_backdated_application = IsNull(is_backdated_application,0) FROM T0100_LEAVE_APPLICATION WHERE Leave_Application_ID  
    --in (SELECT Leave_Application_ID FROM T0120_LEAVE_APPROVAL WHERE Emp_ID = @Emp_Id AND Leave_Approval_ID in (  
    -- SELECT Leave_Approval_ID FROM T0130_LEAVE_APPROVAL_DETAIL WHERE Leave_Approval_ID = @Leave_Approval_Id))  
      
   SELECT @Leave_Short_Name =  IsNull(Default_Short_Name,'') FROM T0040_LEAVE_MASTER WHERE Leave_ID = @Leave_Id AND Cmp_ID = @Cmp_ID  --Changed by Gadriwala Muslim 02102014  
      
   --IF @Leave_Short_Name = 'COMP'   
   IF (@Leave_Short_Name = 'COMP' or @Leave_Short_Name = 'COPH' or @Leave_Short_Name = 'COND')  
    BEGIN  
     EXEC SP_Tri_T0130_LEAVE_APPROVAL_DETAIL_For_CompOff_Leave @Cmp_ID,@Emp_Id,@Emp_Code,@Leave_Approval_Id,@Approval_Status,@Leave_Id,@For_Date,@Leave_Used,@Leave_Asign_As,@Total_Leave_used,@A_From_Date,@A_To_date,@Is_Import,@M_Cancel_WO_HO,@Half_Leave_Date,@Leave_negative_Allow,@Leave_Paid_Unpaid,@Apply_Hourly,@is_backdated_application,@Leave_CompOFf_Dates,@Leave_Short_Name  
    END  
   ELSE  
    BEGIN  
     IF @Half_Payment = 1  
      SET @Half_Payment_Days = @Leave_Used  
         
     EXEC SP_Tri_T0130_LEAVE_APPROVAL_DETAIL_For_Regular_Leave @Cmp_ID,@Emp_Id,@Emp_Code,@Leave_Approval_Id,@Approval_Status,@Leave_Id,@For_Date,@Leave_Used,@Leave_Asign_As,@Total_Leave_used,@A_From_Date,@A_To_date,@Is_Import,@M_Cancel_WO_HO,@Half_Leave_Date,@Leave_negative_Allow,@Leave_Paid_Unpaid,@Apply_Hourly,@is_backdated_application,@Half_Payment  
         
     return       
     IF @Leave_Type = 'ESIC Leave' AND @Approval_Status ='A'   -- Added by Gadriwala Muslim 15/09/2015  
      AND EXISTS(SELECT 1 FROM T0040_SETTING   
         WHERE Cmp_ID = @Cmp_ID AND  Setting_Name = 'Auto credit one medical leave when first time ESIC leave have approved in year'  
           AND Setting_Value=1)  
      BEGIN  
       SET @Medical_Leave_ID = 0  
       SET @Auto_credit_ML = 0  
       SET @Medical_Last_Closing = 0  
       SET @Year_Start_Date = dbo.GET_MONTH_ST_DATE(month(@A_From_Date),Year(@A_From_Date))  
       SET @Year_End_Date = dbo.GET_MONTH_END_DATE(month(@A_From_Date),Year(@A_From_date))  
              
       SELECT @Medical_Leave_ID = Leave_ID FROM T0040_LEAVE_MASTER   
       WHERE cmp_ID = @cmp_ID AND Medical_Leave = 1  
              
       IF NOT EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION LT   
            LEFT OUTER JOIN (SELECT For_date,LT.Leave_ID,emp_id   
                FROM T0140_LEAVE_TRANSACTION LT   
                  INNER JOIN T0040_LEAVE_MASTER LM  on LT.Leave_ID = LM.Leave_ID    
                WHERE LT.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id  AND LT.For_Date >= @A_From_Date   
                  AND LT.For_Date <= @A_To_Date AND leave_used > 0 AND Leave_Type = 'ESIC Leave'  
                ) Qry ON Qry.For_Date = LT.For_Date AND Qry.Leave_ID = LT.Leave_ID AND Qry.emp_id = LT.emp_id    
            INNER JOIN T0040_LEAVE_MASTER LM  ON LT.Leave_ID = LM.Leave_ID   
           where LT.For_Date >= @Year_Start_Date AND LT.For_Date <= @Year_End_Date   
            AND LT.Cmp_ID = @Cmp_ID AND LT.Emp_ID = @Emp_Id AND Leave_Used >0   
            AND Leave_Type = 'ESIC Leave' AND IsNull(Qry.emp_id,0) = 0  
          )  
        BEGIN  
         IF  EXISTS( SELECT 1 FROM T0140_LEAVE_TRANSACTION WHERE Leave_ID = @Medical_Leave_ID  AND For_Date = @Leave_Approval_Date AND Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID)        
          BEGIN  
           SELECT @ML_Trans_ID = Leave_Tran_ID   
           FROM T0140_LEAVE_TRANSACTION   
           WHERE Leave_ID = @Medical_Leave_ID  AND For_Date = @Leave_Approval_Date AND Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID  
                       
           UPDATE T0140_LEAVE_TRANSACTION   
           SET  Leave_Credit = Leave_Credit + 1, Leave_Closing = (Leave_Opening + Leave_Credit + 1 ) - Leave_Used  
           WHERE Leave_Tran_ID = @ML_Trans_ID AND Cmp_ID = @Cmp_ID  
          END  
         ELSE  
          BEGIN  
           SELECT @ML_Trans_ID = IsNull(MAX(Leave_Tran_ID),0) + 1   
           FROM T0140_LEAVE_TRANSACTION   
                     
           SELECT @Medical_Last_Closing = IsNull(Leave_Closing,0)   
           FROM T0140_LEAVE_TRANSACTION    
           WHERE For_Date = (SELECT MAX(for_date)   
                FROM T0140_LEAVE_TRANSACTION   
                WHERE for_date <= @Leave_Approval_Date AND leave_Id = @Medical_Leave_ID   
                  AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id  
                )     
             AND Cmp_ID = @Cmp_ID    
             AND leave_id = @Medical_Leave_ID AND emp_Id = @emp_Id    
                     
           INSERT INTO T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Credit,Leave_Used,Leave_Closing,Leave_Tran_ID)    
           VALUES(@emp_id,@Medical_Leave_ID,@Cmp_ID,@Leave_Approval_Date,@Medical_Last_Closing,1,0, @Medical_Last_Closing + 1 ,@ML_Trans_ID)    
          END  
                 
         SELECT @Medical_Last_Closing = IsNull(Leave_Closing,0)   
         FROM T0140_LEAVE_TRANSACTION    
         WHERE For_Date = (SELECT MAX(for_date)   
              FROM T0140_LEAVE_TRANSACTION   
              WHERE For_Date <= @Leave_Approval_Date AND leave_Id = @Medical_Leave_ID   
                AND Cmp_ID = @Cmp_ID AND Emp_ID = @emp_Id  
              )     
           AND Cmp_ID = @Cmp_ID    
           AND leave_id = @Medical_Leave_ID AND emp_Id = @emp_Id    
                             
           IF @Medical_Last_Closing IS NULL    
          SET @Medical_Last_Closing = 0            
                  
         DECLARE curMedicalLeave CURSOR FOR     
         SELECT leave_tran_id,For_Date   
         FROM dbo.T0140_LEAVE_TRANSACTION   
         WHERE leave_id = @Medical_Leave_ID AND emp_id = @emp_id     
           AND Cmp_ID = @Cmp_ID AND for_date > @Leave_Approval_Date   
         ORDER BY for_date    
                   
         OPEN curMedicalLeave   
         FETCH NEXT FROM curMedicalLeave INTO @cur_ML_tran_ID,@Cur_ML_For_Date    
                 
         WHILE @@FETCH_STATUS = 0    
          BEGIN    
           IF EXISTS(SELECT Leave_Op_Id FROM T0095_LEAVE_OPENING   
              WHERE Cmp_ID = @Cmp_ID AND Emp_Id = @Emp_Id AND Leave_ID = @Medical_Leave_ID   
                AND For_Date = @Cur_ML_For_Date AND Leave_Op_Days > 0)   
            Or @Medical_Posting IS NOT NULL   
            BEGIN  
             Goto Medical1;    
            End    
                         
           SELECT @Medical_Posting = Leave_Posting   
           FROM dbo.T0140_LEAVE_TRANSACTION   
           WHERE leave_tran_id = @cur_ML_tran_ID   
                     
           BEGIN    
            UPDATE dbo.T0140_LEAVE_TRANSACTION   
            SET  Leave_Opening = @Medical_Last_Closing,  
              Leave_Closing = @Medical_Last_Closing + IsNull(Leave_Credit,0) - IsNull(Leave_Used,0) - IsNull(Leave_Encash_Days,0) - IsNull(Back_Dated_Leave,0) - IsNull(Half_Payment_Days,0)  
            WHERE leave_tran_id = @cur_ML_tran_ID    
                     
            Medical1:       
             SET @Medical_Last_Closing = IsNull((SELECT IsNull(Leave_Closing,0) FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @cur_ML_tran_ID),0)    
           END    
                  
           FETCH NEXT FROM curMedicalLeave INTO @cur_ML_tran_ID,@Cur_ML_For_Date    
          END    
         CLOSE curMedicalLeave    
         DEALLOCATE curMedicalLeave          
        END  
      END  
    END  
  END    
 ELSE    
  BEGIN      
   SELECT @Cmp_ID = LA.Cmp_ID,  @Emp_Id = emp_Id ,@Approval_Status = Approval_Status , @M_Cancel_WO_HO = LA.M_Cancel_WO_HO,  
     @Leave_Approval_Id_temp = LA.Leave_Approval_ID, @Leave_Approval_Date = Approval_Date   
   FROM T0120_LEAVE_APPROVAL LA  
     INNER JOIN deleted D ON LA.Leave_Approval_ID=D.Leave_Approval_ID  
       
     
   SELECT @leave_id = leave_id,@Is_Import=Is_Import FROM deleted   
  
   IF @Is_Import = 2 --Added By Nimesh on 06-12-2017 (If Leave is created FROM Attendance Import then Cancel Holiday Policy should be considered)  
    SET @M_Cancel_WO_HO  =1  
   
   SELECT @Leave_Short_Name =  IsNull(Default_Short_Name,''),@Leave_Type = Leave_Type   
   FROM T0040_LEAVE_MASTER   
   WHERE Leave_ID = @Leave_Id AND Cmp_ID = @Cmp_ID      
    
   SELECT @Apply_Hourly = Apply_hourly   
   FROM T0040_LEAVE_MASTER   
   WHERE Leave_ID = @Leave_Id   
    
   -- Added by Ali 25042014 -- Start    
   SET @is_backdated_application = 0  
         
   SELECT @is_backdated_application = IsNull(Is_Backdated_App,0)   
   FROM T0120_LEAVE_APPROVAL   
   WHERE Leave_Approval_ID = @Leave_Approval_Id_temp   
     AND Emp_ID = @Emp_Id   
   ---- Ankit 27122014 --  
   --IF EXISTS(SELECT IS_Backdated_App FROM T0120_LEAVE_APPROVAL WHERE Leave_Application_ID IS NULL AND Leave_Approval_ID = @Leave_Approval_Id_temp)  
   -- BEGIN  
   --  SELECT @is_backdated_application = IS_Backdated_App   
   --  FROM T0120_LEAVE_APPROVAL   
   --  WHERE Leave_Application_ID IS NULL AND Leave_Approval_ID = @Leave_Approval_Id_temp  
   -- END  
   --ELSE  
   -- BEGIN  
   --  SELECT @is_backdated_application =  ISNULL(LA.Is_Backdated_App,is_backdated_application)   
   --  FROM T0100_LEAVE_APPLICATION LAP  
   --    INNER JOIN T0120_LEAVE_APPROVAL LA ON LAP.Leave_Application_ID=LA.Leave_Application_ID  
   --  WHERE Leave_Approval_ID = @Leave_Approval_Id_temp AND LA.Emp_ID=@Emp_Id       
   -- END   
   IF @Leave_Short_Name IN ('COMP', 'COND','COPH') AND @Approval_Status ='A'    
    BEGIN     
     DECLARE curDel CURSOR FOR    
     SELECT Leave_approval_id ,leave_Id,Leave_Period,From_Date,To_Date,Half_Leave_Date FROM deleted     
       
     OPEN curDel    
     FETCH NEXT FROM curDel INTO @Leave_Approval_Id,@Leave_Id , @Total_Leave_Used,@A_From_Date,@A_To_Date,@Half_Leave_Date    
     WHILE @@FETCH_STATUS = 0    
      BEGIN    
       SET @For_Date= @A_From_Date    
         
       INSERT INTO #Leave_date (for_date)    
       EXEC Calculate_Leave_End_Date @Cmp_ID,@Emp_Id,@Leave_Id,@For_Date,@Total_Leave_used,'O',@M_Cancel_WO_HO    
             
       DECLARE curAsgnLeaveDate CURSOR FOR    
       SELECT for_date FROM #leave_date    
         
       OPEN curAsgnLeaveDate     
       FETCH NEXT FROM curAsgnLeaveDate INTO @For_date    
       WHILE @@FETCH_STATUS = 0    
        BEGIN    
         IF @Total_leave_used = 0.5    
          BEGIN    
           SET @Leave_used =0.5    
          END    
         ELSE IF @Total_leave_used = 0.25    
          BEGIN    
           SET @Leave_used =0.25    
          END    
         ELSE IF @Total_leave_used = 0.75    
          BEGIN    
           SET @Leave_used =0.75    
          END    
         ELSE    
          BEGIN    
           IF @For_Date = @Half_Leave_Date    
            BEGIN    
             SET @Leave_used = 0.5    
            END    
           ELSE  
            BEGIN  
             IF @Apply_Hourly = 0  
              SET @Leave_used = 1   
             ELSE   
              SET @Leave_Used = @Total_Leave_used   
            END    
      
           SET @Total_Leave_Used = @Total_leave_used - @Leave_Used              
          END    
                          
         IF @is_backdated_application = 0  
          BEGIN  
                         
           UPDATE T0140_LEAVE_TRANSACTION set Compoff_used = CASE WHEN IsNull(Compoff_used,0) - @Leave_Used     >= 0 then  IsNull(Compoff_used,0) - @Leave_Used    ELSE 0 end  
           WHERE leave_id = @leave_Id AND emp_id = @emp_id AND for_date = @for_date     
           AND Cmp_ID = @Cmp_ID     
          END  
         ELSE  
          BEGIN  
           SELECT @Back_Dated_Leave = Back_Dated_Leave   
           FROM T0140_LEAVE_TRANSACTION     
           WHERE Leave_ID = @leave_Id AND emp_id = @emp_id AND for_date = @for_date AND Cmp_ID = @Cmp_ID    
  
           UPDATE T0140_LEAVE_TRANSACTION   
           SET  Compoff_used = 0,Back_Dated_Leave = CASE WHEN IsNull(@Back_Dated_Leave,0) - @Leave_Used >= 0 THEN IsNull(@Back_Dated_Leave,0) - @Leave_Used ELSE 0 END  
           WHERE Leave_ID = @Leave_Id AND Emp_ID = @Emp_Id AND For_Date = @For_Date AND Cmp_ID = @Cmp_ID     
          END  
         FETCH NEXT FROM curAsgnLeaveDate INTO @For_date    
        END    
       CLOSE curAsgnLeaveDate    
       DEALLOCATE curAsgnLeaveDate     
          
       FETCH NEXT FROM curDel INTO @Leave_Approval_Id,@Leave_Id , @Total_Leave_Used,@A_From_Date,@A_To_Date,@Half_Leave_Date       
      END      
     CLOSE curDel    
     DEALLOCATE curDel   
      
     DECLARE @LEAVE_SYSTEM_DATE AS DATETIME  
     SET  @LEAVE_SYSTEM_DATE = NULL  
      
     SELECT @LEAVE_COMPOFF_DATES = LEAVE_COMPOFF_DATES,@LEAVE_SYSTEM_DATE = SYSTEM_DATE FROM DELETED  
     -- Gadriwala Muslim Added 03092014 - Start    
        
     INSERT INTO #Leave_CompOff_Approved(Leave_date,Leave_Period)  
     SELECT  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10)   
     FROM dbo.SPlit(@Leave_CompOFf_Dates,'#')   
     WHERE DATA <> ''  
    
       IF EXISTS ( SELECT 1 FROM T0040_LEAVE_MASTER WHERE IsNull(DEFAULT_SHORT_NAME,'') = 'COPH' AND LEAVE_ID = @LEAVE_ID)  
      BEGIN   
       DELETE FROM #LEAVE_COMPOFF_APPROVED   
       WHERE MONTH(LEAVE_DATE) = MONTH(@LEAVE_SYSTEM_DATE)   
        AND YEAR(LEAVE_DATE) = YEAR(@LEAVE_SYSTEM_DATE)  
      END   
  
     UPDATE T0140_LEAVE_TRANSACTION   
     SET  CompOff_Debit = Compoff_Debit - LA.Leave_Period,  
       CompOff_balance = CompOff_balance + LA.Leave_Period   
     FROM T0140_LEAVE_TRANSACTION GOT   
       INNER JOIN #Leave_CompOff_Approved LA ON Leave_Date = For_Date  
       INNER JOIN T0040_LEAVE_MASTER LM ON GOT.Leave_ID=LM.Leave_ID  
     WHERE GOT.Emp_ID = @Emp_Id AND GOT.Cmp_ID = @cmp_ID   
       AND LM.Default_Short_Name = @Leave_Short_Name AND LM.Cmp_ID = @Cmp_ID  
       AND Comoff_Flag = 1          
     -- Gadriwala Muslim Added 03092014 - End  
    End -- Approval Flag    
   ELSE  
    BEGIN  
     IF @Approval_Status ='A'    
      BEGIN     
       DECLARE curDel CURSOR FOR    
       SELECT Leave_approval_id ,leave_Id,Leave_Period,From_Date,To_Date,Half_Leave_Date,Half_Payment FROM deleted     
           
       OPEN curDel    
       FETCH NEXT FROM curDel INTO @Leave_Approval_Id,@Leave_Id , @Total_Leave_Used,@A_From_Date,@A_To_Date,@Half_Leave_Date,@Half_Payment  
       WHILE @@FETCH_STATUS = 0    
        BEGIN     
         SET @For_Date= @A_From_Date            
         EXEC getAllDaysBetweenTwoDate @A_From_Date,@A_To_Date         
             
         INSERT INTO #Leave_date (for_date)    
         SELECT test1 FROM test1  
             
         --Commented By Gadriwala 05122014 for Skip Holiday row as per discuss with hardik bhai,nilay bhai  
         --EXEC Calculate_Leave_End_Date @Cmp_ID,@Emp_Id,@Leave_Id,@For_Date,@Total_Leave_used,'O',@M_Cancel_WO_HO    
                
         DECLARE curAsgnLeaveDate CURSOR FOR    
         SELECT for_date FROM #leave_date    
             
         OPEN curAsgnLeaveDate     
         FETCH NEXT FROM curAsgnLeaveDate INTO @For_date    
         WHILE @@FETCH_STATUS = 0    
          BEGIN      
           IF @Total_leave_used = 0.5    
            BEGIN    
             SET @Leave_used =0.5    
            END    
           ELSE IF @Total_leave_used = 0.25    
            BEGIN    
             SET @Leave_used =0.25    
            END    
           ELSE IF @Total_leave_used = 0.75    
            BEGIN    
             SET @Leave_used =0.75    
            END    
           ELSE    
            BEGIN    
             IF @For_Date = @Half_Leave_Date   -- Changed by Gadriwala Muslim 10092014  
              SET @Leave_used = 0.5    
             ELSE  
              BEGIN  
               IF @Apply_Hourly = 0  
                SET @Leave_used = 1    
               ELSE   
                SET @Leave_Used = @Total_Leave_used   
              END   
            END    
                     
           IF @is_backdated_application = 0  
            BEGIN  
             --Added condition by hardik 19/12/2014 for Vital Soft, Half payment AND full payment  
             IF @Half_Payment = 1   
              SET @Half_Payment_Days = @Leave_Used  
                 
             IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION WHERE leave_id = @leave_Id AND emp_id = @emp_id AND for_date = @for_date   AND Cmp_ID = @Cmp_ID   AND Leave_used >= @Leave_Used)  
              BEGIN  
               UPDATE T0140_LEAVE_TRANSACTION   
               SET  Leave_Used = IsNull(Leave_Used,0) - @Leave_Used,  
                 Half_Payment_Days = IsNull(Half_Payment_Days,0) - @Half_Payment_Days,  
                 Leave_Closing = IsNull(Leave_Closing,0) + @Leave_Used + @Half_Payment_Days  
               WHERE leave_id = @leave_Id AND emp_id = @emp_id AND for_date = @for_date  
                 AND Cmp_ID = @Cmp_ID  AND Leave_used >= @Leave_Used  
  
               SET @Total_Leave_Used = @Total_leave_used - @Leave_Used - @Half_Payment_Days  
              END  
            END  
           ELSE  
            BEGIN  
             SELECT @Back_Dated_Leave = Back_Dated_Leave   
             FROM T0140_LEAVE_TRANSACTION     
             WHERE leave_id = @leave_Id AND emp_id = @emp_id AND for_date = @for_date AND Cmp_ID = @Cmp_ID    
                        
             IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION WHERE leave_id = @leave_Id AND emp_id = @emp_id AND for_date = @for_date   AND Cmp_ID = @Cmp_ID   AND Back_Dated_Leave >= @Leave_Used)  
              BEGIN  
               UPDATE T0140_LEAVE_TRANSACTION   
               SET  Leave_Used = 0,Leave_Closing = IsNull(Leave_Closing,0) + @Leave_Used + @Half_Payment_Days,  
                 Back_Dated_Leave = IsNull(@Back_Dated_Leave,0) - @Leave_Used - @Half_Payment_Days  
               WHERE Leave_ID = @leave_Id AND emp_id = @emp_id AND for_date = @for_date AND Cmp_ID = @Cmp_ID   
                 AND Back_Dated_Leave >= @Leave_Used  
                          
               SET @Total_Leave_Used = @Total_leave_used - @Leave_Used -@Half_Payment_Days   
              END  
            END  
                       
           IF @Leave_Type = 'ESIC Leave'  -- Added by Gadriwala Muslim 15/09/2015  
            BEGIN  
             SELECT @Auto_credit_ML = Setting_Value   
             FROM T0040_SETTING   
             WHERE Cmp_ID = @Cmp_ID   
               AND  Setting_Name = 'Auto credit one medical leave when first time ESIC leave have approved in year'  
                 
             IF @Auto_credit_ML = 1   
              BEGIN  
               SET @Medical_Leave_ID = 0  
               SET @Auto_credit_ML = 0  
               SET @Medical_Last_Closing = 0  
               SET @Year_Start_Date = dbo.GET_MONTH_ST_DATE(month(@A_From_Date),Year(@A_From_Date))  
               SET @Year_End_Date = dbo.GET_MONTH_END_DATE(month(@A_From_Date),Year(@A_From_date))  
              
               SELECT @Medical_Leave_ID = Leave_ID   
               FROM T0040_LEAVE_MASTER   
               WHERE Cmp_ID = @Cmp_ID AND Medical_Leave = 1  
              
               If  EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION WHERE Leave_ID = @Medical_Leave_ID  AND For_Date = @Leave_Approval_Date AND Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID AND Leave_credit > 0)        
                BEGIN  
                 SELECT @ML_Trans_ID = Leave_Tran_ID FROM T0140_LEAVE_TRANSACTION WHERE Leave_ID = @Medical_Leave_ID  AND For_Date = @Leave_Approval_Date AND Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID  
                     
                 UPDATE T0140_LEAVE_TRANSACTION   
                 set Leave_Credit = 0, Leave_Closing = Leave_Opening  - Leave_Used  
                 WHERE  Leave_Tran_ID = @ML_Trans_ID AND Cmp_ID = @Cmp_ID    
                     
                 IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION LT   
                     LEFT OUTER JOIN (SELECT For_date,LT.Leave_ID,Emp_ID   
                          FROM T0140_LEAVE_TRANSACTION LT   
                           INNER JOIN T0040_LEAVE_MASTER LM  ON LT.Leave_ID = LM.Leave_ID    
                         WHERE LT.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id  AND LT.For_Date >= @A_From_Date   
                           AND LT.For_Date <= @A_To_Date AND leave_used > 0 AND Leave_Type = 'ESIC Leave') Qry  ON Qry.For_Date = LT.For_Date AND Qry.Leave_ID = LT.Leave_ID AND Qry.emp_id = LT.emp_id    
                     INNER JOIN T0040_LEAVE_MASTER LM  on LT.Leave_ID = LM.Leave_ID   
                    WHERE LT.For_Date >= @Year_Start_Date AND LT.For_Date <= @Year_End_Date   
                     AND LT.Cmp_ID = @Cmp_ID AND LT.Emp_ID = @Emp_Id AND Leave_Used >0   
                     AND Leave_Type = 'ESIC Leave' AND IsNull(Qry.emp_id,0) = 0)  
                  BEGIN  
                   DECLARE @ML_Approval_Date AS DATETIME  
                      
                   SELECT TOP 1 @ML_Approval_Date = Approval_Date   
                   FROM T0120_LEAVE_APPROVAL LA   
                     INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID   
                     INNER JOIN T0040_LEAVE_MASTER LM  ON LAD.Leave_ID = LM.Leave_ID   
                   WHERE From_Date >= @Year_Start_Date AND From_Date <=@Year_End_Date AND LA.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id AND LM. Leave_Type = 'ESIC Leave'  
                      
                   IF  EXISTS( SELECT 1 FROM T0140_LEAVE_TRANSACTION WHERE Leave_ID = @Medical_Leave_ID  AND For_Date = @ML_Approval_Date AND Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID)        
                    BEGIN  
                     SELECT @ML_Trans_ID = Leave_Tran_ID   
                     FROM T0140_LEAVE_TRANSACTION   
                     WHERE Leave_ID = @Medical_Leave_ID  AND For_Date = @ML_Approval_Date AND Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID  
  
                     UPDATE T0140_LEAVE_TRANSACTION   
                     SET  Leave_Credit = Leave_Credit + 1, Leave_Closing = (Leave_Opening + Leave_Credit + 1 ) - Leave_Used  
                     WHERE Leave_Tran_ID = @ML_Trans_ID AND Cmp_ID = @Cmp_ID  
                    END  
                   ELSE  
                    BEGIN  
                     SELECT @ML_Trans_ID = IsNull(MAX(Leave_Tran_ID),0) + 1 FROM T0140_LEAVE_TRANSACTION   
                        
                     SELECT @Medical_Last_Closing = IsNull(Leave_Closing,0)   
                     FROM T0140_LEAVE_TRANSACTION    
                     WHERE FOR_DATE = (SELECT MAX(for_date) FROM T0140_LEAVE_TRANSACTION   
                          WHERE for_date <= @ML_Approval_Date AND leave_Id = @Medical_Leave_ID AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id)     
                       AND Cmp_ID = @Cmp_ID AND leave_id = @Medical_Leave_ID AND emp_Id = @emp_Id    
                        
                     INSERT INTO T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Credit,Leave_Used,Leave_Closing,Leave_Tran_ID)    
                     VALUES(@emp_id,@Medical_Leave_ID,@Cmp_ID,@ML_Approval_Date,@Medical_Last_Closing,1,0, @Medical_Last_Closing + 1 ,@ML_Trans_ID)    
                    END  
                      
                   SELECT @Medical_Last_Closing = IsNull(Leave_Closing,0)   
                   FROM T0140_LEAVE_TRANSACTION   
                   WHERE For_Date = (SELECT MAX(for_date) FROM T0140_LEAVE_TRANSACTION   
                        WHERE For_Date <= @ML_Approval_Date AND leave_Id = @Medical_Leave_ID AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id)     
                     AND Cmp_ID = @Cmp_ID AND leave_id = @Medical_Leave_ID AND emp_Id = @emp_Id    
                                  
                     IF @Medical_Last_Closing IS NULL    
                    SET @Medical_Last_Closing = 0            
                           
                   DECLARE curMedicalLeave CURSOR FOR     
                   SELECT Leave_Tran_ID,For_Date   
                   FROM dbo.T0140_LEAVE_TRANSACTION   
                   WHERE Leave_ID = @Medical_Leave_ID AND Emp_ID = @emp_id AND Cmp_ID = @Cmp_ID   
                     AND for_date > @ML_Approval_Date   
                   ORDER BY for_date    
                       
                   OPEN curMedicalLeave   
                   FETCH NEXT FROM curMedicalLeave INTO @cur_ML_tran_ID,@Cur_ML_For_Date    
                   WHILE @@FETCH_STATUS = 0    
                    BEGIN    
                     IF EXISTS(SELECT Leave_Op_Id FROM T0095_LEAVE_OPENING   
                        WHERE Cmp_ID = @Cmp_ID AND Emp_Id = @Emp_Id AND Leave_ID = @Medical_Leave_ID   
                         AND For_Date = @Cur_ML_For_Date AND Leave_Op_Days > 0)    
                      Or @Medical_Posting IS NOT NULL  
                      BEGIN    
                       Goto Medical3;    
                      END    
                              
                     SELECT @Medical_Posting = Leave_Posting FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @cur_ML_tran_ID   
                         
                     UPDATE dbo.T0140_LEAVE_TRANSACTION   
                     SET  Leave_Opening = @Medical_Last_Closing,  
                       Leave_Closing = @Medical_Last_Closing + IsNull(Leave_Credit,0) - IsNull(Leave_Used,0) - IsNull(Leave_Encash_Days,0) - IsNull(Back_Dated_Leave,0) - IsNull(Half_Payment_Days,0)  
                     WHERE leave_tran_id = @cur_ML_tran_ID    
                           
                     Medical3:       
                      SET @Medical_Last_Closing = IsNull((SELECT IsNull(Leave_Closing,0) FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @cur_ML_tran_ID),0)    
                              
                     FETCH NEXT FROM curMedicalLeave INTO @cur_ML_tran_ID,@Cur_ML_For_Date    
                    END    
                   CLOSE curMedicalLeave    
                   DEALLOCATE curMedicalLeave      
                  END  
                END  
                   
               SELECT @Medical_Last_Closing = IsNull(Leave_Closing,0)   
               FROM T0140_LEAVE_TRANSACTION    
               WHERE for_date = (SELECT MAX(for_date) FROM T0140_LEAVE_TRANSACTION   
                    WHERE For_Date <= @Leave_Approval_Date    
                      AND leave_Id = @Medical_Leave_ID AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id)     
                 AND Cmp_ID = @Cmp_ID AND leave_id = @Medical_Leave_ID AND emp_Id = @emp_Id    
                                  
                 IF @Medical_Last_Closing IS NULL    
                SET @Medical_Last_Closing = 0            
                           
                      
               DECLARE curMedicalLeave CURSOR FOR     
               SELECT Leave_Tran_ID,For_Date   
               FROM dbo.T0140_LEAVE_TRANSACTION   
               WHERE Leave_ID = @Medical_Leave_ID AND Emp_ID = @Emp_Id     
                 AND Cmp_ID = @Cmp_ID AND for_date > @Leave_Approval_Date   
               ORDER BY for_date    
                   
               OPEN curMedicalLeave   
               FETCH NEXT FROM curMedicalLeave INTO @cur_ML_tran_ID,@Cur_ML_For_Date    
               WHILE @@FETCH_STATUS = 0    
                BEGIN    
                 IF EXISTS(SELECT Leave_Op_Id FROM T0095_LEAVE_OPENING WHERE Cmp_ID = @Cmp_ID AND Emp_Id = @Emp_Id AND Leave_ID = @Medical_Leave_ID AND For_Date = @Cur_ML_For_Date AND Leave_Op_Days > 0)    
                  Or @Medical_Posting IS NOT NULL  
                  BEGIN    
                   Goto Medical2;    
                  END    
                     
                 SELECT @Medical_Posting = Leave_Posting FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @cur_ML_tran_ID   
                 BEGIN    
                  BEGIN    
                   UPDATE dbo.T0140_LEAVE_TRANSACTION   
                   SET  Leave_Opening = @Medical_Last_Closing,  
                     Leave_Closing = @Medical_Last_Closing + IsNull(Leave_Credit,0) - IsNull(Leave_Used,0) - IsNull(Leave_Encash_Days,0) - IsNull(Back_Dated_Leave,0) - IsNull(Half_Payment_Days,0)  
                   WHERE Leave_Tran_ID = @cur_ML_tran_ID    
                        
                   Medical2:       
                    SET @Medical_Last_Closing = IsNull((SELECT IsNull(Leave_Closing,0) FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @cur_ML_tran_ID),0)    
                  END    
                 END                              
                 FETCH NEXT FROM curMedicalLeave INTO @cur_ML_tran_ID,@Cur_ML_For_Date    
                END    
               CLOSE curMedicalLeave    
               DEALLOCATE curMedicalLeave          
              END  
            END  
                
           FETCH NEXT FROM curAsgnLeaveDate INTO @For_date    
          END    
         CLOSE curAsgnLeaveDate    
         DEALLOCATE curAsgnLeaveDate     
             
         FETCH NEXT FROM curDel INTO @Leave_Approval_Id,@Leave_Id , @Total_Leave_Used,@A_From_Date,@A_To_Date,@Half_Leave_Date,@Half_Payment  
        END      
       CLOSE curDel    
       DEALLOCATE curDel    
          
       SET @For_Date= @A_From_Date    
         
       DECLARE @ERROR_MSG NVARCHAR(50)  
       SET @ERROR_MSG=''  
           
       SELECT @Pre_Closing = IsNull(Leave_Closing,0)   
       FROM T0140_LEAVE_TRANSACTION    
       WHERE for_date = (SELECT MAX(for_date)   
            FROM T0140_LEAVE_TRANSACTION   
            WHERE for_date <= @For_date AND leave_Id = @leave_id   
              AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id)     
         AND Cmp_ID = @Cmp_ID    
         AND leave_id = @leave_Id AND emp_Id = @emp_Id    
             
       IF @Pre_Closing is null    
        SET @Pre_Closing = 0   
             
       DECLARE @Leave_Negative_Max_Limit  NUMERIC (9,2)  
       SELECT @Leave_negative_Allow = IsNull(Leave_negative_Allow,0),   
         @Leave_Negative_Max_Limit = IsNull(leave_negative_max_limit,0)  
       FROM T0040_leave_master   
       WHERE Leave_ID =@Leave_ID    
           
       DECLARE curLeaveTran CURSOR FOR     
       SELECT Leave_Tran_ID,For_Date   
       FROM dbo.T0140_LEAVE_TRANSACTION   
       WHERE leave_id = @leave_Id AND emp_id = @emp_id     
         AND Cmp_ID = @Cmp_ID AND for_date > @For_date order by for_date    
           
       OPEN curLeaveTran    
       FETCH NEXT FROM curLeaveTran INTO @Chg_Tran_Id,@For_Date_Cur    
        WHILE @@FETCH_STATUS = 0    
         BEGIN    
          IF EXISTS(SELECT Leave_Op_Id FROM T0095_LEAVE_OPENING WHERE Cmp_ID = @Cmp_ID AND Emp_Id = @Emp_Id AND Leave_ID = @Leave_Id AND For_Date = @For_Date_Cur AND Leave_Op_Days > 0)    
           OR @Leave_Posting IS NOT NULL  --Change by Jaina 15-11-2017 (After Discuss with Nimeshbhai)  
           BEGIN    
            BREAK  
           End    
  
          SELECT @Leave_Posting = Leave_Posting   
          FROM dbo.T0140_LEAVE_TRANSACTION   
          WHERE leave_tran_id = @Chg_Tran_Id    
               
          UPDATE dbo.T0140_LEAVE_TRANSACTION   
          SET  Leave_Opening = @Pre_Closing,  
            Leave_Closing = @Pre_Closing + IsNull(Leave_Credit,0) - IsNull(Leave_Used,0) - IsNull(Leave_Encash_Days,0) - IsNull(Back_Dated_Leave,0) - IsNull(Half_Payment_Days,0)  
          WHERE Leave_Tran_ID = @Chg_Tran_Id   
                  
                                  
            
          IF @Leave_negative_Allow = 1 AND @Leave_Negative_Max_Limit > 0  
           AND EXISTS(SELECT 1    
               FROM dbo.T0140_LEAVE_TRANSACTION LT INNER JOIN  
                 T0040_LEAVE_MASTER L on L.Leave_ID = LT.Leave_ID  
               WHERE Leave_Tran_ID = @Chg_Tran_Id   
                 AND (Leave_Closing < (@Leave_Negative_Max_Limit * -1)  
                 AND (L.Default_Short_Name <> 'COMP'))) --Added by Jaina 15-02-2018  
           BEGIN  
            SET @ERROR_MSG= '@@Negative Leave is not allowed Date: ' + CAST(@For_Date_Cur As Varchar(11)) + '@@'  
            RAISERROR(@ERROR_MSG, 16 , 2)  
           END  
          SET @Pre_Closing = IsNull((SELECT IsNull(Leave_Closing,0) FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @Chg_Tran_Id),0)    
             
          FETCH NEXT FROM curLeaveTran INTO @Chg_Tran_Id,@For_Date_Cur    
         END    
        CLOSE curLeaveTran    
        DEALLOCATE curLeaveTran              
      END -- Approval Flag    
         
     SET @ERROR_MSG=''  
    END  
  END    
  
  
GO


CREATE TRIGGER [DBO].[Tri_T0130_LEAVE_APPROVAL_DETAIL]  
ON [dbo].[T0130_LEAVE_APPROVAL_DETAIL]  
FOR  INSERT,  DELETE   
AS  
  
	SET NOCOUNT ON
  
	DECLARE @Cmp_ID as numeric  
	DECLARE @For_Date AS DATETIME  
	DECLARE @Emp_Id as numeric  
	DECLARE @Count as numeric  
	DECLARE @Leave_Approval_Id as numeric  
	DECLARE @Leave_Id as numeric  
	DECLARE @Leave_Used as numeric(18,2)  
	DECLARE @Leave_Asign_As as varchar(20) --hardik 24/06/2011  
	DECLARE @Leave_Asign_As_Cur as varchar(20) --hardik 24/06/2011  
	DECLARE @Leave_Used_Cur as numeric(18,2) --hardik 24/06/2011  
	DECLARE @Code as varchar(50)  
	DECLARE @Last_Leave_Closing as numeric(18,2)  
	DECLARE @From_Date AS DATETIME  
	DECLARE @To_Date AS DATETIME  
	DECLARE @ErrString as varchar(200)  
	DECLARE @varFromDate as varchar(11)   
	DECLARE @To_For_Date AS DATETIME  
	DECLARE @Leave_Tran_ID as numeric  
	DECLARE @Approval_Status as varchar(1)  
	DECLARE @Total_Leave_used as numeric(18,2)  
	DECLARE @A_From_Date AS DATETIME  
	DECLARE @A_To_Date AS DATETIME  
	DECLARE @Leave_negative_Allow tinyint  
	DECLARE @IS_Import int  
	DECLARE @Emp_Code numeric(18,0)  
	DECLARE @Leave_Paid_Unpaid varchar(1)  
	DECLARE @M_Cancel_WO_HO tinyint  
	DECLARE @Half_Leave_Date datetime   
	DECLARE @Apply_Hourly as numeric

	DECLARE @Half_Payment as tinyint
	DECLARE @Half_Payment_Days as Numeric(18,8)

	SET @Apply_Hourly = 0
	SET @M_Cancel_WO_HO = 0  
	SET @Total_Leave_used = 0  
	SET @Leave_negative_Allow =0  

	SET @Half_Payment = 0
	SET @Half_Payment_Days = 0

	DECLARE @Back_Dated_Leave as numeric(18,2)
	DECLARE @is_backdated_application as numeric
	DECLARE @Leave_Approval_Id_temp as numeric
	SET @Back_Dated_Leave = 0
	-- Added by Gadriwala Muslim  02102014 - Start
	DECLARE @Leave_CompOFf_Dates varchar(max)
	SET @Leave_CompOFf_Dates = ''
	CREATE TABLE #Leave_CompOff_Approved
	(
		Leave_Date datetime,
		Leave_Period numeric(18,2)
	)
	-- Added by Gadriwala Muslim 02102014 - End 
  
	CREATE TABLE #Leave_date  
	(   
		for_date datetime  
	)  
 
	DECLARE @Chg_Tran_Id numeric    
	DECLARE @For_Date_Cur Datetime  
	DECLARE @Pre_Closing numeric(18,2)  
	DECLARE @Leave_Posting numeric(18,2)  
	DECLARE @Leave_Short_Name varchar(25)
	SET @Leave_Short_Name = ''
  
	DECLARE @Leave_Type varchar(25)  -- Added by Gadriwala Muslim 15092015
	SET @Leave_Type = '' -- Added by Gadriwala Muslim 15092015
	DECLARE @Year_Start_Date datetime
	DECLARE @Year_End_Date datetime
	DECLARE @Medical_Leave_ID numeric(18,0)
	DECLARE @ML_Trans_ID numeric(18,0)	
	DECLARE @Medical_Last_Closing numeric(18,2)
	DECLARE @Leave_Approval_Date datetime
	DECLARE @Auto_credit_ML numeric(18,0)
	DECLARE @cur_ML_tran_ID numeric(18,0)
	DECLARE @Cur_ML_For_Date datetime
	DECLARE @Medical_Posting numeric(18,2)
	IF  UPDATE (Leave_Approval_Id)   
		BEGIN    
			SELECT  @Cmp_ID = LA.Cmp_ID,  @Emp_Id = emp_Id  ,@Approval_Status = Approval_Status   ,@Leave_Approval_Date = Approval_Date
			From	T0120_LEAVE_APPROVAL LA
					INNER JOIN inserted I ON la.Leave_Approval_ID=I.Leave_Approval_ID
			
    
			
			SELECT	@Emp_Code = Emp_Code 
			FROM	T0080_Emp_Master 
			WHERE	Emp_ID = @Emp_Id  
  
			SELECT	@Leave_Approval_Id = ins.leave_approval_id, @Leave_Id = ins.Leave_Id, @For_Date = From_Date,
					@Leave_Used = ins.Leave_Period ,@Leave_Asign_As = ins.Leave_Assign_As, @Total_Leave_used = ins.Leave_Period,
					@A_From_Date = From_Date ,@A_To_date = To_Date, @Is_Import = Is_Import , @M_Cancel_WO_HO = M_Cancel_WO_HO,
					@Half_Leave_Date = ins.Half_Leave_Date,@Leave_CompOFf_Dates = Leave_CompOFf_Dates,@Half_Payment=Half_Payment  
			FROM	inserted ins   
		    
		    SELECT	@Leave_negative_Allow = IsNull(Leave_negative_Allow,0), @Leave_Paid_Unpaid = Leave_Paid_Unpaid, @Apply_Hourly = Apply_Hourly,@Leave_Type = Leave_Type
		    From	T0040_LEAVE_MASTER 
			WHERE	Leave_ID =@Leave_ID  
    
			IF @Is_Import = 2	--Added By Nimesh on 06-12-2017 (If Leave is created FROM Attendance Import then Cancel Holiday Policy should be considered)
				SET @M_Cancel_WO_HO  =1

			SET @is_backdated_application = 0
			 
			--''Ankit - 27122014
			--IF EXISTS(SELECT * FROM T0120_LEAVE_APPROVAL WHERE Leave_Approval_ID = @Leave_Approval_Id AND Leave_Application_ID IS NULL 
			--							AND Emp_ID = @Emp_Id AND Leave_Approval_ID IN (SELECT Leave_Approval_ID FROM T0130_LEAVE_APPROVAL_DETAIL WHERE Leave_Approval_ID = @Leave_Approval_Id)
			--			 )
			--	BEGIN
					SELECT	@is_backdated_application = IsNull(Is_Backdated_App,0) 
					FROM	T0120_LEAVE_APPROVAL 
					WHERE	Leave_Approval_ID = @Leave_Approval_Id 
							AND Emp_ID = @Emp_Id 
							--AND Leave_Application_ID IS NULL 
							--AND Leave_Approval_ID IN (SELECT Leave_Approval_ID FROM T0130_LEAVE_APPROVAL_DETAIL WHERE Leave_Approval_ID = @Leave_Approval_Id)
			--	END
			--ELSE
			--	BEGIN
			--		 SELECT @is_backdated_application = IsNull(is_backdated_application,0) FROM T0100_LEAVE_APPLICATION WHERE Leave_Application_ID
			--			in (SELECT Leave_Application_ID FROM T0120_LEAVE_APPROVAL WHERE Emp_ID = @Emp_Id AND Leave_Approval_ID in (
			--				SELECT Leave_Approval_ID FROM T0130_LEAVE_APPROVAL_DETAIL WHERE Leave_Approval_ID = @Leave_Approval_Id))
			--	END		
				
			--''Ankit - 27122014	
			
			 --SELECT @is_backdated_application = IsNull(is_backdated_application,0) FROM T0100_LEAVE_APPLICATION WHERE Leave_Application_ID
				--in (SELECT Leave_Application_ID FROM T0120_LEAVE_APPROVAL WHERE Emp_ID = @Emp_Id AND Leave_Approval_ID in (
				--	SELECT Leave_Approval_ID FROM T0130_LEAVE_APPROVAL_DETAIL WHERE Leave_Approval_ID = @Leave_Approval_Id))
				
			SELECT @Leave_Short_Name =  IsNull(Default_Short_Name,'') FROM T0040_LEAVE_MASTER WHERE Leave_ID = @Leave_Id AND Cmp_ID = @Cmp_ID		--Changed by Gadriwala Muslim 02102014
    
			--IF @Leave_Short_Name = 'COMP' 
			IF (@Leave_Short_Name = 'COMP' or @Leave_Short_Name = 'COPH' or @Leave_Short_Name = 'COND')
				BEGIN
					EXEC SP_Tri_T0130_LEAVE_APPROVAL_DETAIL_For_CompOff_Leave @Cmp_ID,@Emp_Id,@Emp_Code,@Leave_Approval_Id,@Approval_Status,@Leave_Id,@For_Date,@Leave_Used,@Leave_Asign_As,@Total_Leave_used,@A_From_Date,@A_To_date,@Is_Import,@M_Cancel_WO_HO,@Half_Leave_Date,@Leave_negative_Allow,@Leave_Paid_Unpaid,@Apply_Hourly,@is_backdated_application,@Leave_CompOFf_Dates,@Leave_Short_Name
				END
			ELSE
				BEGIN
					IF @Half_Payment = 1
						SET @Half_Payment_Days = @Leave_Used
							
					EXEC SP_Tri_T0130_LEAVE_APPROVAL_DETAIL_For_Regular_Leave @Cmp_ID,@Emp_Id,@Emp_Code,@Leave_Approval_Id,@Approval_Status,@Leave_Id,@For_Date,@Leave_Used,@Leave_Asign_As,@Total_Leave_used,@A_From_Date,@A_To_date,@Is_Import,@M_Cancel_WO_HO,@Half_Leave_Date,@Leave_negative_Allow,@Leave_Paid_Unpaid,@Apply_Hourly,@is_backdated_application,@Half_Payment
							
					return					
					IF @Leave_Type = 'ESIC Leave' AND @Approval_Status ='A'   -- Added by Gadriwala Muslim 15/09/2015
						AND EXISTS(SELECT 1 FROM T0040_SETTING 
									WHERE	Cmp_ID = @Cmp_ID AND  Setting_Name = 'Auto credit one medical leave when first time ESIC leave have approved in year'
											AND Setting_Value=1)
						BEGIN
							SET @Medical_Leave_ID = 0
							SET @Auto_credit_ML = 0
							SET @Medical_Last_Closing = 0
							SET @Year_Start_Date = dbo.GET_MONTH_ST_DATE(month(@A_From_Date),Year(@A_From_Date))
							SET @Year_End_Date = dbo.GET_MONTH_END_DATE(month(@A_From_Date),Year(@A_From_date))
												
							SELECT @Medical_Leave_ID = Leave_ID FROM T0040_LEAVE_MASTER 
							WHERE cmp_ID = @cmp_ID AND Medical_Leave = 1
												
							IF NOT EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION LT 
												LEFT OUTER JOIN (SELECT For_date,LT.Leave_ID,emp_id 
																FROM	T0140_LEAVE_TRANSACTION LT 
																		INNER JOIN T0040_LEAVE_MASTER LM  on LT.Leave_ID = LM.Leave_ID  
																WHERE	LT.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id  AND LT.For_Date >= @A_From_Date 
																		AND LT.For_Date <= @A_To_Date AND leave_used > 0 AND Leave_Type = 'ESIC Leave'
																) Qry ON Qry.For_Date = LT.For_Date AND Qry.Leave_ID = LT.Leave_ID AND Qry.emp_id = LT.emp_id  
												INNER JOIN T0040_LEAVE_MASTER LM  ON LT.Leave_ID = LM.Leave_ID 
											where	LT.For_Date >= @Year_Start_Date AND LT.For_Date <= @Year_End_Date 
												AND LT.Cmp_ID = @Cmp_ID AND LT.Emp_ID = @Emp_Id AND Leave_Used >0 
												AND Leave_Type = 'ESIC Leave' AND IsNull(Qry.emp_id,0) = 0
										)
								BEGIN
									IF  EXISTS( SELECT 1 FROM T0140_LEAVE_TRANSACTION WHERE Leave_ID = @Medical_Leave_ID  AND For_Date = @Leave_Approval_Date AND Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID)						
										BEGIN
											SELECT	@ML_Trans_ID = Leave_Tran_ID 
											FROM	T0140_LEAVE_TRANSACTION 
											WHERE	Leave_ID = @Medical_Leave_ID  AND For_Date = @Leave_Approval_Date AND Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID
																					
											UPDATE	T0140_LEAVE_TRANSACTION 
											SET		Leave_Credit = Leave_Credit + 1, Leave_Closing = (Leave_Opening + Leave_Credit + 1 ) - Leave_Used
											WHERE	Leave_Tran_ID = @ML_Trans_ID AND Cmp_ID = @Cmp_ID
										END
									ELSE
										BEGIN
											SELECT	@ML_Trans_ID = IsNull(MAX(Leave_Tran_ID),0) + 1 
											FROM	T0140_LEAVE_TRANSACTION 
																			
											SELECT	@Medical_Last_Closing = IsNull(Leave_Closing,0) 
											FROM	T0140_LEAVE_TRANSACTION  
											WHERE	For_Date = (SELECT	MAX(for_date) 
																FROM	T0140_LEAVE_TRANSACTION 
																WHERE	for_date <= @Leave_Approval_Date AND leave_Id = @Medical_Leave_ID 
																		AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id
																)   
													AND Cmp_ID = @Cmp_ID  
													AND leave_id = @Medical_Leave_ID AND emp_Id = @emp_Id  
																			
											INSERT INTO T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Credit,Leave_Used,Leave_Closing,Leave_Tran_ID)  
											VALUES(@emp_id,@Medical_Leave_ID,@Cmp_ID,@Leave_Approval_Date,@Medical_Last_Closing,1,0, @Medical_Last_Closing + 1 ,@ML_Trans_ID)  
										END
															
									SELECT	@Medical_Last_Closing = IsNull(Leave_Closing,0) 
									FROM	T0140_LEAVE_TRANSACTION  
									WHERE	For_Date = (SELECT	MAX(for_date) 
														FROM	T0140_LEAVE_TRANSACTION 
														WHERE	For_Date <= @Leave_Approval_Date AND leave_Id = @Medical_Leave_ID 
																AND Cmp_ID = @Cmp_ID AND Emp_ID = @emp_Id
														)   
											AND Cmp_ID = @Cmp_ID  
											AND leave_id = @Medical_Leave_ID AND emp_Id = @emp_Id  
                           
					  				IF @Medical_Last_Closing IS NULL  
										SET @Medical_Last_Closing = 0          
															 
									DECLARE curMedicalLeave CURSOR FOR   
									SELECT	leave_tran_id,For_Date 
									FROM	dbo.T0140_LEAVE_TRANSACTION 
									WHERE	leave_id = @Medical_Leave_ID AND emp_id = @emp_id   
											AND Cmp_ID = @Cmp_ID AND for_date > @Leave_Approval_Date 
									ORDER BY for_date  
																	
									OPEN	curMedicalLeave 
									FETCH NEXT FROM curMedicalLeave INTO @cur_ML_tran_ID,@Cur_ML_For_Date  
															
									WHILE @@FETCH_STATUS = 0  
										BEGIN  
											IF EXISTS(SELECT Leave_Op_Id FROM T0095_LEAVE_OPENING 
														WHERE Cmp_ID = @Cmp_ID AND Emp_Id = @Emp_Id AND Leave_ID = @Medical_Leave_ID 
																AND For_Date = @Cur_ML_For_Date AND Leave_Op_Days > 0) 
												Or @Medical_Posting IS NOT NULL 
												BEGIN
													Goto Medical1;  
												End  
													          
											SELECT	@Medical_Posting = Leave_Posting 
											FROM	dbo.T0140_LEAVE_TRANSACTION 
											WHERE	leave_tran_id = @cur_ML_tran_ID 
																	  
											BEGIN  
												UPDATE	dbo.T0140_LEAVE_TRANSACTION 
												SET		Leave_Opening = @Medical_Last_Closing,
														Leave_Closing = @Medical_Last_Closing + IsNull(Leave_Credit,0) - IsNull(Leave_Used,0) - IsNull(Leave_Encash_Days,0) - IsNull(Back_Dated_Leave,0) - IsNull(Half_Payment_Days,0)
												WHERE	leave_tran_id = @cur_ML_tran_ID  
																			
												Medical1:     
													SET @Medical_Last_Closing = IsNull((SELECT IsNull(Leave_Closing,0) FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @cur_ML_tran_ID),0)  
											END  
																
											FETCH NEXT FROM curMedicalLeave INTO @cur_ML_tran_ID,@Cur_ML_For_Date  
										END  
									CLOSE curMedicalLeave  
									DEALLOCATE curMedicalLeave       	
								END
						END
				END
		END  
	ELSE  
		BEGIN    
			SELECT	@Cmp_ID = LA.Cmp_ID,  @Emp_Id = emp_Id ,@Approval_Status = Approval_Status , @M_Cancel_WO_HO = LA.M_Cancel_WO_HO,
					@Leave_Approval_Id_temp = LA.Leave_Approval_ID, @Leave_Approval_Date = Approval_Date 
			FROM	T0120_LEAVE_APPROVAL LA
					INNER JOIN deleted D ON LA.Leave_Approval_ID=D.Leave_Approval_ID
					
			
			SELECT	@leave_id = leave_id,@Is_Import=Is_Import FROM deleted 

			IF @Is_Import = 2	--Added By Nimesh on 06-12-2017 (If Leave is created FROM Attendance Import then Cancel Holiday Policy should be considered)
				SET @M_Cancel_WO_HO  =1
 
			SELECT	@Leave_Short_Name =  IsNull(Default_Short_Name,''),@Leave_Type = Leave_Type 
			FROM	T0040_LEAVE_MASTER 
			WHERE	Leave_ID = @Leave_Id AND Cmp_ID = @Cmp_ID		  
  
			SELECT	@Apply_Hourly = Apply_hourly 
			FROM	T0040_LEAVE_MASTER 
			WHERE	Leave_ID = @Leave_Id 
  
			-- Added by Ali 25042014 -- Start  
			SET @is_backdated_application = 0
					  
			SELECT	@is_backdated_application = IsNull(Is_Backdated_App,0) 
			FROM	T0120_LEAVE_APPROVAL 
			WHERE	Leave_Approval_ID = @Leave_Approval_Id_temp 
					AND Emp_ID = @Emp_Id 
			---- Ankit 27122014 --
			--IF EXISTS(SELECT IS_Backdated_App FROM T0120_LEAVE_APPROVAL WHERE Leave_Application_ID IS NULL AND Leave_Approval_ID = @Leave_Approval_Id_temp)
			--	BEGIN
			--		SELECT	@is_backdated_application = IS_Backdated_App 
			--		FROM	T0120_LEAVE_APPROVAL 
			--		WHERE	Leave_Application_ID IS NULL AND Leave_Approval_ID = @Leave_Approval_Id_temp
			--	END
			--ELSE
			--	BEGIN
			--		SELECT	@is_backdated_application =  ISNULL(LA.Is_Backdated_App,is_backdated_application) 
			--		FROM	T0100_LEAVE_APPLICATION LAP
			--				INNER JOIN T0120_LEAVE_APPROVAL LA ON LAP.Leave_Application_ID=LA.Leave_Application_ID
			--		WHERE	Leave_Approval_ID = @Leave_Approval_Id_temp AND LA.Emp_ID=@Emp_Id					
			--	END 
			IF @Leave_Short_Name IN ('COMP', 'COND','COPH') AND @Approval_Status ='A'  
				BEGIN   
					DECLARE curDel CURSOR FOR  
					SELECT	Leave_approval_id ,leave_Id,Leave_Period,From_Date,To_Date,Half_Leave_Date FROM deleted   
					
					OPEN curDel  
					FETCH NEXT FROM curDel INTO @Leave_Approval_Id,@Leave_Id , @Total_Leave_Used,@A_From_Date,@A_To_Date,@Half_Leave_Date  
					WHILE @@FETCH_STATUS = 0  
						BEGIN  
							SET @For_Date= @A_From_Date  
							
							INSERT INTO #Leave_date (for_date)  
							EXEC Calculate_Leave_End_Date @Cmp_ID,@Emp_Id,@Leave_Id,@For_Date,@Total_Leave_used,'O',@M_Cancel_WO_HO  
											
							DECLARE curAsgnLeaveDate CURSOR FOR  
							SELECT for_date FROM #leave_date  
							
							OPEN curAsgnLeaveDate   
							FETCH NEXT FROM curAsgnLeaveDate INTO @For_date  
							WHILE @@FETCH_STATUS = 0  
								BEGIN  
									IF @Total_leave_used = 0.5  
										BEGIN  
											SET @Leave_used =0.5  
										END  
									ELSE IF @Total_leave_used = 0.25  
										BEGIN  
											SET @Leave_used =0.25  
										END  
									ELSE IF @Total_leave_used = 0.75  
										BEGIN  
											SET @Leave_used =0.75  
										END  
									ELSE  
										BEGIN  
											IF @For_Date = @Half_Leave_Date  
												BEGIN  
													SET @Leave_used = 0.5  
												END  
											ELSE
												BEGIN
													IF @Apply_Hourly = 0
														SET @Leave_used = 1 
													ELSE	
														SET @Leave_Used = @Total_Leave_used 
												END 	
				
											SET @Total_Leave_Used = @Total_leave_used - @Leave_Used            
										END  
											             
									IF @is_backdated_application = 0
										BEGIN
																							
											UPDATE T0140_LEAVE_TRANSACTION set Compoff_used = CASE WHEN IsNull(Compoff_used,0) - @Leave_Used     >= 0 then  IsNull(Compoff_used,0) - @Leave_Used    ELSE 0 end
											WHERE leave_id = @leave_Id AND emp_id = @emp_id AND for_date = @for_date   
											AND Cmp_ID = @Cmp_ID   
										END
									ELSE
										BEGIN
											SELECT	@Back_Dated_Leave = Back_Dated_Leave 
											FROM	T0140_LEAVE_TRANSACTION   
											WHERE	Leave_ID = @leave_Id AND emp_id = @emp_id AND for_date = @for_date AND Cmp_ID = @Cmp_ID  

											UPDATE	T0140_LEAVE_TRANSACTION 
											SET		Compoff_used = 0,Back_Dated_Leave = CASE WHEN IsNull(@Back_Dated_Leave,0) - @Leave_Used >= 0 THEN IsNull(@Back_Dated_Leave,0) - @Leave_Used ELSE 0 END
											WHERE	Leave_ID = @Leave_Id AND Emp_ID = @Emp_Id AND For_Date = @For_Date AND Cmp_ID = @Cmp_ID   
										END
									FETCH NEXT FROM curAsgnLeaveDate INTO @For_date  
								END  
							CLOSE curAsgnLeaveDate  
							DEALLOCATE curAsgnLeaveDate   
        
							FETCH NEXT FROM curDel INTO @Leave_Approval_Id,@Leave_Id , @Total_Leave_Used,@A_From_Date,@A_To_Date,@Half_Leave_Date 			 
						END    
					CLOSE curDel  
					DEALLOCATE curDel 
				
					DECLARE @LEAVE_SYSTEM_DATE AS DATETIME
					SET  @LEAVE_SYSTEM_DATE = NULL
				
					SELECT @LEAVE_COMPOFF_DATES = LEAVE_COMPOFF_DATES,@LEAVE_SYSTEM_DATE = SYSTEM_DATE FROM DELETED
					-- Gadriwala Muslim Added 03092014 - Start  
      
					INSERT	INTO #Leave_CompOff_Approved(Leave_date,Leave_Period)
					SELECT  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
					FROM	dbo.SPlit(@Leave_CompOFf_Dates,'#') 
					WHERE	DATA <> ''
		
  					IF EXISTS ( SELECT 1 FROM T0040_LEAVE_MASTER WHERE IsNull(DEFAULT_SHORT_NAME,'') = 'COPH' AND LEAVE_ID = @LEAVE_ID)
						BEGIN	
							DELETE FROM #LEAVE_COMPOFF_APPROVED 
							WHERE MONTH(LEAVE_DATE) = MONTH(@LEAVE_SYSTEM_DATE) 
								AND YEAR(LEAVE_DATE) = YEAR(@LEAVE_SYSTEM_DATE)
						END	

					UPDATE	T0140_LEAVE_TRANSACTION 
					SET		CompOff_Debit = Compoff_Debit - LA.Leave_Period,
							CompOff_balance	= CompOff_balance + LA.Leave_Period 
					FROM	T0140_LEAVE_TRANSACTION GOT 
							INNER JOIN #Leave_CompOff_Approved LA ON Leave_Date = For_Date
							INNER JOIN T0040_LEAVE_MASTER LM ON GOT.Leave_ID=LM.Leave_ID
					WHERE	GOT.Emp_ID = @Emp_Id AND GOT.Cmp_ID = @cmp_ID 
							AND LM.Default_Short_Name = @Leave_Short_Name AND LM.Cmp_ID = @Cmp_ID
							AND Comoff_Flag = 1								
					-- Gadriwala Muslim Added 03092014 - End
				End -- Approval Flag  
			ELSE
				BEGIN
					IF @Approval_Status ='A'  
						BEGIN   
							DECLARE curDel CURSOR FOR  
							SELECT Leave_approval_id ,leave_Id,Leave_Period,From_Date,To_Date,Half_Leave_Date,Half_Payment FROM deleted   
									
							OPEN curDel  
							FETCH NEXT FROM curDel INTO @Leave_Approval_Id,@Leave_Id , @Total_Leave_Used,@A_From_Date,@A_To_Date,@Half_Leave_Date,@Half_Payment
							WHILE @@FETCH_STATUS = 0  
								BEGIN   
									SET @For_Date= @A_From_Date          
									EXEC getAllDaysBetweenTwoDate @A_From_Date,@A_To_Date       
											
									INSERT INTO #Leave_date (for_date)  
									SELECT test1 FROM test1
											
									--Commented By Gadriwala 05122014 for Skip Holiday row as per discuss with hardik bhai,nilay bhai
									--EXEC Calculate_Leave_End_Date @Cmp_ID,@Emp_Id,@Leave_Id,@For_Date,@Total_Leave_used,'O',@M_Cancel_WO_HO     
														
									DECLARE curAsgnLeaveDate CURSOR FOR  
									SELECT for_date FROM #leave_date  
											
									OPEN curAsgnLeaveDate   
									FETCH NEXT FROM curAsgnLeaveDate INTO @For_date  
									WHILE @@FETCH_STATUS = 0  
										BEGIN    
											IF @Total_leave_used = 0.5  
												BEGIN  
													SET @Leave_used =0.5  
												END  
											ELSE IF @Total_leave_used = 0.25  
												BEGIN  
													SET @Leave_used =0.25  
												END  
											ELSE IF @Total_leave_used = 0.75  
												BEGIN  
													SET @Leave_used =0.75  
												END  
											ELSE  
												BEGIN  
													IF @For_Date = @Half_Leave_Date   -- Changed by Gadriwala Muslim 10092014
														SET @Leave_used = 0.5  
													ELSE
														BEGIN
															IF @Apply_Hourly = 0
																SET @Leave_used = 1  
															ELSE 
																SET @Leave_Used = @Total_Leave_used 
														END	
												END  
						             
											IF @is_backdated_application = 0
												BEGIN
													--Added condition by hardik 19/12/2014 for Vital Soft, Half payment AND full payment
													IF @Half_Payment = 1 
														SET @Half_Payment_Days = @Leave_Used
															
													IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION WHERE leave_id = @leave_Id AND emp_id = @emp_id AND for_date = @for_date   AND Cmp_ID = @Cmp_ID   AND Leave_used >= @Leave_Used)
														BEGIN
															UPDATE	T0140_LEAVE_TRANSACTION 
															SET		Leave_Used = IsNull(Leave_Used,0) - @Leave_Used,
																	Half_Payment_Days = IsNull(Half_Payment_Days,0) - @Half_Payment_Days,
																	Leave_Closing = IsNull(Leave_Closing,0) + @Leave_Used + @Half_Payment_Days
															WHERE	leave_id = @leave_Id AND emp_id = @emp_id AND for_date = @for_date
																	AND Cmp_ID = @Cmp_ID  AND Leave_used >= @Leave_Used

															SET @Total_Leave_Used = @Total_leave_used - @Leave_Used - @Half_Payment_Days
														END
												END
											ELSE
												BEGIN
													SELECT	@Back_Dated_Leave = Back_Dated_Leave 
													FROM	T0140_LEAVE_TRANSACTION   
													WHERE	leave_id = @leave_Id AND emp_id = @emp_id AND for_date = @for_date AND Cmp_ID = @Cmp_ID  
																						
													IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION WHERE leave_id = @leave_Id AND emp_id = @emp_id AND for_date = @for_date   AND Cmp_ID = @Cmp_ID   AND Back_Dated_Leave >= @Leave_Used)
														BEGIN
															UPDATE	T0140_LEAVE_TRANSACTION 
															SET		Leave_Used = 0,Leave_Closing = IsNull(Leave_Closing,0) + @Leave_Used + @Half_Payment_Days,
																	Back_Dated_Leave = IsNull(@Back_Dated_Leave,0) - @Leave_Used - @Half_Payment_Days
															WHERE	Leave_ID = @leave_Id AND emp_id = @emp_id AND for_date = @for_date AND Cmp_ID = @Cmp_ID 
																	AND Back_Dated_Leave >= @Leave_Used
																								
															SET @Total_Leave_Used = @Total_leave_used - @Leave_Used -@Half_Payment_Days 
														END
												END
																					
											IF @Leave_Type = 'ESIC Leave'  -- Added by Gadriwala Muslim 15/09/2015
												BEGIN
													SELECT	@Auto_credit_ML = Setting_Value 
													FROM	T0040_SETTING 
													WHERE	Cmp_ID = @Cmp_ID 
															AND  Setting_Name = 'Auto credit one medical leave when first time ESIC leave have approved in year'
															
													IF @Auto_credit_ML = 1 
														BEGIN
															SET @Medical_Leave_ID = 0
															SET @Auto_credit_ML = 0
															SET @Medical_Last_Closing = 0
															SET @Year_Start_Date = dbo.GET_MONTH_ST_DATE(month(@A_From_Date),Year(@A_From_Date))
															SET @Year_End_Date = dbo.GET_MONTH_END_DATE(month(@A_From_Date),Year(@A_From_date))
												
															SELECT	@Medical_Leave_ID = Leave_ID 
															FROM	T0040_LEAVE_MASTER 
															WHERE	Cmp_ID = @Cmp_ID AND Medical_Leave = 1
												
															If  EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION WHERE Leave_ID = @Medical_Leave_ID  AND For_Date = @Leave_Approval_Date AND Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID AND Leave_credit > 0)						
																BEGIN
																	SELECT @ML_Trans_ID = Leave_Tran_ID FROM T0140_LEAVE_TRANSACTION WHERE Leave_ID = @Medical_Leave_ID  AND For_Date = @Leave_Approval_Date AND Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID
																			
																	UPDATE T0140_LEAVE_TRANSACTION 
																	set Leave_Credit = 0, Leave_Closing = Leave_Opening  - Leave_Used
																	WHERE  Leave_Tran_ID = @ML_Trans_ID AND Cmp_ID = @Cmp_ID  
																			
																	IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION LT 
																					LEFT OUTER JOIN (SELECT For_date,LT.Leave_ID,Emp_ID 
																										FROM	T0140_LEAVE_TRANSACTION LT 
																											INNER JOIN T0040_LEAVE_MASTER LM  ON LT.Leave_ID = LM.Leave_ID  
																									WHERE	LT.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id  AND LT.For_Date >= @A_From_Date 
																											AND LT.For_Date <= @A_To_Date AND leave_used > 0 AND Leave_Type = 'ESIC Leave') Qry  ON Qry.For_Date = LT.For_Date AND Qry.Leave_ID = LT.Leave_ID AND Qry.emp_id = LT.emp_id  
																					INNER JOIN T0040_LEAVE_MASTER LM  on LT.Leave_ID = LM.Leave_ID 
																				WHERE	LT.For_Date >= @Year_Start_Date AND LT.For_Date <= @Year_End_Date 
																					AND LT.Cmp_ID = @Cmp_ID AND LT.Emp_ID = @Emp_Id AND Leave_Used >0 
																					AND Leave_Type = 'ESIC Leave' AND IsNull(Qry.emp_id,0) = 0)
																		BEGIN
																			DECLARE @ML_Approval_Date AS DATETIME
																				
																			SELECT	TOP 1 @ML_Approval_Date = Approval_Date 
																			FROM	T0120_LEAVE_APPROVAL LA 
																					INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																					INNER JOIN T0040_LEAVE_MASTER LM  ON LAD.Leave_ID = LM.Leave_ID 
																			WHERE	From_Date >= @Year_Start_Date AND From_Date <=@Year_End_Date AND LA.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id AND LM. Leave_Type = 'ESIC Leave'
																				
																			IF  EXISTS( SELECT 1 FROM T0140_LEAVE_TRANSACTION WHERE Leave_ID = @Medical_Leave_ID  AND For_Date = @ML_Approval_Date AND Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID)						
																				BEGIN
																					SELECT	@ML_Trans_ID = Leave_Tran_ID 
																					FROM	T0140_LEAVE_TRANSACTION 
																					WHERE	Leave_ID = @Medical_Leave_ID  AND For_Date = @ML_Approval_Date AND Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID

																					UPDATE	T0140_LEAVE_TRANSACTION 
																					SET		Leave_Credit = Leave_Credit + 1, Leave_Closing = (Leave_Opening + Leave_Credit + 1 ) - Leave_Used
																					WHERE	Leave_Tran_ID = @ML_Trans_ID AND Cmp_ID = @Cmp_ID
																				END
																			ELSE
																				BEGIN
																					SELECT @ML_Trans_ID = IsNull(MAX(Leave_Tran_ID),0) + 1 FROM T0140_LEAVE_TRANSACTION 
																						
																					SELECT	@Medical_Last_Closing = IsNull(Leave_Closing,0) 
																					FROM	T0140_LEAVE_TRANSACTION  
																					WHERE	FOR_DATE = (SELECT	MAX(for_date) FROM T0140_LEAVE_TRANSACTION 
																										WHERE	for_date <= @ML_Approval_Date AND leave_Id = @Medical_Leave_ID AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id)   
																							AND Cmp_ID = @Cmp_ID AND leave_id = @Medical_Leave_ID AND emp_Id = @emp_Id  
																						
																					INSERT INTO T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Credit,Leave_Used,Leave_Closing,Leave_Tran_ID)  
																					VALUES(@emp_id,@Medical_Leave_ID,@Cmp_ID,@ML_Approval_Date,@Medical_Last_Closing,1,0, @Medical_Last_Closing + 1 ,@ML_Trans_ID)  
																				END
																				
																			SELECT	@Medical_Last_Closing = IsNull(Leave_Closing,0) 
																			FROM	T0140_LEAVE_TRANSACTION 
																			WHERE	For_Date = (SELECT	MAX(for_date) FROM T0140_LEAVE_TRANSACTION 
																								WHERE	For_Date <= @ML_Approval_Date AND leave_Id = @Medical_Leave_ID AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id)   
																					AND Cmp_ID = @Cmp_ID AND leave_id = @Medical_Leave_ID AND emp_Id = @emp_Id  
					                           
					  														IF @Medical_Last_Closing IS NULL  
																				SET @Medical_Last_Closing = 0          
																				     
																			DECLARE curMedicalLeave CURSOR FOR   
																			SELECT	Leave_Tran_ID,For_Date 
																			FROM	dbo.T0140_LEAVE_TRANSACTION 
																			WHERE	Leave_ID = @Medical_Leave_ID AND Emp_ID = @emp_id AND Cmp_ID = @Cmp_ID 
																					AND for_date > @ML_Approval_Date 
																			ORDER BY for_date  
																					
																			OPEN curMedicalLeave 
																			FETCH NEXT FROM curMedicalLeave INTO @cur_ML_tran_ID,@Cur_ML_For_Date  
																			WHILE @@FETCH_STATUS = 0  
																				BEGIN  
																					IF EXISTS(SELECT Leave_Op_Id FROM T0095_LEAVE_OPENING 
																								WHERE	Cmp_ID = @Cmp_ID AND Emp_Id = @Emp_Id AND Leave_ID = @Medical_Leave_ID 
																									AND For_Date = @Cur_ML_For_Date AND Leave_Op_Days > 0)  
																						Or @Medical_Posting IS NOT NULL
																						BEGIN  
																							Goto Medical3;  
																						END  
																		          
																					SELECT @Medical_Posting = Leave_Posting FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @cur_ML_tran_ID 
																							
																					UPDATE	dbo.T0140_LEAVE_TRANSACTION 
																					SET		Leave_Opening = @Medical_Last_Closing,
																							Leave_Closing = @Medical_Last_Closing + IsNull(Leave_Credit,0) - IsNull(Leave_Used,0) - IsNull(Leave_Encash_Days,0) - IsNull(Back_Dated_Leave,0) - IsNull(Half_Payment_Days,0)
																					WHERE	leave_tran_id = @cur_ML_tran_ID  
																									
																					Medical3:     
																						SET @Medical_Last_Closing = IsNull((SELECT IsNull(Leave_Closing,0) FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @cur_ML_tran_ID),0)  
																		          
																					FETCH NEXT FROM curMedicalLeave INTO @cur_ML_tran_ID,@Cur_ML_For_Date  
																				END  
																			CLOSE curMedicalLeave  
																			DEALLOCATE curMedicalLeave   	
																		END
																END
																	
															SELECT	@Medical_Last_Closing = IsNull(Leave_Closing,0) 
															FROM	T0140_LEAVE_TRANSACTION  
															WHERE	for_date = (SELECT	MAX(for_date) FROM T0140_LEAVE_TRANSACTION 
																				WHERE	For_Date <= @Leave_Approval_Date  
																						AND leave_Id = @Medical_Leave_ID AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id)   
																	AND Cmp_ID = @Cmp_ID AND leave_id = @Medical_Leave_ID AND emp_Id = @emp_Id  
					                           
					  										IF @Medical_Last_Closing IS NULL  
																SET @Medical_Last_Closing = 0          
																				     
																				
															DECLARE curMedicalLeave CURSOR FOR   
															SELECT	Leave_Tran_ID,For_Date 
															FROM	dbo.T0140_LEAVE_TRANSACTION 
															WHERE	Leave_ID = @Medical_Leave_ID AND Emp_ID = @Emp_Id   
																	AND Cmp_ID = @Cmp_ID AND for_date > @Leave_Approval_Date 
															ORDER BY for_date  
																	
															OPEN curMedicalLeave 
															FETCH NEXT FROM curMedicalLeave INTO @cur_ML_tran_ID,@Cur_ML_For_Date  
															WHILE @@FETCH_STATUS = 0  
																BEGIN  
																	IF EXISTS(SELECT Leave_Op_Id FROM T0095_LEAVE_OPENING WHERE Cmp_ID = @Cmp_ID AND Emp_Id = @Emp_Id AND Leave_ID = @Medical_Leave_ID AND For_Date = @Cur_ML_For_Date AND Leave_Op_Days > 0)  
																		Or @Medical_Posting IS NOT NULL
																		BEGIN  
																			Goto Medical2;  
																		END  
																			
																	SELECT @Medical_Posting = Leave_Posting FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @cur_ML_tran_ID 
																	BEGIN  
																		BEGIN  
																			UPDATE	dbo.T0140_LEAVE_TRANSACTION 
																			SET		Leave_Opening = @Medical_Last_Closing,
																					Leave_Closing = @Medical_Last_Closing + IsNull(Leave_Credit,0) - IsNull(Leave_Used,0) - IsNull(Leave_Encash_Days,0) - IsNull(Back_Dated_Leave,0) - IsNull(Half_Payment_Days,0)
																			WHERE	Leave_Tran_ID = @cur_ML_tran_ID  
																				  
																			Medical2:     
																				SET @Medical_Last_Closing = IsNull((SELECT IsNull(Leave_Closing,0) FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @cur_ML_tran_ID),0)  
																		END  
																	END																		          
																	FETCH NEXT FROM curMedicalLeave INTO @cur_ML_tran_ID,@Cur_ML_For_Date  
																END  
															CLOSE curMedicalLeave  
															DEALLOCATE curMedicalLeave       	
														END
												END
		            
											FETCH NEXT FROM curAsgnLeaveDate INTO @For_date  
										END  
									CLOSE curAsgnLeaveDate  
									DEALLOCATE curAsgnLeaveDate   
											
									FETCH NEXT FROM curDel INTO @Leave_Approval_Id,@Leave_Id , @Total_Leave_Used,@A_From_Date,@A_To_Date,@Half_Leave_Date,@Half_Payment
								END    
							CLOSE curDel  
							DEALLOCATE curDel  
								
							SET @For_Date= @A_From_Date  
       
							DECLARE @ERROR_MSG NVARCHAR(50)
							SET @ERROR_MSG=''
									
							SELECT	@Pre_Closing = IsNull(Leave_Closing,0) 
							FROM	T0140_LEAVE_TRANSACTION  
							WHERE	for_date = (SELECT	MAX(for_date) 
												FROM	T0140_LEAVE_TRANSACTION 
												WHERE	for_date <= @For_date AND leave_Id = @leave_id 
														AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id)   
									AND Cmp_ID = @Cmp_ID  
									AND leave_id = @leave_Id AND emp_Id = @emp_Id  
				       
							IF	@Pre_Closing is null  
								SET @Pre_Closing = 0 
										 
							DECLARE @Leave_Negative_Max_Limit  NUMERIC (9,2)
							SELECT	@Leave_negative_Allow = IsNull(Leave_negative_Allow,0),	
									@Leave_Negative_Max_Limit = IsNull(leave_negative_max_limit,0)
							FROM	T0040_leave_master 
							WHERE	Leave_ID =@Leave_ID 	
									
							DECLARE curLeaveTran CURSOR FOR   
							SELECT	Leave_Tran_ID,For_Date 
							FROM	dbo.T0140_LEAVE_TRANSACTION 
							WHERE	leave_id = @leave_Id AND emp_id = @emp_id   
									AND Cmp_ID = @Cmp_ID AND for_date > @For_date order by for_date  
									
							OPEN curLeaveTran  
							FETCH NEXT FROM curLeaveTran INTO @Chg_Tran_Id,@For_Date_Cur  
								WHILE @@FETCH_STATUS = 0  
									BEGIN  
										IF EXISTS(SELECT Leave_Op_Id FROM T0095_LEAVE_OPENING WHERE Cmp_ID = @Cmp_ID AND Emp_Id = @Emp_Id AND Leave_ID = @Leave_Id AND For_Date = @For_Date_Cur AND Leave_Op_Days > 0)  
											OR @Leave_Posting IS NOT NULL  --Change by Jaina 15-11-2017 (After Discuss with Nimeshbhai)
											BEGIN  
												BREAK
											End  

										SELECT	@Leave_Posting = Leave_Posting 
										FROM	dbo.T0140_LEAVE_TRANSACTION 
										WHERE	leave_tran_id = @Chg_Tran_Id  
													
										UPDATE	dbo.T0140_LEAVE_TRANSACTION 
										SET		Leave_Opening = @Pre_Closing,
												Leave_Closing = @Pre_Closing + IsNull(Leave_Credit,0) - IsNull(Leave_Used,0) - IsNull(Leave_Encash_Days,0) - IsNull(Back_Dated_Leave,0) - IsNull(Half_Payment_Days,0)
										WHERE	Leave_Tran_ID = @Chg_Tran_Id 
																
																																
										
										IF	@Leave_negative_Allow = 1 AND @Leave_Negative_Max_Limit > 0
											AND EXISTS(SELECT	1	 
															FROM	dbo.T0140_LEAVE_TRANSACTION LT INNER JOIN
																	T0040_LEAVE_MASTER L on L.Leave_ID = LT.Leave_ID
															WHERE	Leave_Tran_ID = @Chg_Tran_Id 
																	AND (Leave_Closing < (@Leave_Negative_Max_Limit * -1)
																	AND (L.Default_Short_Name <> 'COMP'))) --Added by Jaina 15-02-2018
											BEGIN
												SET @ERROR_MSG=	'@@Negative Leave is not allowed Date: ' + CAST(@For_Date_Cur As Varchar(11))	+ '@@'
												RAISERROR(@ERROR_MSG, 16 , 2)
											END
										SET @Pre_Closing = IsNull((SELECT IsNull(Leave_Closing,0) FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @Chg_Tran_Id),0)  
			        
										FETCH NEXT FROM curLeaveTran INTO @Chg_Tran_Id,@For_Date_Cur  
									END  
								CLOSE curLeaveTran  
								DEALLOCATE curLeaveTran            
						END -- Approval Flag  
							
					SET @ERROR_MSG=''
				END
		END  


