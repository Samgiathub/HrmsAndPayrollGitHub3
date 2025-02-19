

CREATE PROCEDURE [dbo].[P0080_Griev_Application_Allocation]  
    @GrieId  numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@tran_type  varchar(1) 
   ,@CommitteeID int
   ,@Griev_TypeID int
   ,@Griev_CatID int
   ,@Griev_PriorityID int
   ,@Griev_StatusID int
   ,@Comments nvarchar(2000)
   ,@FileName nvarchar(1000)
   ,@GrievAppID int
   ,@LoginID int 
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  --Created by Ronak Kumawat 16032022


 If @tran_type  = 'I'  
  Begin  
  if exists (Select  G_Allocation_ID  from T0080_Griev_Application_Allocation WITH (NOLOCK) Where G_Allocation_ID = @GrieId )   
    begin  
     set @GrieId = 0  
     Return  
    end  

					
				
         select @GrieId = Isnull(max(G_Allocation_ID),0)+1  From T0080_Griev_Application_Allocation  WITH (NOLOCK) 

		 insert into T0080_Griev_Application_Allocation (G_Allocation_ID,Cmp_ID,CommitteeID,Griev_TypeID,Griev_CatID,Griev_PriorityID,
		 Griev_StatusID,Comments,[File_Name],CDTM,[Log],GrievAppID) values
		 (@GrieId,@Cmp_ID,@CommitteeID,@Griev_TypeID,@Griev_CatID,@Griev_PriorityID,@Griev_StatusID,@Comments,@FileName,GETDATE(),@LoginID,@GrievAppID)

		 
		 
		 
		 Update T0080_Griev_Application set IsForwarded =@Griev_StatusID where GA_ID=@GrievAppID



  End  

 Else if @Tran_Type = 'U'  
  begin  
   IF Not Exists(Select G_Allocation_ID  from T0080_Griev_Application_Allocation WITH (NOLOCK) Where G_Allocation_ID = @GrieId)  
    Begin  
     set @GrieId = 0  
     Return   
    End  

	

			if @FileName <> ''
			Begin
				Select @FileName=DocumentName  from T0080_Griev_Application WITH (NOLOCK) Where GA_ID = @GrieId
			End

				 --UPDATE T0080_Griev_Application  
				 --SET [From]= @From
				 --,Emp_IDF=@EmpIDF
				 --,NameF = @NameF
				 --,AddressF = @AddressF
				 --,EmailF = @EmailF
				 --,ContactF = @ContactF
				 --,Receive_From=@RecieveFrom
				 --,Griev_Against = @Griev_Against
				 --,Emp_IDT =@EmpIDT
				 --,NameT = @NameT
				 --,AddressT = @AddressT
				 --,EmailT  =@EmailT
				 --,ContactT = @EmailT
				 --,SubjectLine = @SubLine
				 --,Details =@Details
				 --,DocumentName =@FileName
				 --,UpdatedDate = GETDATE()
				 --,[User ID] = @LoginID
				 --where GA_ID = @GrieId  
		
  end  

 Else if @Tran_Type = 'D'  
  begin  
	if Not Exists(Select G_Allocation_ID  from T0080_Griev_Application_Allocation WITH (NOLOCK) Where G_Allocation_ID = @GrieId)  
		BEGIN

			Set @GrieId = 0
			RETURN 
		End
	ELSE
		Begin


					select * From T0080_Griev_Application_Allocation Where G_Allocation_ID = @GrieId
				--Delete From T0080_Griev_Application_Allocation Where G_Allocation_ID = @GrieId --For Hard Delete

		End
   end  
 RETURN