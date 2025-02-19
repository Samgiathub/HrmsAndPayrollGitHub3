

CREATE PROCEDURE [dbo].[P0080_Griev_Hearing]
    @GHId  numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@tran_type  varchar(1) 
   ,@GAllocationID int
   ,@GStatusID int
   ,@GHDatetime Datetime
   ,@GHLocation nvarchar(1000)
   ,@GHContact nvarchar(10)
   ,@GHComments nvarchar(200)
   ,@LoginID int 
   ,@CommitteID int
   ,@TypeID int
   ,@CategoryID int
   ,@PriorityID int
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  --Created by Ronak Kumawat 25032022


 If @tran_type  = 'I'  
  Begin  
  if exists (Select  GH_ID  from T0080_Griev_Hearing WITH (NOLOCK) Where GH_ID = @GHId )   
    begin  
     set @GHId = 0  
     Return  
    end  

					
					if(@GStatusID=3)
					Begin
						set @GHDatetime = null
						set @GHLocation = null
						set @GHContact = null
					End

				
         select @GHId = Isnull(max(GH_ID),0)+1  From T0080_Griev_Hearing  WITH (NOLOCK) 

		 insert into T0080_Griev_Hearing (GH_ID,Cmp_ID,G_AllocationID,G_StatusID,HearingDate,HearingLocation,GHContactNo,CDTM,[Log],GHComments) values
		 (@GHId,@Cmp_ID,@GAllocationID,@GStatusID,@GHDatetime,@GHLocation,@GHContact,GETDATE(),@LoginID,@GHComments)

		 declare @GAppID as int 
		 select @GAppID=GrievAppID from T0080_Griev_Application_Allocation where G_Allocation_ID=@GAllocationID

		  
		  if @GStatusID = 7
		  Begin
		     --For Transfer

			 declare @NewAllocID as int = 0

		 	exec P0080_Griev_Application_Allocation @NewAllocID OUTPUT,@Cmp_ID,'I',@CommitteID,@TypeID,@CategoryID,@PriorityID,@GStatusID,@GHComments,'',@GAppID,@LoginID

			 Update T0080_Griev_Hearing 
			 set G_AllocationID =@NewAllocID,
			 G_StatusID=@GStatusID ,
			 HearingDate=@GHDatetime, 
			 HearingLocation=@GHLocation,
			 GHContactNo=@GHContact,
			 UDTM=getdate()
			 where GH_ID = @GHId --Hearing Status Update
		 
		 
		 End


		 
		 Update T0080_Griev_Application_Allocation set
		 Griev_StatusID = @GStatusID,
		 UDTM = GETDATE()
		 where G_Allocation_ID = @GAllocationID --Allocation Status Update


		 Update T0080_Griev_Application set
		 IsForwarded =@GStatusID ,
		 UpdatedDate = GETDATE()
		 where GA_ID=@GAppID --Application Status Update



  End  

 Else if @Tran_Type = 'U'  
  begin  
   IF Not Exists(Select GH_ID  from T0080_Griev_Hearing WITH (NOLOCK) Where GH_ID = @GHId)  
    Begin  
     set @GHId = 0  
     Return   
    End  

		
  end  

 Else if @Tran_Type = 'D'  
  begin  
	--if Not Exists(Select GH_ID  from T0080_Griev_Hearing WITH (NOLOCK) Where GH_ID = @GHId)  
	--	BEGIN
	--		Set @GHId = 0
	--		RETURN 
	--	End
	--ELSE
	--	Begin

				exec P0080_ReverseDelete_Grievance_Heairng @id=@GAllocationID

		--End
   end  
 RETURN