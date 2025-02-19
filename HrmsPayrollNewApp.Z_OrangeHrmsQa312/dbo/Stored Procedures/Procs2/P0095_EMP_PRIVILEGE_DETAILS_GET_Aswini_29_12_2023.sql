
  
-- =============================================  
-- Author:  Jaina  
-- Create date: 16-Nov-2015  
-- Description: To retrieve the data for Employee latest Privilege .  
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
-- =============================================  
create PROCEDURE [dbo].[P0095_EMP_PRIVILEGE_DETAILS_GET_Aswini_29/12/2023]  
 @Cmp_ID numeric=0,  
 @Branch_ID varchar(max) = '',   
 @Emp_Id Numeric=0,  
 @Desig_ID numeric=0,  
 @Dept_ID varchar(max) = '',   
 @Grd_ID numeric=0,  
 @Vertical_ID varchar(max) = '',   
 @SubVertical_ID varchar(max) = '',  
 
 @Category varchar(max) ='',	   --added by ronakk 09022022
 @SalarCycle varchar(max)='',	   --added by ronakk 09022022
 @BussinessSgmt varchar(max)='',   --added by ronakk 09022022
 @SubBranch varchar(max)='',	   --added by ronakk 09022022
 @Band varchar (max)='',		   --added by ronakk 09022022
 @EmpType varchar(max)='',		   --added by ronakk 09022022


 @Status numeric=0,  
 @PageNo BigInt = 0,  
 @OrderBy VARCHAR(250) = '' --Mukti(23062017)  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
DECLARE @GroupSize INT --= 0  
DECLARE @COUNT INT;  
DECLARE @strquery as NVARCHAR(MAX) = ''--Mukti(23062017)  
  
SET @GroupSize = 0  --changed jimit 18042016  
  
if @Branch_ID = '0' or @Branch_ID=''    
  set @Branch_ID = null  
  
 if @Dept_ID = '0' or  @Dept_ID=''    
  set @Dept_ID = null   
  
IF @Vertical_ID='0' or @Vertical_ID=''  
 set @Vertical_ID = NULL  

 if @SubVertical_ID='0' or @SubVertical_ID=''  
 set @SubVertical_ID=NULL  
   
 if @Grd_ID = 0      
  set @Grd_ID = null      
 If @Desig_ID = 0      
  set @Desig_ID = null   
   
 IF @Emp_Id = 0  
  SET @Emp_Id = NULL;     
 IF @Status = 0  
  set @Status= NULL;  



  --Added By ronakk 09022022

  if @Category = '0' or @Category=''    
  set @Category = null    
  
  if @SalarCycle = '0' or @SalarCycle=''    
  set @SalarCycle = null     

   if @BussinessSgmt = '0' or @BussinessSgmt=''    
  set @BussinessSgmt = null     

  if @SubBranch = '0' or @SubBranch=''    
  set @SubBranch = null     

   if @Band = '0' or @Band=''    
  set @Band = null     

   if @EmpType = '0' or @EmpType=''    
  set @EmpType = null   



  --End By Ronak 09022022



  
 if @Branch_ID is null  
 Begin   
  select   @Branch_ID = COALESCE(@Branch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID    
  set @Branch_ID = @Branch_ID + ',0'  
 End  
   

 if @Vertical_ID is null  
 Begin   
  select   @Vertical_ID = COALESCE(@Vertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID     
    
  If @Vertical_ID IS NULL  
   set @Vertical_ID = '0';  
  else  
   set @Vertical_ID = @Vertical_ID + ',0'  
 End  


 if @subVertical_ID is null  
 Begin   
  select   @subVertical_ID = COALESCE(@subVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID   
    
  If @subVertical_ID IS NULL  
   set @subVertical_ID = '0';  
  else  
   set @subVertical_ID = @subVertical_ID + ',0'  
     
 End  
   
   
 if @Dept_ID is null  
 Begin   
  select   @Dept_ID = COALESCE(@Dept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_ID   
    
  If @Dept_ID IS NULL  
   set @Dept_ID = '0';  
  else  
   set @Dept_ID = @Dept_ID + ',0'  
 End  
   


-- Added By Ronakk 09022022

if @Category is null  
 Begin 
 
  select   @Category = COALESCE(@Category + ',', '') + cast(Cat_ID as nvarchar(5))  from T0030_Category_Master WITH (NOLOCK) where cmp_ID=@Cmp_ID   
    
  If @Category IS NULL  
   set @Category = '0';  
  else  
   set @Category = @Category + ',0'  
 End  


 if @BussinessSgmt is null  
 Begin 
 
  select   @BussinessSgmt = COALESCE(@BussinessSgmt + ',', '') + cast(Segment_ID as nvarchar(5))  from T0040_Business_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID   
    
  If @BussinessSgmt IS NULL  
   set @BussinessSgmt = '0';  
  else  
   set @BussinessSgmt = @BussinessSgmt + ',0'  
 End  

 if @SubBranch is null  
 Begin 
 
  select   @SubBranch = COALESCE(@SubBranch + ',', '') + cast(SubBranch_ID as nvarchar(5))  from T0050_SubBranch WITH (NOLOCK) where Cmp_ID=@Cmp_ID   
    
  If @SubBranch IS NULL  
   set @SubBranch = '0';  
  else  
   set @SubBranch = @SubBranch + ',0'  
 End  


  if @EmpType is null  
 Begin 
 
  select   @EmpType = COALESCE(@EmpType + ',', '') + cast(Type_ID as nvarchar(5))  from T0040_TYPE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID   
    
  If @EmpType IS NULL  
   set @EmpType = '0';  
  else  
   set @EmpType = @EmpType + ',0'  
 End  


  if @Band is null  
 Begin 
 
  select   @Band = COALESCE(@Band + ',', '') + cast(BandId as nvarchar(5))  from tblBandMaster WITH (NOLOCK) where Cmp_Id=@Cmp_ID   
    
  If @Band IS NULL  
   set @Band = '0';  
  else  
   set @Band = @Band + ',0'  
 End  


 if @SalarCycle is null  
 Begin 
 
  select   @SalarCycle = COALESCE(@SalarCycle + ',', '') + cast(Tran_Id as nvarchar(5))  from T0040_Salary_Cycle_Master WITH (NOLOCK) where Cmp_id=@Cmp_ID   
    
  If @SalarCycle IS NULL  
   set @SalarCycle = '0';  
  else  
   set @SalarCycle = @SalarCycle + ',0'  
 End  


--End By Ronak 09022022






  Create Table #temp_privilege   
  (  
   FROM_DATE varchar(500),  
   PRIVILEGE_ID Numeric,  
   Cmp_ID numeric,  
   Login_ID numeric,  
   Emp_Full_Name varchar(5000),  
   Alpha_Emp_Code varchar(500),  
   PRIVILEGE_NAME varchar(500),  
   PRIVILEGE_TYPE varchar(500),  
   Branch_ID numeric,  
   Grd_ID numeric,  
   Desig_Id numeric,  
   Dept_ID numeric,  
   Trans_Id numeric,  
   Emp_ID numeric,  
   Vertical_ID numeric,  
   SubVertical_ID numeric,

   Cat_ID numeric, --Added By Ronakk09022022
   Segment_ID numeric, --Added By Ronakk09022022
   subBranch_ID numeric, --Added By Ronakk09022022
   Band_Id numeric, --Added By Ronakk09022022
   Type_ID numeric, --Added By Ronakk09022022
   SalCycle_Id numeric, --Added By Ronakk09022022

   Effective_Date varchar(500),  
   Emp_First_Name varchar(500)  
  );  
  

  ------------------ Add By Jigensh Patel 11-Apr-2022--------------
IF OBJECT_ID(N'tempdb..#temp_MasterData') IS NOT NULL
BEGIN
DROP TABLE #temp_MasterData
END

  Create table #temp_MasterData
  (
   Id   Int,
   Table_Name varchar(50)
  )

  CREATE NONCLUSTERED INDEX ix_temp_MasterDataID ON #temp_MasterData (Id,Table_Name);

	Insert into #temp_MasterData(Id,Table_Name)
	select cast(Data as Int),'Branch' from dbo.Split(@Branch_ID, ',')    
	union all
	select cast(Data as Int),'Vertical' from dbo.Split(@Vertical_ID, ',')  
	union all
	select cast(Data as Int),'SubVertical' from dbo.Split(@SubVertical_ID, ',')    
	union all
	select cast(Data as Int),'Dept' from dbo.Split(@Dept_ID, ',')  
	union all
	select cast(Data as Int),'Category' from dbo.Split(@Category, ',')  
	union all
	select cast(Data as Int),'BussinessSgmt' from dbo.Split(@BussinessSgmt, ',') 
	union all
	select cast(Data as Int),'SubBranch' from dbo.Split(@SubBranch, ',') 
	union all
	select cast(Data as Int),'EmpTyp' from dbo.Split(@EmpType, ',') 
	union all
	select cast(Data as Int),'Band' from dbo.Split(@Band, ',') 
	union all
	select cast(Data as Int),'SalarCycle' from dbo.Split(@SalarCycle, ',') 
--------------------- End -----------------------


 INSERT INTO #temp_privilege (FROM_DATE,PRIVILEGE_ID,Cmp_ID,Login_ID,Emp_Full_Name,Alpha_Emp_Code,PRIVILEGE_NAME,  
         PRIVILEGE_TYPE,Branch_ID,Grd_ID,Desig_Id,Dept_ID,Trans_Id,Emp_ID,Vertical_ID,SubVertical_ID,
		 Cat_ID,Segment_ID,subBranch_ID,Band_Id,Type_ID,SalCycle_Id,
		 Effective_Date,Emp_First_Name)  
 SELECT  PD.FROM_DATE,PD.PRIVILEGE_ID,PD.Cmp_ID,PD.Login_ID,PD.Emp_Full_Name,PD.Alpha_Emp_Code,PD.PRIVILEGE_NAME,  
   PD.PRIVILEGE_TYPE,PD.Branch_ID,PD.Grd_ID,PD.Desig_Id,PD.Dept_ID,PD.Trans_Id,PD.Emp_ID,PD.Vertical_ID,  
   PD.SubVertical_ID,PD.Cat_ID,PD.Segment_ID,PD.subBranch_ID,PD.Band_Id,PD.Type_ID,PD.SalDate_id,
   pd.Effective_Date,PD.Emp_First_Name  FROM V0090_EMP_PRIVILEGE_DETAILS as PD
	inner join (SELECT MAX(Effective_Date) as Effective_Date, emp_id, Cmp_ID FROM V0090_EMP_PRIVILEGE_DETAILS
				where Effective_Date<= getdate()  Group By Emp_ID, Cmp_ID) mytemp ON PD.Emp_ID = mytemp.Emp_ID   
									AND PD.Effective_Date =mytemp.Effective_Date AND PD.Cmp_ID=mytemp.Cmp_ID  

	------------- add by jigensh patel 11-Apr-2022-----------------
	left outer join (select id from #temp_MasterData where Table_Name='Branch') B On B.Id=Isnull(PD.Branch_ID,0)
	left outer join (select id from #temp_MasterData where Table_Name='Vertical') V On V.Id=Isnull(PD.Vertical_ID,0)
	left outer join (select id from #temp_MasterData where Table_Name='SubVertical') S On S.Id=Isnull(PD.SubVertical_ID,0)
	left outer join (select id from #temp_MasterData where Table_Name='Dept') D On D.Id=Isnull(PD.Dept_ID,0)
	left outer join (select id from #temp_MasterData where Table_Name='Category')C On C.Id=Isnull(PD.Cat_ID,0)
	left outer join (select id from #temp_MasterData where Table_Name='BussinessSgmt') BS On BS.Id=Isnull(PD.Segment_ID,0)
	left outer join (select id from #temp_MasterData where Table_Name='SubBranch') SB On SB.Id=Isnull(PD.subBranch_ID,0)
	left outer join (select id from #temp_MasterData where Table_Name='EmpTyp') ET On ET.Id=Isnull(PD.Type_ID,0)
	left outer join (select id from #temp_MasterData where Table_Name='Band') BM On BM.Id=Isnull(PD.Band_Id,0)
	left outer join (select id from #temp_MasterData where Table_Name='SalarCycle') SC On SC.Id=Isnull(PD.SalDate_id,0)
	-------------------End --------------------------------

    Where PD.Cmp_ID = @Cmp_ID and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
       and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
      and Isnull(mytemp.Emp_ID,0) = COALESCE(@Emp_Id ,mytemp.Emp_ID,0)   
    --and ISNULL(PD.PRIVILEGE_ID,0)= ISNULL(@Status, ISNULL(PD.PRIVILEGE_ID,0))  
	
	
	------------------------ Comment By Jignesh Patel 11-Apr-2022-----------------
	/*
    and EXISTS (select Data from dbo.Split(@Branch_ID, ',') B Where cast(B.data as numeric)=Isnull(PD.Branch_ID,0))    
    and EXISTS (select Data from dbo.Split(@Vertical_ID, ',') V Where cast(v.data as numeric)=Isnull(PD.Vertical_ID,0))  
    and EXISTS (select Data from dbo.Split(@SubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(PD.SubVertical_ID,0))  
    and EXISTS (select Data from dbo.Split(@Dept_ID, ',') D Where cast(D.data as numeric)=Isnull(PD.Dept_ID,0))   
	and EXISTS (select Data from dbo.Split(@Category, ',') C Where cast(C.data as numeric)=Isnull(PD.Cat_ID,0))  			--Added by ronakk 09022022
	and EXISTS (select Data from dbo.Split(@BussinessSgmt, ',') BS Where cast(BS.data as numeric)=Isnull(PD.Segment_ID,0))	--Added by ronakk 09022022
	and EXISTS (select Data from dbo.Split(@SubBranch, ',') SB Where cast(SB.data as numeric)=Isnull(PD.subBranch_ID,0))	--Added by ronakk 09022022
	and EXISTS (select Data from dbo.Split(@EmpType, ',') ET Where cast(ET.data as numeric)=Isnull(PD.Type_ID,0))			--Added by ronakk 09022022
	and EXISTS (select Data from dbo.Split(@Band, ',') BM Where cast(BM.data as numeric)=Isnull(PD.Band_Id,0))				--Added by ronakk 09022022
	and EXISTS (select Data from dbo.Split(@SalarCycle, ',') SC Where cast(SC.data as numeric)=Isnull(PD.SalDate_id,0))		--Added by ronakk 09022022
    */
	---------------- End -------------------------
  

 DELETE FROM #temp_privilege  
 WHERE PRIVILEGE_ID <>  COALESCE(@Status, PRIVILEGE_ID)  
    --For Paging  
      
IF @PageNo <> 0   
 Begin  
      
   SELECT @COUNT = COUNT(1) FROM #temp_privilege  
  
   SET @GroupSize  = Cast(@COUNT / 15 As Int);  
   IF ((@GroupSize * 15) < @COUNT)  
    SET @GroupSize = @GroupSize + 1;  
     
     
   --;WITH TEMP(PageNo,FROM_DATE,PRIVILEGE_ID,Cmp_ID,Login_ID,Emp_Full_Name,Alpha_Emp_Code,PRIVILEGE_NAME,  
   --     PRIVILEGE_TYPE,Branch_ID,Grd_ID,Desig_Id,Dept_ID,Trans_Id,Emp_ID,Vertical_ID,  
   --     SubVertical_ID,Effective_Date) AS  
   --(   
   -- SELECT TOP (@PageNo * 15) NTILE(@GroupSize) OVER (Order By Emp_ID) As PageNo,FROM_DATE,PRIVILEGE_ID,Cmp_ID,Login_ID,Emp_Full_Name,Alpha_Emp_Code,PRIVILEGE_NAME,  
   --         PRIVILEGE_TYPE,Branch_ID,Grd_ID,Desig_Id,Dept_ID,Trans_Id,Emp_ID,Vertical_ID,  
   --         SubVertical_ID,Effective_Date  
   -- FROM #temp_privilege  
   --)    
   --Select @COUNT As Total,* FROM TEMP WHERE PageNo = @PageNo   
   --Added by Mukti(26062017)start  
  
   ;WITH TEMP(PageNo,FROM_DATE,PRIVILEGE_ID,Cmp_ID,Login_ID,Emp_Full_Name,Alpha_Emp_Code,PRIVILEGE_NAME,  
        PRIVILEGE_TYPE,Branch_ID,Grd_ID,Desig_Id,Dept_ID,Trans_Id,Emp_ID,Vertical_ID,  
        SubVertical_ID,Effective_Date,Emp_First_Name) AS  
   (   
    SELECT TOP (@PageNo * 15) NTILE( @GroupSize ) OVER (Order By Emp_ID) As PageNo,FROM_DATE,PRIVILEGE_ID,Cmp_ID,Login_ID,Emp_Full_Name,Alpha_Emp_Code,PRIVILEGE_NAME,  
            PRIVILEGE_TYPE,Branch_ID,Grd_ID,Desig_Id,Dept_ID,Trans_Id,Emp_ID,Vertical_ID,  
            SubVertical_ID,Effective_Date,Emp_First_Name  
    FROM #temp_privilege  
   )    
   Select cast(@COUNT as varchar(10)) As Total,* INTO #TMP_PRIV FROM TEMP WHERE PageNo = @PageNo  
    
   --SET @strquery = ';WITH TEMP(PageNo,FROM_DATE,PRIVILEGE_ID,Cmp_ID,Login_ID,Emp_Full_Name,Alpha_Emp_Code,PRIVILEGE_NAME,  
   --     PRIVILEGE_TYPE,Branch_ID,Grd_ID,Desig_Id,Dept_ID,Trans_Id,Emp_ID,Vertical_ID,  
   --     SubVertical_ID,Effective_Date,Emp_First_Name) AS  
   --(   
   -- SELECT TOP ('+ Cast(@PageNo as varchar(10)) +' * 15) NTILE('+ Cast(@GroupSize as varchar(10)) +') OVER (Order By Emp_ID) As PageNo,FROM_DATE,PRIVILEGE_ID,Cmp_ID,Login_ID,Emp_Full_Name,Alpha_Emp_Code,PRIVILEGE_NAME,  
   --         PRIVILEGE_TYPE,Branch_ID,Grd_ID,Desig_Id,Dept_ID,Trans_Id,Emp_ID,Vertical_ID,  
   --         SubVertical_ID,Effective_Date,Emp_First_Name  
   -- FROM #temp_privilege  
   --)    
   --Select ' + cast(@COUNT as varchar(10)) +' As Total,* FROM TEMP WHERE PageNo = ' + Cast(@PageNo as varchar(10)) +' Order By ' + @OrderBy + ''  
   if @OrderBy <> '' 
   print 111
    SET @OrderBy = 'Order By ' + @OrderBy  
     
   SET @strquery = 'SELECT * FROM #TMP_PRIV ' + @OrderBy  
   print @strquery  
   EXECUTE (@strquery);  
   --Added by Mukti(26062017)end  
 END  
Else  
 Begin  
  if @OrderBy <> ''  
    SET @OrderBy = 'Order By ' + @OrderBy  
  SET @strquery = 'Select * from #temp_privilege ' + @OrderBy  
  EXEC(@strquery)  
 End  
  
  
  
  