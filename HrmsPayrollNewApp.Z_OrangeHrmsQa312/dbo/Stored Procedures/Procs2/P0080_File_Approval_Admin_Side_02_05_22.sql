


CREATE PROCEDURE [dbo].[P0080_File_Approval_Admin_Side_02_05_22]  
	 @FA_Id numeric(9) output  
	 ,@File_App_Id int
	,@Cmp_ID   numeric(9)  
	,@ApplicationDate Datetime 
	,@ApproveDate DateTime
	,@Branch_Id int
	,@Dept_Id int 
	,@Desig_Id int 
	,@Emp_Id int
	,@S_Emp_Id int
	,@FileNumber nvarchar(50)
	,@FileStatus_Id int
	,@FileType_Id int
	,@tran_type  varchar(1) 
	,@Subject nvarchar(500)
	,@Description nvarchar(max)
	,@ProcessDate Datetime 
	,@FileName nvarchar(max) 
	,@LoginID int
	,@Forward_Emp_Id int
	,@Submit_Emp_Id int
	,@Comment nvarchar(350)
	,@Rpt_Level			INT--added
	,@Is_Fwd_Leave_Rej	NUMERIC = 0--added
	,@Final_Approval		NUMERIC = 0--added
	,@IP_Address varchar(30)= ''
	,@Review_Emp_Id	NUMERIC = 0--added
	,@Reviewed_by_Emp_Id		NUMERIC = 0--added
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  --Created by mansi
   -- Add (start)
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	set @String=''
	set @OldValue =''
	-- Add (end)
	-- Add for audit(start)  
		  declare @OldValue_lvl as  varchar(max)  
		  Declare @String_lvl as varchar(max)  
		  set @String_lvl=''  
		  set @OldValue_lvl =''  
		 -- Add for audit (end)  
	-- Add for audit(start)  
		  declare @OldValue_app as  varchar(max)  
		  Declare @String_app as varchar(max)  
		  set @String_app=''  
		  set @OldValue_app =''  
		 -- Add for audit (end)   
  declare @F_Appr_Id Numeric
  
  DECLARE @Tran_ID	NUMERIC
	SET @Tran_ID = 0
	declare @tran_id_curr as numeric 
	set @tran_id_curr=0
	 --   IF EXISTS( SELECT 1 FROM T0080_File_Approval WITH (NOLOCK) Where File_Apr_Id = @FA_Id  )
		--BEGIN
		--	 set @FA_Id = 0  
		--	 Return  
		--END
 If @tran_type  = 'I'  
  Begin
  SET @F_Appr_Id = 0
  --print 1
  --IF EXISTS( SELECT 1 FROM T0120_GATE_PASS_APPROVAL WITH (NOLOCK) WHERE Emp_ID = @Emp_Id AND From_Time = @From_Time AND To_Time = @To_Time AND Duration = @Duration )
		--		BEGIN
		--			RAISERROR('@@ GatePass For Same Time Already Approved @@',16,2)
		--			RETURN;
		--		END
		----commented on 18-04-22 start
		--IF @Rpt_Level > 0
		--		BEGIN	
		--		print 3
		--			SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM dbo.T0115_File_Level_Approval WITH (NOLOCK)
					
		--			INSERT INTO dbo.T0115_File_Level_Approval
		--				   (Tran_ID,Approve_Date,File_Apr_Id,Cmp_Id,File_App_Id,Emp_Id,File_Number,F_StatusId,F_TypeId,Subject,Description,Process_Date,File_App_Doc,Forward_Emp_Id,Submit_Emp_Id,Approval_Comments,S_Emp_Id,Rpt_Level,System_Date,[User ID] )
		--			VALUES (@Tran_ID,@ApproveDate,@FA_Id,@Cmp_ID,@File_App_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@S_Emp_Id,@Rpt_Level,getDate(),@LoginID)	
		--	-- Add for audit(start)
		--	exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='Tran_ID',@key_Values=@Tran_ID,@String=@String output
		--	set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
		---- Add for audit(end)	
		--			SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM dbo.T0115_File_Level_Approval WITH (NOLOCK)
				  
		--		  set @F_Appr_Id=@Tran_ID
		--		END
		----commented on 18-04-22 end
		IF @Final_Approval = 1 OR (@Is_Fwd_Leave_Rej = 0 )
				BEGIN
				--print 4
					IF @Rpt_Level = 0 AND @File_App_Id = 0
						BEGIN
						  exec P0080_File_Application_Admin_Side @File_App_Id OUTPUT,@Cmp_ID,@ApplicationDate,@Branch_Id,@Dept_Id,@Desig_Id,@Emp_Id,@S_Emp_Id,@FileNumber,@FileType_Id,'I',@Subject,@Description,@ProcessDate,@FileName,@LoginID
							--EXEC P0100_GATE_PASS_APPLICATION @File_App_Id OUTPUT,@Cmp_ID,@Emp_ID,@Apr_Date,@For_Date,@From_Time,@To_Time,@Duration,@Reason_ID,'Gate-Pass Direct Approved by Admin',@Login_ID,'I'
						END
						
					--SELECT @FA_Id = ISNULL(MAX(File_Apr_Id),0) + 1 FROM dbo.T0080_File_Approval WITH (NOLOCK)
	-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0080_File_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			
		-- Add for audit(end)	
			if(@FileStatus_Id=4)
			begin
			INSERT INTO T0080_File_Approval (Approve_Date,Branch_Id,Dept_Id,Desig_Id,Emp_Id,S_Emp_Id,
			File_Number,F_StatusId,F_TypeId,Subject,Description,Process_Date,File_App_Doc,Cmp_ID,
			CreatedDate,[User ID],Forward_Emp_Id,Submit_Emp_Id,CreatedBy,File_App_Id,Approval_Comments,Review_Emp_Id,Reviewed_by_Emp_Id)
			VALUES(@ApproveDate,@Branch_Id,@Dept_Id,@Desig_Id,@Emp_Id,@S_Emp_Id,@FileNumber,
			 @FileStatus_Id,@FileType_Id,@Subject,@Description,@ProcessDate,
			 @FileName,@Cmp_ID,GETDATE(),@LoginID,@Forward_Emp_Id,@Submit_Emp_Id,@LoginID,@File_App_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id)
    		--for History start
				SELECT @FA_Id = ISNULL(MAX(File_Apr_Id),0)  FROM dbo.T0080_File_Approval WITH (NOLOCK)
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
					VALUES (@Cmp_ID,@File_App_Id,@FA_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,@tran_type,@Tran_ID,'T0080_File_Approval')	
					--for History end
		-- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Approval',@OldValue,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)			----Update file_apr_id,status based in file_level_approve
		  
			end
		if(@FileStatus_Id=3)
		begin
		--set @FA_Id=0---added
			-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String_lvl output
			set @OldValue_lvl = @OldValue_lvl + 'New Value' + '#' + cast(@String_lvl as varchar(max))
		-- Add for audit(end)	
			update  T0115_File_Level_Approval set --File_Apr_Id=@FA_Id,
			F_StatusId=@FileStatus_Id,File_App_Doc=@FileName,
			Process_Date=@ProcessDate,Approval_Comments=@Comment,System_Date=GETDATE()
			,Forward_Emp_Id=@Forward_Emp_Id,Submit_Emp_Id=@Submit_Emp_Id,
			Subject=@Subject,Description=@Description
			where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID
				and Rpt_Level=(select max(Rpt_Level)from T0115_File_Level_Approval 
                 where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)
				
			-- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,'U','File Level Approve',@OldValue_lvl,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)
		----for History start
		--				INSERT INTO dbo.T0115_File_Level_Approval_History
		--				   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
		--			VALUES (@Cmp_ID,@File_App_Id,@FA_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,'U',@Tran_ID,'T0115_File_Level_Approval')	
		--			--for History end
		end
		 else if(@FileStatus_Id=2) 
		begin
		 ----set @FA_Id=0--added
			-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String_lvl output
			set @OldValue_lvl = @OldValue_lvl + 'New Value' + '#' + cast(@String_lvl as varchar(max))
		-- Add for audit(end)	
		   update  T0115_File_Level_Approval set --File_Apr_Id=@FA_Id,
		   F_StatusId=@FileStatus_Id,File_App_Doc=@FileName,
			Process_Date=@ProcessDate,Approval_Comments=@Comment,
			--Review_Emp_Id=@Review_Emp_Id,Reviewed_by_Emp_Id=@Reviewed_by_Emp_Id,--added 23-05-22
			--System_Date=GETDATE()
			--,Forward_Emp_Id=@Forward_Emp_Id,Submit_Emp_Id=@Submit_Emp_Id,
			Subject=@Subject,Description=@Description
			where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID
				and Rpt_Level=(select max(Rpt_Level)from T0115_File_Level_Approval 
                 where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)
				
		 -- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,'U','File Level Approve',@OldValue_lvl,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)
		----for History start
		--				INSERT INTO dbo.T0115_File_Level_Approval_History
		--				   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
		--			VALUES (@Cmp_ID,@File_App_Id,@FA_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,'U',@Tran_ID,'T0115_File_Level_Approval')	
		--			--for History end
		end
        else if(@FileStatus_Id=5) 
		begin
		 ----set @FA_Id=0--added
			-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String_lvl output
			set @OldValue_lvl = @OldValue_lvl + 'New Value' + '#' + cast(@String_lvl as varchar(max))
		-- Add for audit(end)	
		   update  T0115_File_Level_Approval set --File_Apr_Id=@FA_Id,
		   F_StatusId=@FileStatus_Id,File_App_Doc=@FileName,
			Process_Date=@ProcessDate,Approval_Comments=@Comment,
			Review_Emp_Id=@Review_Emp_Id,Reviewed_by_Emp_Id=@Reviewed_by_Emp_Id,--added 23-05-22
			--System_Date=GETDATE()
			--,Forward_Emp_Id=@Forward_Emp_Id,Submit_Emp_Id=@Submit_Emp_Id,
			Subject=@Subject,Description=@Description
			where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID
				and Rpt_Level=(select max(Rpt_Level)from T0115_File_Level_Approval 
                 where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)
				
		 -- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,'U','File Level Approve',@OldValue_lvl,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)
		----for History start
		--				INSERT INTO dbo.T0115_File_Level_Approval_History
		--				   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
		--			VALUES (@Cmp_ID,@File_App_Id,@FA_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,'U',@Tran_ID,'T0115_File_Level_Approval')	
		--			--for History end
		end
		  else if(@FileStatus_Id=4)
		begin
		--print 44
         --print @FA_Id--mansi
		-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String_lvl output
			set @OldValue_lvl = @OldValue_lvl + 'New Value' + '#' + cast(@String_lvl as varchar(max))
		-- Add for audit(end)	
		   update  T0115_File_Level_Approval set File_Apr_Id=@FA_Id,F_StatusId=@FileStatus_Id,
		    File_App_Doc=@FileName,Process_Date=@ProcessDate,
		   Approval_Comments=@Comment
		   ,Subject=@Subject,Description=@Description
		    ,[User ID] = @LoginID--added
			,Forward_Emp_Id=0,Submit_Emp_Id=0,
			@Review_Emp_Id=0,@Review_Emp_Id=0
			--,Forward_Emp_Id=@Forward_Emp_Id,Submit_Emp_Id=@Submit_Emp_Id,
			--@Review_Emp_Id=@Review_Emp_Id,@Review_Emp_Id=@Reviewed_by_Emp_Id
			where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID
				and Rpt_Level=(select max(Rpt_Level)from T0115_File_Level_Approval 
                 where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)
			 --for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
					VALUES (@Cmp_ID,@File_App_Id,@FA_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,'U',@Tran_ID,'T0115_File_Level_Approval')	
					--for History end	
		end
				
				----if(@FileStatus_Id<>4)
				----begin
				----set @Tran_ID=(select tran_id from T0115_File_Level_Approval 
				----where rpt_level= (select max(Rpt_Level) from T0115_File_Level_Approval 
    ----             where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)and File_App_Id=@File_App_Id)
				----end
			
		-- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,'U','File Level Approve',@OldValue_lvl,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)	
		
		----Update file_apr_id,status based in file_level_approve
		 		-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0080_File_Application' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String_app output
			set @OldValue_app = @OldValue_app + 'New Value' + '#' + cast(@String_app as varchar(max))
				-- Add for audit(end)
			Update T0080_File_Application set F_StatusId =@FileStatus_Id,UpdatedByUserId=@LoginID,UpdatedDate=GETDATE() 
			WHERE File_App_Id = @File_App_Id AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID
			
	-- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,'U','File Application',@OldValue_app,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)		
			--SELECT @FA_Id = ISNULL(MAX(File_Apr_Id),0) + 1 FROM dbo.T0080_File_Approval WITH (NOLOCK)
			if(@FileStatus_Id=4)
			begin
			SELECT @FA_Id = ISNULL(MAX(File_Apr_Id),0)+1 FROM dbo.T0080_File_Approval WITH (NOLOCK)	
			  set @F_Appr_Id=@FA_Id			  
				set @FA_Id=@F_Appr_Id
				end
				else
				begin
				set @tran_id_curr=(select tran_id from T0115_File_Level_Approval 
				where rpt_level= (select max(Rpt_Level) from T0115_File_Level_Approval 
                 where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)and File_App_Id=@File_App_Id)
				 set @FA_Id=@tran_id_curr
				end
   end
   
  end
 Else if @Tran_Type = 'U' 
 begin
 SET @F_Appr_Id = 0
  begin   
   ----print 2
   -- if (@FA_Id<>0)
	
	 -----commented start 03-06-22
		--	UPDATE	dbo.T0080_File_Approval set 
		--		 File_App_Doc=@FileName,Subject=@Subject,Description=@Description
		--		 ,Process_Date=@ProcessDate,F_StatusId=@FileStatus_Id,Approval_Comments=@Comment,
		--		 Approve_Date=@ApproveDate,Forward_Emp_Id=@Forward_Emp_Id,Submit_Emp_Id=@Submit_Emp_Id
		--		 ,UpdatedBy=@LoginID,UpdatedDate=GETDATE()
		--		 ,Review_Emp_Id=@Review_Emp_Id,Reviewed_by_Emp_Id=@Reviewed_by_Emp_Id--added by 23-05-22
		--		 --added 05-04-22
		--		 where File_App_Id=@File_App_Id and File_Apr_Id=@FA_Id  and Emp_Id=@Emp_Id and Cmp_ID=@Cmp_ID
		--		 --for History start
		--				INSERT INTO dbo.T0115_File_Level_Approval_History
		--				   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
		--			VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,@tran_type,@Tran_ID,'T0080_File_Approval')	
		--			--for History end
  --     		-- Add for audit(start)
		--		exec P9999_Audit_get @table = 'T0080_File_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String output
		--		set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
		--	-- Add for audit(end) 
		--	 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Approval',@OldValue,@Emp_ID,@LoginId,@IP_Address--added
	 --  --  SELECT @FA_Id = ISNULL(MAX(File_Apr_Id),0) + 1 FROM dbo.T0080_File_Approval WITH (NOLOCK)	--commented
	 --   ---commented end 03-06-22
	 if(@FileStatus_Id=4)
	 begin 
	 	-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0080_File_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			
		-- Add for audit(end)	
				
			INSERT INTO T0080_File_Approval (Approve_Date,Branch_Id,Dept_Id,Desig_Id,Emp_Id,S_Emp_Id,
			File_Number,F_StatusId,F_TypeId,Subject,Description,Process_Date,File_App_Doc,Cmp_ID,
			CreatedDate,[User ID],Forward_Emp_Id,Submit_Emp_Id,CreatedBy,File_App_Id,Approval_Comments,Review_Emp_Id,Reviewed_by_Emp_Id)
			VALUES(@ApproveDate,@Branch_Id,@Dept_Id,@Desig_Id,@Emp_Id,@S_Emp_Id,@FileNumber,
			 @FileStatus_Id,@FileType_Id,@Subject,@Description,@ProcessDate,
			 @FileName,@Cmp_ID,GETDATE(),@LoginID,@Forward_Emp_Id,@Submit_Emp_Id,@LoginID,@File_App_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id)
    		--for History start
				SELECT @FA_Id = ISNULL(MAX(File_Apr_Id),0)  FROM dbo.T0080_File_Approval WITH (NOLOCK)
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
					VALUES (@Cmp_ID,@File_App_Id,@FA_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,@tran_type,@Tran_ID,'T0080_File_Approval')	
					--for History end
		-- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Approval',@OldValue,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)	
		
	 end
	   if(@FileStatus_Id=3)
		begin
		----set @FA_Id=0--added
			-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String_lvl output
			set @OldValue_lvl = @OldValue_lvl + 'New Value' + '#' + cast(@String_lvl as varchar(max))
		-- Add for audit(end)	
			update  T0115_File_Level_Approval set --File_Apr_Id=@FA_Id,
			F_StatusId=@FileStatus_Id,File_App_Doc=@FileName,
			Process_Date=@ProcessDate,Approval_Comments=@Comment,System_Date=GETDATE()
			,Forward_Emp_Id=@Forward_Emp_Id,Submit_Emp_Id=@Submit_Emp_Id,
			Subject=@Subject,Description=@Description
			where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID
				and Rpt_Level=(select max(Rpt_Level)from T0115_File_Level_Approval 
                 where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)
				
			-- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,'U','File Level Approve',@OldValue_lvl,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)
		----for History start
		--				INSERT INTO dbo.T0115_File_Level_Approval_History
		--				   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
		--			VALUES (@Cmp_ID,@File_App_Id,@FA_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,'U',@Tran_ID,'T0115_File_Level_Approval')	
		--			--for History end
		end
		 else if(@FileStatus_Id=2) 
		begin
		----set @FA_Id=0--added
			-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String_lvl output
			set @OldValue_lvl = @OldValue_lvl + 'New Value' + '#' + cast(@String_lvl as varchar(max))
		-- Add for audit(end)	
		   update  T0115_File_Level_Approval set --File_Apr_Id=@FA_Id,
		   F_StatusId=@FileStatus_Id,File_App_Doc=@FileName,
			Process_Date=@ProcessDate,Approval_Comments=@Comment,
			--Review_Emp_Id=@Review_Emp_Id,Reviewed_by_Emp_Id=@Reviewed_by_Emp_Id,--added 23-05-22
			--System_Date=GETDATE()
			--,Forward_Emp_Id=@Forward_Emp_Id,Submit_Emp_Id=@Submit_Emp_Id,
			Subject=@Subject,Description=@Description
			where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID
				and Rpt_Level=(select max(Rpt_Level)from T0115_File_Level_Approval 
                 where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)
				
		 -- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,'U','File Level Approve',@OldValue_lvl,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)
		----for History start
		--				INSERT INTO dbo.T0115_File_Level_Approval_History
		--				   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
		--			VALUES (@Cmp_ID,@File_App_Id,@FA_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,'U',@Tran_ID,'T0115_File_Level_Approval')	
		--			--for History end
		end
        else if(@FileStatus_Id=5) 
		begin
		----set @FA_Id=0--added
			-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String_lvl output
			set @OldValue_lvl = @OldValue_lvl + 'New Value' + '#' + cast(@String_lvl as varchar(max))
		-- Add for audit(end)	
		   update  T0115_File_Level_Approval set --File_Apr_Id=@FA_Id,
		   F_StatusId=@FileStatus_Id,File_App_Doc=@FileName,
			Process_Date=@ProcessDate,Approval_Comments=@Comment,
			Review_Emp_Id=@Review_Emp_Id,Reviewed_by_Emp_Id=@Reviewed_by_Emp_Id,--added 23-05-22
			--System_Date=GETDATE()
			--,Forward_Emp_Id=@Forward_Emp_Id,Submit_Emp_Id=@Submit_Emp_Id,
			Subject=@Subject,Description=@Description
			where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID
				and Rpt_Level=(select max(Rpt_Level)from T0115_File_Level_Approval 
                 where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)
				
		 -- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,'U','File Level Approve',@OldValue_lvl,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)
		----for History start
		--				INSERT INTO dbo.T0115_File_Level_Approval_History
		--				   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
		--			VALUES (@Cmp_ID,@File_App_Id,@FA_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,'U',@Tran_ID,'T0115_File_Level_Approval')	
		--			--for History end
		end
		 	  else if(@FileStatus_Id=4)
		begin 
		--print 123
		--print @FileStatus_Id

		-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String_lvl output
			set @OldValue_lvl = @OldValue_lvl + 'New Value' + '#' + cast(@String_lvl as varchar(max))
		-- Add for audit(end)	
		   update  T0115_File_Level_Approval set File_Apr_Id=@FA_Id,F_StatusId=@FileStatus_Id,
		   File_App_Doc=@FileName,Process_Date=@ProcessDate,
		   Approval_Comments=@Comment
		   ,Subject=@Subject,Description=@Description
		    ,[User ID] = @LoginID--added
			,Forward_Emp_Id=0,Submit_Emp_Id=0,
			@Review_Emp_Id=0,@Review_Emp_Id=0
			--,Forward_Emp_Id=@Forward_Emp_Id,Submit_Emp_Id=@Submit_Emp_Id,
			--@Review_Emp_Id=@Review_Emp_Id,@Review_Emp_Id=@Reviewed_by_Emp_Id
			where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID
				and Rpt_Level=(select max(Rpt_Level)from T0115_File_Level_Approval 
                 where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)
				
				
		end
		 if(@FileStatus_Id<>4)
				begin
				set @Tran_ID=(select tran_id from T0115_File_Level_Approval 
				where rpt_level= (select max(Rpt_Level) from T0115_File_Level_Approval 
                 where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)and File_App_Id=@File_App_Id)
				end
			--for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
					VALUES (@Cmp_ID,@File_App_Id,@FA_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,'U',@Tran_ID,'T0115_File_Level_Approval')	
					--for History end	
		-- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,'U','File Level Approve',@OldValue_lvl,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)	
		
	   -- Add for audit(start)
			exec P9999_Audit_get @table = 'T0080_File_Application' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String_app output
			set @OldValue_app = @OldValue_app + 'New Value' + '#' + cast(@String_app as varchar(max))
				-- Add for audit(end)		
			
			Update T0080_File_Application set F_StatusId =@FileStatus_Id,UpdatedByUserId=@LoginID,UpdatedDate=GETDATE() 
			WHERE File_App_Id = @File_App_Id AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID
			
	-- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,'U','File Application',@OldValue_app,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)	
	  if(@FileStatus_Id=4)
			begin
			SELECT @FA_Id = ISNULL(MAX(File_Apr_Id),0)+1 FROM dbo.T0080_File_Approval WITH (NOLOCK)	
			  set @F_Appr_Id=@FA_Id
			  
				set @FA_Id=@F_Appr_Id
				end
				else
				begin
				set @tran_id_curr=(select tran_id from T0115_File_Level_Approval 
				where rpt_level= (select max(Rpt_Level) from T0115_File_Level_Approval 
                 where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)and File_App_Id=@File_App_Id)
				 set @FA_Id=@tran_id_curr
				end
		--end
	end
		
	
  end  
 

 Else if @Tran_Type = 'D'  
  begin 
  SET @F_Appr_Id = 0
  DECLARE @Se_emp_id AS NUMERIC(18,0)
			SET @Se_emp_id = 0
			SET @Tran_id = 0
			SELECT @Se_emp_id = S_Emp_ID,@Tran_id = Tran_ID,@Rpt_Level = Rpt_Level FROM T0115_File_Level_Approval WITH (NOLOCK)
			WHERE  File_App_Id=@File_App_Id AND Rpt_Level IN (SELECT MAX(Rpt_Level) FROM T0115_File_Level_Approval WITH (NOLOCK) WHERE File_App_Id=@File_App_Id )
			
			IF @Se_emp_id = @S_Emp_ID --AND @Apr_ID = 0
				BEGIN
					--select @Tran_ID
					DELETE FROM T0115_File_Level_Approval WHERE Tran_id = @Tran_ID
				END
			
			IF @FA_Id <> 0 
				BEGIN
					--Comment by Jaina 08-05-2017 ( In Final Approval, Roll back not wroking)
					--Added By Jimit 02012018
					--If @S_Emp_ID = 0
					--	BEGIN
			-- Add for Audit(start)
			exec P9999_Audit_get @table='T0115_File_Level_Approval' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String_app output
			set @OldValue_lvl = @OldValue_lvl + 'old Value' + '#' + cast(@String as varchar(max))
			 -- Add for Audit(end)
							 DELETE FROM T0115_File_Level_Approval WHERE File_App_Id = @File_App_Id 
				--for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,@tran_type,@Tran_ID,'T0115_File_Level_Approval')	
					--for History end
				-- Add for Audit(start)
			exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Level Approval',@OldValue_lvl,@Emp_ID,@LoginId,@IP_Address
			-- Add for Audit(end)
					--	END
					--Ended
		-- Add for Audit(start)
			exec P9999_Audit_get @table='T0080_File_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String output
			set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
		-- Add for Audit(end)	
			DELETE FROM dbo.T0080_File_Approval WHERE File_Apr_Id = @FA_Id AND File_App_Id = @File_App_Id 	
					--for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,@tran_type,@Tran_ID,'T0080_File_Approval')	
					--for History end
		-- Add for Audit(start)
		 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Approval',@OldValue,@Emp_ID,@LoginId,@IP_Address
		 -- Add for Audit(end)	
				END	
		-- Add for Audit(start)
			exec P9999_Audit_get @table='T0080_File_Application' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String_app output
			set @OldValue_app = @OldValue_app + 'old Value' + '#' + cast(@String as varchar(max))
		-- Add for Audit(end)
		 UPDATE dbo.T0080_File_Application SET F_StatusId = 1 WHERE File_App_Id=@File_App_Id
		 	--for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,@tran_type,'U','T0080_File_Application')	
					--for History end
		 -- Add for Audit(start)
		 exec P9999_Audit_Trail @Cmp_ID,'U','File Application',@OldValue_app,@Emp_ID,@LoginId,@IP_Address
		 	-- Add for Audit(end)
   set @F_Appr_Id=@Tran_ID
   set @FA_Id=@F_Appr_Id
  end
 RETURN

 -- exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Approval',@OldValue,@Emp_ID,@LoginId,@IP_Address

