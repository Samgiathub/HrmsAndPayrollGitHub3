CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Grievance_Application] 

  @GrieId  numeric(9) =0
 ,@AppNo nvarchar(20)
 ,@Cmp_ID   numeric(9) 
 ,@EmpIDF int
 ,@Griev_Against int 
 ,@EmpIDT int
 ,@NameT nvarchar(100)
 ,@AddressT nvarchar(1000)
 ,@EmailT nvarchar(500)
 ,@ContactT nvarchar(50)
 ,@SubLine nvarchar(400)
 ,@Details nvarchar(max)
 ,@tran_type  varchar(1)
 ,@FileName nvarchar(100) 
 ,@LoginID int 
 ,@Result nvarchar(max)='' output

AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  --Change by Ronak Kumawat 17082022



  Declare @RecieveDate Datetime  = Getdate()
  Declare @From int =0
  Declare @NameF nvarchar(100)
  Declare @AddressF nvarchar(1000)
  Declare @EmailF nvarchar(500)
  Declare @ContactF nvarchar(50)
  Declare @RecieveFrom int = 6
 

 
 If @From=0
 Begin
   -- From 0 Means Employee
   set @NameF =null
   set @AddressF = null
   set @EmailF = null
   set @ContactF = null
 End
 Else If @From=1
 Begin
	-- From 1 Means Other
	 Set @EmpIDF = null
 End



 If @Griev_Against=0
 Begin
   --  0 Means Employee
   set @NameT =null
   set @AddressT = null
   set @EmailT = null
   set @ContactT = null
 End
 Else If @Griev_Against=1
 Begin
	-- 1 Means Other
	 Set @EmpIDT = null
 End





 If @tran_type  = 'I'  
  Begin  
  if exists (Select GA_ID   from T0080_Griev_Application WITH (NOLOCK) Where GA_ID = @GrieId )   
    begin  
     set @GrieId = 0  

	 set @Result = 'Record already exist'

     Return  
    end 
	

	if @From = 0 and @Griev_Against = 0
	Begin
		if exists (Select GA_ID  from T0080_Griev_Application WITH (NOLOCK) Where Emp_IDF=@EmpIDF and Emp_IDT=@EmpIDT and SubjectLine=@SubLine and (IsForwarded <> 5 or IsForwarded <> 3))
		Begin
		 set @GrieId =0
		 set @Result = 'Application and against person cant be same'
		 return
		end
	End
	else if @From = 0 and @Griev_Against = 1
	begin
		if exists (Select GA_ID  from T0080_Griev_Application WITH (NOLOCK) Where Emp_IDF=@EmpIDF and NameT=@NameT and (IsForwarded <> 5 or IsForwarded <> 3))
		Begin
		 set @GrieId =0
		 set @Result = 'Record already exist'
		 return
		end
	end
	else if @From = 1 and @Griev_Against = 0
	begin
		if exists (Select GA_ID  from T0080_Griev_Application WITH (NOLOCK) Where NameF=@NameF and Emp_IDT=@EmpIDT and (IsForwarded <> 5 or IsForwarded <> 3))
		Begin
		 set @GrieId =0
		 set @Result = 'Record already exist'
		 return
		end
	end



	if @AppNo = ''
	Begin
		select @GrieId = Isnull(max(GA_ID),0)+1  From T0080_Griev_Application  WITH (NOLOCK) 
	    set @AppNo = 'GA'+CAST(@GrieId as nvarchar)
	end

					
				
   
    INSERT INTO T0080_Griev_Application (App_No,Receive_Date,[From],Emp_IDF,NameF,AddressF,EmailF,ContactF,Receive_From,Griev_Against,
	                                      Emp_IDT,NameT,AddressT,EmailT,ContactT,SubjectLine,Details,DocumentName,Cmp_ID,CreatedDate,[User ID])  
             VALUES(@AppNo,@RecieveDate,@From,@EmpIDF,@NameF,@AddressF,@EmailF,@ContactF,@RecieveFrom,@Griev_Against,
					@EmpIDT,@NameT,@AddressT,@EmailT,@ContactT,@SubLine,@Details,@FileName,@Cmp_ID,GETDATE(),@LoginID)

					 select @GrieId = Isnull(max(GA_ID),0)  From T0080_Griev_Application  WITH (NOLOCK) 

					  set @Result = 'Record saved succefully !!'

  End  

 Else if @Tran_Type = 'U'  
  begin  
   IF Not Exists(Select GA_ID  from T0080_Griev_Application WITH (NOLOCK) Where GA_ID = @GrieId)  
    Begin  
     set @GrieId = 0  
     Return   
    End  

			if @FileName <> ''
			Begin
				Select @FileName=DocumentName  from T0080_Griev_Application WITH (NOLOCK) Where GA_ID = @GrieId
			End

				 UPDATE T0080_Griev_Application  
				 SET [From]= @From
				 ,Emp_IDF=@EmpIDF
				 ,NameF = @NameF
				 ,AddressF = @AddressF
				 ,EmailF = @EmailF
				 ,ContactF = @ContactF
				 ,Receive_From=@RecieveFrom
				 ,Griev_Against = @Griev_Against
				 ,Emp_IDT =@EmpIDT
				 ,NameT = @NameT
				 ,AddressT = @AddressT
				 ,EmailT  =@EmailT
				 ,ContactT = @EmailT
				 ,SubjectLine = @SubLine
				 ,Details =@Details
				 ,DocumentName =@FileName
				 ,UpdatedDate = GETDATE()
				 ,[User ID] = @LoginID
				 where GA_ID = @GrieId  
		
  end  

 Else if @Tran_Type = 'D'  
  begin 
	if Exists(Select GrievAppID  from T0080_Griev_Application_Allocation WITH (NOLOCK) Where GrievAppID = @GrieId)  
		BEGIN

			Set @GrieId = 0
			 set @Result = 'Refrence exist can not delete !!'

			RETURN 
		End
	ELSE
		Begin

				

				Delete From T0080_Griev_Application Where GA_ID = @GrieId --For Hard Delete

				  set @Result = 'Record deleted succefully !!'

		End
   end  
 RETURN