
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0130_Asset_Approval_Delete]
	@Asset_Approval_ID numeric output
	,@Cmp_ID numeric
	,@AssetM_ID numeric
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @AssetM_ID1 numeric
	DECLARE @Asset_ID numeric
	DECLARE @Asset_Approval_ID1 numeric
	DECLARE @Return_Date datetime
	declare @allocation_date datetime
	declare @Application_Type numeric
	declare @Asset_Application_ID numeric
Begin

	if @AssetM_ID > 0  --for delete of Approve Asset
		begin
			select @Application_Type=Application_Type,@AssetM_ID1=AssetM_ID  From dbo.T0130_Asset_Approval_Det WITH (NOLOCK) Where  Asset_Approval_ID=@Asset_Approval_ID and Cmp_ID=@Cmp_ID and assetm_id=@assetm_id 
			select @Asset_Application_ID=Asset_Application_ID From dbo.T0120_Asset_Approval WITH (NOLOCK) Where  Asset_Approval_ID=@Asset_Approval_ID and Cmp_ID=@Cmp_ID 
			
			if @Application_Type =0
				begin
						--if exists(select * from T0130_Asset_Approval_Det ad where(ad.AssetM_ID not in(select top 1 AssetM_ID  From T0130_Asset_Approval_Det Where  Asset_Approval_ID=@Asset_Approval_ID and Cmp_ID=@Cmp_ID)and ad.Application_Type=1))    
					--select @allocation_date=allocation_date From dbo.T0120_Asset_Approval Where  Asset_Approval_ID=@Asset_Approval_ID and  Cmp_ID=@Cmp_ID
							
					if exists(select * from T0120_Asset_Approval WITH (NOLOCK) where @Asset_Approval_ID in (select Return_asset_approval_id from T0130_Asset_Approval_Det WITH (NOLOCK) where Cmp_ID=@Cmp_ID)and Cmp_ID=@Cmp_ID)
							begin
									set @Asset_Approval_ID=-1
									return	-1
							end
								
						UPDATE ad SET ad.allocation=0,ad.Asset_Status='W'
						FROM T0040_Asset_Details ad
						JOIN T0130_Asset_Approval_Det aa ON aa.AssetM_ID = ad.AssetM_ID
						where aa.Asset_Approval_ID=@Asset_Approval_ID and aa.Cmp_ID=@Cmp_ID and ad.assetm_id=@assetm_id 
						
						if @Asset_Application_ID > 0
							begin
								update T0110_Asset_Application_Details
								set Status='P'
								where Asset_Application_ID=@Asset_Application_ID and assetM_id=@AssetM_ID1  and Cmp_ID=@Cmp_ID
								
								update T0100_Asset_Application
								set Application_status='P'
								where Asset_Application_ID=@Asset_Application_ID and Cmp_ID=@Cmp_ID
							end
							
					--Delete from T0140_Asset_Transaction where Asset_Approval_ID = @Asset_Approval_ID and assetm_id=@assetm_id 	 			
					Delete from T0110_Asset_Installation_Details where Asset_Approval_ID=@Asset_Approval_ID	and assetm_id=@assetm_id 	 
					Delete from T0130_Asset_Approval_Det where Asset_Approval_ID=@Asset_Approval_ID and assetm_id=@assetm_id 
						
				end
			else
				begin
						select @Return_Date=Return_Date   From dbo.T0130_Asset_Approval_Det WITH (NOLOCK)
						Where  Asset_Approval_ID = @Asset_Approval_ID and Cmp_ID=@Cmp_ID and assetm_id=@assetm_id 
			
						--if exists(select * from T0120_Asset_Approval AA inner join T0130_Asset_Approval_Det AAD on aa.Asset_Approval_ID = aad.Asset_Approval_ID where aad.Allocation_Date > @Return_Date and aa.Cmp_ID=@Cmp_ID  and aa.Asset_Approval_ID <> @Asset_Approval_ID and aad.assetm_id=@assetm_id )
						--if exists(select * from T0120_Asset_Approval where @Asset_Approval_ID in (select Return_asset_approval_id from T0130_Asset_Approval_Det where Cmp_ID=@Cmp_ID)and Cmp_ID=@Cmp_ID)
						--	begin
						--			--RAISERROR ('@@Asset Return Application already done so cannot be deleted.', 16, 2)
						--			-- return	@Asset_Approval_ID
						--			 set @Asset_Approval_ID=-1
						--			 return	-1
						--	end
						if exists(select * from T0120_Asset_Approval WITH (NOLOCK) where @AssetM_ID1 in (select AssetM_ID from T0130_Asset_Approval_Det WITH (NOLOCK) where Cmp_ID=@Cmp_ID and application_type=0 and Asset_Approval_ID>@Asset_Approval_ID)and Cmp_ID=@Cmp_ID)				
							begin
								set	@Asset_Approval_ID=-1
								return	@Asset_Approval_ID 
							end
							
						begin
							UPDATE ad SET ad.allocation=1,ad.Asset_Status='W'
							FROM T0040_Asset_Details ad
							JOIN T0130_Asset_Approval_Det aa ON aa.AssetM_ID = ad.AssetM_ID
							where aa.Asset_Approval_ID=@Asset_Approval_ID and aa.Cmp_ID=@Cmp_ID and ad.allocation=0 and ad.assetm_id=@assetm_id 
						end
									
						update T0110_Asset_Application_Details
						set Status='P'
						where Asset_Application_ID=@Asset_Application_ID and assetM_id=@AssetM_ID1  and Cmp_ID=@Cmp_ID
										--update T0100_Asset_Application
						--set Application_status='P'
						--where Asset_Application_ID=@Asset_Application_ID and Cmp_ID=@Cmp_ID
						
							
						Delete from T0110_Asset_Installation_Details where Asset_Approval_ID=@Asset_Approval_ID and assetm_id=@assetm_id 
						Delete from T0130_Asset_Approval_Det where Asset_Approval_ID=@Asset_Approval_ID and assetm_id=@assetm_id 
				end
		end
	else  --for delete of Reject Asset
		begin
			select @Application_Type=Application_Type,@Asset_ID=Asset_ID  From dbo.T0130_Asset_Approval_Det WITH (NOLOCK) Where  Asset_Approval_ID=@Asset_Approval_ID and Cmp_ID=@Cmp_ID 
			select @Asset_Application_ID=Asset_Application_ID From dbo.T0120_Asset_Approval WITH (NOLOCK) Where  Asset_Approval_ID=@Asset_Approval_ID and Cmp_ID=@Cmp_ID 
			
			if @Application_Type =0 --for allocation of asset 
				begin
						--if exists(select * from T0130_Asset_Approval_Det ad where(ad.AssetM_ID not in(select top 1 AssetM_ID  From T0130_Asset_Approval_Det Where  Asset_Approval_ID=@Asset_Approval_ID and Cmp_ID=@Cmp_ID)and ad.Application_Type=1))    
					--select @allocation_date=allocation_date From dbo.T0120_Asset_Approval Where  Asset_Approval_ID=@Asset_Approval_ID and  Cmp_ID=@Cmp_ID
							
					if exists(select * from T0120_Asset_Approval WITH (NOLOCK) where @Asset_Approval_ID in (select Return_asset_approval_id from T0130_Asset_Approval_Det WITH (NOLOCK) where Cmp_ID=@Cmp_ID)and Cmp_ID=@Cmp_ID)
							begin
									set @Asset_Approval_ID=-1
									return	-1
							end
							
						if @Asset_Application_ID > 0
							begin
								update T0110_Asset_Application_Details
								set Status='P'
								where Asset_Application_ID=@Asset_Application_ID and Asset_ID=@Asset_ID and Cmp_ID=@Cmp_ID
								
								update T0100_Asset_Application
								set Application_status='P'
								where Asset_Application_ID=@Asset_Application_ID and Cmp_ID=@Cmp_ID
							end
							
				--	Delete from T0110_Asset_Installation_Details where Asset_Approval_ID=@Asset_Approval_ID		 
					Delete from T0130_Asset_Approval_Det where Asset_Approval_ID=@Asset_Approval_ID and Approval_Status='R'
						
				end
			else --for Return of asset
				begin
						select @Return_Date=Return_Date   From dbo.T0130_Asset_Approval_Det WITH (NOLOCK)
						Where  Asset_Approval_ID = @Asset_Approval_ID and Cmp_ID=@Cmp_ID and assetm_id=@assetm_id 
			
						select @Application_Type=Application_Type,@Asset_ID=Asset_ID  From dbo.T0130_Asset_Approval_Det WITH (NOLOCK) Where  Asset_Approval_ID=@Asset_Approval_ID and Cmp_ID=@Cmp_ID 
						select @Asset_Application_ID=Asset_Application_ID From dbo.T0120_Asset_Approval WITH (NOLOCK) Where  Asset_Approval_ID=@Asset_Approval_ID and Cmp_ID=@Cmp_ID 
			
						--if exists(select * from T0120_Asset_Approval AA inner join T0130_Asset_Approval_Det AAD on aa.Asset_Approval_ID = aad.Asset_Approval_ID where aad.Allocation_Date > @Return_Date and aa.Cmp_ID=@Cmp_ID  and aa.Asset_Approval_ID <> @Asset_Approval_ID and aad.assetm_id=@assetm_id )
						--if exists(select * from T0120_Asset_Approval where @Asset_Approval_ID in (select Return_asset_approval_id from T0130_Asset_Approval_Det where Cmp_ID=@Cmp_ID)and Cmp_ID=@Cmp_ID)
						--	begin
						--			--RAISERROR ('@@Asset Return Application already done so cannot be deleted.', 16, 2)
						--			-- return	@Asset_Approval_ID
						--			 set @Asset_Approval_ID=-1
						--			 return	-1
						--	end
						if exists(select * from T0120_Asset_Approval WITH (NOLOCK) where @AssetM_ID1 in (select AssetM_ID from T0130_Asset_Approval_Det WITH (NOLOCK) where Cmp_ID=@Cmp_ID and application_type=0 and Asset_Approval_ID>@Asset_Approval_ID)and Cmp_ID=@Cmp_ID)				
							begin
								set	@Asset_Approval_ID=-1
								return	@Asset_Approval_ID 
							end
							
							if @Asset_Application_ID > 0
							begin
								update T0110_Asset_Application_Details
								set Status='P'
								where Asset_Application_ID=@Asset_Application_ID and Asset_ID=@Asset_ID and Cmp_ID=@Cmp_ID
								
								update T0100_Asset_Application
								set Application_status='P'
								where Asset_Application_ID=@Asset_Application_ID and Cmp_ID=@Cmp_ID
							end
																				
						--update T0110_Asset_Application_Details
						--set Status='P'
						--where Asset_Application_ID=@Asset_Application_ID and assetM_id=@AssetM_ID1  and Cmp_ID=@Cmp_ID
										--update T0100_Asset_Application
						--set Application_status='P'
						--where Asset_Application_ID=@Asset_Application_ID and Cmp_ID=@Cmp_ID
						
						--Delete from T0110_Asset_Installation_Details where Asset_Approval_ID=@Asset_Approval_ID and assetm_id=@assetm_id 
						Delete from T0130_Asset_Approval_Det where Asset_Approval_ID=@Asset_Approval_ID and Approval_Status='R'
				end
		end
		
End			












