

-- =============================================
-- Author:		Ripal Patel
-- Create date: 27 Jan 2014
-- Description:	
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_OpHoliday_RECORD_GET]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@Constraint	varchar(max) = ''
AS
BEGIN
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
	  
	
Create Table #Emp_Cons    
 (        
  Emp_ID numeric        
 )        
         
 if @Constraint <> ''        
  begin
        
   Insert Into #Emp_Cons        
   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')
   
  end        
 else        
  begin
      
   Insert Into #Emp_Cons
   select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join         
     ( select max(Increment_id) as Increment_id , Emp_ID from T0095_Increment WITH (NOLOCK)       
		 where Increment_Effective_date <= @To_Date        
		 and Cmp_ID = @Cmp_ID        
		 group by emp_ID  ) Qry on        
     I.Emp_ID = Qry.Emp_ID and I.Increment_id = Qry.Increment_id
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
		(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK) ) qry        
		where cmp_ID = @Cmp_ID   and          
		(( @From_Date  >= join_Date  and  @From_Date <= left_date )         
		or ( @To_Date  >= join_Date  and @To_Date <= left_date )        
		or Left_date is null and @To_Date >= Join_Date)        
		or @To_Date >= left_date  and  @From_Date <= left_date )         
       
  end
  
  --Added by Jaina 15-09-2016
	DECLARE @Optional_Holiday_caption as Varchar(20)	
	SELECT @Optional_Holiday_caption = Isnull(Alias,'Optional Holiday') from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and SortingNo = 93
  
	
  select  Em.Alpha_Emp_Code,
		  Em.Emp_Full_Name as Emp_Name,   --Added By Jimit 12102018
		  EM.Alpha_Emp_Code + '-' + EM.Emp_Full_Name Emp_Full_Name,EM.Emp_ID,HM.Hday_Name,
		  Convert(varchar(20),OHAPR.Op_Holiday_Apr_Date,103) Op_Holiday_Apr_Date,
		  Convert(varchar(20),HM.H_From_Date,103) H_From_Date,
		  Convert(varchar(20),HM.H_To_Date,103) H_To_Date,
		   OHAPR.Op_Holiday_Apr_Status,
		 Case when OHAPR.Op_Holiday_Apr_Status = 'A' then 'Approved' When OHAPR.Op_Holiday_Apr_Status = 'R' then 'Rejected' end as Apr_Status,
	     CM.Cmp_Name,CM.cmp_logo,CM.Cmp_Address,@From_Date as From_Date,@To_Date as To_Date,
		 --,EM.Alpha_Emp_Code,
		 Em.Emp_First_Name,Em.Branch_Name,Em.Branch_ID  --added jimit 15062015
		 ,@Optional_Holiday_caption As Caption  --Added By Jaina 15-09-2016
		 from T0120_Op_Holiday_Approval OHAPR WITH (NOLOCK) inner join
			  T0100_OP_Holiday_Application OHAPP WITH (NOLOCK) on OHAPR.Op_Holiday_App_ID = OHAPP.Op_Holiday_App_ID inner join
			  T0040_HOLIDAY_MASTER HM WITH (NOLOCK) on HM.Hday_ID = OHAPR.HDay_ID inner join
			  V0080_Employee_Details EM on EM.Emp_ID = OHAPR.Emp_ID inner join
			  T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = OHAPR.Cmp_ID 
		Where OHAPR.Cmp_ID = @Cmp_ID And OHAPR.Emp_ID in (select * from #Emp_Cons) And
			  HM.H_From_Date between @From_Date and @To_Date
  
  Drop Table #Emp_Cons
  
END


