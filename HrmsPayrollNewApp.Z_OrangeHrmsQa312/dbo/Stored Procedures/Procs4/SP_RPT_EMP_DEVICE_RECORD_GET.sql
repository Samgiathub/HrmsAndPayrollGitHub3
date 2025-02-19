---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_DEVICE_RECORD_GET]    
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
 ,@Constraint varchar(MAX) = ''   -- REPLACE MAX LENGTH INSTEAD 5000 ISSUED CERA UPDATED BY RAJPUT ON 05042018
 ,@ip_address varchar(500) = ''   --Mukti 26102015 
 ,@PBranch_ID varchar(max) = ''  --Mukti 04-11-2015
 ,@PVertical_ID	varchar(max)= '' --Mukti 04-11-2015
 ,@PSubVertical_ID	varchar(max)= '' --Mukti 04-11-2015
 ,@PDept_ID varchar(max)=''  --Mukti 04-11-2015
 ,@CSV int = 0	--Krushna 15-07-2020
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
      
 if @ip_address =''
    set @ip_address=null

--Added By Mukti 04-11-2015(Start)
	IF @PBranch_ID = '0' or @PBranch_ID=''
		set @PBranch_ID = null   	

	if @PVertical_ID ='0' or @PVertical_ID = ''		
		set @PVertical_ID = null

	if @PsubVertical_ID ='0' or @PsubVertical_ID = ''
		set @PsubVertical_ID = null

	IF @PDept_ID = '0' or @PDept_Id='' 
		set @PDept_ID = NULL	 

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
--Added By Mukti 04-11-2015(end)

--Commented By Mukti 04-11-2015(Start)	
	--CREATE TABLE #Emp_Cons	-- Ankit 08092014 for Same Date Increment
	-- (      
	--   Emp_ID numeric ,     
	--   Branch_ID numeric,
	--   Increment_ID numeric    
	-- )   
	 
	-- EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint --,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
--Commented By Mukti 04-11-2015(end)	

--Added By Mukti 04-11-2015(Start)	      
 Create table #Emp_Cons 
 (    
  Emp_ID numeric    
 )    
     
     
     
 if @Constraint <> ''    
	  begin    
	   Insert Into #Emp_Cons    
	   select  cast(data  as numeric) from dbo.Split (@Constraint,'#') WHERE DATA <> ''
	  -- select * from #Emp_Cons
	  end    
 else    
  begin    
   Insert Into #Emp_Cons    
    
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
 end    
 --Added By Mukti 04-11-2015(end)
     if @CSV = 0 
		begin   
			 select I_Q.* , E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,E.Emp_Full_Name as Emp_Full_Name,CM.Cmp_Name,CM.Cmp_Address,diod.IO_Datetime,@From_Date as From_Date ,@To_Date as To_Date     
			 ,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Branch_Address,Comp_Name ,ip.device_Name,
			 diod.ip_address,   --changed By Jimit 24122018  (as per Golcha case IPaddrtess are not coming in the Report)
			 SV.SubVertical_Name,V.Vertical_Name
			 ,SB.SubBranch_Name,diod.In_Out_flag as InOutFlag
			 from t9999_device_inout_detail diod WITH (NOLOCK) inner join   	 
			 T0080_EMP_MASTER E WITH (NOLOCK) on diod.enroll_no = e.enroll_no inner join   
			 #Emp_Cons EL on E.Emp_ID =EL.Emp_ID left outer join	     
			 T0010_Company_master CM WITH (NOLOCK) on e.Cmp_ID =Cm.Cmp_ID left outer join    
			 --t0040_ip_master ip on diod.IP_Address = ip.IP_Address inner join  --- Comment by jignesh 05-01-2013 add below line  
			 (select distinct ip_address, device_Name from t0040_ip_master WITH (NOLOCK) where Cmp_ID =@Cmp_ID) as ip on diod.IP_Address = ip.IP_Address inner join    
			 (select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Vertical_Id,SubVertical_Id,SubBranch_Id from T0095_Increment I WITH (NOLOCK) inner join     
			 ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)  -- Ankit 08092014 for Same Date Increment  
			 where Increment_Effective_date <= @To_Date    
			 and Cmp_ID = @Cmp_ID    
			 group by emp_ID  ) Qry on    
			 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q     
			 on E.Emp_ID = I_Q.Emp_ID  inner join    
			 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN        
			 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN    
			 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN    
			 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Left outer JOIN     
			 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Left outer JOIN     
			 T0040_Vertical_Segment V WITH (NOLOCK) ON I_Q.Vertical_Id=v.Vertical_Id Left outer JOIN     
			 T0050_SubVertical SV WITH (NOLOCK) on I_Q.SubVertical_Id=sv.SubVertical_Id Left outer JOIN     
			 T0050_SubBranch SB WITH (NOLOCK) on I_Q.SubBranch_Id=SB.SubBranch_Id
			 WHERE E.Enroll_No = diod.Enroll_No   -- This Enroll Condition added by Mihir Adeshara as per Mr Hardik Instruction and Comment Below Condition
			 -- E.Cmp_ID = @Cmp_Id And diod.IP_Address = ip.IP_Address     
			 And (diod.IO_Datetime >= @From_Date And diod.IO_Datetime <= @To_Date + 1) And cm.Cmp_ID = @Cmp_ID    
			 And E.Emp_ID in (select Emp_ID From #Emp_Cons) and 
			 --Isnull(diod.IP_Address,'') =isnull(@IP_Address ,Isnull(diod.IP_Address,''))    --Ip_Address added by Mukti 26102015
			 EXISTS (select Data from dbo.Split(Isnull(@IP_Address,diod.IP_Address), ',') IP Where IP.data = Isnull(diod.IP_Address,'')) --Added By Jimit 05072018
			 --order by E.Emp_Code asc    
			 Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
					When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
						Else e.Alpha_Emp_Code
					End, diod.IO_DateTime
			
			 --ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) , diod.IO_DateTime
		end
	else
		begin
			select	RIGHT('00000000' + CAST(E.Enroll_No AS varchar(8)), 8) as Enroll_No
						,cast(CONVERT(VARCHAR(10),diod.IO_DateTime,103)as varchar(10)) + ' ' + cast(cast(diod.IO_DateTime as time)as varchar(5)) as DeviceDatetime
				from	t9999_device_inout_detail diod WITH (NOLOCK)
						inner join T0080_EMP_MASTER E WITH (NOLOCK) on diod.enroll_no = e.enroll_no 
						inner join #Emp_Cons EL on E.Emp_ID =EL.Emp_ID 
				WHERE	E.Enroll_No = diod.Enroll_No
						And (diod.IO_Datetime >= @From_Date And diod.IO_Datetime <= @To_Date + 1)
						And E.Emp_ID in (select Emp_ID From #Emp_Cons) and 
						Isnull(diod.IP_Address,'') =isnull(@IP_Address ,Isnull(diod.IP_Address,''))
				Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
					When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
						Else e.Alpha_Emp_Code
					End, diod.IO_DateTime
		end
      
 RETURN    
    

    

