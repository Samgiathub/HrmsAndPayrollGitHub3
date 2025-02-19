





CREATE PROCEDURE [dbo].[P0115_FILE_LEVEL_APPROVAL_02_05_22]
	 @Tran_ID				NUMERIC(18,0)	OUTPUT
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

BEGIN

	-- Add (start)
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	set @String=''
	set @OldValue =''
	-- Add (end)
	-- Add (start)
	declare @OldValue_app as  varchar(max)
	Declare @String_app as varchar(max)
	set @String_app=''
	set @OldValue_app =''
	-- Add (end)
	Declare @Create_Date As Datetime
	
	Set @Create_Date = GETDATE()
	
	If @S_Emp_ID = 0
		Set @S_Emp_ID = NULL
	--IF @Curr_ID=0
	--	SET @Curr_ID=null
		
	--IF @Curr_Rate=0
	--	SET @Curr_Rate=null		
	declare @login_emp as numeric
	 set @login_emp=(Select Emp_ID from T0011_LOGIN where Login_ID=@LoginID)
	 --print @FileName--mansi
	If UPPER(@Tran_Type) = 'I'
		Begin
			
			IF Exists(Select 1 From T0115_File_Level_Approval WITH (NOLOCK) Where Emp_ID=@Emp_ID 
			and File_App_Id=@File_App_Id And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)
				Begin
					Set @Tran_ID = 0
					Select @Tran_ID
					Return 
				End
		
			Select @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 From T0115_File_Level_Approval WITH (NOLOCK)
		--	  ---for getting filename in format start '
		--	  declare @file as varchar(max)
		--	  if CHARINDEX('#',@filename) > 0
		--	   begin 
  --set @file=@fileName
		--	end
		--	  else
		--	  begin 
  -- set @file=cast(FORMAT(GETDATE(), 'dd MM yyyy HH mm ss')as varchar)+'-'+cast(@tran_id as varchar)+'-'+cast(@cmp_id as varchar)+'-'+'FL'+'-'+'#'+cast(@fileName as varchar)
		--	end
		--	print @file--mansi
		--	---for getting filename in format end '
						-- Add for audit(start)
						--print @Tran_ID
			exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='Tran_Id',@key_Values=@Tran_ID,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
				-- Add for audit(end)
				INSERT INTO dbo.T0115_File_Level_Approval
						   (Tran_ID,Approve_Date,File_Apr_Id,Cmp_Id,File_App_Id,Emp_Id,File_Number,F_StatusId,F_TypeId,Subject,Description,Process_Date,File_App_Doc,Forward_Emp_Id,Submit_Emp_Id,Approval_Comments,S_Emp_Id,Rpt_Level,System_Date,[User ID],Review_Emp_Id,Reviewed_by_Emp_Id )
					VALUES (@Tran_ID,@ApproveDate,0,@Cmp_ID,@File_App_Id,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@S_Emp_Id,@Rpt_Level,getDate(),@LoginID,@Review_Emp_Id,@Reviewed_by_Emp_Id)	
					--print 22
					--for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,@tran_type,@Tran_ID,'T0115_File_Level_Approval')	
					--for History end
					-- Add for audit(start)
					exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Level Approve',@OldValue,@Emp_ID,@LoginId,@IP_Address
					-- Add for audit(end)	
					 select @Tran_ID = Isnull(max(Tran_Id),0)  From T0115_File_Level_Approval  WITH (NOLOCK) 
			
			if(@FileStatus_Id=5)
			begin 
			-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0080_File_Application' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String_app output
			set @OldValue_app = @OldValue_app + 'New Value' + '#' + cast(@String as varchar(max))
			-- Add for audit(end)	
		 update  T0080_File_Application set F_StatusId=@FileStatus_Id,RComments=@Comment,Review_Emp_Id=@Review_Emp_Id where File_App_Id=@File_App_Id
		 	-- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Application',@OldValue_app,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)	
			end 
			else
			begin 
			-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0080_File_Application' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String_app output
			set @OldValue_app = @OldValue_app + 'New Value' + '#' + cast(@String as varchar(max))
			-- Add for audit(end)	
		 update  T0080_File_Application set F_StatusId=@FileStatus_Id where File_App_Id=@File_App_Id
		 	-- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Application',@OldValue_app,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)	
			end
				
		End
	Else if @Tran_Type = 'U'  
	 begin  
   -- print 1111
  --IF Not Exists(Select Tran_Id  from T0115_File_Level_Approval WITH (NOLOCK) Where Tran_Id = @Tran_ID ) 
   IF Not Exists(Select Tran_Id  from T0115_File_Level_Approval WITH (NOLOCK) Where Tran_Id = @Tran_ID and F_StatusId in(2,3,5))  
    Begin  
	-- print 1

     set @Tran_ID = 0  
     Return   
    End 
   if(@FileStatus_Id=3)
   begin 
   if((@Forward_Emp_Id=@login_emp)or(@Submit_Emp_Id=@login_emp))
	begin
		-- print 3
		-- ---for getting filename in format start '
		-- Declare @file_F as varchar(max)
		--  if CHARINDEX('#',@filename) > 0
		--	   begin 
  --set @file_F=@fileName
		--	end
		--	  else
		--	  begin 
  -- set @file_F=cast(FORMAT(GETDATE(), 'dd MM yyyy HH mm ss')as varchar)+'-'+cast(@tran_id as varchar)+'-'+cast(@cmp_id as varchar)+'-'+'FL'+'-'+'#'+cast(@fileName as varchar)
		--	end
		--	---for getting filename in format end '
	 UPDATE T0115_File_Level_Approval  
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
					 where File_App_Id = @File_App_Id   and Tran_Id=@Tran_ID
				
						--for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,@tran_type,@Tran_ID,'T0115_File_Level_Approval')	
						
					--for History end
			 -- Add for audit(start)
				exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='Tran_Id',@key_Values=@Tran_ID,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			-- Add for audit(end)  
			 select @Tran_ID = Tran_Id From T0115_File_Level_Approval  WITH (NOLOCK) where Tran_Id=@Tran_ID
			--select @Tran_ID = Isnull(max(Tran_Id),0)  From T0115_File_Level_Approval  WITH (NOLOCK) 
	end
   end
   else if(@FileStatus_Id=5)
   begin 
   if((@Review_Emp_Id=@login_emp)or(@Reviewed_by_Emp_Id=@login_emp))
	begin
		-- print 5
-----for getting filename in format start '
--			  declare @file_R as varchar(max)
--			  if CHARINDEX('#',@filename) > 0
--			   begin 
--  set @file_R=@fileName
--			end
--			  else
--			  begin 
--   set @file_R=cast(FORMAT(GETDATE(), 'dd MM yyyy HH mm ss')as varchar)+'-'+cast(@tran_id as varchar)+'-'+cast(@cmp_id as varchar)+'-'+'FL'+'-'+'#'+cast(@fileName as varchar)
--			end
--			print @file_R--mansi
--			---for getting filename in format end '
	 ---for getting filename in format end '
	 UPDATE T0115_File_Level_Approval  
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
					 ,Review_Emp_Id=@Review_Emp_Id--added
					 ,Reviewed_by_Emp_Id=@Reviewed_by_Emp_Id--added
					 where File_App_Id = @File_App_Id   and Tran_Id=@Tran_ID and Rpt_Level=@Rpt_Level

							--for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_type)
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,@tran_type,@Tran_ID,'T0115_File_Level_Approval')	
					--for History end
			 -- Add for audit(start)
				exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='Tran_Id',@key_Values=@Tran_ID,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			-- Add for audit(end)  
			 select @Tran_ID = Tran_Id From T0115_File_Level_Approval  WITH (NOLOCK) where Tran_Id=@Tran_ID
			--select @Tran_ID = Isnull(max(Tran_Id),0)  From T0115_File_Level_Approval  WITH (NOLOCK) 
				
				-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0080_File_Application' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String_app output
			set @OldValue_app = @OldValue_app + 'New Value' + '#' + cast(@String as varchar(max))
			-- Add for audit(end)	
		 update  T0080_File_Application set F_StatusId=@FileStatus_Id,RComments=@Comment,Review_Emp_Id=@Review_Emp_Id where File_App_Id=@File_App_Id
		 	-- Add for audit(start)
			 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Application',@OldValue_app,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)	
	end
   end
   else
   begin
 	-- print 2
  -----for getting filename in format start '
		--	  declare @file_U as varchar(max)
		--	  if CHARINDEX('#',@filename) > 0
		--	   begin 
  --set @file_U=@fileName
		--	end
		--	  else
		--	  begin 
  -- set @file_U=cast(FORMAT(GETDATE(), 'dd MM yyyy HH mm ss')as varchar)+'-'+cast(@tran_id as varchar)+'-'+cast(@cmp_id as varchar)+'-'+'FL'+'-'+'#'+cast(@fileName as varchar)
		--	end
		--	---for getting filename in format end '
	 UPDATE T0115_File_Level_Approval  
					 SET Approve_Date= @ApproveDate,
					 F_StatusId=@FileStatus_Id
					 ,F_TypeId =@FileType_Id
					 ,Subject = @Subject
					 ,Description = @Description
					 ,Process_Date  =@ProcessDate
					 --,File_App_Doc =@file_U--updated
					 ,File_App_Doc =@FileName--updated
					 ,Approval_Comments=@Comment
					 ,Forward_Emp_Id=@Forward_Emp_Id
					 ,Submit_Emp_Id=@Submit_Emp_Id
					 ,System_Date = GETDATE()
					 ,[User ID] = @LoginID
					 -- ,Review_Emp_Id=@Review_Emp_Id--added
					 --,Reviewed_by_Emp_Id=@Reviewed_by_Emp_Id--added
					 where File_App_Id = @File_App_Id   and Tran_Id=@Tran_ID

							--for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,H_Forward_Emp_Id,H_Submit_Emp_Id,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type)
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@FileStatus_Id,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,@Forward_Emp_Id,@Submit_Emp_Id,@Comment,@Review_Emp_Id,@Reviewed_by_Emp_Id,@Rpt_Level,getDate(),@LoginID,@tran_type,@Tran_ID,'T0115_File_Level_Approval')	
					--for History end
			 -- Add for audit(start)
				exec P9999_Audit_get @table = 'T0115_File_Level_Approval' ,@key_column='Tran_Id',@key_Values=@Tran_ID,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			-- Add for audit(end)  
			 select @Tran_ID = Tran_Id From T0115_File_Level_Approval  WITH (NOLOCK) where Tran_Id=@Tran_ID
			-- select @Tran_ID = Isnull(max(Tran_Id),0)  From T0115_File_Level_Approval  WITH (NOLOCK) 
			-- Add for audit(end)	
		 update  T0080_File_Application set F_StatusId=@FileStatus_Id where File_App_Id=@File_App_Id
		 	-- Add for audit(start)
			exec P9999_Audit_get @table = 'T0080_File_Application' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Application',@OldValue,@Emp_ID,@LoginId,@IP_Address
		-- Add for audit(end)
	end
  End
	 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Level Approve',@OldValue,@Emp_ID,@LoginId,@IP_Address	
END
