CREATE  Procedure P0080_ReverseDelete_Grievance_Heairng
@id int -- Main Allocation ID
As
Begin

--Created  by ronakk 16042022
			if exists (select GHH_ID from V0080_Griev_Hearing_History_Lettest where G_AllocationID=@ID)
			Begin
			  
			  Declare @GHHID as int
			  Declare @GHID as int 
			
			  declare @Status as int
			  declare @Location as nvarchar(1000)
			  declare @Contact as nvarchar(15)
			  declare @AllocID as int
			  declare @AppID as int
			
			  declare @HeairngDate as Datetime
			
			  select @GHHID=GHH_ID from V0080_Griev_Hearing_History_Lettest where G_AllocationID=@ID --Get Letest record based on allocation id
			
			
			  select @GHID=G_HearingID,@HeairngDate=Last_HearingDate,@Status=G_StatusID ,@AllocID=G_AllocationID,@Location=GHHLocation,@Contact=GHHContact
			  from T0080_Griev_Hearing_History where GHH_ID=@GHHID -- Store last hearing date for update next heairng date
			
			
			   Delete from T0080_Griev_Hearing_History where GHH_ID=@GHHID -- delete last record
			
			  if exists(select GHH_ID from V0080_Griev_Hearing_History_Lettest where GH_ID=@GHID)
			  Begin
			
				 select @GHHID=GHH_ID from V0080_Griev_Hearing_History_Lettest 
				 where GH_ID=@GHID -- get letest record after delete record
			
			     select @GHID=G_HearingID,@Status=G_StatusID,@Location=GHHLocation,@Contact=GHHContact,@AllocID=G_AllocationID
			     from T0080_Griev_Hearing_History where GHH_ID=@GHHID -- get last record for update 
			
			  End
			  else
			  Begin
			     set @Status=4
			  End
			
			  select top 1 @AppID=GrievAppID from T0080_Griev_Application_Allocation where G_Allocation_ID = @AllocID
			
			  if(@ID=@AllocID)
			  Begin
					
					update T0080_Griev_Hearing set HearingDate=@HeairngDate,G_StatusID=@Status,HearingLocation=@Location,GHContactNo=@Contact,UDTM=getdate()
					where GH_ID=@GHID
			
					update T0080_Griev_Application_Allocation set Griev_StatusID=@Status ,UDTM=GETDATE()
					where G_Allocation_ID=@AllocID
			
					update T0080_Griev_Application set IsForwarded=@Status,UpdatedDate=GETDATE()
					where GA_ID=@AppID
			
			  end
			  else
			  Begin
			      
				  Delete from T0080_Griev_Application_Allocation where G_Allocation_ID=@ID
				   
				   update T0080_Griev_Hearing set HearingDate=@HeairngDate,G_StatusID=@Status,G_AllocationID=@AllocID,
				   HearingLocation=@Location,GHContactNo=@Contact,UDTM=getdate()
					where GH_ID=@GHID
			
				   update T0080_Griev_Application_Allocation set Griev_StatusID=@Status ,UDTM=GETDATE()
				   where G_Allocation_ID=@AllocID
				   
				   update T0080_Griev_Application set IsForwarded=@Status,UpdatedDate=GETDATE()
				   where GA_ID=@AppID
				 
			  end
			
			End
			else
			Begin
			
				declare @CountHearing as int 
				declare @HeairngID as int 
				declare @ApplicationID as int
			
			     select @CountHearing=AttemptHearing,@HeairngID=GH_ID,@ApplicationID=AppID 
				 from V0080_Griev_App_Alloc_FullDetails where G_Allocation_ID=@ID
			
				 if @CountHearing=0 and @HeairngID<>0
				 Begin
				      
					  Delete From T0080_Griev_Hearing where GH_ID=@HeairngID
					  
					  Update T0080_Griev_Application_Allocation set Griev_StatusID=2,UDTM=GETDATE() 
					  where G_Allocation_ID=@ID 
			
					  update T0080_Griev_Application set IsForwarded=2,UpdatedDate=GETDATE()
				      where GA_ID=@ApplicationID
			
				 End
				 else if @CountHearing=0 and @HeairngID=0
				 Begin
			
				      Delete from T0080_Griev_Application_Allocation 
					  where G_Allocation_ID=@ID 
			
				      update T0080_Griev_Application set IsForwarded=0,UpdatedDate=GETDATE()
				      where GA_ID=@ApplicationID
				 End
			
			End

End
