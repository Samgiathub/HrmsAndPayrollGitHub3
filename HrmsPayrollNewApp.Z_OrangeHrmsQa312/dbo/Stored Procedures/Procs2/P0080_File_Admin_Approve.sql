

					
CREATE PROCEDURE [dbo].[P0080_File_Admin_Approve]  
	  @FA_Id  numeric(9) output  
	   ,@File_App_Id int
	,@Cmp_ID   numeric(9)  
	,@ApproveDate Datetime 
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
	,@IP_Address varchar(30)= '' --added
	,@Review_Emp_Id	NUMERIC = 0--added
	,@Reviewed_by_Emp_Id		NUMERIC = 0--added
	,@Rpt_Level			INT--added
	,@FileTypeNumber  nvarchar(max)--added by mansi 22-08-22
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
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
  --Created by mansi

 If @tran_type  = 'I'  
  Begin  
  if exists (Select File_Apr_Id   from T0080_File_Approval WITH (NOLOCK) Where File_Apr_Id =  @FA_Id and cmp_id=@Cmp_ID  )   
    begin  
     set  @FA_Id  = 0  
     Return  
    end 
	--added for  adding application start
	 if(@File_App_Id=0)
	 begin
	 DECLARE @returnValue INT
	 declare @ApplicationDate as datetime=getdate()
	
     exec P0080_File_Application_Admin_Side @File_App_Id OUTPUT,@Cmp_ID,@ApplicationDate,@Branch_Id,@Dept_Id,@Desig_Id,@Emp_Id,@S_Emp_Id,@FileNumber,@FileType_Id,'I',@Subject,@Description,@ProcessDate,@FileName,@LoginID,@IP_Address,@Comment,@FileTypeNumber---updated by mansi 22-08-22
	 end
	 	--added for  adding application end
			--added for  adding level start
					
		 if not exists(select 1 from T0115_File_Level_Approval where File_App_Id=@File_App_Id and Cmp_Id=@Cmp_ID)
		begin 
		 print 11--mansi
			Declare @tran_Id as numeric
		   Select @tran_Id = ISNULL(MAX(Tran_ID),0) + 1 From T0115_File_Level_Approval WITH (NOLOCK)
		   print @tran_Id
		   -- Add for audit(start)
			
			exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='Tran_Id',@key_Values=@Tran_ID,@String=@String_lvl output
			set @OldValue_lvl = @OldValue_lvl + 'New Value' + '#' + cast(@String_lvl as varchar(max))	 
				-- Add for audit(end)
		   INSERT INTO dbo.T0115_File_Level_Approval
						   (Tran_ID,Approve_Date,File_Apr_Id,Cmp_Id,File_App_Id,Emp_Id,File_Number,F_StatusId,F_TypeId,Subject,Description,Process_Date,File_App_Doc,Forward_Emp_Id,Submit_Emp_Id,Approval_Comments,S_Emp_Id,Rpt_Level,System_Date,[User ID],Review_Emp_Id,Reviewed_by_Emp_Id,File_Type_Number )---updated by mansi 22-08-22
					VALUES (@tran_Id,@ApproveDate,0,@Cmp_ID,@File_App_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@S_Emp_Id,@Rpt_Level,getDate(),@LoginID,@Review_Emp_Id,@Reviewed_by_Emp_Id,@FileTypeNumber)	---updated by mansi 22-08-22
				-- Add for audit(start)
					exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Level Approve',@OldValue,@Emp_ID,@LoginId,@IP_Address
					-- Add for audit(end)	
					--for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type,File_Type_Number)---updated by mansi 22-08-22
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,@tran_type,@Tran_ID,'T0115_File_Level_Approval',@FileTypeNumber)	---updated by mansi 22-08-22
					--for History end
		
		end 
		--added for  adding level end
				--for updating in file_level_fwd tbl start
				if(@FileStatus_Id=3)
				begin
					if not exists(select 1 from T0115_File_Level_Approval_Forward where File_App_Id=@File_App_Id and Cmp_Id=@Cmp_ID and Rpt_Level=@Rpt_Level)
							begin 
								declare @tran_id_fw_i as numeric(18,0)
								set @tran_id_fw_i=(select Tran_Id from T0115_File_Level_Approval 
                                                  where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID and Rpt_Level=@Rpt_Level)
								INSERT INTO dbo.T0115_File_Level_Approval_Forward
									   (Tran_Id,Approve_Date,File_Apr_Id,Cmp_Id,File_App_Id,Emp_Id,File_Number,F_StatusId,F_TypeId,Subject,Description,Process_Date,File_App_Doc,Forward_Emp_Id,Submit_Emp_Id,Approval_Comments,S_Emp_Id,Rpt_Level,System_Date,[User ID],Review_Emp_Id,Reviewed_by_Emp_Id ,File_Type_Number)---updated by mansi 22-08-22
								VALUES (@tran_id_fw_i,@ApproveDate,0,@Cmp_ID,@File_App_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@S_Emp_Id,@Rpt_Level,getDate(),@LoginID,@Review_Emp_Id,@Reviewed_by_Emp_Id,@FileTypeNumber)	---updated by mansi 22-08-22
							end
						UPDATE T0115_File_Level_Approval_Forward  
							 SET Approve_Date= @ApproveDate,
							 F_StatusId=@FileStatus_Id
							 ,F_TypeId =@FileType_Id
							 ,Subject = @Subject
							 ,Description = @Description
							 ,Process_Date  =@ProcessDate
							 ,File_App_Doc =@FileName--updated
							 ,Approval_Comments=@Comment
							 ,Forward_Emp_Id=@Forward_Emp_Id
							 ,Submit_Emp_Id=@Submit_Emp_Id
							 ,System_Date = GETDATE()
							 ,[User ID] = @LoginID
							 where File_App_Id = @File_App_Id   and Rpt_Level=@Rpt_Level  and Tran_Id=@tran_id_fw_i--and Tran_Id=@Tran_ID
				end
				--for updating in file_level_fwd tbl end
		--for updating in file_level_fwd tbl end
		if(@FileStatus_Id=4)
		begin			
   -- Add for audit(start)
			exec P9999_Audit_get @table = 'T0080_File_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			
		-- Add for audit(end)	
     INSERT INTO T0080_File_Approval (Approve_Date,Branch_Id,Dept_Id,Desig_Id,Emp_Id,S_Emp_Id,File_Number,F_StatusId,F_TypeId,Subject,Description,Process_Date,File_App_Doc,Cmp_ID,CreatedDate,[User ID],Forward_Emp_Id,Submit_Emp_Id,CreatedBy,Approval_Comments,File_App_Id,Review_Emp_Id,Reviewed_by_Emp_Id,File_Type_Number)---updated by mansi 22-08-22
	
	
             VALUES(@ApproveDate,@Branch_Id,@Dept_Id,@Desig_Id,@Emp_Id,@S_Emp_Id,@FileNumber,
			 @FileStatus_Id,
			 @FileType_Id,@Subject,@Description,@ProcessDate,@FileName,@Cmp_ID,GETDATE(),@LoginID,@Forward_Emp_Id,@Submit_Emp_Id,@LoginID,@Comment,@File_App_Id,@Review_Emp_Id,@Reviewed_by_Emp_Id,@FileTypeNumber)---updated by mansi 22-08-22
			 --for History start
			 
				select  @FA_Id  = Isnull(max(File_Apr_Id),0)  From T0080_File_Approval  WITH (NOLOCK) 		
				INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,CreatedDate,[User ID],H_Trans_Type,Tbl_Type,File_Type_Number)---updated by mansi 22-08-22
					VALUES (@Cmp_ID,@File_App_Id,@FA_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,getDate(),@LoginID,@tran_type,'T0080_File_Approval',@FileTypeNumber)	---updated by mansi 22-08-22
					--for History end
		-- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Approval',@OldValue,@Emp_ID,@LoginId,@IP_Address
			 	-- Add for audit(end)	
		end	
		if(@FileStatus_Id<>4) 
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
			Forward_Emp_Id=@Forward_Emp_Id,Submit_Emp_Id=@Submit_Emp_Id,
			Subject=@Subject,Description=@Description
			where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID
				and Rpt_Level=(select max(Rpt_Level)from T0115_File_Level_Approval 
                 where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)
				
		 -- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,'U','File Level Approve',@OldValue_lvl,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)
		--for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type,File_Type_Number)---updated by mansi 22-08-22
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,'U',@Tran_ID,'T0115_File_Level_Approval',@FileTypeNumber)	---updated by mansi 22-08-22
					--for History end
				-- Add for audit(start)
				exec P9999_Audit_get @table = 'T0080_File_Application' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String_app output
				set @OldValue_app = @OldValue_app + 'New Value' + '#' + cast(@String_app as varchar(max))
			-- Add for audit(end)	
			if(@FileStatus_Id=5)
			begin
			Update T0080_File_Application set 
			RComments=@Comment,Review_Emp_Id=@Review_Emp_Id,F_StatusId =@FileStatus_Id,
			UpdatedByUserId=@LoginID,UpdatedDate=GETDATE() 
			WHERE File_App_Id = @File_App_Id AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID
					if(@Review_Emp_Id=@Emp_Id)
					begin 
						Update T0080_File_Application set 
						Subject=@Subject,Description=@Description,Process_Date=@ProcessDate,File_App_Doc=@FileName
						WHERE File_App_Id = @File_App_Id AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID
					end
			end
			else
			begin
			Update T0080_File_Application set F_StatusId =@FileStatus_Id,UpdatedByUserId=@LoginID,UpdatedDate=GETDATE() 
			WHERE File_App_Id = @File_App_Id AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID
			end
			-- Add for audit(start)
					exec P9999_Audit_Trail @Cmp_ID,'U','File Application',@OldValue_app,@Emp_ID,@LoginId,@IP_Address
			-- Add for audit(end)	
		end
		  else if(@FileStatus_Id=4)
		begin
		
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
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type,File_Type_Number)---updated by mansi 22-08-22
					VALUES (@Cmp_ID,@File_App_Id,@FA_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,'U',@Tran_ID,'T0115_File_Level_Approval',@FileTypeNumber)	---updated by mansi 22-08-22
					--for History end	
					-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0080_File_Application' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String_app output
			set @OldValue_app = @OldValue_app + 'New Value' + '#' + cast(@String_app as varchar(max))
				-- Add for audit(end)		
			Update T0080_File_Application set F_StatusId =@FileStatus_Id,UpdatedByUserId=@LoginID,UpdatedDate=GETDATE() 
			WHERE File_App_Id = @File_App_Id AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID
			
	-- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,'U','File Application',@OldValue_app,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)
		end
			
select  @FA_Id  = Isnull(max(File_Apr_Id),0)+1  From T0080_File_Approval  WITH (NOLOCK) 
  End  

 Else if @Tran_Type = 'U'  
  begin 

  declare @t_id as numeric
		 if(@FileStatus_Id=4)
	 begin 
	 	-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0080_File_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			
		-- Add for audit(end)	
				
			INSERT INTO T0080_File_Approval (Approve_Date,Branch_Id,Dept_Id,Desig_Id,Emp_Id,S_Emp_Id,
			File_Number,F_StatusId,F_TypeId,Subject,Description,Process_Date,File_App_Doc,Cmp_ID,
			CreatedDate,[User ID],Forward_Emp_Id,Submit_Emp_Id,CreatedBy,File_App_Id,Approval_Comments,Review_Emp_Id,Reviewed_by_Emp_Id,File_Type_Number)---updated by mansi 22-08-22
			VALUES(@ApproveDate,@Branch_Id,@Dept_Id,@Desig_Id,@Emp_Id,@S_Emp_Id,@FileNumber,
			 @FileStatus_Id,@FileType_Id,@Subject,@Description,@ProcessDate,
			 @FileName,@Cmp_ID,GETDATE(),@LoginID,@Forward_Emp_Id,@Submit_Emp_Id,@LoginID,@File_App_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@FileTypeNumber)---updated by mansi 22-08-22
    		 
			 --for History start
				SELECT @FA_Id = ISNULL(MAX(File_Apr_Id),0)  FROM dbo.T0080_File_Approval WITH (NOLOCK)
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type,File_Type_Number)---updated by mansi 22-08-22
					VALUES (@Cmp_ID,@File_App_Id,@FA_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,@tran_type,@Tran_ID,'T0080_File_Approval',@FileTypeNumber)	---updated by mansi 22-08-22
					--for History end
			 	-- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Approval',@OldValue,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)	
			
	 end
	 			set @t_id=(select tran_id from T0115_File_Level_Approval 
				where rpt_level= (select max(Rpt_Level) from T0115_File_Level_Approval 
                 where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)and File_App_Id=@File_App_Id)
			
	 --print 11
	
  --added for  adding level start
					
		 if not exists(select 1 from T0115_File_Level_Approval where File_App_Id=@File_App_Id and Cmp_Id=@Cmp_ID and Rpt_Level=@Rpt_Level)
		begin 
		-- print 11--mansi
			Declare @tr_Id as numeric
		   Select @tr_Id = ISNULL(MAX(Tran_ID),0) + 1 From T0115_File_Level_Approval WITH (NOLOCK)
		   --print @tran_Id
		   -- Add for audit(start)
			
			exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='Tran_Id',@key_Values=@Tran_ID,@String=@String_lvl output
			set @OldValue_lvl = @OldValue_lvl + 'New Value' + '#' + cast(@String_lvl as varchar(max))	 
				-- Add for audit(end)
		   INSERT INTO dbo.T0115_File_Level_Approval
						   (Tran_ID,Approve_Date,File_Apr_Id,Cmp_Id,File_App_Id,Emp_Id,File_Number,F_StatusId,F_TypeId,Subject,Description,Process_Date,File_App_Doc,Forward_Emp_Id,Submit_Emp_Id,Approval_Comments,S_Emp_Id,Rpt_Level,System_Date,[User ID],Review_Emp_Id,Reviewed_by_Emp_Id ,File_Type_Number)---updated by mansi 22-08-22
					VALUES (@tr_Id,@ApproveDate,0,@Cmp_ID,@File_App_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@S_Emp_Id,@Rpt_Level,getDate(),@LoginID,@Review_Emp_Id,@Reviewed_by_Emp_Id,@FileTypeNumber)	---updated by mansi 22-08-22
				-- Add for audit(start)
					exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Level Approve',@OldValue,@Emp_ID,@LoginId,@IP_Address
					-- Add for audit(end)	
					--for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type,File_Type_Number)---updated by mansi 22-08-22
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,'I',@tr_Id,'T0115_File_Level_Approval',@FileTypeNumber)	---updated by mansi 22-08-22
					--for History end		
		end 
		--added for  adding level end
		else 
		begin
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
				--for updating in file_level_fwd tbl start
				if(@FileStatus_Id=3)
				begin
					if not exists(select 1 from T0115_File_Level_Approval_Forward where File_App_Id=@File_App_Id and Cmp_Id=@Cmp_ID and Rpt_Level=@Rpt_Level)
							begin 
								declare @tran_id_fw as numeric(18,0)
								set @tran_id_fw=(select Tran_Id from T0115_File_Level_Approval 
                                                  where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID and Rpt_Level=@Rpt_Level)
								INSERT INTO dbo.T0115_File_Level_Approval_Forward
									   (Tran_Id,Approve_Date,File_Apr_Id,Cmp_Id,File_App_Id,Emp_Id,File_Number,F_StatusId,F_TypeId,Subject,Description,Process_Date,File_App_Doc,Forward_Emp_Id,Submit_Emp_Id,Approval_Comments,S_Emp_Id,Rpt_Level,System_Date,[User ID],Review_Emp_Id,Reviewed_by_Emp_Id ,File_Type_Number)
								VALUES (@tran_id_fw,@ApproveDate,0,@Cmp_ID,@File_App_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@S_Emp_Id,@Rpt_Level,getDate(),@LoginID,@Review_Emp_Id,@Reviewed_by_Emp_Id,@FileTypeNumber)	
							end
						UPDATE T0115_File_Level_Approval_Forward  
							 SET Approve_Date= @ApproveDate,
							 F_StatusId=@FileStatus_Id
							 ,F_TypeId =@FileType_Id
							 ,Subject = @Subject
							 ,Description = @Description
							 ,Process_Date  =@ProcessDate
							 ,File_App_Doc =@FileName--updated
							 ,Approval_Comments=@Comment
							 ,Forward_Emp_Id=@Forward_Emp_Id
							 ,Submit_Emp_Id=@Submit_Emp_Id
							 ,System_Date = GETDATE()
							 ,[User ID] = @LoginID
							 where File_App_Id = @File_App_Id   and Rpt_Level=@Rpt_Level  and Tran_Id=@tran_id_fw--and Tran_Id=@Tran_ID
				end
				--for updating in file_level_fwd tbl end
		end
		 else if(@FileStatus_Id=2) 
		begin
			-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String_lvl output
			set @OldValue_lvl = @OldValue_lvl + 'New Value' + '#' + cast(@String_lvl as varchar(max))
		-- Add for audit(end)	
		   update  T0115_File_Level_Approval set --File_Apr_Id=@FA_Id,
		   F_StatusId=@FileStatus_Id,File_App_Doc=@FileName,
			Process_Date=@ProcessDate,Approval_Comments=@Comment,			
			Subject=@Subject,Description=@Description
			where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID
				and Rpt_Level=(select max(Rpt_Level)from T0115_File_Level_Approval 
                 where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)
				
		 -- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,'U','File Level Approve',@OldValue_lvl,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)
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
			
			Update T0080_File_Application set F_StatusId =@FileStatus_Id,UpdatedByUserId=@LoginID,UpdatedDate=GETDATE() 
			,File_App_Doc=@FileName,@Subject=@Subject,Description=@Description,RComments=@Comment
			WHERE File_App_Id = @File_App_Id AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID
		 -- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,'U','File Level Approve',@OldValue_lvl,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)
		
		end
		 	  else if(@FileStatus_Id=4)
		begin 
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
			where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID
				and Rpt_Level=(select max(Rpt_Level)from T0115_File_Level_Approval 
                 where File_App_Id=@File_App_Id and cmp_id=@Cmp_ID)
				
				
		end
				--for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type,File_Type_Number)
					VALUES (@Cmp_ID,@File_App_Id,@FA_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,'U',@t_id,'T0115_File_Level_Approval',@FileTypeNumber)	
					--for History end	
		end
		
			exec P9999_Audit_get @table = 'T0080_File_Application' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String_app output
			set @OldValue_app = @OldValue_app + 'New Value' + '#' + cast(@String_app as varchar(max))
				-- Add for audit(end)		
			if(@FileStatus_Id=5)
			begin
			Update T0080_File_Application set 
			RComments=@Comment,Review_Emp_Id=@Review_Emp_Id,F_StatusId =@FileStatus_Id,UpdatedByUserId=@LoginID,UpdatedDate=GETDATE() 
			WHERE File_App_Id = @File_App_Id AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID
			if(@Review_Emp_Id=@Emp_Id)
					begin 
						Update T0080_File_Application set 
						Subject=@Subject,Description=@Description,Process_Date=@ProcessDate,File_App_Doc=@FileName
						WHERE File_App_Id = @File_App_Id AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID
					end
			end
			else
			begin
			Update T0080_File_Application set F_StatusId =@FileStatus_Id,UpdatedByUserId=@LoginID,UpdatedDate=GETDATE() 
			WHERE File_App_Id = @File_App_Id AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID
			end
			
		-- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,'U','File Application',@OldValue_app,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)	
		 select  @FA_Id  = Isnull(max(File_Apr_Id),0)  From T0080_File_Approval  WITH (NOLOCK) 
  end  

 Else if @Tran_Type = 'D'  
  begin  
	if Not Exists(Select File_Apr_Id  from T0080_File_Approval WITH (NOLOCK) Where File_Apr_Id =  @FA_Id )  
		BEGIN
		  
			Set  @FA_Id  = 0
			RETURN 
		End
	ELSE
		Begin
		 -- Add for Audit(start)
			exec P9999_Audit_get @table='T0080_File_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String output
			set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
		-- Add for Audit(end)	
				
				Delete From T0080_File_Approval Where File_Apr_Id =  @FA_Id  --For Hard Delete
				
				--for History start
					INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,CreatedDate,[User ID],H_Trans_Type,Tbl_Type,File_Type_Number)
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,getDate(),@LoginID,@tran_type,'T0080_File_Application',@FileTypeNumber)	
					
					--for History end
		-- Add for Audit(start)
		 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Approval',@OldValue,@Emp_ID,@LoginId,@IP_Address
		 -- Add for Audit(end)	
		 -- Add for Audit(start)
			exec P9999_Audit_get @table='T0115_File_Level_Approval' ,@key_column='File_Apr_Id',@key_Values=@FA_Id,@String=@String output
			set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
		-- Add for Audit(end)	
				
				Delete From T0115_File_Level_Approval Where File_App_Id =  @File_App_Id and Cmp_Id=@Cmp_ID  --For Hard Delete
				
				--for History start
					INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,CreatedDate,[User ID],H_Trans_Type,Tbl_Type,File_Type_Number)
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,getDate(),@LoginID,@tran_type,'T0115_File_Level_Approval',@FileTypeNumber)	
					
					--for History end
		-- Add for Audit(start)
		 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Level Approval',@OldValue,@Emp_ID,@LoginId,@IP_Address
		 -- Add for Audit(end)	
		 -- Add for Audit(start)
			exec P9999_Audit_get @table='T0080_File_Application' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String_app output
			set @OldValue_app = @OldValue_app + 'old Value' + '#' + cast(@String as varchar(max))
		-- Add for Audit(end)
		if(@File_App_Id<>0)
		begin
		 UPDATE dbo.T0080_File_Application SET F_StatusId = 1 WHERE File_App_Id=@File_App_Id and cmp_id=@Cmp_ID
		 	--for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,CreatedDate,[User ID],H_Trans_Type,Tbl_Type,File_Type_Number)
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,getDate(),@LoginID,'U','T0080_File_Application',@FileTypeNumber)	
					--for History end
		 -- Add for Audit(start)
		 exec P9999_Audit_Trail @Cmp_ID,'U','File Application',@OldValue_app,@Emp_ID,@LoginId,@IP_Address
		 	-- Add for Audit(end)
		end
		
		End
   end  
 RETURN
