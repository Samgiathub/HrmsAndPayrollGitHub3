  
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[SP_GET_ASSET_APPROVAL_FORMAT2]  
  @Cmp_ID   numeric,  
  @From_Date  DATETIME,  
  @To_date DATETIME,  
  @constraint  varchar(MAX),  
  @branch1   numeric  
 --,@Branch_ID  numeric   = 0  
 ,@Cat_ID  numeric  = 0  
 ,@Grd_ID  numeric = 0  
 ,@Type_ID  numeric  = 0  
 --,@Dept_ID  numeric  = 0  
 ,@Desig_ID  numeric = 0  
 ,@Emp_ID  numeric  = 0  
 ,@RC_ID   numeric(18,0) = 0  
 ,@Asset_ID     numeric    
 ,@Dept_Id1  numeric   
 ,@Brand   numeric   
 AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
 --if @Branch_ID = 0  
 -- set @Branch_ID = null  
 if @Cat_ID = 0  
  set @Cat_ID = null  
 if @Type_ID = 0  
  set @Type_ID = null  
 --if @Dept_ID = 0  
 -- set @Dept_ID = null  
 if @Grd_ID = 0  
  set @Grd_ID = null  
 if @Emp_ID = 0  
  set @Emp_ID = null  
 If @Desig_ID = 0  
  set @Desig_ID = null  
 if @Branch1 = 0  
  set @Branch1 = null  
 if @Brand = 0  
  set @Brand = NULL  
       
 Declare @Emp_Cons Table  
 (  
  Emp_ID numeric  
 )  
 declare @AssetM_Id as numeric(18,0)  
 declare @AssetCat_Id as numeric(18,0)   
 declare @Description as varchar(500)  
 declare @Type_of_Asset as  varchar(250)  
 declare @SerialNo as varchar(250)  
 declare @Brand_Id as numeric(18,0)  
 declare @Model as varchar(250)  
 declare @Vendor as varchar(250)  
 declare @Status as varchar(25)  
 declare @Warranty_Starts as varchar(50)  
 declare @Warranty_Ends as varchar(50)  
 declare @Purchase_Date as varchar(50)  
 declare @Image as varchar(max)  
 declare @Asset_Code as  Varchar(250)  
 declare @Allocation as numeric(18,0)  
 declare @Asset_Status as Varchar(10)  
 declare @Invoice_No as Varchar(100)  
 declare @Invoice_Amount as numeric(18,2)  
 declare @Attach_Doc as Varchar(max)  
 declare @Part_No as Varchar(max)  
 declare @IMEI_No as Varchar(max)  
 declare @Mac_Address as Varchar(max)  
 declare @Vendor_Address as Varchar(max)  
 declare @Invoice_Date as datetime  
 declare @PONO as Varchar(100)  
 declare @pono_Date as datetime  
 declare @City as Varchar(200)  
 declare @Contact_Person as Varchar(250)  
 declare @contact_no as Varchar(30)  
 declare @Dispose_Date as datetime  
 declare @Vendor_Id as numeric(18,0)   
 declare @Asset_Name as varchar(250)  
 declare @BRAND_Name as varchar(250)  
 declare @Alpha_Emp_Code as varchar(250)  
 declare @Emp_Full_Name as varchar(250)  
 declare @Dept_Name as Varchar(250)  
 declare @Installation_Type as Varchar(100)  
 declare @Asset_Title as Varchar(250)  
 declare @Asset_Installation_Name as Varchar(300)  
 declare @Installation_Details as Varchar(max)  
 declare @Branch_Name as varchar(250)  
 declare @Desig_Name as Varchar(300)  
 declare @Cat_Name as Varchar(300)  
 declare @Asset_Approval_ID as numeric(18,0)  
 declare @Asset_Approval_date as datetime   
 declare @application_type as numeric(18,0)  
 declare @Transfer_Emp_Id as numeric(18,0)  
 declare @Allocation_date as DATETIME  
   
 CREATE table #ASSET_EMP  
 (  
  Cmp_Id numeric(18,0) ,  
  AssetM_Id numeric(18,0) ,  
  [Description] varchar(500),  
  Type_of_Asset  varchar(250),  
  SerialNo  varchar(250),  
  AssetCat_Id numeric(18,0) ,  
  Model  varchar(250),  
  Vendor  varchar(250),  
  Warranty_Starts datetime,  
  Warranty_Ends datetime,  
  Purchase_Date datetime,  
  Asset_Code  Varchar(250),  
  Allocation numeric(18,0) ,  
  Invoice_No Varchar(100),  
  Invoice_Amount numeric(18,2) ,  
  Vendor_Address Varchar(max),  
  Invoice_Date datetime,  
  PONO Varchar(100),  
  pono_Date datetime,  
  City Varchar(200),  
  Contact_Person Varchar(250),  
  contact_no Varchar(30),  
  Dispose_Date datetime,  
  Vendor_Id numeric(18,0) ,  
  Asset_Name  varchar(250),  
  BRAND_Name  varchar(250),  
  Emp_Id  numeric(18,0) ,  
  Alpha_Emp_Code varchar(250),  
  Emp_Full_Name varchar(250),  
  Dept_Name Varchar(250),  
  Installation_Type Varchar(100),  
  Asset_Title Varchar(250),  
  Branch_Name  varchar(250),  
  Desig_Name Varchar(300),  
  Cat_Name Varchar(300),  
  Asset_Approval_ID numeric(18,0) ,  
  Asset_Approval_date datetime,  
  Transfer_Emp_Id  numeric(18,0) ,  
  Installation_Details Varchar(max),  
  Installation_Name Varchar(max),  
  Application_Type VARCHAR(25),  
  Allocation_date datetime,  
  Brand_ID NUMERIC(18,0)  
 )  
   
  
 CREATE TABLE #ASSET_INSTALLATION  
 (  
 Emp_ID numeric(18,0),  
 Installation_Details Varchar(max),  
 Installation_Name Varchar(max),  
 Installation_Type Varchar(max),   
 assetm_id numeric(18,0),  
 asset_approval_id numeric(18,0)  
 )  
   
 declare @Installation_Details1 Varchar(max)  
 declare @Installation_Name1 Varchar(max)  
 declare @Installation_Type1 Varchar(max)   
   
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
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  
   Where Cmp_ID = @Cmp_ID   
   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))  
   and Branch_ID = isnull(@branch1 ,Branch_ID)  
   and Grd_ID = isnull(@Grd_ID ,Grd_ID)  
   and isnull(Dept_ID,0) = isnull(@Dept_Id1 ,isnull(Dept_ID,0))  
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
    --select Emp_ID From @Emp_Cons  
  
 BEGIN  
     DECLARE ASSET_DETAILS CURSOR FOR  
    select apd.Asset_Approval_ID,apd.application_type,apd.assetm_id,ap.emp_id  
    from T0130_Asset_Approval_Det apd WITH (NOLOCK)  
    inner join T0120_Asset_Approval ap WITH (NOLOCK) on apd.Asset_Approval_ID=ap.Asset_Approval_ID and apd.cmp_id=ap.cmp_id  
    and ap.application_type <> 1  
    where ap.cmp_id=@cmp_id and apd.Application_Type <> 1 and (ap.emp_id in (select Emp_ID From @Emp_Cons)or ap.Transfer_emp_id in (select Emp_ID From @Emp_Cons))  
  OPEN ASSET_DETAILS  
    fetch next from ASSET_DETAILS into @Asset_Approval_ID,@application_type,@AssetM_ID,@emp_id  
     while @@fetch_status = 0  
     Begin  
      if @application_type=0 --fill asset while Allocation  
      begin  
         SELECT distinct @AssetCat_Id=ad.Asset_Id,@AssetM_Id=ad.AssetM_Id,@Description=ad.[Description],@Type_of_asset=ad.Type_of_asset,@SerialNO=ad.SerialNO,@Model=ad.Model,@Warranty_Starts=ad.Warranty_Starts ,  
         @Warranty_Ends=ad.Warranty_Ends,@Purchase_Date=ad.Purchase_Date ,  
         @pono=ad.pono,@pono_Date=ad.pono_Date,@Invoice_no=ad.Invoice_no,@Invoice_Date=ad.Invoice_Date,@BRAND_Name=br.BRAND_Name,@Asset_Name=am.Asset_Name,@Emp_ID=ap.Emp_ID,  
            @Installation_Details=isnull(dbo.T0110_Asset_Installation_Details.Installation_Details,''),@asset_Installation_Name=isnull(dbo.T0030_Asset_Installation.Installation_Name,''),  
            @Alpha_Emp_Code=e.Alpha_Emp_Code,@Emp_Full_Name=e.Emp_Full_Name,@Dept_Name=T0040_DEPARTMENT_MASTER.Dept_Name,  
            @Installation_Type=isnull(T0030_Asset_Installation.Installation_Type,0),  
         @Asset_Title=isnull(T0110_Asset_Title_Details.Asset_Title,''),@asset_Installation_Name=isnull(asd.Installation_Name,''),  
            @Desig_Name=T0040_DESIGNATION_MASTER.Desig_Name,@Branch_Name=T0030_BRANCH_MASTER.Branch_Name,  
            @asset_approval_id=ap.asset_approval_id,@asset_approval_date=ap.asset_approval_date,@Cat_name=c.Cat_name,  
            @Vendor=v.Vendor_Name,@Vendor_Address =v.[Address],@City=v.City,@Contact_Person=v.Contact_Person,@contact_no=V.contact_number,@Asset_Code=ad.Asset_Code  
            ,@Transfer_Emp_Id=ap.Transfer_Emp_Id,@Invoice_Amount=Invoice_Amount,@Allocation_date=apd.Allocation_Date,@Brand_ID=ad.BRAND_ID  
         FROM  dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN  
            dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN  
            dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join   
            Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join  
            T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID inner join  
            T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Emp_ID <> 0 left outer join  
            T0080_Emp_Master e WITH (NOLOCK) on e.Cmp_ID=ap.Cmp_ID and e.Emp_ID=ap.Emp_ID and ap.Application_Type=0 left join  
            dbo.T0110_Asset_Installation_Details WITH (NOLOCK) ON dbo.T0110_Asset_Installation_Details.AssetM_Id = ad.AssetM_ID and dbo.T0110_Asset_Installation_Details.Emp_Id=e.emp_id and dbo.T0110_Asset_Installation_Details.Emp_Id in (select Emp_ID From
 @Emp_Cons) and T0110_Asset_Installation_Details.Installation_Details <> '' left JOIN  
            dbo.T0030_Asset_Installation WITH (NOLOCK) ON dbo.T0030_Asset_Installation.Asset_Installation_Id = T0110_Asset_Installation_Details.Asset_Installation_Id  left join  
            dbo.T0110_Asset_Title_Details WITH (NOLOCK) ON dbo.T0110_Asset_Title_Details.AssetM_Id = ad.AssetM_ID  and T0110_Asset_Title_Details.Asset_Title <> '' left JOIN  
            dbo.T0030_Asset_Installation asd WITH (NOLOCK) ON asd.Asset_Installation_Id = T0110_Asset_Title_Details.Asset_Installation_Id  left join            
          --  V0080_EMP_MASTER_INCREMENT_GET EI on e.Emp_ID=EI.Emp_ID left join  
          (  
           Select I.Emp_ID, I.Branch_ID, I.Cmp_ID, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID, I.Type_ID, I.Grd_ID, I.Cat_ID, I.Desig_Id, I.Segment_ID, I.subBranch_ID  
           FROM T0095_INCREMENT I WITH (NOLOCK) WHERE I.Increment_Effective_date =   
           (Select MAX(Increment_Effective_date) FROM T0095_INCREMENT I1 WITH (NOLOCK)  
              WHERE I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID   
              AND Increment_Effective_date <= @To_Date)  
               AND Cmp_ID=@Cmp_ID  
           ) AS mm ON E.Emp_ID = mm.Emp_ID AND E.Cmp_ID = mm.Cmp_ID left join  
            dbo.t0030_category_master c WITH (NOLOCK) on c.Cat_ID = mm.Cat_ID left join  
            dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on mm.Dept_ID= T0040_DEPARTMENT_MASTER.Dept_Id  left join  
            dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) on mm.Desig_Id = T0040_DESIGNATION_MASTER.Desig_ID left join  
                           dbo.T0030_BRANCH_MASTER WITH (NOLOCK) on mm.Branch_ID = T0030_BRANCH_MASTER.Branch_ID left join                                           
                           dbo.t0040_Vendor_master v WITH (NOLOCK) on v.Vendor_ID = ad.Vendor_ID   
         where ap.Cmp_ID=@cmp_id and apd.Application_Type=0 and ap.Emp_ID <> 0 and isnull(ap.Transfer_Emp_ID,0)=0 and  E.Emp_ID in (select Emp_ID From @Emp_Cons) and apd.AssetM_ID=@AssetM_ID and ap.application_type=0  
         order by Asset_Name asc  
         --select * from #ASSET_EMP   
         insert into #ASSET_EMP(AssetCat_Id,AssetM_Id,[Description],Type_of_Asset,SerialNo,Model,Vendor,Warranty_Starts,Warranty_Ends,Purchase_Date,Asset_Code,Allocation,Invoice_No,Invoice_Amount,Vendor_Address,Invoice_Date,PONO,pono_Date,City,Contact_Person,contact_no,Dispose_Date,Vendor_Id, Asset_Name,BRAND_Name,Emp_Id,Alpha_Emp_Code,Emp_Full_Name,Dept_Name,Branch_Name,Desig_Name,Cat_Name,Asset_Approval_ID,Asset_Approval_date,cmp_id,Transfer_Emp_Id,Installation_Details,Installation_Name,Asset_Title,Installation_Type,Application_Type,Allocation_date,Brand_ID)  
         values(@AssetCat_Id,@AssetM_Id,@Description,@Type_of_Asset,@SerialNo,@Model,@Vendor,@Warranty_Starts,@Warranty_Ends,@Purchase_Date,@Asset_Code,@Allocation,@Invoice_No,@Invoice_Amount,@Vendor_Address,@Invoice_Date,@PONO,@pono_Date,@City,@Contact_Person,@contact_no,@Dispose_Date,@Vendor_Id,@Asset_Name,@BRAND_Name,@Emp_Id,@Alpha_Emp_Code,@Emp_Full_Name,@Dept_Name,@Branch_Name,@Desig_Name,@Cat_Name,@Asset_Approval_ID,@Asset_Approval_date,@cmp_id,@Transfer_Emp_Id,@Installation_Details,@asset_Installation_Name,@Asset_Title,@Installation_Type,@application_type,@Allocation_date,@Brand_Id)  
           
         --SELECT   @Installation_Details1=isnull(dbo.T0110_Asset_Installation_Details.Installation_Details,''),  
         --  @Installation_Name1=isnull(dbo.T0030_Asset_Installation.Installation_Name,''),  
         --  @Installation_Type1=isnull(T0030_Asset_Installation.Installation_Type,0)              
         --FROM  dbo.T0040_Asset_Details ad  INNER JOIN  
         --    T0120_Asset_Approval ap on ap.Cmp_ID=ad.Cmp_ID  inner  join  
         --    T0130_Asset_Approval_Det apd on apd.Cmp_ID=ap.Cmp_ID and ap.Asset_Approval_Id=apd.Asset_Approval_Id inner join  
         --    T0080_Emp_Master e on e.Cmp_ID=ad.Cmp_ID and  e.Emp_ID=ap.Emp_ID inner join  
         --    dbo.T0110_Asset_Installation_Details ON dbo.T0110_Asset_Installation_Details.AssetM_Id = apd.AssetM_ID and ap.Asset_Approval_Id=dbo.T0110_Asset_Installation_Details.Asset_Approval_Id and dbo.T0110_Asset_Installation_Details.Emp_Id=e.emp_id and  
         --    T0110_Asset_Installation_Details.Installation_Details <> '' inner JOIN  
         --    dbo.T0030_Asset_Installation ON dbo.T0030_Asset_Installation.Asset_Installation_Id = T0110_Asset_Installation_Details.Asset_Installation_Id    
         --where ad.Cmp_ID=@cmp_id and ap.Emp_ID <> 0 and isnull(ap.Transfer_Emp_ID,0) =0 and T0030_Asset_Installation.Installation_Name<>'' and ap.application_type=0 and    
         --E.Emp_ID=@emp_id and ap.Asset_Approval_ID=@Asset_Approval_ID and T0030_Asset_Installation.Installation_Type=0 and ap.Asset_Approval_date between @From_Date and @to_date  
         --order by Installation_Name  
           
         --if @Installation_Name1 <> ''  
          --BEGIN  
           insert into #ASSET_INSTALLATION(Emp_ID,Installation_Details,Installation_Name,Installation_Type,assetm_id,asset_approval_id)  
           --values(@emp_id,@Installation_Details1,@Installation_Name1,@Installation_Type1,@AssetM_Id,@Asset_Approval_ID)  
           SELECT   @emp_id,isnull(dbo.T0110_Asset_Installation_Details.Installation_Details,''),  
           isnull(dbo.T0030_Asset_Installation.Installation_Name,''),  
           isnull(T0030_Asset_Installation.Installation_Type,0),ad.AssetM_Id,@Asset_Approval_ID              
           FROM  dbo.T0040_Asset_Details ad WITH (NOLOCK)  INNER JOIN  
               T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=ad.Cmp_ID  inner  join  
               T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ap.Cmp_ID and ap.Asset_Approval_Id=apd.Asset_Approval_Id inner join  
               T0080_Emp_Master e WITH (NOLOCK) on e.Cmp_ID=ad.Cmp_ID and  e.Emp_ID=ap.Emp_ID inner join  
               dbo.T0110_Asset_Installation_Details WITH (NOLOCK) ON dbo.T0110_Asset_Installation_Details.AssetM_Id = apd.AssetM_ID and ap.Asset_Approval_Id=dbo.T0110_Asset_Installation_Details.Asset_Approval_Id and dbo.T0110_Asset_Installation_Details.Emp_Id=e.emp_id and  
               T0110_Asset_Installation_Details.Installation_Details <> '' and dbo.T0110_Asset_Installation_Details.AssetM_ID =@assetm_id inner JOIN  
               dbo.T0030_Asset_Installation WITH (NOLOCK) ON dbo.T0030_Asset_Installation.Asset_Installation_Id = T0110_Asset_Installation_Details.Asset_Installation_Id    
           where ad.Cmp_ID=@cmp_id and ad.AssetM_ID =@assetm_id and ap.Emp_ID <> 0 and isnull(ap.Transfer_Emp_ID,0) =0 and T0030_Asset_Installation.Installation_Name<>'' and ap.application_type=0 and    
           E.Emp_ID=@emp_id and ap.Asset_Approval_ID=@Asset_Approval_ID and T0030_Asset_Installation.Installation_Type=0 and ap.Asset_Approval_date between @From_Date and @to_date  
          --END  
       end   
     ELSE if  @application_type=3 --for Transfer   
      begin        
       SELECT distinct @AssetCat_Id=ad.Asset_Id,@AssetM_Id=ad.AssetM_Id,@Description=ad.[Description],@Type_of_asset=ad.Type_of_asset,@SerialNO=ad.SerialNO,@Model=ad.Model,@Warranty_Starts=ad.Warranty_Starts ,  
         @Warranty_Ends=ad.Warranty_Ends,@Purchase_Date=ad.Purchase_Date ,  
         @pono=ad.pono,@pono_Date=ad.pono_Date,@Invoice_no=ad.Invoice_no,@Invoice_Date=ad.Invoice_Date,@BRAND_Name=br.BRAND_Name,@Asset_Name=am.Asset_Name,@Emp_ID=ap.Transfer_Emp_ID,  
            @Installation_Details=isnull(dbo.T0110_Asset_Installation_Details.Installation_Details,''),@asset_Installation_Name=isnull(dbo.T0030_Asset_Installation.Installation_Name,''),  
            @Alpha_Emp_Code=e.Alpha_Emp_Code,@Emp_Full_Name=e.Emp_Full_Name,@Dept_Name=T0040_DEPARTMENT_MASTER.Dept_Name,  
            @Installation_Type=isnull(T0030_Asset_Installation.Installation_Type,0),  
         @Asset_Title=isnull(T0110_Asset_Title_Details.Asset_Title,''),@asset_Installation_Name=isnull(asd.Installation_Name,''),  
            @Desig_Name=T0040_DESIGNATION_MASTER.Desig_Name,@Branch_Name=T0030_BRANCH_MASTER.Branch_Name,  
            @asset_approval_id=ap.asset_approval_id,@asset_approval_date=ap.asset_approval_date,@Cat_name=c.Cat_Name,  
            @Vendor =v.Vendor_Name,@Vendor_Address =v.[Address],@City=v.City,@Contact_Person=v.Contact_Person,@contact_no=V.contact_number,@Asset_Code=ad.Asset_Code,  
            @Transfer_Emp_Id=ap.Transfer_Emp_Id,@Invoice_Amount=Invoice_Amount,@Allocation_date=apd.Allocation_Date,@Brand_Id=ad.BRAND_ID  
            FROM  dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN  
            dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN  
            dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join   
            Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join  
            T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID inner join  
            T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID  and ap.Transfer_Emp_ID in (select Emp_ID From @Emp_Cons) and ap.Application_Type=3 inner join   
            T0080_Emp_Master e WITH (NOLOCK) on e.Cmp_ID=ap.Cmp_ID and e.Emp_ID=ap.Transfer_Emp_ID  left join  
            dbo.T0110_Asset_Installation_Details WITH (NOLOCK) ON dbo.T0110_Asset_Installation_Details.AssetM_Id = ad.AssetM_ID and dbo.T0110_Asset_Installation_Details.Emp_Id=e.emp_id and dbo.T0110_Asset_Installation_Details.Emp_Id in (select Emp_ID From
 @Emp_Cons) and T0110_Asset_Installation_Details.Installation_Details <> '' left JOIN  
            dbo.T0030_Asset_Installation WITH (NOLOCK) ON dbo.T0030_Asset_Installation.Asset_Installation_Id = T0110_Asset_Installation_Details.Asset_Installation_Id  left join  
            dbo.T0110_Asset_Title_Details WITH (NOLOCK) ON dbo.T0110_Asset_Title_Details.AssetM_Id = ad.AssetM_ID  and T0110_Asset_Title_Details.Asset_Title <> '' left JOIN  
            dbo.T0030_Asset_Installation asd WITH (NOLOCK) ON asd.Asset_Installation_Id = T0110_Asset_Title_Details.Asset_Installation_Id  left join                     --                 
           -- V0080_EMP_MASTER_INCREMENT_GET EI on e.Emp_ID=EI.Emp_ID left join  
           (  
           Select I.Emp_ID, I.Branch_ID, I.Cmp_ID, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID, I.Type_ID, I.Grd_ID, I.Cat_ID, I.Desig_Id, I.Segment_ID, I.subBranch_ID  
           FROM T0095_INCREMENT I WITH (NOLOCK) WHERE I.Increment_Effective_date =   
           (Select MAX(Increment_Effective_date) FROM T0095_INCREMENT I1 WITH (NOLOCK)  
              WHERE I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID   
              AND Increment_Effective_date <= @To_Date)  
               AND Cmp_ID=@Cmp_ID  
           ) AS mm ON E.Emp_ID = mm.Emp_ID AND E.Cmp_ID = mm.Cmp_ID left join  
            dbo.t0030_category_master c WITH (NOLOCK) on c.Cat_ID = mm.Cat_ID left join  
            dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on mm.Dept_ID= T0040_DEPARTMENT_MASTER.Dept_Id  left join  
            dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) on mm.Desig_Id = T0040_DESIGNATION_MASTER.Desig_ID left join  
                           dbo.T0030_BRANCH_MASTER WITH (NOLOCK) on mm.Branch_ID = T0030_BRANCH_MASTER.Branch_ID left join    
                           dbo.t0040_Vendor_master v WITH (NOLOCK) on v.Vendor_ID = ad.Vendor_ID   
         where ap.Cmp_ID=@cmp_id and apd.Application_Type=3 and ap.Transfer_Emp_ID <> 0 and ap.application_type=3 and ap.Asset_Approval_Id=@Asset_Approval_Id and  
         ap.Transfer_Emp_ID in (select Emp_ID From @Emp_Cons) and apd.AssetM_ID=@AssetM_ID and isnull(ad.Asset_Code,'') <> ''  
         order by Asset_Name asc   
            
         insert into #ASSET_EMP(AssetCat_Id,AssetM_Id,[Description],Type_of_Asset,SerialNo,Model,Vendor,Warranty_Starts,Warranty_Ends,Purchase_Date,Asset_Code,Allocation,Invoice_No,Invoice_Amount,Vendor_Address,Invoice_Date,PONO,pono_Date,City,Contact_Person,contact_no,Dispose_Date,Vendor_Id, Asset_Name,BRAND_Name,Emp_Id,Alpha_Emp_Code,Emp_Full_Name,Dept_Name,Branch_Name,Desig_Name,Cat_Name,Asset_Approval_ID,Asset_Approval_date,cmp_id,Transfer_Emp_Id,Installation_Details,Installation_Name,Asset_Title,Installation_Type,Application_Type,Allocation_date,Brand_ID)  
         values(@AssetCat_Id,@AssetM_Id,@Description,@Type_of_Asset,@SerialNo,@Model,@Vendor,@Warranty_Starts,@Warranty_Ends,@Purchase_Date,@Asset_Code,@Allocation,@Invoice_No,@Invoice_Amount,@Vendor_Address,@Invoice_Date,@PONO,@pono_Date,@City,@Contact_Person,@contact_no,@Dispose_Date,@Vendor_Id,@Asset_Name,@BRAND_Name,@Transfer_Emp_ID,@Alpha_Emp_Code,@Emp_Full_Name,@Dept_Name,@Branch_Name,@Desig_Name,@Cat_Name,@Asset_Approval_ID,@Asset_Approval_date,@cmp_id,@Transfer_Emp_Id,@Installation_Details,@asset_Installation_Name,@Asset_Title,@Installation_Type,@application_type,@Allocation_date,@Brand_Id)  
         -- select * from #ASSET_EMP   
           
         --SELECT   @Installation_Details1=isnull(dbo.T0110_Asset_Installation_Details.Installation_Details,''),  
         --  @Installation_Name1=isnull(dbo.T0030_Asset_Installation.Installation_Name,''),  
         --  @Installation_Type1=isnull(T0030_Asset_Installation.Installation_Type,0)              
         --FROM  dbo.T0040_Asset_Details ad  INNER JOIN  
         --    T0120_Asset_Approval ap on ap.Cmp_ID=ad.Cmp_ID  inner  join  
         --    T0130_Asset_Approval_Det apd on apd.Cmp_ID=ap.Cmp_ID and ap.Asset_Approval_Id=apd.Asset_Approval_Id inner join  
         --    T0080_Emp_Master e on e.Cmp_ID=ad.Cmp_ID and  e.Emp_ID=ap.Transfer_Emp_Id inner join  
         --    dbo.T0110_Asset_Installation_Details ON dbo.T0110_Asset_Installation_Details.AssetM_Id = apd.AssetM_ID and ap.Asset_Approval_Id=dbo.T0110_Asset_Installation_Details.Asset_Approval_Id and dbo.T0110_Asset_Installation_Details.Emp_Id=e.emp_id and  
         --    T0110_Asset_Installation_Details.Installation_Details <> '' inner JOIN  
         --    dbo.T0030_Asset_Installation ON dbo.T0030_Asset_Installation.Asset_Installation_Id = T0110_Asset_Installation_Details.Asset_Installation_Id    
         --where ad.Cmp_ID=@cmp_id and isnull(ap.Transfer_Emp_ID,0) >0 and T0030_Asset_Installation.Installation_Name<>'' and ap.application_type=3   
         --and  E.Emp_ID=@emp_id and ap.Asset_Approval_ID=@Asset_Approval_ID and T0030_Asset_Installation.Installation_Type=0 and ap.Asset_Approval_date between @From_Date and @to_date  
         --order by Installation_Name  
         --if @Installation_Name1 <> ''  
          --BEGIN  
           insert into #ASSET_INSTALLATION(Emp_ID,Installation_Details,Installation_Name,Installation_Type,assetm_id,asset_approval_id)  
           --values(@emp_id,@Installation_Details1,@Installation_Name1,@Installation_Type1,@AssetM_Id,@Asset_Approval_ID)          
           SELECT  @emp_id,isnull(dbo.T0110_Asset_Installation_Details.Installation_Details,''),  
           isnull(dbo.T0030_Asset_Installation.Installation_Name,''),isnull(T0030_Asset_Installation.Installation_Type,0),ad.AssetM_Id,@Asset_Approval_ID              
           FROM  dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN  
               T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=ad.Cmp_ID  inner  join  
               T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ap.Cmp_ID and ap.Asset_Approval_Id=apd.Asset_Approval_Id inner join  
               T0080_Emp_Master e WITH (NOLOCK) on e.Cmp_ID=ad.Cmp_ID and  e.Emp_ID=ap.Transfer_Emp_Id inner join  
               dbo.T0110_Asset_Installation_Details WITH (NOLOCK) ON dbo.T0110_Asset_Installation_Details.AssetM_Id = apd.AssetM_ID and ap.Asset_Approval_Id=dbo.T0110_Asset_Installation_Details.Asset_Approval_Id and dbo.T0110_Asset_Installation_Details.Emp_Id=e.emp_id and  
               T0110_Asset_Installation_Details.Installation_Details <> '' and dbo.T0110_Asset_Installation_Details.AssetM_ID =@assetm_id inner JOIN  
               dbo.T0030_Asset_Installation WITH (NOLOCK) ON dbo.T0030_Asset_Installation.Asset_Installation_Id = T0110_Asset_Installation_Details.Asset_Installation_Id    
           where ad.Cmp_ID=@cmp_id and ad.AssetM_ID =@assetm_id and isnull(ap.Transfer_Emp_ID,0) >0 and T0030_Asset_Installation.Installation_Name<>'' and ap.application_type=3   
           and  E.Emp_ID=@emp_id and ap.Asset_Approval_ID=@Asset_Approval_ID and T0030_Asset_Installation.Installation_Type=0 and ap.Asset_Approval_date between @From_Date and @to_date  
          --END  
      end  
    fetch next from ASSET_DETAILS into @Asset_Approval_ID,@application_type,@AssetM_ID,@emp_id  
    End  
   close ASSET_DETAILS   
   deallocate ASSET_DETAILS  
    
     
  if (@Asset_ID > 0)  
   BEGIN  
    select ae.*,co.Cmp_Name,co.Cmp_Address,co.cmp_logo from #ASSET_EMP ae   
    inner join T0010_COMPANY_MASTER co WITH (NOLOCK) on ae.cmp_id=co.cmp_id  
    where ae.Cmp_ID=@cmp_id and isnull(ae.Asset_Code,'') <> '' and isnull(ae.emp_id,0) >0  
    and ae.AssetCat_Id=@Asset_ID and Asset_Approval_date between @From_Date and @to_date and Brand_Id=ISNULL(@Brand,Brand_Id)  
   END  
  ELSE  
   BEGIN  
    select ae.*,co.Cmp_Name,co.Cmp_Address,co.cmp_logo from #ASSET_EMP ae   
    inner join T0010_COMPANY_MASTER co WITH (NOLOCK) on ae.cmp_id=co.cmp_id  
    where ae.Cmp_ID=@cmp_id and isnull(ae.Asset_Code,'') <> '' and isnull(ae.emp_id,0) >0 and Asset_Approval_date between @From_Date and @to_date and Brand_Id=ISNULL(@Brand,Brand_Id)  
   END  
     
  ---------To fill Asset Installation Details(start) ----------------------------------------  
  -- DECLARE ASSET_INSTALLATION CURSOR FOR  
  --  select Emp_Id,Transfer_Emp_Id,Application_Type from #ASSET_EMP where Cmp_ID=@cmp_id  
  --OPEN ASSET_INSTALLATION  
  --  fetch next from ASSET_INSTALLATION into @emp_id,@Transfer_Emp_Id,@application_type  
  --   while @@fetch_status = 0  
  --   Begin    
  --    if @application_type=0  
  --     BEGIN            
  --      SELECT  distinct  ap.Emp_ID,isnull(dbo.T0110_Asset_Installation_Details.Installation_Details,'')as Installation_Details,isnull(dbo.T0030_Asset_Installation.Installation_Name,'')Installation_Name,  
  --          isnull(T0030_Asset_Installation.Installation_Type,0)Installation_Type,T0110_Asset_Installation_Details.assetm_id,ap.asset_approval_id  
  --      FROM  dbo.T0040_Asset_Details ad  INNER JOIN  
  --          T0120_Asset_Approval ap on ap.Cmp_ID=ad.Cmp_ID  inner  join  
  --          T0130_Asset_Approval_Det apd on apd.Cmp_ID=ap.Cmp_ID and ap.Asset_Approval_Id=apd.Asset_Approval_Id inner join  
  --          T0080_Emp_Master e on e.Cmp_ID=ad.Cmp_ID and  e.Emp_ID=ap.Emp_ID inner join  
  --          dbo.T0110_Asset_Installation_Details ON dbo.T0110_Asset_Installation_Details.AssetM_Id = apd.AssetM_ID and ap.Asset_Approval_Id=dbo.T0110_Asset_Installation_Details.Asset_Approval_Id and dbo.T0110_Asset_Installation_Details.Emp_Id=e.emp_id and  
  --          T0110_Asset_Installation_Details.Installation_Details <> '' inner JOIN  
  --          dbo.T0030_Asset_Installation ON dbo.T0030_Asset_Installation.Asset_Installation_Id = T0110_Asset_Installation_Details.Asset_Installation_Id    
  --      where ad.Cmp_ID=@cmp_id and ap.Emp_ID <> 0 and isnull(ap.Transfer_Emp_ID,0) =0 and T0030_Asset_Installation.Installation_Name<>'' and ap.application_type=0 and  E.Emp_ID in (select Emp_ID From @Emp_Cons) and T0030_Asset_Installation.Installation_Type=0  
  --      and ap.Asset_Approval_date between @From_Date and @to_date  
  --      order by Installation_Name  
  --     END  
  --    ELSE if  @application_type=3 --for Transfer   
  --     BEGIN            
  --      SELECT  distinct  ap.Emp_ID,isnull(dbo.T0110_Asset_Installation_Details.Installation_Details,'')as Installation_Details,isnull(dbo.T0030_Asset_Installation.Installation_Name,'')Installation_Name,  
  --          isnull(T0030_Asset_Installation.Installation_Type,0)Installation_Type,T0110_Asset_Installation_Details.assetm_id,ap.asset_approval_id  
  --      FROM  dbo.T0040_Asset_Details ad  INNER JOIN  
  --          T0120_Asset_Approval ap on ap.Cmp_ID=ad.Cmp_ID  inner  join  
  --          T0130_Asset_Approval_Det apd on apd.Cmp_ID=ap.Cmp_ID and ap.Asset_Approval_Id=apd.Asset_Approval_Id inner join  
  --          T0080_Emp_Master e on e.Cmp_ID=ad.Cmp_ID and  e.Emp_ID=ap.Transfer_Emp_Id inner join  
  --          dbo.T0110_Asset_Installation_Details ON dbo.T0110_Asset_Installation_Details.AssetM_Id = apd.AssetM_ID and ap.Asset_Approval_Id=dbo.T0110_Asset_Installation_Details.Asset_Approval_Id and dbo.T0110_Asset_Installation_Details.Emp_Id=e.emp_id and  
  --          T0110_Asset_Installation_Details.Installation_Details <> '' inner JOIN  
  --          dbo.T0030_Asset_Installation ON dbo.T0030_Asset_Installation.Asset_Installation_Id = T0110_Asset_Installation_Details.Asset_Installation_Id    
  --      where ad.Cmp_ID=@cmp_id and isnull(ap.Transfer_Emp_ID,0) >0 and T0030_Asset_Installation.Installation_Name<>'' and ap.application_type=3 and  E.Emp_ID in (select Emp_ID From @Emp_Cons) and T0030_Asset_Installation.Installation_Type=0  
  --      and ap.Asset_Approval_date between @From_Date and @to_date  
  --      order by Installation_Name  
  --     END  
  --   end  
  --  fetch next from ASSET_INSTALLATION into @emp_id,@Transfer_Emp_Id,@application_type  
  --  End  
  -- close ASSET_INSTALLATION   
  -- deallocate ASSET_INSTALLATION   
   select DISTINCT * from #ASSET_INSTALLATION order by Installation_Name  
  ---------To fill ASSET_INSTALLATION Installation Details(end) ----------------------------------------   
    
  ---------To fill Asset Title Details(start) ----------------------------------------   
    SELECT  distinct ad.assetM_Id ,ap.emp_id,  
       isnull(asd.Installation_Type,0)Installation_Type,  
       isnull(T0110_Asset_Title_Details.Asset_Title,'')as Asset_Title,isnull(asd.Installation_Name,'')   
       as asset_Installation_Name--,ap.asset_approval_id  
    FROM  dbo.T0040_Asset_Details ad WITH (NOLOCK) INNER JOIN  
       dbo.T0110_Asset_Title_Details WITH (NOLOCK) ON dbo.T0110_Asset_Title_Details.AssetM_Id = ad.AssetM_ID and T0110_Asset_Title_Details.Asset_Title <> '' inner JOIN  
       T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID inner join  
       T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Emp_ID <> 0 inner join  
       dbo.T0030_Asset_Installation asd WITH (NOLOCK) ON asd.Asset_Installation_Id = T0110_Asset_Title_Details.Asset_Installation_Id  inner join   
       @Emp_Cons EC on EC.Emp_ID=ap.Emp_ID   
    where ad.Cmp_ID=@cmp_id  and asd.Installation_Name<>'' and  asd.Installation_Type=1 and ap.application_type=0  
    and ap.Asset_Approval_date between @From_Date and @to_date and ad.Brand_Id=ISNULL(@Brand,ad.Brand_Id)  
    order by asset_Installation_Name  
    --Union  
    --SELECT  distinct ad.assetM_Id ,ap.emp_id,  
    --   isnull(asd.Installation_Type,0)Installation_Type,  
    --   isnull(T0110_Asset_Title_Details.Asset_Title,'')as Asset_Title,isnull(asd.Installation_Name,'')   
    --   as asset_Installation_Name,ap.asset_approval_id  
    --FROM  dbo.T0040_Asset_Details ad  INNER JOIN  
    --   T0130_Asset_Approval_Det apd on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID inner join  
    --   dbo.T0110_Asset_Title_Details ON dbo.T0110_Asset_Title_Details.AssetM_Id = apd.AssetM_ID and T0110_Asset_Title_Details.Asset_Title <> '' inner JOIN  
    --   T0120_Asset_Approval ap on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Transfer_Emp_ID <> 0 inner join  
    --   dbo.T0030_Asset_Installation asd ON asd.Asset_Installation_Id = T0110_Asset_Title_Details.Asset_Installation_Id    
    --where ad.Cmp_ID=@cmp_id  and asd.Installation_Name<>'' and  asd.Installation_Type=1 and ap.application_type=3  
  ---------To fill Asset Title Details(end) ----------------------------------------    
END  
  
  
  