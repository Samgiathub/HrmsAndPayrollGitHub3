  
  
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P_MOBILE_INOUT_DETAIL_GET_05052022]  
  @Cmp_ID  numeric     
 ,@Emp_ID  numeric      
 ,@From_Date  datetime        
 ,@To_Date  datetime         
 ,@Branch_ID  varchar(MAX) = ''      
 ,@Cat_ID  varchar(MAX) = ''    
 ,@Grd_ID  varchar(MAX) = ''    
 ,@Type_ID  numeric    
 ,@Dept_ID  varchar(max)=''    
 ,@Desig_ID  varchar(max)=''    
 ,@Constraint varchar(MAX) = ''    
 ,@Vertical_ID_Multi varchar(max)=''  
 ,@Subvertical_ID_Multi varchar(max)=''   
 ,@Segment_Id varchar(max)=''   
 ,@SubBranch_ID varchar(max)=''  
 ,@SortBy varchar(max) = null  
 ,@SortType varchar(max) = null  
AS  
BEGIN  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
   
 declare @Query varchar(max) = ''  
 if @Type_ID = 0        
  set @Type_ID = null   
   
 if @Emp_ID = 0        
  set @Emp_ID = null        
   
 IF @Vertical_ID_Multi='0' or @Vertical_ID_Multi=''   
 set @Vertical_ID_Multi=null   
  
 IF @Subvertical_ID_Multi='0' or @Subvertical_ID_Multi=''   
 set @Subvertical_ID_Multi=null   
    
 IF @Dept_ID='0' or @Dept_ID=''   
 set @Dept_ID=null                
   
 IF object_ID('tempdb..#Emp_Cons') is not null  
 Begin  
  drop table #Emp_Cons  
 End        
         
 CREATE table #Emp_Cons   
 (        
   Emp_ID numeric ,       
   Branch_ID numeric,  
   Increment_ID numeric  
 )        
  
 exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_ID,@Vertical_ID_Multi,@Subvertical_ID_Multi,@SubBranch_ID,0,0,0,'0',0,0                 
   
 declare @lFromDate varchar(50) = '',@lToDate varchar(50) = ''  
 select @lFromDate = convert(varchar(10), @From_Date,120)  
 select @lToDate = convert(varchar(10), @To_Date,120)  
  
 if @Constraint <> ''  
  BEGIN     
   INSERT INTO #Emp_Cons  
   SELECT cast(data  as numeric),0,0 FROM dbo.Split(@Constraint,'#') T  
    
     
   select @Query = @Query + 'select IO_Tran_DetailsID,Emp_ID,IMEI_No,In_Out_Flag,IO_Datetime,Reason,Emp_Full_Name,Alpha_Emp_Code,Location,approval_status,ManagerComment from (  
   select DISTINCT md.IO_Tran_DetailsID,md.Emp_ID,SUBSTRING(md.IMEI_No,8,15) as IMEI_No,case when md.In_Out_Flag =''I'' THEN ''In'' else ''Out'' END as In_Out_Flag,  
    md.IO_Datetime as IO_Datetime,md.Reason,em.Emp_Full_Name,em.Alpha_Emp_Code,  
    --right(md.Location, CHARINDEX('':'', REVERSE(md.Location)) - 1)as Location,  
    case when ISNULL(md.Location,'''')='''' THEN md.Location else right(md.Location, CHARINDEX('':'', REVERSE(md.Location)) - 1) END as Location,  
    md.approval_status,md.ManagerComment  
   from T9999_MOBILE_INOUT_DETAIL md WITH (NOLOCK)  
    INNER JOIN T0080_EMP_MASTER em WITH (NOLOCK) on md.Emp_ID=em.Emp_ID   
    INNER join #Emp_Cons ec on md.Emp_ID=ec.Emp_ID     
   where em.Cmp_ID=' + convert(varchar,@Cmp_ID) + '  
   and datediff(day,''' + @lFromDate + ''',md.IO_Datetime) >=0  
   and  datediff(day,md.IO_Datetime,''' + @lToDate + ''' ) >= 0  
    ) t order by '+ isnull(@SortBy,'') + ' ' + isnull(@SortType,'')
   --) t ORDER by ' + @SortBy + ' ' + @SortType  
  
   exec(@Query)  
  END  
 ELSE  
  
  BEGIN  
   select @Query = @Query + 'select IO_Tran_DetailsID,Emp_ID,IMEI_No,In_Out_Flag,IO_Datetime,Reason,Emp_Full_Name,Alpha_Emp_Code,Location,Approval_Status,ManagerComment from (  
   select DISTINCT md.IO_Tran_DetailsID,md.Emp_ID,SUBSTRING(md.IMEI_No,8,15) as IMEI_No,case when md.In_Out_Flag =''I'' THEN ''In'' else ''Out'' END as In_Out_Flag,  
    IO_Datetime,md.Reason,em.Emp_Full_Name,em.Alpha_Emp_Code,  
    --right(md.Location, CHARINDEX('':'', REVERSE(md.Location)) - 1)as Location,  
    case when ISNULL(md.Location,'''')='''' THEN md.Location else right(md.Location, CHARINDEX('':'', REVERSE(md.Location)) - 1) END as Location,  
     md.Approval_Status,md.ManagerComment  
   from T9999_MOBILE_INOUT_DETAIL md WITH (NOLOCK)  
    INNER JOIN T0080_EMP_MASTER em WITH (NOLOCK) on md.Emp_ID=em.Emp_ID  
   where em.Cmp_ID= ' + convert(varchar,@Cmp_ID) + '  
   and datediff(day,''' + @lFromDate + ''',md.IO_Datetime) >=0  
   and  datediff(day,md.IO_Datetime,''' + @lToDate + ''' ) >= 0  
    ) t order by '+ isnull(@SortBy,'') + ' ' + isnull(@SortType,'')
   --) t ORDER by ' + @SortBy + ' ' + @SortType
   
   
   exec(@Query)  
  END  
END