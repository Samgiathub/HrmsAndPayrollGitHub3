


---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_Asset_Allocation_Details]
	 @Cmp_ID	 numeric
	--,@emp_id   numeric
	,@approval_id numeric
	,@status varchar(5)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @status='A'
		begin
		select 555
			select ap.asset_id,ap.Brand_id,ap.Serial_No,case when convert(varchar(10),ap.Purchase_date,103) ='01/01/1900' then '' else convert(varchar(10),ap.Purchase_date,103) end as Purchase_date,case when convert(varchar(10),ap.allocation_Date,103)='01/01/1900' then '' else convert(varchar(10),ap.allocation_Date,103) end allocation_Date, 
            case when convert(varchar(10),ap.Return_date,103) ='01/01/1900' then '' else convert(varchar(10),ap.Return_date,103) end as Return_date,ap.AssetM_Id,ap.Asset_code,ap.asset_approval_id,ap.Model_name as Model,v.Brand_Name as Brand,am.Asset_Name as Asset,ap.cmp_Id, 
            case when ap.Approval_status='A' then 'Approve' else 'Reject' end as Approval_status,ap.Installment_Amount,case when convert(varchar(10),ap.Installment_date,103) ='01/01/1900' then '' else convert(varchar(10),ap.Installment_date,103) end as Installment_date,v.[Description]as Asset_Description from t0130_asset_approval_det ap WITH (NOLOCK)
            inner join t0040_asset_master am WITH (NOLOCK) on am.asset_id=ap.asset_id and am.cmp_id=ap.cmp_id 
            left join V0040_asset_details v on ap.assetm_id=v.assetm_id and ap.cmp_id=v.cmp_id  
            where ap.asset_approval_id = @approval_id and ap.Cmp_ID =@Cmp_ID
        end                                                              
   else
		begin
		select 666
			select ap.asset_id,0 as Brand_id,ap.Serial_No,case when convert(varchar(10),ap.Purchase_date,103) ='01/01/1900' then '' else convert(varchar(10),ap.Purchase_date,103) end as Purchase_date,case when convert(varchar(10),ap.allocation_Date,103)='01/01/1900' then '' else convert(varchar(10),ap.allocation_Date,103) end allocation_Date, 
            case when convert(varchar(10),ap.Return_date,103) ='01/01/1900' then '' else convert(varchar(10),ap.Return_date,103) end as Return_date,ap.AssetM_Id,ap.Asset_code,ap.asset_approval_id,ap.Model_name as Model,'' as Brand,v.Asset_Name as Asset,ap.cmp_Id,case when ap.Approval_status='A' then 'Approve' else 'Reject' end as Approval_status, 
            0 as Installment_Amount,'' as Installment_date,v1.[Description]as Asset_Description from t0130_asset_approval_det ap WITH (NOLOCK)
            left join V0040_asset_details v1 on ap.assetm_id=v1.assetm_id and ap.cmp_id=v1.cmp_id  
            inner join t0040_asset_master v WITH (NOLOCK) on ap.asset_id=v.asset_id and ap.cmp_id=v.cmp_id  
            where ap.asset_approval_id =@approval_id and ap.Cmp_ID =@Cmp_ID
		end        
                                          
Return




