


CREATE PROCEDURE [dbo].[P0080_File_Application_Admin_Side_30_09_22] 
	 @File_App_Id numeric(9) output  
	,@Cmp_ID   numeric(9)  
	,@ApplicationDate Datetime 
	,@Branch_Id int
	,@Dept_Id int 
	,@Desig_Id int 
	,@Emp_Id int
	,@S_Emp_Id int
	,@FileNumber nvarchar(50)
	--,@FileStatus_Id int
	,@FileType_Id int
	,@tran_type  varchar(1) 
	,@Subject nvarchar(500)
	,@Description nvarchar(max)
	,@ProcessDate Datetime 
	,@FileName nvarchar(max) 
	,@LoginID int 
	,@IP_Address varchar(30)= ''
	,@RComment varchar(500)
	,@FileTypeNumber  nvarchar(max)--added by mansi 17-08-22
	,@FileTypeName  nvarchar(max)--added by mansi 30-09-22
	
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
 If @tran_type  = 'I'  
  Begin  
  if exists (Select File_App_Id   from T0080_File_Application WITH (NOLOCK) Where File_App_Id = @File_App_Id )   
    begin  
     set @File_App_Id = 0  
     Return  
    end  	


    INSERT INTO T0080_File_Application (Application_Date,Branch_Id,Dept_Id,Desig_Id,Emp_Id,S_Emp_Id,File_Number,F_StatusId,
	--F_StatusId,
	F_TypeId,Subject,Description,Process_Date,File_App_Doc,Cmp_ID,CreatedDate,[User ID],File_Type_Number,File_Type_Name)
             VALUES(@ApplicationDate,@Branch_Id,@Dept_Id,@Desig_Id,@Emp_Id,@S_Emp_Id,@FileNumber,1,
			 --@FileStatus_Id,
			 @FileType_Id,@Subject,@Description,@ProcessDate,@FileName,@Cmp_ID,GETDATE(),@LoginID,@FileTypeNumber,@FileTypeName)
			 	Select @File_App_Id = ISNULL(MAX(File_App_Id),0)  From T0080_File_Application WITH (NOLOCK)
			 		--for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type,H_Approval_Comments,File_Type_Number)
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,1,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,0,getDate(),@LoginID,@tran_type,0,'T0080_File_Application',@RComment,@FileTypeNumber)	
					--for History end
				-- Add for audit(start)
		
				print @string
			exec P9999_Audit_get @table = 'T0080_File_Application' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
		-- Add for audit(end)	
		  exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Application',@OldValue,@Emp_ID,@LoginId,@IP_Address
					 select @File_App_Id = Isnull(max(File_App_Id),0)  From T0080_File_Application  WITH (NOLOCK) 
	

  End  

 Else if @Tran_Type = 'U'  
  begin  
   IF Not Exists(Select File_App_Id  from T0080_File_Application WITH (NOLOCK) Where File_App_Id = @File_App_Id)  
    Begin  
     set @File_App_Id = 0  
     Return   
    End  
	Declare @file_status_id as int=(Select F_StatusId  from T0080_File_Application WITH (NOLOCK) Where File_App_Id = @File_App_Id)
	declare @file_Comments varchar(500)
						declare @file_nm varchar(max)
						declare @File_Status as int
						-- Declare @file_F as varchar(max)
	if(@file_status_id<>5)
	begin
		if exists	(	select File_App_Id 
									from T0115_File_Level_Approval WITH (NOLOCK)
									where Cmp_ID=@Cmp_ID and File_App_Id=@File_App_Id and Emp_ID=@Emp_ID 
								)
					begin
						RAISERROR (N'File Approval - Reference Exist.', 16, 2); 
						RETURN
					
					end
				--	-- Add for audit(start)
				--	exec P9999_Audit_get @table='T0080_File_Application' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String output
				--	set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
				---- Add for audit(end)
			--if @FileName=''
			--Begin
			--	Select @FileName=File_App_Doc  from T0080_File_Application WITH (NOLOCK) Where File_App_Id = @File_App_Id
			--End
			
			 --set @file_F=cast(FORMAT(GETDATE(), 'dd MM yyyy HH mm ss')as varchar)+'-'+cast(@File_App_Id as varchar)+'-'+cast(@cmp_id as varchar)+'-'+'FP'+'-'+'#'+cast(@fileName as varchar)
			 
			if @FileName = ''	
			begin
					 UPDATE T0080_File_Application  
					 SET Application_Date= @ApplicationDate
					 ,Branch_Id=@Branch_Id
					 ,Dept_Id = @Dept_Id
					 ,Desig_Id = @Desig_Id
					 ,Emp_Id = @Emp_Id
					 ,S_Emp_Id = @S_Emp_Id
					 ,File_Number=@FileNumber
					 --,F_StatusId = @FileStatus_Id
					 ,F_TypeId =@FileType_Id
					 ,Subject = @Subject
					 ,Description = @Description
					 ,Process_Date  =@ProcessDate
					 --,File_App_Doc =@FileName
					 ,UpdatedDate = GETDATE()
					 --,[User ID] = @LoginID
					 ,UpdatedByUserId= @LoginID
					 where File_App_Id = @File_App_Id  
				 end
			else 
			begin 
					  UPDATE T0080_File_Application  
					 SET Application_Date= @ApplicationDate
					 ,Branch_Id=@Branch_Id
					 ,Dept_Id = @Dept_Id
					 ,Desig_Id = @Desig_Id
					 ,Emp_Id = @Emp_Id
					 ,S_Emp_Id = @S_Emp_Id
					 ,File_Number=@FileNumber
					 --,F_StatusId = @FileStatus_Id
					 ,F_TypeId =@FileType_Id
					 ,Subject = @Subject
					 ,Description = @Description
					 ,Process_Date  =@ProcessDate
					 ,File_App_Doc =@FileName
					 --,File_App_Doc =@file_F
					 ,UpdatedDate = GETDATE()
					 --,[User ID] = @LoginID
					 ,UpdatedByUserId= @LoginID
					 ,File_Type_Number=@FileTypeNumber--added by mansi 17-08-22
					 where File_App_Id = @File_App_Id  
				 end
				
				 		--for History start
						set @file_nm =(select File_App_Doc from T0080_File_Application where file_app_id=@File_App_Id)
						set @file_Comments=(select Approval_Comments from T0115_File_Level_Approval where Tran_Id=(select Tran_Id from T0115_File_Level_Approval where File_App_Id=@File_App_Id))
						 set @File_Status =(select F_StatusId from T0080_File_Application  where File_App_Id = @File_App_Id ) 
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type,H_Approval_Comments,File_Type_Number)
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@File_Status,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@file_nm,0,getDate(),@LoginID,'U',0,'T0080_File_Application',@RComment,@FileTypeNumber)	
					--for History end
					end
	else
	begin
	declare @login_emp as numeric
	 set @login_emp=(Select Emp_ID from T0011_LOGIN where Login_ID=@LoginID)
		Declare @Review_e_id as numeric(18,0)			 
			 set @Review_e_id=(select Review_Emp_Id from T0115_File_Level_Approval where Tran_Id=(select Tran_Id from T0115_File_Level_Approval where File_App_Id=@File_App_Id and Rpt_Level=1))
		if(@Review_e_id<>@login_emp)		
					begin
						RAISERROR (N'File Approval - Reference Exist.', 16, 2); 
						RETURN
					
					end
			
					UPDATE T0080_File_Application  
					 SET Application_Date= @ApplicationDate
					 ,Branch_Id=@Branch_Id
					 ,Dept_Id = @Dept_Id
					 ,Desig_Id = @Desig_Id
					 ,Emp_Id = @Emp_Id
					 ,S_Emp_Id = @S_Emp_Id
					 ,File_Number=@FileNumber
					 --,F_StatusId = @FileStatus_Id
					 ,F_TypeId =@FileType_Id
					 ,Subject = @Subject
					 ,Description = @Description
					 ,Process_Date  =@ProcessDate
					 ,File_App_Doc =@FileName
					 --,File_App_Doc =@file_F
					 ,UpdatedDate = GETDATE()
					 --,[User ID] = @LoginID
					 ,UpdatedByUserId= @LoginID
					 ,File_Type_Number=@FileTypeNumber--added by mansi 17-08-22
					 where File_App_Id = @File_App_Id  
				--added for chaging updated user in file level 1 start(22-07-22)
				update T0115_File_Level_Approval 
				set [User ID]=@LoginID
				where File_App_Id = @File_App_Id  and Rpt_Level=1
				--added for chaging updated user in file level 1 end(22-07-22)
				 		--for History start

							declare @review_emp as numeric(18,0),@Review_by_emp as numeric(18,0)
							set @review_emp=(select Review_Emp_Id from T0115_File_Level_Approval where Tran_Id=(select Tran_Id from T0115_File_Level_Approval where File_App_Id=@File_App_Id and Rpt_Level=1))
							set @Review_by_emp=(select Reviewed_by_Emp_Id from T0115_File_Level_Approval where Tran_Id=(select Tran_Id from T0115_File_Level_Approval where File_App_Id=@File_App_Id and Rpt_Level=1))
						set @file_nm=(select File_App_Doc from T0080_File_Application where file_app_id=@File_App_Id )
						set @file_Comments=(select Approval_Comments from T0115_File_Level_Approval where Tran_Id=(select Tran_Id from T0115_File_Level_Approval where File_App_Id=@File_App_Id and Rpt_Level=1))
						set @File_Status=(select F_StatusId from T0080_File_Application  where File_App_Id = @File_App_Id ) 
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type,H_Approval_Comments,H_Review_Emp_Id,H_Reviewed_by_Emp_Id,File_Type_Number)
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,@File_Status,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@file_nm,0,getDate(),@LoginID,'U',0,'T0080_File_Application',@RComment,@review_emp,@Review_by_emp,@FileTypeNumber)	
					--for History end
					end

			-- Add for audit(start)
				exec P9999_Audit_get @table = 'T0080_File_Application' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			-- Add for audit(end)  
			  exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Application',@OldValue,@Emp_ID,@LoginId,@IP_Address
  end  

 Else if @Tran_Type = 'D'  
  begin  
	if Not Exists(Select File_App_Id  from T0080_File_Application WITH (NOLOCK) Where File_App_Id = @File_App_Id)  
		BEGIN

			Set @File_App_Id = 0
			RETURN 
		End
	ELSE
		Begin
		-----added on 08-04-22 start
		-- IF EXISTS( SELECT 1 FROM T0080_File_Approval WITH (NOLOCK) WHERE File_App_Id = @File_App_Id )  
		--	 --BEGIN  
		--	 --RAISERROR('@@ File Application Status changed, you can''t delete @@',16,2)  
		--		--RETURN;  
		--	 --END  
		--	 BEGIN

		--	Set @File_App_Id = 0
		--	RETURN 
		--End
		--else
		--		---added on 08-04-22 end	
		-- Add for Audit(start)
			exec P9999_Audit_get @table='T0080_File_Application' ,@key_column='File_App_Id',@key_Values=@File_App_Id,@String=@String output
			set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
		-- Add for Audit(end)
		--for History start
						INSERT INTO dbo.T0115_File_Level_Approval_History
						   (Cmp_Id,File_App_Id,File_Apr_Id,Emp_Id,H_File_Number,H_F_StatusId,H_F_TypeId,H_Subject,H_Description,H_S_Emp_Id,H_Process_Date,H_File_App_Doc,Rpt_Level,CreatedDate,[User ID],H_Trans_Type,H_Tran_Id,Tbl_Type,H_Approval_Comments,File_Type_Number)
					VALUES (@Cmp_ID,@File_App_Id,0,@Emp_ID,@FileNumber,1,@FileType_Id,@Subject,@Description,@S_Emp_Id,@ProcessDate,@FileName,0,getDate(),@LoginID,@tran_type,0,'T0080_File_Application',@RComment,@FileTypeNumber)	
					--for History end
				Delete From T0080_File_Application Where File_App_Id = @File_App_Id --For Hard Delete
			exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'File Application',@OldValue,@Emp_ID,@LoginId,@IP_Address
		End
   end  
   --print @OldValue
   --exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'File Application',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
 
 RETURN
