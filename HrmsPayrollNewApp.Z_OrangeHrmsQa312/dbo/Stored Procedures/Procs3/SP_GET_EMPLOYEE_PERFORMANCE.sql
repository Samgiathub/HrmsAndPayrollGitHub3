
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_EMPLOYEE_PERFORMANCE]  
  @Cmp_ID  numeric    
 ,@From_Date  datetime    
 ,@To_Date  datetime    
 ,@Branch_ID  numeric   = 0    
 ,@Cat_ID  numeric  = 0    
 ,@Grd_ID  numeric = 0    
 ,@Type_ID  numeric  = 0    
 ,@Dept_ID  numeric  = 0    
 ,@Desig_ID  numeric = 0    
 ,@PERFORMANCE NUMERIC(18,0)  
 ,@S_emp_id numeric(18,0)  
 ,@Employee numeric(18,0)=0  
 ,@PBranch_ID varchar(max) = ''  --Added By Jaina 29-09-2015
 ,@PVertical_ID	varchar(max)= '' --Added By Jaina 29-09-2015
 ,@PSubVertical_ID	varchar(max)= '' --Added By Jaina 29-09-2015
 ,@PDept_ID varchar(max)=''  --Added By Jaina 29-09-2015
   
AS 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

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
   
 if @S_emp_id = 0  
 set @S_emp_id = null  
  
if @Employee=0  
 set @Employee=null   
      
 If @Desig_ID = 0    
  set @Desig_ID = null    
    
 IF @PBranch_ID = '0' or @PBranch_ID='' --Added By Jaina 29-09-2015
		set @PBranch_ID = null   	

	if @PVertical_ID ='0' or @PVertical_ID = ''		--Added By Jaina 29-09-2015
		set @PVertical_ID = null

	if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	--Added By Jaina 29-09-2015
		set @PsubVertical_ID = null

	IF @PDept_ID = '0' or @PDept_Id=''  --Added By Jaina 29-09-2015
		set @PDept_ID = NULL	 


--Added By Jaina 29-09-2015 Start		
	if @PBranch_ID is null
	Begin	
		select   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @PBranch_ID = @PBranch_ID + ',0'
	End
	
	if @PVertical_ID is null
	Begin	
		select   @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		If @PVertical_ID IS NULL
			set @PVertical_ID = '0';
		else
			set @PVertical_ID = @PVertical_ID + ',0'		
	End
	if @PsubVertical_ID is null
	Begin	
		select   @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		If @PsubVertical_ID IS NULL
			set @PsubVertical_ID = '0';
		else
			set @PsubVertical_ID = @PsubVertical_ID + ',0'
	End
	IF @PDept_ID is null
	Begin
		select   @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		
		if @PDept_ID is null
			set @PDept_ID = '0';
		else
			set @PDept_ID = @PDept_ID + ',0'
	End
	--Added By Jaina 29-09-2015 End
		
	print @PVertical_ID
 DECLARE @TOTAL_OUT_OF_POINTS NUMERIC(18,0)  
 SET  @TOTAL_OUT_OF_POINTS =0  
    
 Declare @Emp_Cons Table    
 (    
   Emp_ID numeric   
 )    
   
   Insert Into @Emp_Cons    
   select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join     
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)   
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
   and Isnull(i.Emp_ID,0) = isnull(@Employee ,Isnull(i.Emp_ID,0)) 
   --Added By Jaina 14-10-2015 start   
   and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') B Where cast(B.data as numeric)=Isnull(I.Branch_ID,0))
   and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
   and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
   and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0)) 
   --Added By Jaina 14-10-2015 end
   and I.Emp_ID in     
    ( select Emp_Id from    
    (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry    
    where cmp_ID = @Cmp_ID   and      
    (( @From_Date  >= join_Date  and  @From_Date <= left_date )     
    or ( @To_Date  >= join_Date  and @To_Date <= left_date )    
    or Left_date is null and @To_Date >= Join_Date)    
    or @To_Date >= left_date  and  @From_Date <= left_date )    
    

DECLARE @DATA TABLE  
 (  
   EMP_ID        NUMERIC(18,0)  
  ,EMP_CODE      VARCHAR(25)  --Change by paras 02/07/2013   
  ,EMP_FULL_NAME VARCHAR(200)  
  ,CMP_ID        NUMERIC(18,0)  
  ,FOR_DATE      DATETIME  
  ,PERCENTAGE    NUMERIC(18,0)  
  ,OUT_OF_PER    NUMERIC(18,0)   
  ,PER_INC_TRAN_ID NUMERIC(18,0)  
 )  

SELECT @TOTAL_OUT_OF_POINTS = ISNULL(TOTAL_POINTS,0) FROM  T0040_PERFORMANCE_INCENTIVE_MASTER WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND PER_INC_TRAN_ID=@PERFORMANCE  
   

insert into @DATA  
SELECT ES.EMP_ID,EM.Alpha_Emp_Code , EM.EMP_FULL_NAME ,@CMP_ID,@FROM_DATE,0,@TOTAL_OUT_OF_POINTS,isnull(@PERFORMANCE,0)  
FROM @Emp_Cons ES INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ES.EMP_ID=EM.EMP_ID   
  

declare @per numeric(18,1)  
declare @temp_emp_id numeric(18,0)   
     
 declare curperformance cursor for                      
 select emp_id,isnull(percentage,0) from T0100_EMP_PERFORMANCE_DETAIL WITH (NOLOCK) where month(for_date)=month(@from_date) And year(for_date)=year(@from_date) AND PER_INC_TRAN_ID=@PERFORMANCE  
 open curperformance                        
  fetch next from curperformance into @temp_emp_id,@per  
                 
  while @@fetch_status = 0                      
   begin     
   
   update @DATA set PERCENTAGE = @per where emp_id= @temp_emp_id  
    
   fetch next from curperformance into @temp_emp_id,@per  
                    
   end                      
 close curperformance                      
 deallocate curperformance    
        
--Select @S_emp_id  
if @S_emp_id is null  
 Begin  
    
  SELECT DISTINCT D.*,I_Q.Branch_ID FROM @DATA D
		inner join ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
				where Increment_Effective_date <= @To_Date
				and Cmp_ID = @Cmp_ID
				group by emp_ID  ) Qry on
				I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
		on D.EMP_ID = I_Q.Emp_ID
  order by Emp_Code  
  
 end  
else  
 Begin  
    
  declare @Approve_from varchar(15)  
    
  select @Approve_from=Approve_from from t0040_performance_incentive_master WITH (NOLOCK) where per_inc_tran_id=@performance  
     
    
     
   if @Approve_from = 'MANAGER'  
		Begin  
			 SELECT DISTINCT D.*,I_Q.Branch_ID FROM @DATA D 
				inner join t0080_emp_master EM WITH (NOLOCK) on D.emp_ID=Em.emp_id 
				inner join ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
								( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
								where Increment_Effective_date <= @To_Date
								and Cmp_ID = @Cmp_ID
								group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
						on D.EMP_ID = I_Q.Emp_ID
			where emp_superior=@S_emp_id order by D.Emp_Code  
		End  
   else if @Approve_from = 'SUPERVISOR'  
		Begin  
	       
	       
			 --SELECT D.* FROM @DATA D inner join t0080_emp_master EM on D.emp_ID=Em.emp_id   
			 --inner join t0090_emp_reporting_detail erd on D.emp_id=erd.emp_id  
			 --where R_Emp_ID=@S_emp_id order by D.Emp_Code  
		     
		     
		     
			 SELECT DISTINCT D.*,I_Q.Branch_ID FROM @DATA D inner join t0080_emp_master EM WITH (NOLOCK) on D.emp_ID=Em.emp_id   
			 inner join t0090_emp_reporting_detail erd WITH (NOLOCK) on D.emp_id=erd.emp_id  
			 inner join ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
								( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
								where Increment_Effective_date <= @To_Date
								and Cmp_ID = @Cmp_ID
								group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
						on D.EMP_ID = I_Q.Emp_ID
			where R_Emp_ID=@S_emp_id order by D.Emp_Code  
			
		End  
    
 End   
        
  
        
RETURN  
  
  


