


CREATE PROCEDURE [dbo].[P0040_File_Type_Master]  
    @F_TypeID numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@FileTypeTitle nvarchar(max)
   ,@tran_type  varchar(1) 
   ,@FileTypeCode varchar(max)
    ,@FileTypeNumber varchar(max)--added by mansi
   ,@CreatedBy varchar(max)--added by mansi
   ,@File_Type_Start_Date datetime--added by mansi
   ,@File_Type_End_Date datetime--added by mansi

AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  --Created by mansi 
  declare @IsActive as tinyint
  declare @ct_app as int
  declare @ct_apr as int

  if @FileTypeCode=''
  begin
	set @FileTypeCode = null
  end
  

 If @tran_type  = 'I'  
  Begin  
  if exists (Select F_TypeID  from T0040_File_Type_Master WITH (NOLOCK) Where F_TypeID = @F_TypeID )   
    begin  
     set @F_TypeID = 0  
     Return  
    end  
	
		if exists (Select F_TypeID  from T0040_File_Type_Master WITH (NOLOCK) Where TypeTitle = @FileTypeTitle and Cmp_ID=@Cmp_ID  )   
		  begin  
		   set @F_TypeID = 0  
		   Return  
		  end  
		  --added by mansi 29_08_22
	
		  if(@File_Type_End_Date='')
		   begin 
		     set @IsActive=1
		  end
		  else 
		  begin 
		    set @IsActive=0
		  end
		   --ended by mansi 29_08_22

    select @F_TypeID = Isnull(max(F_TypeID),0) + 1  From T0040_File_Type_Master  WITH (NOLOCK) 
    INSERT INTO T0040_File_Type_Master (F_TypeID,TypeTitle,TypeCode,TypeCDTM,Cmp_ID,File_Type_Number,Created_By,File_Type_Start_Date,File_Type_End_Date,Is_Active)  
             VALUES(@F_TypeID,@FileTypeTitle,@FileTypeCode,GETDATE(),@Cmp_ID,@FileTypeNumber,@CreatedBy,@File_Type_Start_Date,@File_Type_End_Date,@IsActive)--updated by mansi 29-08-22


  End  
 Else if @Tran_Type = 'U'  
  begin  
  set @ct_app=0--added on 30-08-22
  set @ct_apr=0--added on 30-08-22
   IF Not Exists(Select F_TypeID  from T0040_File_Type_Master WITH (NOLOCK) Where F_TypeID = @F_TypeID)  
    Begin  
     set @F_TypeID = 0  
     Return   
    End  


		if exists (Select F_TypeID  from T0040_File_Type_Master WITH (NOLOCK) Where  F_TypeID <> @F_TypeID and TypeTitle = @FileTypeTitle and Cmp_ID=@Cmp_ID  )   
		  begin  
		   set @F_TypeID = 0  
		   Return  
		  end  
		  print 456
		  --added by mansi 29-08-22 for end date logic
		  if(@File_Type_End_Date<>'')
		  begin
		    print 11--need to remove
				 if exists (Select count(File_App_Id)as f_app from T0080_File_Application  WITH (NOLOCK) Where  F_TypeID = @F_TypeID and File_Type_Number=@FileTypeNumber and Cmp_ID=@Cmp_ID)   
					begin  
					print 22--need to remove
						  set @ct_app=(Select count(File_App_Id)as f_app from T0080_File_Application  WITH (NOLOCK) Where  F_TypeID = @F_TypeID and File_Type_Number=@FileTypeNumber and Cmp_ID=@Cmp_ID)
						  print  @ct_app--need to remove
						  if exists (Select count(File_App_Id)as f_apr from T0080_File_Approval WITH (NOLOCK) Where  F_TypeID = @F_TypeID and File_Type_Number=@FileTypeNumber and Cmp_ID=@Cmp_ID)   
						   begin  
						   print 33--need to remove
							  set @ct_apr=(Select count(File_App_Id)as f_apr from T0080_File_Approval WITH (NOLOCK) Where  F_TypeID = @F_TypeID and File_Type_Number=@FileTypeNumber and Cmp_ID=@Cmp_ID)
									  print @ct_apr--need to remove
									  if(@ct_apr<>@ct_app)
									  begin 
									  print 44--need to remove
										 set @F_TypeID = 0  
											Return 
									  end
									  else
									  begin 
										print 55--need to remove
										 UPDATE T0040_File_Type_Master  
										 SET TypeTitle = @FileTypeTitle
										 ,TypeCode=@FileTypeCode 
										 ,TypeUDTM = getdate()
										 ,File_Type_Number=@FileTypeNumber  --adddedd by mansi
										 ,Created_By=@CreatedBy  --added by mansi
										 ,File_Type_Start_Date=@File_Type_Start_Date --added by mansi
										 ,File_Type_End_Date=@File_Type_End_Date --added by mansi
										 ,Is_Active=0--added on  29-08-22
										 where F_TypeID = @F_TypeID  
									  end
						end  
						  else
						   begin
						   print 66--need to remove
								set @F_TypeID = 0  
								Return
							end
					end  
					else
					begin
						print 77--need to remove
						  if(@File_Type_End_Date='')
							begin 
							 set @IsActive=1
						  end
						  else 
							begin 
							set @IsActive=0
						  end
					   
							 UPDATE T0040_File_Type_Master  
							 SET TypeTitle = @FileTypeTitle
							 ,TypeCode=@FileTypeCode 
							 ,TypeUDTM = getdate()
							 ,File_Type_Number=@FileTypeNumber  --adddedd by mansi
							 ,Created_By=@CreatedBy  --added by mansi
							 ,File_Type_Start_Date=@File_Type_Start_Date --added by mansi
							 ,File_Type_End_Date=@File_Type_End_Date --added by mansi
							 ,Is_Active=@IsActive--added on  29-08-22
							 where F_TypeID = @F_TypeID  
					end
		  end 
		  --ended by mansi 29-08-22 for end date logic
		  else
		   begin
		    print 88--need to remove
				--added by mansi 29_08_22
				  if(@File_Type_End_Date='')
				   begin 
					 set @IsActive=1
				  end
				  else 
				  begin 
					set @IsActive=0
				  end
			   --ended by mansi 29_08_22

					 UPDATE T0040_File_Type_Master  
					 SET TypeTitle = @FileTypeTitle
					 ,TypeCode=@FileTypeCode 
					 ,TypeUDTM = getdate()
					 ,File_Type_Number=@FileTypeNumber  --adddedd by mansi
					 ,Created_By=@CreatedBy  --added by mansi
					 ,File_Type_Start_Date=@File_Type_Start_Date --added by mansi
					 ,File_Type_End_Date=@File_Type_End_Date --added by mansi
					 ,Is_Active=@IsActive--added on  29-08-22
					 where F_TypeID = @F_TypeID  
		  end--added by mansi 29_08_22
  end  
 Else if @Tran_Type = 'D'  
  begin  
  set @ct_app=0--added on 30-08-22
  set @ct_apr=0--added on 30-08-22
	if Not Exists(Select F_TypeID  from T0040_File_Type_Master WITH (NOLOCK) Where F_TypeID = @F_TypeID)  
		BEGIN
		
			Set @F_TypeID = 0
			RETURN 
		End
		---added on 30-08-22 based on 
		else
		begin
		if exists (Select count(File_App_Id)as f_app from T0080_File_Application  WITH (NOLOCK) Where  F_TypeID = @F_TypeID and File_Type_Number=@FileTypeNumber and Cmp_ID=@Cmp_ID)   
					begin  
					print 222--need to remove
						  set @ct_app=(Select count(File_App_Id)as f_app from T0080_File_Application  WITH (NOLOCK) Where  F_TypeID = @F_TypeID and File_Type_Number=@FileTypeNumber and Cmp_ID=@Cmp_ID)
						  print  @ct_app--need to remove
									if(@ct_app>0)
									  begin 
									  print 444--need to remove
										 set @F_TypeID = 0  
											Return 
									  end
									  else
									  begin 
										print 555--need to remove
										 Delete From T0040_File_Type_Master Where F_TypeID = @F_TypeID --For Hard Delete
									  end
						
						
					end 
		ELSE
	 			 Begin
		  print 222222
				--update T0040_File_Type_Master set
				--Is_Active=0,
				--TypeUDTM=getdate()
				--where F_TypeID = @F_TypeID  --For Soft Delete
			
				Delete From T0040_File_Type_Master Where F_TypeID = @F_TypeID --For Hard Delete
		
		
		End
		end
		--ended on 30-08-22
	 ----commented start on 30-08-22
	 --ELSE
	 --	 Begin

		--		--update T0040_File_Type_Master set
		--		--Is_Active=0,
		--		--TypeUDTM=getdate()
		--		--where F_TypeID = @F_TypeID  --For Soft Delete
			
		--		Delete From T0040_File_Type_Master Where F_TypeID = @F_TypeID --For Hard Delete
		
		
		--End
		----commented end on 30-08-22
   end  
 RETURN
