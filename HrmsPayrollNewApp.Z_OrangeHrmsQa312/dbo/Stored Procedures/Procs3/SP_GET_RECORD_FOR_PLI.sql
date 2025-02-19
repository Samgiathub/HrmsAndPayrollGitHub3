



---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_RECORD_FOR_PLI]  
  @Cmp_ID  numeric  
 ,@From_Date  datetime  
 ,@To_Date  datetime   
 ,@Branch_ID  numeric   = 0  
 ,@Cat_ID  numeric  = 0  
 ,@Grd_ID  numeric = 0  
 ,@Type_ID  numeric  = 0  
 ,@Dept_ID  numeric  = 0  
 ,@Desig_ID  numeric = 0  
 ,@Emp_ID  numeric  = 0  
 ,@Constraint varchar(5000) = ''  
 ,@Per_Inc_tran_ID numeric(18,0)=0  
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
 if @Emp_ID = 0  
  set @Emp_ID = null  
    
 If @Desig_ID = 0  
  set @Desig_ID = null  
    
 if @Per_Inc_tran_ID = 0  
  set @Per_Inc_tran_ID=null  
   
 Declare @Emp_Cons Table  
 (  
  Emp_ID numeric  
 )  
   
 Declare @Emp_PLI_Details Table  
 (  
  Emp_ID numeric(18,0),  
  Per_inc_tran_id numeric(18,0),  
  per_points numeric(18,0),  
  Out_of_points numeric(18,0),  
  for_date datetime  
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
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  
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
    or @To_Date >= left_date  and  @From_Date <= left_date )   
     
  end  
 declare @Emp_ID_Cur numeric(18,0)    
 declare Curemp_per cursor for  
 select Emp_ID from @Emp_Cons order by Emp_Id  
 open Curemp_per    
  fetch next from Curemp_per into @Emp_ID_Cur  
  while @@fetch_status = 0  
   begin   
     
         
      declare @Per_inc_tran_ID_Cur numeric(18,0)    
      declare @Per_inc_points  numeric(18,0)  
      declare @Per_inc_Out_points  numeric(18,0)  
      declare @For_Date datetime  
      set @Per_inc_points=0  
      set @Per_inc_Out_points=0  
        
      declare Cur_emp_per_inc_tran cursor for  
      select per_inc_tran_id,isnull(PERCENTAGE,0),isnull(OUT_OF_PER,0),for_date from t0100_EMp_performance_detail WITH (NOLOCK) where Emp_ID = @Emp_ID_Cur  
                        and for_date >=@From_Date and for_date <=@To_date and Isnull(per_inc_tran_ID,0) = isnull(@per_inc_tran_ID,Isnull(per_inc_tran_ID,0)) order by per_inc_tran_ID   
      open Cur_emp_per_inc_tran    
         fetch next from Cur_emp_per_inc_tran into @Per_inc_tran_ID_Cur,@Per_inc_points,@Per_inc_Out_points,@For_Date  
         while @@fetch_status = 0  
          begin   
             if Not Exists(select Emp_ID from @Emp_PLI_Details where Emp_ID=@Emp_ID_Cur)  
           Begin  
            insert into @Emp_PLI_Details  
            select @Emp_ID_Cur,Per_inc_tran_id,null,null,getdate() from t0040_performance_incentive_master WITH (NOLOCK) where Cmp_ID=@cmp_id  
           End  
            
   if exists (select Per_inc_tran_id from @Emp_PLI_Details where Per_inc_tran_id=@Per_inc_tran_ID_Cur and Emp_ID=@Emp_ID_Cur)  
            Begin  
               update @Emp_PLI_Details set   
               per_points=isnull(per_points,0)+@Per_inc_points  
               ,Out_of_points=isnull(Out_of_points,0)+@Per_inc_Out_points where   
               Emp_ID=@Emp_ID_Cur And Per_inc_tran_id=@Per_inc_tran_ID_Cur  
            End  
          else  
            
            BEgin  
             insert into @Emp_PLI_Details values(@Emp_ID_Cur,@Per_inc_tran_ID_Cur,@Per_inc_points,@Per_inc_Out_points,@For_Date)  
            End  
     
         fetch next from Cur_emp_per_inc_tran into @Per_inc_tran_ID_Cur,@Per_inc_points,@Per_inc_Out_points,@For_Date  
        end  
      close Cur_emp_per_inc_tran  
      deallocate Cur_emp_per_inc_tran     
       
     
   fetch next from Curemp_per into @Emp_ID_Cur  
   end  
 close Curemp_per  
 deallocate Curemp_per  
    
  select EPD.*,Per_name,GM.grd_name,desig_name,dept_name,branch_name,branch_address,cmp_name,cmp_address,@From_Date as From_date,@To_Date as To_Date,
	E.emp_Code,E.Emp_Full_Name  
    from @Emp_PLI_Details EPD inner join t0040_performance_incentive_master PIM WITH (NOLOCK) 
    on EPD.Per_inc_tran_id = PIM.Per_inc_tran_id inner join t0080_emp_master E WITH (NOLOCK)  
    on EPD.Emp_ID=E.Emp_ID inner join t0010_company_master CM  WITH (NOLOCK) 
    on E.Cmp_ID = Cm.Cmp_id inner join       
    T0040_GRADE_MASTER GM WITH (NOLOCK) ON E.Grd_ID = GM.Grd_ID LEFT OUTER JOIN  
    T0040_TYPE_MASTER ETM WITH (NOLOCK) ON E.Type_ID = ETM.Type_ID LEFT OUTER JOIN  
    T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON E.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN  
    T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON E.Dept_Id = DM.Dept_Id INNER JOIN   
    T0030_BRANCH_MASTER BM WITH (NOLOCK) ON E.BRANCH_ID = BM.BRANCH_ID   
   where Isnull(EPD.per_inc_tran_ID,0) = isnull(@per_inc_tran_ID,Isnull(EPD.per_inc_tran_ID,0))   
 return




