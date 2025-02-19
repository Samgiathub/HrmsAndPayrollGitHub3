
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Asset_Installment_Statement]

	 @cmp_Id numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	--,@Asset_Name		varchar(100)
As
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
	 
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null

Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else 
		begin
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date and  @From_Date <= left_date ) 
			
		end	


--SELECT  distinct   At.For_Date as Paid_Date,ISNULL(At.Issue_Amount,0) as Purchase_Amount ,ISNULL(At.Receive_Amount,0) as Install_Amount, 
--                      Aad.Installment_date,E.emp_Id,E.Alpha_Emp_Code
--FROM         dbo.T0130_Asset_Approval_Det Aad CROSS JOIN
--                      dbo.T0140_Asset_Transaction At inner join 
--                      dbo.T0080_EMP_MASTER E on at.Emp_Id = E.Emp_ID 
--                      where at.Cmp_Id=@Cmp_ID and E.Emp_ID in (select Emp_ID From @Emp_Cons) and at.Emp_Id<>0

		SELECT  distinct   At.For_Date as Paid_Date,ISNULL(At.Issue_Amount,0) as Purchase_Amount ,ISNULL(At.Receive_Amount,0) as Install_Amount, 
			at.asset_opening,am.asset_id,Aad.Installment_date,am.asset_name,E.emp_Id,E.Alpha_Emp_Code,E.Emp_Full_Name,E.Emp_Full_Name,C.Cmp_Address,C.Cmp_Name,
			ISNULL(at.Asset_Closing,0) as Balance,ad.asset_code,br.brand_name,ad.model,ap.asset_approval_date,ad.assetm_id,Aad.Deduction_Type
			,INC.Branch_ID --Added by Nimesh 11-Jul-2015 (To filter by multi branch)
		FROM dbo.T0130_Asset_Approval_Det Aad WITH (NOLOCK) inner join 
			t0040_asset_details ad WITH (NOLOCK) on aad.assetM_id=ad.assetM_id and aad.cmp_id=ad.cmp_id inner join 
			t0040_brand_master br WITH (NOLOCK) on br.brand_id=ad.brand_id and ad.cmp_id=br.cmp_id inner join
			T0040_ASSET_MASTER AM WITH (NOLOCK) ON aad.asset_id=am.asset_id and am.cmp_id=aad.cmp_id inner join					
			t0120_asset_approval ap WITH (NOLOCK) on ap.asset_approval_id=aad.asset_approval_id inner join
			dbo.T0140_Asset_Transaction At WITH (NOLOCK) on ap.asset_approval_id=at.asset_approval_id and at.emp_id=ap.emp_id and aad.AssetM_ID = at.AssetM_Id inner join 
			dbo.T0080_EMP_MASTER E WITH (NOLOCK) on at.Emp_Id = E.Emp_ID inner join
			dbo.T0010_COMPANY_MASTER C WITH (NOLOCK) on c.Cmp_Id= e.Cmp_ID LEFT OUTER JOIN
			(
				Select Emp_ID,Branch_ID FROM T0095_INCREMENT I WITH (NOLOCK)
				WHERE I.Increment_Effective_date = (Select MAX(Increment_Effective_date) FROM T0095_INCREMENT I1 WITH (NOLOCK)
													WHERE	I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID 
															AND Increment_Effective_date <= @To_Date													
													)
					  AND Cmp_ID=@cmp_Id
			) INC ON INC.Emp_ID=E.Emp_ID
		where at.Cmp_Id=@Cmp_ID  and E.Emp_ID in (select Emp_ID From @Emp_Cons) and at.Emp_Id<>0
		and ISNULL(At.Receive_Amount,0)>0 and ap.asset_approval_date between @From_Date and @To_Date

