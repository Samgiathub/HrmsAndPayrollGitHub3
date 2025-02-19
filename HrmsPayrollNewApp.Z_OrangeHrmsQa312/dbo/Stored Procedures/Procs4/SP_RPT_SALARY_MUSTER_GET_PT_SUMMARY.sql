


-- =============================================
-- Author:		<Ankit>
-- Create date: <13-11-2013>
-- Description:	<Description,,>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================


CREATE  PROCEDURE [dbo].[SP_RPT_SALARY_MUSTER_GET_PT_SUMMARY]            
 @Cmp_ID  numeric      
,@From_Date  datetime      
,@To_Date  datetime      
,@Branch_ID  numeric      
,@Cat_ID  numeric       
,@Grd_ID  numeric      
,@Type_ID  numeric      
,@Dept_ID  numeric      
,@Desig_ID  numeric      
,@Emp_ID  numeric      
,@constraint  varchar(5000)   
,@Sal_Type  numeric = 0
,@PBranch_ID varchar = '0'
,@Salary_Cycle_id numeric = 0	 -- Added By Gadriwala Muslim 21082013
,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 21082013
,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013
,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 21082013	
,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013	

AS      
 
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
  
    if @Salary_Cycle_id = 0  -- Added By Gadriwala Muslim 21082013
	set @Salary_Cycle_id = NULL
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubBranch_Id = null	
   

		  Declare @Sal_St_Date   Datetime    
		  Declare @Sal_end_Date   Datetime  
		  
			If @Branch_ID is null
				Begin 
					select Top 1 @Sal_St_Date  = Sal_st_Date 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
				End
			Else
				Begin
					select @Sal_St_Date  =Sal_st_Date 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
				End    
		       
		 if isnull(@Sal_St_Date,'') = ''    
			begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			end     
		 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
			begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			end     
		 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
			begin    
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
			   set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_end_Date   
			End

      
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
      
   select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join       
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment  WITH (NOLOCK)    
     where Increment_Effective_date <= @To_Date      
     and Cmp_ID = @Cmp_ID      
     group by emp_ID  ) Qry on      
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date       
             
   Where Cmp_ID = @Cmp_ID       
   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))				 -- Added By Gadriwala Muslim 21082013
   and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))			 -- Added By Gadriwala Muslim 21082013
   and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))	 -- Added By Gadriwala Muslim 21082013
   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0))		 -- Added By Gadriwala Muslim 21082013
  
   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)       
   and I.Emp_ID in       
    ( select Emp_Id from      
    (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry      
    where cmp_ID = @Cmp_ID   and        
    (( @From_Date  >= join_Date  and  @From_Date <= left_date )       
    or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
    or Left_date is null and @To_Date >= Join_Date)      
    or @To_Date >= left_date  and  @From_Date <= left_date )       
         
  end       
      
 --------      
 --Declare @PT_Challan Table
	--  ( 
	--	Cmp_ID		numeric ,
	--	Branch_ID 		numeric ,
	--	PT_L_T_Limit  	varchar(50),
	--	A_PT_Amount		numeric default 0,
	--	PT_Amount		numeric default 0,
	--	P_month		numeric ,
	--	P_Year		numeric,
	--	PT_calculated_Amount  numeric	default 0,
	--	Emp_Count	numeric default 0 ,
	--	PT_NA       numeric default 0,
	--	Total_PT    numeric default 0
		
	--  )	
							  
									
							  
	--	insert into @PT_Challan (Cmp_Id,Branch_Id,A_PT_Amount,PT_L_T_Limit,P_Month,P_Year)
	--	select distinct p.Cmp_ID,p.Branch_ID ,Amount ,cast(From_Limit as varchar(20)) + '-' +  cast(To_Limit as varchar(20))  ,Month(@To_Date) ,year(@To_Date)

	--	from T0040_professional_setting p inner join 
	--	( select max(for_Date)For_Date ,Branch_ID from T0040_professional_setting 
	--		where Cmp_ID =@cmp_ID and (Branch_ID = ISNULL(@Branch_ID,Branch_ID) or isnull(Branch_ID,0) = 0 ) and For_Date <= @To_Date      --add branch_Id,For_date condition Mihir 06092011 -- branch condition altered by mitesh on 23072012
	--	group by branch_ID) q on p.For_Date = q.for_Date and isnull(p.Branch_ID,0) = isnull(q.Branch_ID,0)
	--	Where p.Cmp_Id =@Cmp_ID and isnull(P.Branch_ID,0) = isnull(q.Branch_ID,0)

	--	--from dbo.T0040_professional_setting p where Cmp_ID = @Cmp_ID and isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0))
	--	--	and For_date = (
	--	--	select max(For_Date) from dbo.T0040_professional_setting where Cmp_ID = @Cmp_ID and For_Date <=@ And isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0)) and month(for_date) <= month(@for_date))
		 
				

	--	update @PT_Challan 
	--	set PT_Amount = q.Sum_PT_Amount ,
	--		PT_calculated_Amount = q.sum_PT_calculated_Amount,
	--		Emp_Count = q.Emp_Count
	--	From @PT_Challan  P inner join 
	--		( Select Branch_Id,count(ms.emp_Id)Emp_Count,PT_Amount,sum(PT_Amount) Sum_PT_Amount,Sum(PT_calculated_Amount ) sum_PT_calculated_Amount 
	--			From	T0200_MONTHLY_SALARY ms inner join T0095_Increment I on ms.Increment_ID =i.Increment_ID 
	--			inner join @emp_Cons ec on ms.emp_ID = ec.emp_ID 
	--			Where Month_St_date >=@From_Date and Month_End_Date <=@To_Date
	--			group by Branch_ID ,PT_Amount) q on p.Branch_ID =q.Branch_ID and p.A_PT_Amount = q.PT_Amount
	--	Where  isnull(p.Branch_ID,0) >0 			

	-- 	update @PT_Challan 
	--	set PT_Amount = q.Sum_PT_Amount ,
	--		PT_calculated_Amount = q.sum_PT_calculated_Amount,
	--		Emp_Count = q.Emp_Count
	--	From @PT_Challan  P inner join 
	--		( Select PT_Amount,count(ms.emp_Id)Emp_Count,sum(PT_Amount) Sum_PT_Amount,Sum(PT_calculated_Amount ) sum_PT_calculated_Amount 
	--			From	T0200_MONTHLY_SALARY ms inner join T0095_Increment I on ms.Increment_ID =i.Increment_ID 
	--			inner join @emp_Cons ec on ms.emp_ID = ec.emp_ID 
	--			Where Month_St_date >=@From_Date and Month_End_Date <=@To_Date 
	--			group by PT_Amount) q on isnull(p.Branch_ID,0) =0 and p.A_PT_Amount = q.PT_Amount
	--	Where  isnull(p.Branch_ID,0) =0
		
		
	--	update @PT_Challan 
	--	set  PT_NA = q.PT_NA
	--	From @PT_Challan  P inner join 
	--		(Select count(ms.Emp_ID) PT_NA 
	--			From	T0200_MONTHLY_SALARY ms inner join T0095_Increment I on ms.Increment_ID =i.Increment_ID 
	--			inner join @emp_Cons ec on ms.emp_ID = ec.emp_ID 
	--			Where Month_St_date >=@From_Date and Month_End_Date <=@To_Date
	--			group by PT_Amount) q on isnull(p.Branch_ID,0) =0 and p.A_PT_Amount = 0
	--	Where  isnull(p.Branch_ID,0) =0
		
		

	--select p.* ,Branch_NAme,Cmp_Phone,Cmp_Address,Cmp_Name,@From_Date as Month_Start_Date,
	--	@To_Date as Month_End_Date,(select [dbo].[F_Number_TO_Word](sum(PT_Amount)) from @PT_Challan) as Total_PT_inWord ,BM.Branch_ID 
	--from @PT_Challan	p left outer Join T0030_Branch_MAster bm  on p.Branch_ID = bm.Branch_ID
	--Inner join T0010_COMPANY_MASTER CM  on p.Cmp_Id = cm.Cmp_ID 
	
	
Select PT_Amount as A_PT_Amount,count(ms.emp_Id)Emp_Count,sum(PT_Amount) PT_Amount,Sum(PT_calculated_Amount ) sum_PT_calculated_Amount 
From	T0200_MONTHLY_SALARY ms WITH (NOLOCK) -- inner join T0095_Increment I on ms.Increment_ID =i.Increment_ID 
Where Month_St_date >=@From_Date and Month_End_Date <=@To_Date
And ms.Emp_Id In (select Emp_ID from @Emp_Cons)
group by PT_Amount

			    
			    
RETURN
