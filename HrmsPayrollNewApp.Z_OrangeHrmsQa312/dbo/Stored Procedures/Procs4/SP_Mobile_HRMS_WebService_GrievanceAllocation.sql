CREATE Procedure [dbo].[SP_Mobile_HRMS_WebService_GrievanceAllocation]
(
 @GrieId  numeric(9) output  
   ,@Cmp_ID   numeric(9) 
   ,@CommitteeID int
   ,@Griev_TypeID int
   ,@Griev_CatID int
   ,@Griev_PriorityID int
   ,@Griev_StatusID int
   ,@Comments nvarchar(2000)
   ,@FileName nvarchar(1000)
   ,@GrievAppID int
   ,@LoginID int
   ,@Type as varchar(10)='',
@Result as varchar(20)='' output
)
As 
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