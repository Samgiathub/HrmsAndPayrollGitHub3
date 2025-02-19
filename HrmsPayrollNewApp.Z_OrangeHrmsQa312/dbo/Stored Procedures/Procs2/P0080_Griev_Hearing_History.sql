

CREATE PROCEDURE [dbo].[P0080_Griev_Hearing_History]
    @GHHId  numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@tran_type  varchar(1) 
   ,@GHearingID int
   ,@GHStatusID int
   ,@GHNDatetime Datetime
   ,@GHComments nvarchar(2000)
   ,@GHDocName nvarchar(400)
   ,@GHLocation nvarchar(2000)
   ,@GHContact nvarchar(10)
   ,@LoginID int 
   ,@CommitteID int
   ,@TypeID int
   ,@CategoryID int
   ,@PriorityID int

AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  --Created by Ronak Kumawat 26032022


 If @tran_type  = 'I'  
  Begin  
  if exists (Select  GHH_ID  from T0080_Griev_Hearing_History WITH (NOLOCK) Where GHH_ID = @GHHId )   
    begin  
     set @GHHId = 0  
     Return  
    end  

			if @GHStatusID = 5
			Begin
			    
				set @GHNDatetime = null

			End

         select @GHHId = Isnull(max(GHH_ID),0)+1  From T0080_Griev_Hearing_History  WITH (NOLOCK) 

		

		 Declare @LastHearingDate as Datetime
		 declare @GAllocationID as int
		 declare @GHHL as nvarchar(2000)
		 declare @GHHC as nvarchar(10)

		 select @LastHearingDate = HearingDate,@GAllocationID=G_AllocationID,
		 @GHHL = HearingLocation, @GHHC = GHContactNo
		 from T0080_Griev_Hearing where GH_ID=@GHearingID


		 declare @GAppID as int 
		 select top 1 @GAppID=GrievAppID from T0080_Griev_Application_Allocation where G_Allocation_ID=@GAllocationID	


	
		 insert into T0080_Griev_Hearing_History (GHH_ID,Cmp_ID,G_HearingID,G_StatusID,Last_HearingDate,
		 Next_HearingDate,GHHComments,GHHDocName,CDTM,[Log],GHHLocation,GHHContact,G_AllocationID) values
		 (@GHHId,@Cmp_ID,@GHearingID,@GHStatusID,@LastHearingDate,@GHNDatetime,@GHComments,@GHDocName,GETDATE(),@LoginID,@GHHL,@GHHC,@GAllocationID)

		 
		 
		  if @GHStatusID = 7
		 Begin
		     --For Transfer

			 declare @NewAllocID as int = 0

		 	exec P0080_Griev_Application_Allocation @NewAllocID OUTPUT,@Cmp_ID,'I',@CommitteID,@TypeID,@CategoryID,@PriorityID,@GHStatusID,@GHComments,'',@GAppID,@LoginID

			 Update T0080_Griev_Hearing 
			 set G_AllocationID =@NewAllocID,
			 G_StatusID=@GHStatusID ,
			 HearingDate=@GHNDatetime, 
			 HearingLocation=@GHLocation,
			 GHContactNo=@GHContact,
			 UDTM=getdate()
			 where GH_ID = @GHearingID --Hearing Status Update
		 
		 
		 End
		 else
		 Begin

			 Update T0080_Griev_Hearing set G_StatusID=@GHStatusID ,HearingDate=@GHNDatetime, 
			 HearingLocation=@GHLocation,GHContactNo=@GHContact,UDTM=getdate()
			 where GH_ID = @GHearingID --Hearing Status Update
		 
		 
		 End

		 
		 Update T0080_Griev_Application_Allocation 
		 set Griev_StatusID = @GHStatusID ,
		 UDTM=getdate()
		 where G_Allocation_ID = @GAllocationID --Allocation Status Update


		 Update T0080_Griev_Application 
		 set IsForwarded =@GHStatusID,
		 UpdatedDate=getdate()
		 where GA_ID=@GAppID --Application Status Update


  End  

 Else if @Tran_Type = 'U'  
  begin  
   IF Not Exists(Select GHH_ID  from T0080_Griev_Hearing_History WITH (NOLOCK) Where GHH_ID = @GHHId)  
    Begin  
     set @GHHId = 0  
     Return   
    End  

  end  

 Else if @Tran_Type = 'D'  
  begin  
	if Not Exists(Select GHH_ID  from T0080_Griev_Hearing_History WITH (NOLOCK) Where GHH_ID = @GHHId)  
		BEGIN

			Set @GHHId = 0
			RETURN 
		End
	ELSE
		Begin
		
					--select * From T0080_Griev_Hearing_History Where GHH_ID = @GHHId
				Delete From T0080_Griev_Hearing_History Where GHH_ID = @GHHId --For Hard Delete

		End
   end  
 RETURN