
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0120_Asset_Approval_Delete]
	@Asset_Approval_ID numeric output
	,@Cmp_ID numeric
	,@Asset_Application_ID numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Application_Type numeric
	DECLARE @AssetM_ID1 numeric
	DECLARE @Asset_Approval_ID1 numeric
	DECLARE @Return_Date datetime
	declare @allocation_date datetime
	declare @Transfer_Id as numeric
	
Begin
		
	select @Application_Type=Application_Type,@AssetM_ID1=AssetM_ID  From dbo.T0130_Asset_Approval_Det WITH (NOLOCK) Where  Asset_Approval_ID=@Asset_Approval_ID and Cmp_ID=@Cmp_ID
	print @Asset_Approval_ID
	print @Application_Type
	print @AssetM_ID1
	
	if (@Application_Type =0) or (@Application_Type =2)  --while allocation
		begin
				--if exists(select * from T0130_Asset_Approval_Det ad where(ad.AssetM_ID not in(select top 1 AssetM_ID  From T0130_Asset_Approval_Det Where  Asset_Approval_ID=@Asset_Approval_ID and Cmp_ID=@Cmp_ID)and ad.Application_Type=1))    
			--select @allocation_date=allocation_date From dbo.T0120_Asset_Approval Where  Asset_Approval_ID=@Asset_Approval_ID and  Cmp_ID=@Cmp_ID
			--if exists(select * from T0120_Asset_Approval AA inner join T0130_Asset_Approval_Det AAD on aa.Asset_Approval_ID = aad.Asset_Approval_ID where aad.Return_Date > aad.allocation_date  and aa.Cmp_ID=@Cmp_ID  and aa.Asset_Approval_ID <> @Asset_Approval_ID)
				if exists(select * from T0120_Asset_Approval WITH (NOLOCK) where @Asset_Approval_ID in (select isnull(Return_asset_approval_id,0) from T0130_Asset_Approval_Det WITH (NOLOCK) where Cmp_ID=@Cmp_ID and isnull(Return_asset_approval_id,0) > 0)and Cmp_ID=@Cmp_ID and Asset_Approval_ID=@Asset_Approval_ID) 
					begin
						set	@Asset_Approval_ID=-1
						return	@Asset_Approval_ID
					end
					
										
				UPDATE ad SET ad.allocation=0,ad.Asset_Status='W'
				FROM T0040_Asset_Details ad
				JOIN T0130_Asset_Approval_Det aa ON aa.AssetM_ID = ad.AssetM_ID
				where aa.Asset_Approval_ID=@Asset_Approval_ID and aa.Cmp_ID=@Cmp_ID
				
				update T0100_Asset_Application
				set Application_status='P'
				where Asset_Application_ID=@Asset_Application_ID and Cmp_ID=@Cmp_ID
				
							
				--update T0110_Asset_Application_Details
				--set Status='P'
				--where Asset_Application_ID=@Asset_Application_ID and asset_id in (@Asset_ID) and Cmp_ID=@Cmp_ID
				
				Delete from T0140_Asset_Transaction where Asset_Approval_ID = @Asset_Approval_ID	
				Delete from T0130_Asset_Approval_Det where Asset_Approval_ID=@Asset_Approval_ID 
				Delete from T0110_Asset_Installation_Details where Asset_Approval_ID=@Asset_Approval_ID
				Delete from T0120_Asset_Approval where Asset_Approval_ID = @Asset_Approval_ID	
						
		end
    else if  (@Application_Type =1)--while Return
		begin
				select @Return_Date=Return_Date   From dbo.T0130_Asset_Approval_Det WITH (NOLOCK)
				Where  Asset_Approval_ID = @Asset_Approval_ID and Cmp_ID=@Cmp_ID
				
				if exists(select * from T0120_Asset_Approval WITH (NOLOCK) where @AssetM_ID1 in (select AssetM_ID from T0130_Asset_Approval_Det WITH (NOLOCK) where Cmp_ID=@Cmp_ID and application_type=0 and Asset_Approval_ID>@Asset_Approval_ID)and Cmp_ID=@Cmp_ID)				
					begin
						set	@Asset_Approval_ID=-1
						return	@Asset_Approval_ID 
					end
					
				begin
					UPDATE ad SET ad.allocation=1,ad.Asset_Status='W'
					FROM T0040_Asset_Details ad
					JOIN T0130_Asset_Approval_Det aa ON aa.AssetM_ID = ad.AssetM_ID
					where aa.Asset_Approval_ID=@Asset_Approval_ID and aa.Cmp_ID=@Cmp_ID and ad.allocation=0
				end
							
				update T0100_Asset_Application
				set Application_status='P'
				where Asset_Application_ID=@Asset_Application_ID and Cmp_ID=@Cmp_ID
				
				--update T0110_Asset_Application_Details
				--set Status='P'
				--where Asset_Application_ID=@Asset_Application_ID and assetM_id=@AssetM_ID1 and Cmp_ID=@Cmp_ID
				--and assetM_id=@AssetM_ID1
				Delete from T0140_Asset_Transaction where Asset_Approval_ID = @Asset_Approval_ID
				Delete from T0130_Asset_Approval_Det where Asset_Approval_ID=@Asset_Approval_ID
				Delete from T0110_Asset_Installation_Details where Asset_Approval_ID=@Asset_Approval_ID
				Delete from T0120_Asset_Approval where Asset_Approval_ID = @Asset_Approval_ID
		end
	else if  (@Application_Type =3)--while Transfer
		begin
			if exists(select * from T0120_Asset_Approval WITH (NOLOCK) where @Asset_Approval_ID in (select isnull(Return_asset_approval_id,0) from T0130_Asset_Approval_Det WITH (NOLOCK) where Cmp_ID=@Cmp_ID and isnull(Return_asset_approval_id,0) > 0)and Cmp_ID=@Cmp_ID and Asset_Approval_ID=@Asset_Approval_ID) 
					begin
						set	@Asset_Approval_ID=-1
						return	@Asset_Approval_ID
					end
		--For Deleting Return entry(start)
			select @Transfer_Id=Asset_Approval_ID  From dbo.T0130_Asset_Approval_Det WITH (NOLOCK) Where  Transfer_Id = @Asset_Approval_ID and Cmp_ID=@Cmp_ID
			Delete from T0140_Asset_Transaction where Asset_Approval_ID = @Transfer_Id
			Delete from T0110_Asset_Installation_Details where Asset_Approval_ID=@Transfer_Id
			Delete from T0130_Asset_Approval_Det where Asset_Approval_ID=@Transfer_Id
			Delete from T0120_Asset_Approval where Asset_Approval_ID = @Transfer_Id
		--For Deleting Return entry(end)		
				
			UPDATE ad SET ad.allocation=1,ad.Asset_Status='W'
				FROM T0040_Asset_Details ad
				JOIN T0130_Asset_Approval_Det aa ON aa.AssetM_ID = ad.AssetM_ID
				where aa.Asset_Approval_ID=@Asset_Approval_ID and aa.Cmp_ID=@Cmp_ID
										
			Delete from T0140_Asset_Transaction where Asset_Approval_ID = @Asset_Approval_ID
			Delete from T0110_Asset_Installation_Details where Asset_Approval_ID=@Asset_Approval_ID
			Delete from T0130_Asset_Approval_Det where Asset_Approval_ID=@Asset_Approval_ID
			Delete from T0120_Asset_Approval where Asset_Approval_ID = @Asset_Approval_ID
		end
End			




