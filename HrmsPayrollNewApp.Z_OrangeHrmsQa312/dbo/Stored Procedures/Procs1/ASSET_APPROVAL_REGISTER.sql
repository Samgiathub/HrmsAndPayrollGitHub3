

---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[ASSET_APPROVAL_REGISTER]
     @Cmp_ID        numeric,
     @From_Date  DATETIME,
     @To_date   DATETIME,
     @constraint    varchar(MAX),     
	 @Emp_ID        numeric  = 0 ,
	 @Asset_Code1   Varchar(250),   
     @Branch_ID		varchar(max)='' ,
	 @Cat_ID 		varchar(max)='' ,
	 @Grd_ID 		varchar(max)='',
	 @Type_ID 		varchar(max)='',
	 @Dept_ID 		varchar(max)='',
	 @Desig_ID 		varchar(max)='',
	 @flag			numeric  = 0 
    
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


   IF @Branch_ID = '0' or @Branch_ID=''
		set @Branch_ID = null
		
	IF @Cat_ID = '0' or @Cat_ID='' 
		set @Cat_ID = null

	IF @Grd_ID = '0' or @Grd_ID=''  
		set @Grd_ID = null

	IF @Type_ID = '0' or @Type_ID=''  
		set @Type_ID = null

	IF @Dept_ID = '0' or @Dept_ID='' 
		set @Dept_ID = null

	IF @Desig_ID = '0' or @Desig_ID=''  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null

    if @Asset_Code1='--Select--' or @Asset_Code1=''
        set @Asset_Code1=null
        
    --Declare #Emp_Cons Table
    --(
    --    Emp_ID  numeric
    --)
    
    --if @Constraint <> ''
    --    begin
    --        Insert Into #Emp_Cons
    --        select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
    --    end
    --else 
    --    begin
    --        Insert Into #Emp_Cons

    --        select I.Emp_Id from T0095_Increment I inner join 
    --                ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
    --                where Increment_Effective_date <= @To_Date
    --                and Cmp_ID = @Cmp_ID
    --                group by emp_ID  ) Qry on
    --                I.Emp_ID = Qry.Emp_ID   and I.Increment_effective_Date = Qry.For_Date
    --        Where Cmp_ID = @Cmp_ID 
    --        and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
    --        and Branch_ID = isnull(@Branch1 ,Branch_ID)
    --        and Grd_ID = isnull(@Grd_ID ,Grd_ID)
    --        and isnull(Dept_ID,0) = isnull(@Dept_Id1 ,isnull(Dept_ID,0))
    --        and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
    --        and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
    --        and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
    --        and I.Emp_ID in 
    --            ( select Emp_Id from
    --            (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
    --            where cmp_ID = @Cmp_ID   and  
    --            (( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
    --            or ( @To_Date  >= join_Date  and @To_Date <= left_date )
    --            or Left_date is null and @To_Date >= Join_Date)
    --            or @To_Date >= left_date and  @From_Date <= left_date ) 
            
    --    end
      
      CREATE table #Emp_Cons
	 (
		Emp_ID	numeric,
		Branch_ID numeric, 
		Increment_ID numeric  
	 )  
	 
     exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'',0,0    	
        
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
    declare @Asset_ID as numeric(18,0)
    declare @Emp_Full_Name as varchar(250)
    declare @Pending_amount as numeric(18,2)
    declare @Branch_Name varchar(250)
    declare @Dept_Name varchar(250)
    declare @Cmp_Name varchar(250)
    declare @Cmp_Address varchar(max)
    declare @Transfer_Emp_Id numeric(18,0)
    declare @Branch_Id_Asset numeric(18,0)
    declare @Transfer_Branch_Id numeric(18,0)
    declare @Dept_Id_Asset numeric(18,0)
    declare @Transfer_Dept_Id numeric(18,0)
    declare @Return_Asset_Approval_Id numeric(18,0)
	declare	@Emp_Dept varchar(200)
	declare @Emp_Desig varchar(200)
	DECLARE @Emp_Branch VARCHAR(200)
	DECLARE @Branch_For_Dept VARCHAR(200)
	DECLARE @Transfer_Branch_For_Dept varchar(200)
	DECLARE @BRANCH_FOR_DEPT_ID INT
	DECLARE @Transfer_Dept_Branch_ID INT
	declare @Comment varchar(max)
	declare @Emp_Branch_ID int
	DECLARE @Data_Sim_Number_Service_Provider  VARCHAR(200)
	
    CREATE table #ASSET_EMP
    (
     Asset_Name  varchar(250),
     BRAND_Name  varchar(250),
     Asset_Code  varchar(250),
     Serial_No  varchar(250),
     Allocation_Date  datetime,--varchar(50),
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
     Emp_Branch varchar(200), --Mukti(08012018)
	 Emp_Dept varchar(200), --Mukti(08012018)
	 Emp_Desig varchar(200),--Mukti(08012018)  
	 BRANCH_FOR_DEPT_ID	int,	 
	 Branch_For_Dept varchar(200),
	 Comment varchar(Max),
	 Emp_Branch_ID int	
    )
    print @From_Date
    print @To_date
   --  select * From #Emp_Cons
   
  
    DECLARE ASSET_DETAILS CURSOR FOR
                select apd.Asset_Approval_ID,apd.application_type,apd.assetm_id,ap.emp_id,ap.Transfer_Emp_Id,ap.Branch_Id,ap.Transfer_Branch_Id,ap.Dept_Id,ap.Transfer_Dept_Id
                from T0130_Asset_Approval_Det apd WITH (NOLOCK)
                inner join T0120_Asset_Approval ap WITH (NOLOCK) on apd.Asset_Approval_ID=ap.Asset_Approval_ID and apd.cmp_id=ap.cmp_id
                where ap.cmp_id=@cmp_id and apd.Allocation_Date >= @From_Date and apd.Allocation_Date <= @To_date --and asset_code='tab/0113'
					--and 1 = case when exists(select 1 from #Emp_Cons where Emp_Id=AP.Emp_Id)  then 1 else 0 end
                -- and ((ap.emp_id in (select Emp_ID From #Emp_Cons)) or (ap.Transfer_emp_id in (select Emp_ID From #Emp_Cons)))  
                OPEN ASSET_DETAILS
                            fetch next from ASSET_DETAILS into @Asset_Approval_ID,@application_type,@AssetM_ID,@emp_id,@Transfer_Emp_Id,@Branch_Id_Asset,
                            @Transfer_Branch_Id,@Dept_Id_Asset,@Transfer_Dept_Id
                                while @@fetch_status = 0
                                    Begin
                                        if @application_type=1 --fill asset while return
                                            begin
                                                SELECT DISTINCT 
                                                     @Asset_Name=dbo.T0040_ASSET_MASTER.Asset_Name,@BRAND_Name=dbo.T0040_BRAND_MASTER.BRAND_Name,@Asset_Code= dbo.T0040_Asset_Details.Asset_Code,@SerialNo=dbo.T0040_Asset_Details.SerialNo, 
                                                     @Allocation_Date=dbo.T0130_Asset_Approval_Det.Allocation_Date,@Type_of_Asset=dbo.T0040_Asset_Details.Type_of_Asset, 
                                                     @Model= dbo.T0040_Asset_Details.Model,@Return_Date= CONVERT(varchar(11), dbo.T0130_Asset_Approval_Det.Return_Date, 103),@Asset_Id=T0040_ASSET_MASTER.Asset_Id,
                                                     @Brand_Id=T0130_Asset_Approval_Det.Brand_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Emp_Full_Name=E.Emp_Full_Name+'-'+E.Alpha_Emp_Code,
                                                     @AssetM_Id=T0130_Asset_Approval_Det.AssetM_Id,@Branch_Name=B.Branch_Name,@Dept_Name=D.dept_name,
                                                     @Asset_Status=CASE WHEN dbo.T0040_Asset_Details.Asset_Status = 'D' THEN 'Damage' WHEN dbo.T0040_Asset_Details.Asset_Status = 'Dispose' THEN 'Dispose' ELSE 'Working' END,
                                                     @Cmp_Name=co.Cmp_Name,@Cmp_Address=co.Cmp_Address,@Return_Asset_Approval_Id=Return_Asset_Approval_Id,
                                                     @Emp_Dept=ISNULL(DE.Dept_Name,''),@Emp_Desig=ISNULL(DS.desig_name,''),@Emp_Branch=ISNULL(BE.Branch_Name,''),
                                                     @Branch_For_Dept=BD.Branch_Name,@Transfer_Branch_For_Dept=BDT.Branch_Name,
                                                     @Transfer_Branch_Id=case when @application_type=3 then dbo.T0120_Asset_Approval.Transfer_Branch_ID else dbo.T0120_Asset_Approval.branch_id end
                                                 FROM dbo.T0130_Asset_Approval_Det WITH (NOLOCK) INNER JOIN
                                                                          Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=T0130_Asset_Approval_Det.Cmp_ID inner join
                                                                          dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID left JOIN
                                                                          dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID left JOIN
                                                                          dbo.T0040_Asset_Details WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN
                                                                          dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID AND 
                                                                          dbo.T0120_Asset_Approval.Cmp_ID = dbo.T0130_Asset_Approval_Det.Cmp_ID LEFT OUTER JOIN
                                                                          dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
                                                                          (
																			Select I.Emp_ID, I.Branch_ID, I.Cmp_ID, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID, I.Type_ID, I.Grd_ID, I.Cat_ID, I.Desig_Id, I.Segment_ID, I.subBranch_ID
																			FROM T0095_INCREMENT I WITH (NOLOCK) WHERE I.Increment_Effective_date = 
																			(Select MAX(Increment_Effective_date) FROM T0095_INCREMENT I1 WITH (NOLOCK)
																						WHERE	I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID 
																					 AND Increment_Effective_date <= @To_Date)
																					  AND Cmp_ID=@Cmp_ID
																			) AS mm ON E.Emp_ID = mm.Emp_ID AND E.Cmp_ID = mm.Cmp_ID left join
																		  dbo.t0040_department_master AS DE WITH (NOLOCK) ON mm.Dept_ID = DE.Dept_ID AND DE.Cmp_ID = mm.Cmp_ID left join
																		  dbo.t0040_designation_master AS DS WITH (NOLOCK) ON mm.Desig_ID = DS.Desig_ID AND DS.Cmp_ID = mm.Cmp_ID left join
																		  dbo.T0030_BRANCH_MASTER AS BE WITH (NOLOCK) ON mm.Branch_ID = BE.Branch_ID AND BE.Cmp_ID = mm.Cmp_ID left join
                                                                          dbo.T0030_BRANCH_MASTER AS B WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Branch_ID = B.Branch_ID AND B.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
                                                                          dbo.t0040_department_master AS D WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Dept_ID = D.Dept_ID AND D.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN                                                             
                                                                          dbo.T0030_BRANCH_MASTER BD WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Branch_For_Dept = BD.Branch_ID AND BD.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0030_BRANCH_MASTER BDT WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Branch_For_Dept = BDT.Branch_ID AND BDT.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID 
                                                WHERE     isnull(Return_asset_approval_id, 0) > 0 and   isnull(Return_Date, '') <> '1900-01-01 00:00:00.000'   and T0130_Asset_Approval_Det.Asset_Approval_ID=@Asset_Approval_ID 
                                                and T0130_Asset_Approval_Det.application_type=@application_type and T0130_Asset_Approval_Det.AssetM_ID=@AssetM_ID                                                                                                             
                                                
                                                
                                            if exists(select * from T0120_Asset_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=3)
                                                begin
                                                    select @Transfer_Branch_Id=Transfer_Branch_Id,@Transfer_Emp_Id=Transfer_Emp_Id,@Transfer_Dept_Id=Transfer_Dept_Id from T0120_Asset_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=3
                                                    
                                                    if isnull(@Transfer_Emp_Id,0)>0 
                                                        begin
                                                            update #ASSET_EMP 
                                                            set Return_Date=@Return_Date
                                                            where Transfer_Emp_Id=@Transfer_Emp_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
                                                        end
                                                    
                                                     if isnull(@Transfer_Branch_Id,0) >0 
                                                        begin
                                                            update #ASSET_EMP 
                                                            set Return_Date=@Return_Date
                                                            where Transfer_Branch_Id=@Transfer_Branch_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
                                                        end
                                                     if isnull(@Transfer_Dept_Id,0) >0  
                                                        begin
                                                            update #ASSET_EMP 
                                                            set Return_Date=@Return_Date
                                                            where Transfer_Dept_Id=@Transfer_Dept_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
                                                        end
                                                end
                                            else
                                                begin
                                                    select @Branch_Id_Asset=Branch_Id,@Emp_Id=Emp_Id,@Dept_Id_Asset=Dept_Id from T0120_Asset_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=0
                                                    
                                                    if isnull(@Emp_Id,0)>0 
                                                        begin
                                                            update #ASSET_EMP 
                                                            set Return_Date=@Return_Date
                                                            where Emp_Id=@Emp_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
                                                        end
                                                    
                                                     if isnull(@Branch_Id_Asset,0) >0 
                                                        begin
                                                            update #ASSET_EMP 
                                                            set Return_Date=@Return_Date
                                                            where Branch_Id=@Branch_Id_Asset and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
                                                        end
                                                     if isnull(@Dept_Id_Asset,0) >0  
                                                        begin
                                                            update #ASSET_EMP 
															set Return_Date=@Return_Date
                                                            where Dept_Id=@Dept_Id_Asset and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
                                                        end
                                                end
                                            end
                                        else if @application_type=3 --fill asset while Transfer
                                            begin
                                                    SELECT DISTINCT 
                                                     @Asset_Name=dbo.T0040_ASSET_MASTER.Asset_Name,@BRAND_Name=dbo.T0040_BRAND_MASTER.BRAND_Name,@Asset_Code= dbo.T0040_Asset_Details.Asset_Code,@SerialNo=dbo.T0040_Asset_Details.SerialNo, 
                                                     @Allocation_Date=dbo.T0130_Asset_Approval_Det.Allocation_Date,@Type_of_Asset=dbo.T0040_Asset_Details.Type_of_Asset, 
                                                     @Model= dbo.T0040_Asset_Details.Model,@Return_Date= CONVERT(varchar(11), dbo.T0130_Asset_Approval_Det.Return_Date, 103),@Asset_Id=T0040_ASSET_MASTER.Asset_Id,
                                                     @Brand_Id=T0130_Asset_Approval_Det.Brand_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Emp_Full_Name=E.Alpha_Emp_Code + '-' + E.Emp_Full_Name,
                                                     @AssetM_Id=T0130_Asset_Approval_Det.AssetM_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Branch_Name=B.Branch_Name,
                                                     @Dept_Name=D.dept_name,                             
                                                     @Asset_Status=CASE WHEN dbo.T0040_Asset_Details.Asset_Status = 'D' THEN 'Damage' WHEN dbo.T0040_Asset_Details.Asset_Status = 'Dispose' THEN 'Dispose' ELSE 'Working' END,
                                                     @Cmp_Name=co.Cmp_Name,@Cmp_Address=co.Cmp_Address,@Emp_Dept=ISNULL(DE.Dept_Name,''),@Emp_Desig=ISNULL(DS.desig_name,''),@Emp_Branch=ISNULL(BE.Branch_Name,''),
                                                     @Branch_For_Dept=case when T0120_Asset_Approval.Application_Type=3 then BDT.Branch_Name else bd.Branch_Name end,
                                                     @BRANCH_FOR_DEPT_ID=case when T0120_Asset_Approval.Application_Type=3 then BDT.Branch_ID else bd.Branch_ID end,
                                                     @Comment=Comments,@Emp_Branch_ID=mm.Branch_ID,
                                                     @Transfer_Branch_Id=case when @application_type=3 then dbo.T0120_Asset_Approval.Transfer_Branch_ID else dbo.T0120_Asset_Approval.branch_id end
                                            FROM dbo.T0130_Asset_Approval_Det WITH (NOLOCK) INNER JOIN
                                                                          Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=T0130_Asset_Approval_Det.Cmp_ID inner join
                                                                          dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID INNER JOIN
                                                                          dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN
                                                                          dbo.T0040_Asset_Details WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN
                                                                          dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID AND 
                                                                          dbo.T0120_Asset_Approval.Cmp_ID = dbo.T0130_Asset_Approval_Det.Cmp_ID LEFT OUTER JOIN
                                                                          dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
                                                                          (
																			Select I.Emp_ID, I.Branch_ID, I.Cmp_ID, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID, I.Type_ID, I.Grd_ID, I.Cat_ID, I.Desig_Id, I.Segment_ID, I.subBranch_ID
																			FROM T0095_INCREMENT I WITH (NOLOCK) WHERE I.Increment_Effective_date = 
																			(Select MAX(Increment_Effective_date) FROM T0095_INCREMENT I1 WITH (NOLOCK)
																						WHERE	I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID 
																					 AND Increment_Effective_date <= @To_Date)
																					  AND Cmp_ID=@Cmp_ID
																			) AS mm ON E.Emp_ID = mm.Emp_ID AND E.Cmp_ID = mm.Cmp_ID left join
																		  dbo.t0040_department_master AS DE WITH (NOLOCK) ON mm.Dept_ID = DE.Dept_ID AND DE.Cmp_ID = mm.Cmp_ID left join
																		  dbo.t0040_designation_master AS DS WITH (NOLOCK) ON mm.Desig_ID = DS.Desig_ID AND DS.Cmp_ID = mm.Cmp_ID left join
																		  dbo.T0030_BRANCH_MASTER AS BE WITH (NOLOCK) ON mm.Branch_ID = BE.Branch_ID AND BE.Cmp_ID = mm.Cmp_ID left join
                                                                          dbo.T0030_BRANCH_MASTER AS B WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Branch_ID = B.Branch_ID AND B.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
                                                                          dbo.t0040_department_master AS D WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Dept_ID = D.Dept_ID AND D.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN                                                                       
                                                                          dbo.T0030_BRANCH_MASTER BD WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Branch_For_Dept = BD.Branch_ID AND BD.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0030_BRANCH_MASTER BDT WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Branch_For_Dept = BDT.Branch_ID AND BDT.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID 
                                                WHERE    Return_asset_approval_id is null  and T0130_Asset_Approval_Det.Asset_Approval_ID=@Asset_Approval_ID
                                                and T0130_Asset_Approval_Det.application_type=@application_type and T0130_Asset_Approval_Det.AssetM_ID=@AssetM_ID
                                               -- and mm.Branch_ID=isnull(@Branch_ID,mm.Branch_ID) and dbo.T0120_Asset_Approval.Transfer_Branch_ID=isnull(@Branch_ID,dbo.T0120_Asset_Approval.Transfer_Branch_ID)
                                            
                                                INSERT INTO #ASSET_EMP(Asset_Name,BRAND_Name,Asset_Code,Serial_No,Allocation_Date,Type_of_Asset,Model,Return_Date,Emp_id,AssetM_Id,Asset_Id,Brand_Id,Asset_Approval_ID,Alpha_Emp_Code,Emp_Full_Name,Branch_Name,Asset_Status,Dept_Name,Cmp_Name,Cmp_Address,application_type,Transfer_Emp_Id,Branch_Id,Transfer_Branch_Id,Dept_Id,Transfer_Dept_Id,Emp_Branch,Emp_Dept,Emp_Desig,BRANCH_FOR_DEPT_ID,Branch_For_Dept,Comment,Emp_Branch_ID)
                                                VALUES(@Asset_Name,@BRAND_Name,@Asset_Code,@SerialNo,@Allocation_Date,@Type_of_Asset,@Model,'',@Emp_id,@AssetM_Id,@Asset_Id,@Brand_Id,@Asset_Approval_ID,@Alpha_Emp_Code,@Emp_Full_Name,@Branch_Name,@Asset_Status,@Dept_Name,@Cmp_Name,@Cmp_Address,@application_type,@Transfer_Emp_Id,@Branch_Id_Asset,@Transfer_Branch_Id,@Dept_Id_Asset,@Transfer_Dept_Id,@Emp_Branch,@Emp_Dept,@Emp_Desig,@BRANCH_FOR_DEPT_ID,@Branch_For_Dept,@comment,@Emp_Branch_ID)
                                            
                                            end
                                        else
                                            begin
                                            SELECT DISTINCT 
                                                     @Asset_Name=dbo.T0040_ASSET_MASTER.Asset_Name,@BRAND_Name=dbo.T0040_BRAND_MASTER.BRAND_Name,@Asset_Code= dbo.T0040_Asset_Details.Asset_Code,@SerialNo=dbo.T0040_Asset_Details.SerialNo, 
                                                     @Allocation_Date=dbo.T0130_Asset_Approval_Det.Allocation_Date,@Type_of_Asset=dbo.T0040_Asset_Details.Type_of_Asset, 
                                                     @Model= dbo.T0040_Asset_Details.Model,@Return_Date= CONVERT(varchar(11), dbo.T0130_Asset_Approval_Det.Return_Date, 103),@Asset_Id=T0040_ASSET_MASTER.Asset_Id,
                                                     @Brand_Id=T0130_Asset_Approval_Det.Brand_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Emp_Full_Name=E.Alpha_Emp_Code + '-' + E.Emp_Full_Name,
                                                     @AssetM_Id=T0130_Asset_Approval_Det.AssetM_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Branch_Name=B.Branch_Name,
                                                     @Dept_Name=D.dept_name,@Asset_Status=CASE WHEN dbo.T0040_Asset_Details.Asset_Status = 'D' THEN 'Damage' WHEN dbo.T0040_Asset_Details.Asset_Status = 'Dispose' THEN 'Dispose' ELSE 'Working' END,
                                                     @Cmp_Name=co.Cmp_Name,@Cmp_Address=co.Cmp_Address,@Emp_Dept=ISNULL(DE.Dept_Name,''),@Emp_Desig=ISNULL(DS.desig_name,''),@Emp_Branch=ISNULL(BE.Branch_Name,''),
                                                     @Branch_For_Dept=case when T0120_Asset_Approval.Application_Type=3 then BDT.Branch_Name else bd.Branch_Name end,
                                                     @BRANCH_FOR_DEPT_ID=case when T0120_Asset_Approval.Application_Type=3 then BDT.Branch_ID else bd.Branch_ID end,@Comment=Comments,
                                                     @Emp_Branch_ID=mm.Branch_ID,
                                                     @Transfer_Branch_Id=case when @application_type=3 then dbo.T0120_Asset_Approval.Transfer_Branch_ID else dbo.T0120_Asset_Approval.branch_id end
                                            FROM dbo.T0130_Asset_Approval_Det WITH (NOLOCK) INNER JOIN
                                                                          Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=T0130_Asset_Approval_Det.Cmp_ID inner join
                                                                          dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID INNER JOIN
                                                                          dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN
                                                                          dbo.T0040_Asset_Details WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN
                                                                          dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID AND 
                                                                          dbo.T0120_Asset_Approval.Cmp_ID = dbo.T0130_Asset_Approval_Det.Cmp_ID LEFT OUTER JOIN
                                                                          dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
                                                                          (
																			Select I.Emp_ID, I.Branch_ID, I.Cmp_ID, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID, I.Type_ID, I.Grd_ID, I.Cat_ID, I.Desig_Id, I.Segment_ID, I.subBranch_ID
																			FROM T0095_INCREMENT I WITH (NOLOCK) WHERE I.Increment_Effective_date = 
																			(Select MAX(Increment_Effective_date) FROM T0095_INCREMENT I1 WITH (NOLOCK)
																						WHERE	I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID 
																					 AND Increment_Effective_date <= @To_Date)
																					  AND Cmp_ID=@Cmp_ID
																			) AS mm ON E.Emp_ID = mm.Emp_ID AND E.Cmp_ID = mm.Cmp_ID left join
																		  dbo.t0040_department_master AS DE WITH (NOLOCK) ON mm.Dept_ID = DE.Dept_ID AND DE.Cmp_ID = mm.Cmp_ID left join
																		  dbo.t0040_designation_master AS DS WITH (NOLOCK) ON mm.Desig_ID = DS.Desig_ID AND DS.Cmp_ID = mm.Cmp_ID left join
																		  dbo.T0030_BRANCH_MASTER AS BE WITH (NOLOCK) ON mm.Branch_ID = BE.Branch_ID AND BE.Cmp_ID = mm.Cmp_ID left join
                                                                          dbo.T0030_BRANCH_MASTER AS B WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Branch_ID = B.Branch_ID AND B.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
                                                                          dbo.t0040_department_master AS D WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Dept_ID = D.Dept_ID AND D.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN                                                                     
                                                                          dbo.T0030_BRANCH_MASTER BD WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Branch_For_Dept = BD.Branch_ID AND BD.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0030_BRANCH_MASTER BDT WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Branch_For_Dept = BDT.Branch_ID AND BDT.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID
                                                WHERE    Return_asset_approval_id is null  and T0130_Asset_Approval_Det.Asset_Approval_ID=@Asset_Approval_ID
                                                and T0130_Asset_Approval_Det.application_type=@application_type and T0130_Asset_Approval_Det.AssetM_ID=@AssetM_ID  
                                               -- and mm.Branch_ID=isnull(@Branch_ID,mm.Branch_ID)and dbo.T0120_Asset_Approval.Transfer_Branch_ID=isnull(@Branch_ID,dbo.T0120_Asset_Approval.Transfer_Branch_ID)
                                               -- print 'm'
                                                INSERT INTO #ASSET_EMP(Asset_Name,BRAND_Name,Asset_Code,Serial_No,Allocation_Date,Type_of_Asset,Model,Return_Date,Emp_id,AssetM_Id,Asset_Id,Brand_Id,Asset_Approval_ID,Alpha_Emp_Code,Emp_Full_Name,Branch_Name,Asset_Status,Dept_Name,Cmp_Name,Cmp_Address,application_type,Transfer_Emp_Id,Branch_Id,Transfer_Branch_Id,Dept_Id,Transfer_Dept_Id,Emp_Branch,Emp_Dept,Emp_Desig,BRANCH_FOR_DEPT_ID,Branch_For_Dept,Comment,Emp_Branch_ID)
                                                VALUES(@Asset_Name,@BRAND_Name,@Asset_Code,@SerialNo,@Allocation_Date,@Type_of_Asset,@Model,'',@Emp_id,@AssetM_Id,@Asset_Id,@Brand_Id,@Asset_Approval_ID,@Alpha_Emp_Code,@Emp_Full_Name,@Branch_Name,@Asset_Status,@Dept_Name,@Cmp_Name,@Cmp_Address,@application_type,@Transfer_Emp_Id,@Branch_Id_Asset,@Transfer_Branch_Id,@Dept_Id_Asset,@Transfer_Dept_Id,@Emp_Branch,@Emp_Dept,@Emp_Desig,@BRANCH_FOR_DEPT_ID,@Branch_For_Dept,@comment,@Emp_Branch_ID)
                               -- select * from #ASSET_EMP
                                            end                                     
                            
                            fetch next from ASSET_DETAILS into @Asset_Approval_ID,@application_type,@AssetM_ID,@emp_id,@Transfer_Emp_Id,@Branch_Id_Asset,@Transfer_Branch_Id,@Dept_Id_Asset,@Transfer_Dept_Id
                            End
                    close ASSET_DETAILS 
                    deallocate ASSET_DETAILS
                    
               -- select * from #ASSET_EMP where Transfer_Branch_Id >0
            if @Asset_Code1 <>'' --to fill Asset Code wise
                begin       
                    select DISTINCT ae.Asset_Code as [Asset Code],Asset_Name as [Asset Name],Brand_Name as [Brand],Serial_No as [Serial No],ae.Model,
                    ad.[Description],
                    CASE WHEN ad.Purchase_date = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Purchase_date, 103)END AS [Purchase date],
                    CASE WHEN ad.Warranty_Starts = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Warranty_Starts, 103)END AS [Warranty Starts],
                    CASE WHEN ad.Warranty_Ends = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Warranty_Ends, 103)END AS [Warranty Ends],
                    Emp_Full_Name as [Employee Name],ae.Emp_Branch as Branch,ae.Emp_Dept as Department,ae.Emp_Desig as Designation,Branch_name as [Branch_Allocation],Dept_Name as[Department_Allocation],Allocation_date as[Allocation date],Return_Date as [Return Date],ae.Asset_Status as [Asset Status]
                    from #ASSET_EMP ae
                    inner join T0040_Asset_Details ad WITH (NOLOCK) on ae.AssetM_Id=ad.AssetM_ID
                    where ad.Asset_Code=ISNULL(@Asset_Code1,ad.Asset_Code) and ad.Cmp_ID=@Cmp_ID
                    --and emp_id in (select Emp_ID From #Emp_Cons)
                end
            else
                begin   					  
					if @flag = -1
						BEGIN					
							if @Branch_ID IS NOT NULL
								BEGIN
									select ae.Asset_Code as [Asset Code],Asset_Name as [Asset Name],Brand_Name as [Brand],Serial_No as [Serial No],ae.Model,
									ad.[Description],
									CASE WHEN ad.Purchase_date = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Purchase_date, 103)END AS [Purchase date],
									CASE WHEN ad.Warranty_Starts = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Warranty_Starts, 103)END AS [Warranty Starts],
									CASE WHEN ad.Warranty_Ends = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Warranty_Ends, 103)END AS [Warranty Ends],
									Emp_Full_Name as [Employee Name],--ae.Emp_Branch as Branch,
									--ae.Emp_Dept as Department,
									ae.Emp_Desig as Designation,
									--Branch_name as [Branch_Allocation],
									Case when isnull(Dept_Name,'') <> '' then isnull(Dept_Name,'') else ae.Emp_Dept end as Department,
									--Dept_Name as[Department_Allocation],--Branch_For_Dept,
									case when isnull(Emp_Full_Name,'') <> '' then isnull(ae.Emp_Branch,'') 
										  when isnull(Branch_name,'') <> '' then isnull(Branch_name,'') 
										  when isnull(Dept_Name,'') <> ''  then isnull(Branch_For_Dept,'') end as [Branch Name],
									convert(varchar(11),asm.Allocation_date,103) as[Allocation date],Return_Date as [Return Date],ae.Asset_Status as [Asset Status],Comment							
									from #ASSET_EMP ae
									inner join (select max(Allocation_Date)Allocation_Date,AssetM_Id from #ASSET_EMP GROUP by AssetM_Id)asm 
									on asm.AssetM_Id=ae.AssetM_Id and asm.Allocation_Date=ae.Allocation_Date
									inner join T0040_Asset_Details ad WITH (NOLOCK) on asm.AssetM_Id=ad.AssetM_ID
									where ad.Cmp_ID=@Cmp_ID 
									and (ISNULL(BRANCH_FOR_DEPT_ID,0) IN (select Data from dbo.Split(ISNULL(@Branch_Id,ISNULL(BRANCH_FOR_DEPT_ID,0)), '#') PB Where PB.Data <> '')
									or							
									isnull(ae.Transfer_Branch_Id,0) IN (select Data from dbo.Split(ISNULL(@Branch_Id,ISNULL(ae.Transfer_Branch_Id,0)), '#') PB Where PB.Data <> '')
									or
									ISNULL(ae.Emp_Branch_ID,0) IN (select Data from dbo.Split(ISNULL(@Branch_Id,ISNULL(ae.Emp_Branch_ID,0)), '#') PB Where PB.Data <> ''))									
									and ad.Asset_Code=ISNULL(@Asset_Code1,ad.Asset_Code) --and ae.Return_Date ='1900-01-01'
									order by substring(ae.asset_code,0, charindex('/',ae.asset_code)) + '/' + 
									right('0000000' + substring(ae.asset_code,charindex('/',ae.asset_code)+1, len(ae.asset_code)), 7)
									--,ae.Asset_Name,ae.BRAND_Name,[Serial No],ad.Model,ad.[Description]
								END
							ELSE
								BEGIN
								print 'mmm3'
									select ae.Asset_Code as [Asset Code],Asset_Name as [Asset Name],Brand_Name as [Brand],Serial_No as [Serial No],ae.Model,
									ad.[Description],
									CASE WHEN ad.Purchase_date = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Purchase_date, 103)END AS [Purchase date],
									CASE WHEN ad.Warranty_Starts = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Warranty_Starts, 103)END AS [Warranty Starts],
									CASE WHEN ad.Warranty_Ends = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Warranty_Ends, 103)END AS [Warranty Ends],
									Emp_Full_Name as [Employee Name],--ae.Emp_Branch as Branch,
									--ae.Emp_Dept as Department,
									ae.Emp_Desig as Designation,
									--Branch_name as [Branch_Allocation],
									Case when isnull(Dept_Name,'') <> '' then isnull(Dept_Name,'') else ae.Emp_Dept end as Department,
									case when isnull(Emp_Full_Name,'') <> '' then isnull(ae.Emp_Branch,'') 
										  when isnull(Branch_name,'') <> '' then isnull(Branch_name,'') 
										  when isnull(Dept_Name,'') <> ''  then isnull(Branch_For_Dept,'') end as [Branch Name],
									convert(varchar(11),asm.Allocation_date,103) as[Allocation date],Return_Date as [Return Date],ae.Asset_Status as [Asset Status],Comment							
									from #ASSET_EMP ae
									inner join (select max(Allocation_Date)Allocation_Date,AssetM_Id from #ASSET_EMP GROUP by AssetM_Id)asm 
									on asm.AssetM_Id=ae.AssetM_Id and asm.Allocation_Date=ae.Allocation_Date
									inner join T0040_Asset_Details ad WITH (NOLOCK) on asm.AssetM_Id=ad.AssetM_ID
									where ad.Cmp_ID=@Cmp_ID 
									--and (ISNULL(BRANCH_FOR_DEPT_ID,0)=ISNULL(@Branch_Id,ISNULL(BRANCH_FOR_DEPT_ID,0)) or							
									--ISNULL(ae.Branch_Id,0)=ISNULL(@Branch_Id,ISNULL(ae.Branch_Id,0)) or
									-- isnull(ae.Transfer_Branch_Id,0) =isnull(@Branch_Id,isnull(ae.Transfer_Branch_Id,0)) or
									--ISNULL(ae.Emp_Branch_ID,0) =isnull(@Branch_Id,ISNULL(ae.Emp_Branch_ID,0)))
									--and ISNULL(Emp_Full_Name,'') <> ''and   ae.Emp_Branch_ID=isnull(@Branch_ID,ae.Emp_Branch_ID)
									--and ((ae.emp_id in (select Emp_ID From #Emp_Cons)) or (ae.Transfer_emp_id in (select Emp_ID From #Emp_Cons)))   
									and ad.Asset_Code=ISNULL(@Asset_Code1,ad.Asset_Code) --and ae.Return_Date ='1900-01-01'
									order by substring(ae.asset_code,0, charindex('/',ae.asset_code)) + '/' + 
									right('0000000' + substring(ae.asset_code,charindex('/',ae.asset_code)+1, len(ae.asset_code)), 7)									
								END
						END  
					ELSE if @flag = 0
						BEGIN	
							select ae.Asset_Code as [Asset Code],Asset_Name as [Asset Name],Brand_Name as [Brand],Serial_No as [Serial No],ae.Model,
							ad.[Description],
							CASE WHEN ad.Purchase_date = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Purchase_date, 103)END AS [Purchase date],
							CASE WHEN ad.Warranty_Starts = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Warranty_Starts, 103)END AS [Warranty Starts],
							CASE WHEN ad.Warranty_Ends = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Warranty_Ends, 103)END AS [Warranty Ends],
							Emp_Full_Name as [Employee Name],ae.Emp_Branch as Branch,							
							ae.Emp_Desig as Designation,
							Case when isnull(Dept_Name,'') <> '' then isnull(Dept_Name,'') else ae.Emp_Dept end as Department,							
							convert(varchar(11),asm.Allocation_date,103) as[Allocation date],Return_Date as [Return Date],ae.Asset_Status as [Asset Status],Comment
							,ID1.Installation_Details as 'Data Sim Number & Service Provider'
							from #ASSET_EMP ae
							inner join (select max(Allocation_Date)Allocation_Date,AssetM_Id from #ASSET_EMP GROUP by AssetM_Id)asm 
							on asm.AssetM_Id=ae.AssetM_Id and asm.Allocation_Date=ae.Allocation_Date
							inner join T0040_Asset_Details ad WITH (NOLOCK) on asm.AssetM_Id=ad.AssetM_ID	LEFT JOIN	
							(select DISTINCT Installation_Details,AssetM_Id,Asset_Approval_ID from T0110_Asset_Installation_Details ID WITH (NOLOCK)
							inner join  T0030_Asset_Installation AI WITH (NOLOCK) ON AI.Asset_Installation_ID=ID.Asset_Installation_ID
							AND AI.Installation_Name='Data Sim Number & Service Provider')ID1 ON ID1.AssetM_Id=AE.AssetM_Id	and ID1.Asset_Approval_ID=ae.Asset_Approval_ID	
							where ad.Cmp_ID=@Cmp_ID and ISNULL(Emp_Full_Name,'') <> '' and   ae.Emp_Branch_ID IN (select Data from dbo.Split(ISNULL(@Branch_Id,ISNULL(ae.Emp_Branch_ID,0)), '#') PB Where PB.Data <> '')
							and ((ae.emp_id in (select Emp_ID From #Emp_Cons)) or (ae.Transfer_emp_id in (select Emp_ID From #Emp_Cons)))   
							and ad.Asset_Code=ISNULL(@Asset_Code1,ad.Asset_Code)
							order by substring(ae.asset_code,0, charindex('/',ae.asset_code)) + '/' + 
							right('0000000' + substring(ae.asset_code,charindex('/',ae.asset_code)+1, len(ae.asset_code)), 7)

						END  
					else if @flag=1
						BEGIN
							--select ae.Asset_Code as [Asset Code],Asset_Name as [Asset Name],Brand_Name as [Brand],Serial_No as [Serial No],ae.Model,
							--ad.[Description],
							--CASE WHEN ad.Purchase_date = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Purchase_date, 103)END AS [Purchase date],
							--CASE WHEN ad.Warranty_Starts = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Warranty_Starts, 103)END AS [Warranty Starts],
							--CASE WHEN ad.Warranty_Ends = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Warranty_Ends, 103)END AS [Warranty Ends],
							--Branch_name as [Branch_Allocation],
							--Allocation_date as[Allocation date],Return_Date as [Return Date],ae.Asset_Status as [Asset Status] ,comment							
							--from #ASSET_EMP ae
							--inner join (select max(Asset_Approval_ID)Asset_Approval_ID,AssetM_Id from #ASSET_EMP GROUP by AssetM_Id)asm 
							--on asm.AssetM_Id=ae.AssetM_Id and asm.Asset_Approval_ID=ae.Asset_Approval_ID
							--inner join T0040_Asset_Details ad on ae.AssetM_Id=ad.AssetM_ID 	
							--where ad.Cmp_ID=@Cmp_ID and (ISNULL(ae.Transfer_Branch_Id,0) >0 or ISNULL(ae.Branch_Id,0) >0) and 
							--ad.Asset_Code=ISNULL(@Asset_Code1,ad.Asset_Code)
							--and ISNULL(Branch_name,'') <> '' and ae.Transfer_Branch_Id IN (select Data from dbo.Split(ISNULL(@Branch_Id,ISNULL(ae.Transfer_Branch_Id,0)), '#') PB Where PB.Data <> '')
							--order by substring(ae.asset_code,0, charindex('/',ae.asset_code)) + '/' + 
							--right('000000' + substring(ae.asset_code,charindex('/',ae.asset_code)+1, len(ae.asset_code)), 7)
							
							select  ae.Asset_Code as [Asset Code],Asset_Name as [Asset Name],Brand_Name as [Brand],Serial_No as [Serial No],ae.Model,
							ad.[Description],
							CASE WHEN ad.Purchase_date = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Purchase_date, 103)END AS [Purchase date],
							CASE WHEN ad.Warranty_Starts = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Warranty_Starts, 103)END AS [Warranty Starts],
							CASE WHEN ad.Warranty_Ends = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Warranty_Ends, 103)END AS [Warranty Ends],
							--Emp_Full_Name as [Employee Name],ae.Emp_Branch as Branch,ae.Emp_Dept as Department,ae.Emp_Desig as Designation,
							--ad.Branch_ID,ae.Transfer_Branch_Id,
							--case when ISNULL(ae.Branch_Id,0) >0 then bm.Branch_Name else bm1.Branch_Name end [Branch_Allocation],
							Branch_name as [Branch_Allocation],--'' as[Department_Allocation],
							ae.Allocation_date as[Allocation date],Return_Date as [Return Date],ae.Asset_Status as [Asset Status] ,comment
							into #tmpbranch
							from #ASSET_EMP ae
							inner join (select max(Asset_Approval_ID)Asset_Approval_ID,AssetM_Id from #ASSET_EMP GROUP by AssetM_Id)asm 
							on asm.AssetM_Id=ae.AssetM_Id and asm.Asset_Approval_ID=ae.Asset_Approval_ID
							inner join T0040_Asset_Details ad WITH (NOLOCK) on ae.AssetM_Id=ad.AssetM_ID
							--left join T0030_BRANCH_MASTER bm on bm.Branch_ID =ae.Branch_Id
							--left join T0030_BRANCH_MASTER bm1 on bm1.Branch_ID =ae.Transfer_Branch_Id
							where ad.Cmp_ID=@Cmp_ID and (ISNULL(ae.Transfer_Branch_Id,0) >0 or ISNULL(ae.Branch_Id,0) >0) and 
							ad.Asset_Code=ISNULL(@Asset_Code1,ad.Asset_Code)
							 and (ae.Transfer_Branch_Id =isnull(@Branch_Id,0) or ae.Branch_Id =isnull(@Branch_Id,0))
							order by substring(ae.asset_code,0, charindex('/',ae.asset_code)) + '/' + 
							right('0000000' + substring(ae.asset_code,charindex('/',ae.asset_code)+1, len(ae.asset_code)), 7)
							select DISTINCT * from #tmpbranch
						END    
					else if @flag=2
						BEGIN
							select ae.Asset_Code as [Asset Code],Asset_Name as [Asset Name],Brand_Name as [Brand],Serial_No as [Serial No],ae.Model,
							ad.[Description],
							CASE WHEN ad.Purchase_date = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Purchase_date, 103)END AS [Purchase date],
							CASE WHEN ad.Warranty_Starts = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Warranty_Starts, 103)END AS [Warranty Starts],
							CASE WHEN ad.Warranty_Ends = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), ad.Warranty_Ends, 103)END AS [Warranty Ends],
							--Emp_Full_Name as [Employee Name],ae.Emp_Branch as Branch,ae.Emp_Dept as Department,ae.Emp_Desig as Designation,'' as [Branch_Allocation],
							Dept_Name as[Department_Allocation],Branch_For_Dept,
							Allocation_date as[Allocation date],Return_Date as [Return Date],ae.Asset_Status as [Asset Status],Comment--,BRANCH_FOR_DEPT_ID 
							from #ASSET_EMP ae
							inner join (select max(Asset_Approval_ID)Asset_Approval_ID,AssetM_Id from #ASSET_EMP GROUP by AssetM_Id)asm 
							on asm.AssetM_Id=ae.AssetM_Id and asm.Asset_Approval_ID=ae.Asset_Approval_ID
							inner join T0040_Asset_Details ad WITH (NOLOCK) on ae.AssetM_Id=ad.AssetM_ID
							where ad.Cmp_ID=@Cmp_ID and isnull(Dept_Name,'') <>'' and (ISNULL(ae.Transfer_Dept_Id,0) >0 or ISNULL(ae.Dept_Id,0)>0)
							and (ae.Transfer_Dept_Id =isnull(@Dept_Id,ae.Transfer_Dept_Id) or ae.Dept_Id =isnull(@Dept_Id,ae.Dept_Id))
							and ae.Emp_Id=0 and ad.Asset_Code=ISNULL(@Asset_Code1,ad.Asset_Code)
							and BRANCH_FOR_DEPT_ID IN (select Data from dbo.Split(ISNULL(@Branch_Id,ISNULL(BRANCH_FOR_DEPT_ID,0)), '#') PB Where PB.Data <> '')
							order by substring(ae.asset_code,0, charindex('/',ae.asset_code)) + '/' + 
							right('0000000' + substring(ae.asset_code,charindex('/',ae.asset_code)+1, len(ae.asset_code)), 7)
						END  
					end
