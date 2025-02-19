CREATE PROCEDURE [dbo].[SP_GET_ASSET_APPROVAL_FORMAT1]  
  @Cmp_ID   numeric,  
  @allocation1 varchar(20),  
 -- @format varchar(20),  
  @From_Date  DATETIME,  
  @To_date DATETIME,  
  @constraint  varchar(MAX),  
  @branch1   numeric  
 ,@Branch_ID  numeric   = 0  
 ,@Cat_ID  numeric  = 0  
 ,@Grd_ID  numeric = 0  
 ,@Type_ID  numeric  = 0  
 ,@Dept_ID  numeric  = 0  
 ,@Desig_ID  numeric = 0  
 ,@Emp_ID  numeric  = 0  
 ,@RC_ID   numeric(18,0) = 0  
 ,@Asset_ID     numeric    
 ,@Dept_Id1  numeric  
 ,@Type   Varchar(15)  
 ,@Brand   numeric  
AS  
SET NOCOUNT ON;   
 if @Branch_ID = 0  
  set @Branch_ID = null  
 if @Cat_ID = 0  
  set @Cat_ID = null  
 if @Type_ID = 0  
  set @Type_ID = null  
 if @Dept_ID = 0  
  set @Dept_ID = null  
 if @Grd_ID = 0  
  set @Grd_ID = null  
 if @Emp_ID = 0  
  set @Emp_ID = null  
 If @Desig_ID = 0  
  set @Desig_ID = null  
 if @Branch1 = 0  
  set @Branch1 = null  
 if @Type =0 --<> 2  
  set @Type = NULL   
 if @Brand = 0  
  set @Brand = NULL  
  --Application Type   
   --0-allocation  
   --1-return  
   --2-sell  
   --3-transfer  
 Declare @Emp_Cons Table  
 (  
  Emp_ID numeric  
 )  
   
 if @Constraint <> ''  
  begin  
    Insert Into @Emp_Cons  
   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')   
  end  
 else   
  begin  
   Insert Into @Emp_Cons  
  
   select I.Emp_Id from T0095_Increment I inner join   
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment  
     where Increment_Effective_date <= @To_Date  
     and Cmp_ID = @Cmp_ID  
     group by emp_ID  ) Qry on  
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  
   Where Cmp_ID = @Cmp_ID   
   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))  
   and Branch_ID = isnull(@Branch1 ,Branch_ID)  
   and Grd_ID = isnull(@Grd_ID ,Grd_ID)  
   and isnull(Dept_ID,0) = isnull(@Dept_Id1 ,isnull(Dept_ID,0))  
   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))  
   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)   
   and I.Emp_ID in   
    ( select Emp_Id from  
    (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry  
    where cmp_ID = @Cmp_ID   and    
    (( @From_Date  >= join_Date  and  @From_Date <= left_date )   
    or ( @To_Date  >= join_Date  and @To_Date <= left_date )  
    or Left_date is null and @To_Date >= Join_Date)  
    or @To_Date >= left_date and  @From_Date <= left_date )   
     
  end  
    
 declare @Asset_Approval_ID as numeric(18,0)  
 declare @application_type as numeric(18,0)  
 declare @AssetM_ID as numeric(18,0)  
 declare @Asset_Name as varchar(250)  
 declare @BRAND_Name as varchar(250)  
 declare @Asset_Code as varchar(250)  
 declare @SerialNo as varchar(250)  
 declare @Allocation_Date as  varchar(50)  
 declare @Vendor as varchar(250)  
 declare @Type_of_Asset as varchar(250)  
 declare @Model as varchar(250)  
 declare @Return_Date  as  varchar(50)  
 declare @Alpha_Emp_Code as varchar(250)  
 declare @Brand_Id as numeric(18,0)   
 declare @Asset_Status as varchar(250)  
 declare @Asset_ID1 as numeric(18,0)  
 declare @Emp_Full_Name as varchar(250)  
 declare @Pending_amount as numeric(18,2)  
 declare @Branch_Name varchar(250)  
 declare @Dept_Name varchar(250)  
 declare @Cmp_Name varchar(250)  
 declare @Cmp_Address varchar(max)  
 declare @Transfer_Emp_Id numeric(18,0)  
 declare @Transfer_Branch_Id numeric(18,0)   
 declare @Transfer_Dept_Id numeric(18,0)  
 declare @Return_Asset_Approval_Id numeric(18,0)  
 declare @Warranty_Start varchar(50)  
 declare @Warranty_End varchar(50)  
 declare @Purchase_Date varchar(50)  
 declare @Asset_Description VARCHAR(MAX)  
 declare @Emp_Dept varchar(200)  
 declare @Emp_Desig varchar(200)  
 DECLARE @Emp_Branch VARCHAR(200)  
 DECLARE @BRANCH_FOR_DEPT VARCHAR(200)  
 DECLARE @Transfer_Dept_Branch VARCHAR(200)  
 DECLARE @BRANCH_FOR_DEPT_ID INT  
 DECLARE @Transfer_Dept_Branch_ID INT  
 DECLARE @Vendor_Name varchar(500)  
 CREATE table #ASSET_EMP  
 (  
  Asset_Name  varchar(250),  
  BRAND_Name  varchar(250),  
  Asset_Code  varchar(250),  
  Serial_No  varchar(250),  
  Allocation_Date  varchar(50),  
  Return_Date  varchar(50),  
  Type_of_Asset  varchar(250),  
  Model  varchar(250),  
  AssetM_Id numeric(18,0) ,  
  Asset_Id numeric(18,0) ,  
  Brand_Id numeric(18,0) ,  
  Asset_Approval_ID numeric(18,0) ,  
  Emp_Id  numeric(18,0) ,  
  Alpha_Emp_Code varchar(250),  
  Emp_Full_Name varchar(250),  
  Branch_Name  varchar(250),  
  Asset_Status  varchar(25),  
  Dept_Name varchar(250),  
  Cmp_Name varchar(250),  
  Cmp_Address varchar(max),  
  Application_Type numeric(18,0),  
  Transfer_Emp_Id numeric(18,0),  
  Branch_Id numeric(18,0),  
  Transfer_Branch_Id numeric(18,0),  
  Dept_Id numeric(18,0),  
  Transfer_Dept_Id numeric(18,0),  
  Warranty_Start varchar(50),  
  Warranty_End varchar(50),  
  Purchase_Date varchar(50),  
  Asset_Description  VARCHAR(MAX),  
  Emp_Branch varchar(200), --Mukti(08012018)  
  Emp_Dept varchar(200), --Mukti(08012018)  
  Emp_Desig varchar(200),--Mukti(08012018)  
  From_Date DATETIME,  
  To_Date DATETIME,  
  BRANCH_FOR_DEPT_ID int,  
  Transfer_Dept_Branch_ID int,  
  BRANCH_FOR_DEPT varchar(200), --Mukti(19092019)  
  Transfer_Dept_Branch varchar(200), --Mukti(19092019)      
  Vendor_Name varchar(500),  
  Emp_QR_Code VARBINARY(MAX),  
  Asset_Filter int  
 )  
   
 CREATE TABLE #Final_Asset  
 (  
 Asset_Approval_ID numeric(18,0),  
 application_type numeric(18,0),  
 assetm_id numeric(18,0),  
 emp_id numeric(18,0),  
 Transfer_Emp_Id numeric(18,0),  
 Branch_Id numeric(18,0),  
 Transfer_Branch_Id numeric(18,0),  
 Dept_Id numeric(18,0),  
 Transfer_Dept_Id numeric(18,0)  
 )   
  
    --SELECT * FROM #Final_Asset  
 DECLARE ASSET_DETAILS CURSOR FOR   
    select apd.Asset_Approval_ID,apd.application_type,apd.assetm_id,  
    ap.emp_id,ap.Transfer_Emp_Id,ap.Branch_Id,ap.Transfer_Branch_Id,  
    ap.Dept_Id,ap.Transfer_Dept_Id  
    from T0130_Asset_Approval_Det apd WITH (NOLOCK)  
    inner join T0120_Asset_Approval ap WITH (NOLOCK) on apd.Asset_Approval_ID=ap.Asset_Approval_ID and apd.cmp_id=ap.cmp_id  
   where ap.cmp_id=@cmp_id and (apd.Allocation_Date >= @From_Date and apd.Allocation_Date <= @To_date)   
    OPEN ASSET_DETAILS  
       fetch next from ASSET_DETAILS into @Asset_Approval_ID,@application_type,@AssetM_ID,@emp_id,@Transfer_Emp_Id,@Branch_Id,@Transfer_Branch_Id,@Dept_Id,@Transfer_Dept_Id  
        while @@fetch_status = 0  
         Begin  
         --select 333,@application_type  
          if @application_type=1 --fill asset while return  
           begin            
            SELECT DISTINCT   
              @Asset_Name=dbo.T0040_ASSET_MASTER.Asset_Name,@BRAND_Name=dbo.T0040_BRAND_MASTER.BRAND_Name,@Asset_Code= dbo.T0040_Asset_Details.Asset_Code,@SerialNo=dbo.T0040_Asset_Details.SerialNo,   
                 @Allocation_Date=CONVERT(varchar(11),dbo.T0130_Asset_Approval_Det.Allocation_Date,103),@Type_of_Asset=dbo.T0040_Asset_Details.Type_of_Asset,   
                 @Model= dbo.T0040_Asset_Details.Model,@Return_Date= CONVERT(varchar(11), dbo.T0130_Asset_Approval_Det.Return_Date, 103),@Asset_Id1=T0040_ASSET_MASTER.Asset_Id,  
                 @Brand_Id=T0130_Asset_Approval_Det.Brand_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Emp_Full_Name=E.Emp_Full_Name+'-'+E.Alpha_Emp_Code,  
                 @AssetM_Id=T0130_Asset_Approval_Det.AssetM_Id,@Branch_Name=B.Branch_Name,@Dept_Name=D.dept_name,  
                 @Asset_Status=CASE WHEN dbo.T0040_Asset_Details.Asset_Status = 'D' THEN 'Damage' WHEN dbo.T0040_Asset_Details.Asset_Status = 'Dispose' THEN 'Dispose' ELSE 'Working' END,  
                 @Cmp_Name=co.Cmp_Name,@Cmp_Address=co.Cmp_Address,@Return_Asset_Approval_Id=Return_asset_Approval_Id,@Emp_Dept=ISNULL(DE.Dept_Name,''),@Emp_Desig=ISNULL(DS.desig_name,''),  
                 @Emp_Branch=ISNULL(BE.Branch_Name,'')  
                   FROM dbo.T0130_Asset_Approval_Det  INNER JOIN  
                    Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=T0130_Asset_Approval_Det.Cmp_ID inner join  
                    dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID left JOIN  
                    dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID left JOIN  
                    dbo.T0040_Asset_Details WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN  
                    dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID LEFT OUTER JOIN  
                    dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN  
                    (  
                   Select I.Emp_ID, I.Branch_ID, I.Cmp_ID, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID, I.Type_ID, I.Grd_ID, I.Cat_ID, I.Desig_Id, I.Segment_ID, I.subBranch_ID  
                   FROM T0095_INCREMENT I WITH (NOLOCK) WHERE I.Increment_Effective_date =   
                   (Select MAX(Increment_Effective_date) FROM T0095_INCREMENT I1 WITH (NOLOCK)  
                      WHERE I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID   
                      AND Increment_Effective_date <= @To_Date)  
                       AND Cmp_ID=@Cmp_ID  
                   ) AS mm ON E.Emp_ID = mm.Emp_ID AND E.Cmp_ID = mm.Cmp_ID left join  
                    dbo.t0040_department_master DE WITH (NOLOCK) ON mm.Dept_ID = DE.Dept_ID AND DE.Cmp_ID = mm.Cmp_ID left join  
                    dbo.t0040_designation_master DS WITH (NOLOCK) ON mm.Desig_ID = DS.Desig_ID AND DS.Cmp_ID = mm.Cmp_ID left join  
                    dbo.T0030_BRANCH_MASTER BE WITH (NOLOCK) ON mm.Branch_ID = BE.Branch_ID AND BE.Cmp_ID = mm.Cmp_ID left join  
                    dbo.T0030_BRANCH_MASTER B WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Branch_ID = B.Branch_ID AND B.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN  
                    dbo.t0040_department_master D WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Dept_ID = D.Dept_ID AND D.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID left join                    
                    dbo.T0030_BRANCH_MASTER BD WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Branch_For_Dept = BD.Branch_ID AND D.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID left join                     
                    dbo.T0030_BRANCH_MASTER BDT WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Branch_For_Dept = BDT.Branch_ID AND BDT.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID  
            WHERE     isnull(Return_asset_approval_id, 0) > 0 and   isnull(Return_Date, '') <> '1900-01-01 00:00:00.000'   and T0130_Asset_Approval_Det.Asset_Approval_ID=@Asset_Approval_ID   
            and T0130_Asset_Approval_Det.application_type=@application_type   
            and T0130_Asset_Approval_Det.AssetM_ID=@AssetM_ID --and T0130_Asset_Approval_Det.Allocation_Date BETWEEN @From_Date and @To_Date   
              
           if exists(select * from T0120_Asset_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=3)  
            begin  
             select @Transfer_Branch_Id=Transfer_Branch_Id,@Transfer_Emp_Id=Transfer_Emp_Id,@Transfer_Dept_Id=Transfer_Dept_Id   
             from T0120_Asset_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=3  
               
             if isnull(@Transfer_Emp_Id,0)>0   
              begin  
               update #ASSET_EMP   
               set Application_Type=1,Return_Date=@Return_Date  
               where Transfer_Emp_Id=@Transfer_Emp_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id  
              end  
               
              if isnull(@Transfer_Branch_Id,0) >0   
              begin  
               update #ASSET_EMP   
               set Application_Type=1,Return_Date=@Return_Date  
               where Transfer_Branch_Id=@Transfer_Branch_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id  
              end  
              if isnull(@Transfer_Dept_Id,0) >0    
              begin  
               update #ASSET_EMP   
               set Application_Type=1,Return_Date=@Return_Date  
               where Transfer_Dept_Id=@Transfer_Dept_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id  
              end  
            end  
           else  
            begin  
             select @Branch_Id=Branch_Id,@Emp_Id=Emp_Id,@Dept_Id=Dept_Id   
             from T0120_Asset_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=0  
             --select @Branch_Id=Branch_Id,@Dept_Id=Dept_Id from T0120_Asset_Approval where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=0  
               
             if isnull(@Emp_Id,0)>0   
              begin  
               update #ASSET_EMP   
               set Application_Type=1,Return_Date=@Return_Date  
               where Emp_Id=@Emp_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id  
              end  
               
              if isnull(@Branch_Id,0) >0   
              begin  
               update #ASSET_EMP   
               set Application_Type=1,Return_Date=@Return_Date  
               where Branch_Id=@Branch_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id  
              end  
              if isnull(@Dept_Id,0) >0    
              begin  
               update #ASSET_EMP   
               set Application_Type=1,Return_Date=@Return_Date  
               where Dept_Id=@Dept_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id  
              end  
            end  
           end  
          else if @application_type=3 --fill asset while Transfer  
           begin  
             SELECT DISTINCT   
              @Asset_Name=dbo.T0040_ASSET_MASTER.Asset_Name,@BRAND_Name=dbo.T0040_BRAND_MASTER.BRAND_Name,@Asset_Code= dbo.T0040_Asset_Details.Asset_Code,@SerialNo=dbo.T0040_Asset_Details.SerialNo,   
                 @Allocation_Date=CONVERT(varchar(11),dbo.T0130_Asset_Approval_Det.Allocation_Date,103),@Type_of_Asset=dbo.T0040_Asset_Details.Type_of_Asset,   
                 @Model= dbo.T0040_Asset_Details.Model,@Return_Date= CONVERT(varchar(11), dbo.T0130_Asset_Approval_Det.Return_Date, 103),@Asset_Id1=T0040_ASSET_MASTER.Asset_Id,  
                 @Brand_Id=T0130_Asset_Approval_Det.Brand_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Emp_Full_Name=E.Alpha_Emp_Code + '-' + E.Emp_Full_Name,  
                 @AssetM_Id=T0130_Asset_Approval_Det.AssetM_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Branch_Name=B.Branch_Name,  
                 @Dept_Name=D.dept_name,             
                    @Asset_Status=CASE WHEN dbo.T0040_Asset_Details.Asset_Status = 'D' THEN 'Damage' WHEN dbo.T0040_Asset_Details.Asset_Status = 'Dispose' THEN 'Dispose' ELSE 'Working' END,  
                    @Cmp_Name=co.Cmp_Name,@Cmp_Address=co.Cmp_Address,  
                    @Warranty_Start=CONVERT(varchar(11),T0040_Asset_Details.Warranty_Starts,103),@Warranty_End=CONVERT(varchar(11),T0040_Asset_Details.Warranty_Ends,103),@Purchase_Date=CONVERT(varchar(11),T0040_Asset_Details.Purchase_Date,103),  
                    @Asset_Description=dbo.T0040_Asset_Details.Description,@Emp_Dept=ISNULL(DE.Dept_Name,''),@Emp_Desig=ISNULL(DS.desig_name,''),@Emp_Branch=ISNULL(BE.Branch_Name,''),  
                    @BRANCH_FOR_DEPT=BD.Branch_Name ,@Transfer_Dept_Branch=BDT.Branch_Name,@BRANCH_FOR_DEPT_ID=Branch_For_Dept,@Transfer_Dept_Branch_ID=Transfer_Branch_For_Dept,@Vendor_Name=ISNULL(Vendor_Name,'')  
           FROM dbo.T0130_Asset_Approval_Det INNER JOIN  
                    Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=T0130_Asset_Approval_Det.Cmp_ID inner join  
                    dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID INNER JOIN  
                    dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN  
                    dbo.T0040_Asset_Details WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN  
                    dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID LEFT OUTER JOIN  
                    dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN  
                    (  
                   Select I.Emp_ID, I.Branch_ID, I.Cmp_ID, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID, I.Type_ID, I.Grd_ID, I.Cat_ID, I.Desig_Id, I.Segment_ID, I.subBranch_ID  
                   FROM T0095_INCREMENT I WITH (NOLOCK) WHERE I.Increment_Effective_date =   
                   (Select MAX(Increment_Effective_date) FROM T0095_INCREMENT I1 WITH (NOLOCK)  
                      WHERE I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID   
                      AND Increment_Effective_date <= @To_Date)  
                       AND Cmp_ID=@Cmp_ID  
                   ) AS mm ON E.Emp_ID = mm.Emp_ID AND E.Cmp_ID = mm.Cmp_ID left join  
                    dbo.t0040_department_master DE WITH (NOLOCK) ON mm.Dept_ID = DE.Dept_ID AND DE.Cmp_ID = mm.Cmp_ID left join  
                    dbo.t0040_designation_master DS WITH (NOLOCK) ON mm.Desig_ID = DS.Desig_ID AND DS.Cmp_ID = mm.Cmp_ID left join  
                    dbo.T0030_BRANCH_MASTER  BE WITH (NOLOCK) ON mm.Branch_ID = BE.Branch_ID AND BE.Cmp_ID = mm.Cmp_ID left join  
                    dbo.T0030_BRANCH_MASTER B WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Branch_ID = B.Branch_ID AND B.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN  
                    dbo.t0040_department_master D WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Dept_ID = D.Dept_ID AND D.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN                    
                    dbo.T0030_BRANCH_MASTER BD WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Branch_For_Dept = BD.Branch_ID AND D.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID left join                     
                    dbo.T0030_BRANCH_MASTER BDT WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Branch_For_Dept = BDT.Branch_ID AND BDT.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT JOIN  
                    T0040_Vendor_Master VM WITH (NOLOCK) ON VM.Vendor_Id=dbo.T0040_Asset_Details.Vendor_Id  
            WHERE    Return_asset_approval_id is null  and T0130_Asset_Approval_Det.Asset_Approval_ID=@Asset_Approval_ID  
            and T0130_Asset_Approval_Det.application_type=@application_type and T0130_Asset_Approval_Det.AssetM_ID=@AssetM_ID   
            --and T0130_Asset_Approval_Det.Allocation_Date BETWEEN @From_Date and @To_Date  
             
            INSERT INTO #ASSET_EMP
				(Asset_Name,BRAND_Name,Asset_Code,Serial_No,Allocation_Date,Type_of_Asset,Model,Return_Date,Emp_id,AssetM_Id,Asset_Id,Brand_Id,Asset_Approval_ID,Alpha_Emp_Code,Emp_Full_Name,
				Branch_Name,Asset_Status,Dept_Name,Cmp_Name,Cmp_Address,application_type,Transfer_Emp_Id,Branch_Id,Transfer_Branch_Id,Dept_Id,Transfer_Dept_Id,Warranty_Start,Warranty_End,
				Purchase_Date,Asset_Description,Emp_Branch,Emp_Dept,Emp_Desig,FROM_DATE,TO_DATE,BRANCH_FOR_DEPT_ID,Transfer_Dept_Branch_ID,BRANCH_FOR_DEPT,Transfer_Dept_Branch,Vendor_Name,Emp_QR_Code,
				Asset_Filter
				)  
				VALUES
				(@Asset_Name,@BRAND_Name,@Asset_Code,@SerialNo,@Allocation_Date,@Type_of_Asset,@Model,'',@Emp_id,@AssetM_Id,@Asset_Id1,@Brand_Id,@Asset_Approval_ID,@Alpha_Emp_Code,@Emp_Full_Name,
				@Branch_Name,@Asset_Status,@Dept_Name,@Cmp_Name,@Cmp_Address,@application_type,@Transfer_Emp_Id,@Branch_Id,@Transfer_Branch_Id,@Dept_Id,@Transfer_Dept_Id,@Warranty_Start,
				@Warranty_End,@Purchase_Date,@Asset_Description,@Emp_Branch,@Emp_Dept,@Emp_Desig,@FROM_DATE,@TO_DATE,@BRANCH_FOR_DEPT_ID,@Transfer_Dept_Branch_ID,@BRANCH_FOR_DEPT,
				@Transfer_Dept_Branch,@Vendor_Name,CAST(0 AS VARBINARY(MAX)),isnull(@Asset_ID,0)
				)  
             
           end  
          else  
           begin  
            SELECT DISTINCT   
              @Asset_Name=dbo.T0040_ASSET_MASTER.Asset_Name,@BRAND_Name=dbo.T0040_BRAND_MASTER.BRAND_Name,@Asset_Code= dbo.T0040_Asset_Details.Asset_Code,@SerialNo=dbo.T0040_Asset_Details.SerialNo,   
                 @Allocation_Date=CONVERT(varchar(11),dbo.T0130_Asset_Approval_Det.Allocation_Date,103),@Type_of_Asset=dbo.T0040_Asset_Details.Type_of_Asset,   
                 @Model= dbo.T0040_Asset_Details.Model,@Return_Date= CONVERT(varchar(11), dbo.T0130_Asset_Approval_Det.Return_Date, 103),@Asset_Id1=T0040_ASSET_MASTER.Asset_Id,  
                 @Brand_Id=T0130_Asset_Approval_Det.Brand_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Emp_Full_Name=E.Alpha_Emp_Code + '-' + E.Emp_Full_Name,  
                 @AssetM_Id=T0130_Asset_Approval_Det.AssetM_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Branch_Name=B.Branch_Name,  
                 @Dept_Name=D.dept_name,@Asset_Status=CASE WHEN dbo.T0040_Asset_Details.Asset_Status = 'D' THEN 'Damage' WHEN dbo.T0040_Asset_Details.Asset_Status = 'Dispose' THEN 'Dispose' ELSE 'Working' END,  
                    @Cmp_Name=co.Cmp_Name,@Cmp_Address=co.Cmp_Address,  
                    @Warranty_Start=CONVERT(varchar(11),T0040_Asset_Details.Warranty_Starts,103),@Warranty_End=CONVERT(varchar(11),T0040_Asset_Details.Warranty_Ends,103),@Purchase_Date=CONVERT(varchar(11),T0040_Asset_Details.Purchase_Date,103),  
                    @Asset_Description=dbo.T0040_Asset_Details.Description,@Emp_Dept=ISNULL(DE.Dept_Name,''),@Emp_Desig=ISNULL(DS.desig_name,''),@Emp_Branch=ISNULL(BE.Branch_Name,''),  
                    @BRANCH_FOR_DEPT=BD.Branch_Name,@Transfer_Dept_Branch=BDT.Branch_Name,@BRANCH_FOR_DEPT_ID=Branch_For_Dept,@Transfer_Dept_Branch_ID=Transfer_Branch_For_Dept,@Vendor_Name=ISNULL(Vendor_Name,'')  
           FROM dbo.T0130_Asset_Approval_Det INNER JOIN  
                    Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=T0130_Asset_Approval_Det.Cmp_ID inner join  
                    dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID INNER JOIN  
                    dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN  
                    dbo.T0040_Asset_Details WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN  
                    dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID LEFT OUTER JOIN  
                    dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN                     
                    (  
                   Select I.Emp_ID, I.Branch_ID, I.Cmp_ID, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID, I.Type_ID, I.Grd_ID, I.Cat_ID, I.Desig_Id, I.Segment_ID, I.subBranch_ID  
                   FROM T0095_INCREMENT I WITH (NOLOCK) WHERE I.Increment_Effective_date =   
                   (Select MAX(Increment_Effective_date) FROM T0095_INCREMENT I1 WITH (NOLOCK)  
                      WHERE I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID   
                      AND Increment_Effective_date <= @To_Date)  
                       AND Cmp_ID=@Cmp_ID  
                   ) AS mm ON E.Emp_ID = mm.Emp_ID AND E.Cmp_ID = mm.Cmp_ID left join  
                    dbo.t0040_department_master  DE WITH (NOLOCK) ON mm.Dept_ID = DE.Dept_ID AND DE.Cmp_ID = mm.Cmp_ID left join  
                    dbo.t0040_designation_master  DS WITH (NOLOCK) ON mm.Desig_ID = DS.Desig_ID AND DS.Cmp_ID = mm.Cmp_ID left join  
                    dbo.T0030_BRANCH_MASTER  BE WITH (NOLOCK) ON mm.Branch_ID = BE.Branch_ID AND BE.Cmp_ID = mm.Cmp_ID left join  
                    dbo.T0030_BRANCH_MASTER  B WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Branch_ID = B.Branch_ID AND B.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN  
                    dbo.t0040_department_master  D WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Dept_ID = D.Dept_ID AND D.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT JOIN                     
                    dbo.T0030_BRANCH_MASTER  BD WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Branch_For_Dept = BD.Branch_ID AND D.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID left join                     
                    dbo.T0030_BRANCH_MASTER  BDT WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Branch_For_Dept = BDT.Branch_ID AND BDT.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT JOIN  
                    T0040_Vendor_Master VM WITH (NOLOCK) ON VM.Vendor_Id=dbo.T0040_Asset_Details.Vendor_Id  
            WHERE    Return_asset_approval_id is null  and T0130_Asset_Approval_Det.Asset_Approval_ID=@Asset_Approval_ID  
            and T0130_Asset_Approval_Det.application_type=@application_type and T0130_Asset_Approval_Det.AssetM_ID=@AssetM_ID   
            --and T0130_Asset_Approval_Det.Allocation_Date BETWEEN @From_Date and @To_Date  
              
            INSERT INTO #ASSET_EMP
				(Asset_Name,BRAND_Name,Asset_Code,Serial_No,Allocation_Date,Type_of_Asset,Model,Return_Date,Emp_id,AssetM_Id,Asset_Id,Brand_Id,Asset_Approval_ID,Alpha_Emp_Code,Emp_Full_Name,
				Branch_Name,Asset_Status,Dept_Name,Cmp_Name,Cmp_Address,application_type,Transfer_Emp_Id,Branch_Id,Transfer_Branch_Id,Dept_Id,Transfer_Dept_Id,Warranty_Start,Warranty_End,
				Purchase_Date,Asset_Description,Emp_Branch,Emp_Dept,Emp_Desig,FROM_DATE,To_Date,BRANCH_FOR_DEPT_ID,Transfer_Dept_Branch_ID,BRANCH_FOR_DEPT,Transfer_Dept_Branch,
				Vendor_Name,Emp_QR_Code,Asset_Filter
				)  
				VALUES
				(@Asset_Name,@BRAND_Name,@Asset_Code,@SerialNo,@Allocation_Date,@Type_of_Asset,@Model,'',@Emp_id,@AssetM_Id,@Asset_Id1,@Brand_Id,@Asset_Approval_ID,@Alpha_Emp_Code,@Emp_Full_Name,
				@Branch_Name,@Asset_Status,@Dept_Name,@Cmp_Name,@Cmp_Address,@application_type,@Transfer_Emp_Id,@Branch_Id,@Transfer_Branch_Id,@Dept_Id,@Transfer_Dept_Id,@Warranty_Start,
				@Warranty_End,@Purchase_Date,@Asset_Description,@Emp_Branch,@Emp_Dept,@Emp_Desig,@FROM_DATE,@To_Date,@BRANCH_FOR_DEPT_ID,@Transfer_Dept_Branch_ID,@BRANCH_FOR_DEPT,
				@Transfer_Dept_Branch,@Vendor_Name,CAST(0 AS VARBINARY(MAX)),isnull(@Asset_ID,0)
				)  
          
           end            
         
       fetch next from ASSET_DETAILS into @Asset_Approval_ID,@application_type,@AssetM_ID,@emp_id,@Transfer_Emp_Id,@Branch_Id,@Transfer_Branch_Id,@Dept_Id,@Transfer_Dept_Id  
       End  
     close ASSET_DETAILS   
     deallocate ASSET_DETAILS  
       
     --select * from #ASSET_EMP  
    --select Emp_ID From @Emp_Cons  
    
  --SELECT 333,@Type  
    begin   
     if @allocation1='Employee Asset'   
      begin  
      if @Type =1        
       BEGIN  
       --select * from #ASSET_EMP where (convert(DATETIME,Return_Date,103) >= @From_Date and convert(DATETIME,Return_Date,103) <= @To_date)  
        if @Asset_ID > 0  
         begin  
          select *,substring(emp_full_name, CHARINDEX('-', emp_full_name)+1,LEN(emp_full_name)-CHARINDEX('-', emp_full_name))Emp_Name from #ASSET_EMP where (convert(DATETIME,Return_Date,103) >= @From_Date and convert(DATETIME,Return_Date,103) <= @To_date)
 and emp_id in (select Emp_ID From @Emp_Cons) and isnull(Emp_Full_Name,'') <> '' and isnull(Transfer_Emp_Id,0)=0 and Asset_ID=@Asset_ID and Application_Type = ISNULL(@Type,Application_Type) and Brand_Id=ISNULL(@Brand,Brand_Id)  
          union  
          select *,substring(emp_full_name, CHARINDEX('-', emp_full_name)+1,LEN(emp_full_name)-CHARINDEX('-', emp_full_name))Emp_Name from #ASSET_EMP where (convert(DATETIME,Return_Date,103) >= @From_Date and convert(DATETIME,Return_Date,103) <= @To_date)
 and Transfer_emp_id in (select Emp_ID From @Emp_Cons) and isnull(Emp_Full_Name,'') <> '' and Asset_ID=@Asset_ID and Application_Type = ISNULL(@Type,Application_Type) and Brand_Id=ISNULL(@Brand,Brand_Id)  
         end  
        else  
         begin        
          select *,substring(emp_full_name, CHARINDEX('-', emp_full_name)+1,LEN(emp_full_name)-CHARINDEX('-', emp_full_name))Emp_Name from #ASSET_EMP where (convert(DATETIME,Return_Date,103) >= @From_Date and convert(DATETIME,Return_Date,103) <= @To_date)
 and emp_id in (select Emp_ID From @Emp_Cons) and isnull(Emp_Full_Name,'') <> '' and isnull(Transfer_Emp_Id,0)=0   
          and Application_Type = ISNULL(@Type,Application_Type) and Brand_Id=ISNULL(@Brand,Brand_Id)  
          union  
          select *,substring(emp_full_name, CHARINDEX('-', emp_full_name)+1,LEN(emp_full_name)-CHARINDEX('-', emp_full_name))Emp_Name from #ASSET_EMP where (convert(DATETIME,Return_Date,103) >= @From_Date and convert(DATETIME,Return_Date,103) <= @To_date)
 and Transfer_emp_id in (select emp_id From @Emp_Cons) and isnull(Emp_Full_Name,'') <> ''   
          and Application_Type = ISNULL(@Type,Application_Type) and Brand_Id=ISNULL(@Brand,Brand_Id)  
         end  
       END  
      else  
       BEGIN  
        if @Asset_ID > 0  
         begin  
          select *,substring(emp_full_name, CHARINDEX('-', emp_full_name)+1,LEN(emp_full_name)-CHARINDEX('-', emp_full_name))Emp_Name
		  from #ASSET_EMP 
		  where emp_id in (select Emp_ID From @Emp_Cons) and isnull(Emp_Full_Name,'') <> '' and isnull(Transfer_Emp_Id,0)=0 and Asset_ID=@Asset_ID and Application_Type = ISNULL(@Type,Application_Type) and Brand_Id=ISNULL(@Brand,Brand_Id)  
          union  
          select *,substring(emp_full_name, CHARINDEX('-', emp_full_name)+1,LEN(emp_full_name)-CHARINDEX('-', emp_full_name))Emp_Name 
		  from #ASSET_EMP 
		  where Transfer_emp_id in (select Emp_ID From @Emp_Cons) and isnull(Emp_Full_Name,'') <> '' and Asset_ID=@Asset_ID and Application_Type = ISNULL(@Type,Application_Type)
		  and Brand_Id=ISNULL(@Brand,Brand_Id)  
         end  
        else  
         begin        
          select *,substring(emp_full_name, CHARINDEX('-', emp_full_name)+1,LEN(emp_full_name)-CHARINDEX('-', emp_full_name))Emp_Name
		  from #ASSET_EMP 
		  where emp_id in (select Emp_ID From @Emp_Cons) and isnull(Emp_Full_Name,'') <> '' and isnull(Transfer_Emp_Id,0)=0   
          and Application_Type = ISNULL(@Type,Application_Type) and Brand_Id=ISNULL(@Brand,Brand_Id)  
          union  
          select *,substring(emp_full_name, CHARINDEX('-', emp_full_name)+1,LEN(emp_full_name)-CHARINDEX('-', emp_full_name))Emp_Name from #ASSET_EMP where Transfer_emp_id in (select emp_id From @Emp_Cons) and isnull(Emp_Full_Name,'') <> ''   
          and Application_Type = ISNULL(@Type,Application_Type) and Brand_Id=ISNULL(@Brand,Brand_Id)  
         end  
       END  
      end  
     else  if @allocation1='Branch Asset'   
      begin  
      if (@branch1 > 0 and @Asset_ID > 0)  
        begin  
         select *,substring(emp_full_name, CHARINDEX('-', emp_full_name)+1,LEN(emp_full_name)-CHARINDEX('-', emp_full_name))Emp_Name
		 from #ASSET_EMP 
		 where (isnull(Branch_Name,'') <> '' and (Branch_ID=@branch1 or Transfer_Branch_ID=@branch1))and (isnull(Branch_Name,'') <> '' and (Asset_ID=@Asset_ID)) and Brand_Id=ISNULL(@Brand,Brand_Id)  
       end  
      else if @branch1 > 0   
        begin         
         select *,substring(emp_full_name, CHARINDEX('-', emp_full_name)+1,LEN(emp_full_name)-CHARINDEX('-', emp_full_name))Emp_Name
		 from #ASSET_EMP 
		 where (isnull(Branch_Name,'') <> '' and (Branch_ID=@branch1 or Transfer_Branch_ID=@branch1)) and Brand_Id=ISNULL(@Brand,Brand_Id)  
       end  
      else  
       begin  
        select *,substring(emp_full_name, CHARINDEX('-', emp_full_name)+1,LEN(emp_full_name)-CHARINDEX('-', emp_full_name))Emp_Name 
		from #ASSET_EMP
		where isnull(Branch_Name,'') <> '' and Brand_Id=ISNULL(@Brand,Brand_Id)  
       end  
      end        
     else  if @allocation1='Department Asset'   
      begin  
      if (@Dept_Id1 > 0 and @Asset_ID > 0)  
       begin  
        select *,substring(emp_full_name, CHARINDEX('-', emp_full_name)+1,LEN(emp_full_name)-CHARINDEX('-', emp_full_name))Emp_Name
		from #ASSET_EMP
		where isnull(Dept_Name,'') <> '' and (Dept_Id=@Dept_Id1 or Transfer_Dept_Id=@Dept_Id1) and Asset_ID=@Asset_ID   
        and Application_Type = ISNULL(@Type,Application_Type) and (BRANCH_FOR_DEPT_ID=ISNULL(@branch1,BRANCH_FOR_DEPT_ID) OR Transfer_Dept_Branch_ID=ISNULL(@branch1,Transfer_Dept_Branch_ID))
		and Brand_Id=ISNULL(@Brand,Brand_Id)  
       end  
      else if @Dept_Id1 > 0   
        begin  
         select *,substring(emp_full_name, CHARINDEX('-', emp_full_name)+1,LEN(emp_full_name)-CHARINDEX('-', emp_full_name))Emp_Name 
		 from #ASSET_EMP 
		 where (isnull(Dept_Name,'') <> ''  and (BRANCH_FOR_DEPT_ID=ISNULL(@branch1,BRANCH_FOR_DEPT_ID) OR Transfer_Dept_Branch_ID=ISNULL(@branch1,Transfer_Dept_Branch_ID))  
          and Application_Type = ISNULL(@Type,Application_Type) and (Dept_Id=@Dept_Id1 or Transfer_Dept_Id=@Dept_Id1)) and Brand_Id=ISNULL(@Brand,Brand_Id)  
       end  
      else  
       begin          
        select *,substring(emp_full_name, CHARINDEX('-', emp_full_name)+1,LEN(emp_full_name)-CHARINDEX('-', emp_full_name))Emp_Name
		from #ASSET_EMP
		where isnull(Dept_Name,'') <> '' and (BRANCH_FOR_DEPT_ID=ISNULL(@branch1,BRANCH_FOR_DEPT_ID) OR Transfer_Dept_Branch_ID=ISNULL(@branch1,Transfer_Dept_Branch_ID))  
         and Application_Type = ISNULL(@Type,Application_Type) and Brand_Id=ISNULL(@Brand,Brand_Id)  
       end  
      end  
     --where emp_id in (select Emp_ID From @Emp_Cons)         
    end   