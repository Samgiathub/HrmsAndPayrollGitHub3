CREATE PROCEDURE [dbo].[SP_MOBILE_HRMS_WEBSERVICE_GetActiveToken_Notification]            
   @Cmp_ID INT = 0            
 ,@Emp_ID INT = 0            
 ,@Type VARCHAR(50) = null
 ,@Rpt_lvl as int=0
AS                                
BEGIN    
    
    Declare  @scheme_id as Numeric(18,0)  
	,@Rpt_Manager as varchar(50) 
	,@S_Emp_IDs INT  
    
    
          
 IF (@Type = 'Bulk')            
 BEGIN            
  Select distinct DeviceID,* from T0095_Emp_IMEI_Details            
  where (Cmp_Id = @Cmp_ID OR @Cmp_ID = 0)            
  and DeviceID <> '' and DeviceID IS NOT NULL            
 END            
 ELSE IF (@Type = 'Ticket')            
 BEGIN            
              
  DECLARE @send_TO INT, @d1 varchar(300),@d2 varchar(300)            
              
  Select @send_TO = ISNULL(SendTo,0) from T0090_Ticket_Application            
  WHERE Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID            
              
  Select top 1 @d1 = DeviceID from T0095_Emp_IMEI_Details where Emp_ID = @send_TO and IS_Active = 1             
  Select top 1 @d2 = DeviceID from T0095_Emp_IMEI_Details where Emp_ID = @Emp_ID and IS_Active = 1             
              
  Select @d1 as Mangr_Device_Id,@d2 as Emp_Device_Id            
            
 END           
 --Added by Yogesh on 23012024-----START---------------------------------------        
 ELSE IF (@Type = 'Bulk_Birthday')           
 BEGIN            
           
 Select distinct DeviceID from T0095_Emp_IMEI_Details            
 where (Cmp_Id = @Cmp_ID OR @Cmp_ID = 0)            
 and DeviceID <> '' and DeviceID IS NOT NULL  and IS_Active = 1          
  End          
  --Added by Yogesh on 23012024-----End---------------------------------------        
  ELSE IF (@Type = 'ClaimApplication')           
	BEGIN            
	--Declare  @scheme_id as Numeric(18,0)  
	--,@Rpt_Manager as varchar(50) 
	--,@S_Emp_IDs INT  
	set @scheme_id=(select Max(Scheme_ID) from T0095_EMP_SCHEME where type='Claim' and Emp_id=@emp_id and Effective_Date=(select Max(Effective_date) from T0095_EMP_SCHEME  where Emp_ID=@emp_id and cmp_id=@Cmp_ID and Type='Claim'))       
     
	set @Rpt_Manager=(select Rpt_Mgr_1 from V0050_Scheme_Detail where Scheme_Id=@scheme_id) --and rpt_level=1   
	--select @Rpt_Manager


		if @Rpt_Manager='Reporting Manager'
		begin
		 set @S_Emp_IDs =(select rd.R_Emp_ID from T0080_EMP_MASTER em inner join T0090_EMP_REPORTING_DETAIL RD on em.Emp_ID=rd.Emp_ID 
			and rd.Effect_Date=(select Max(Effect_Date) as Effect_Date from  T0090_EMP_REPORTING_DETAIL  where emp_id=@Emp_ID and Cmp_ID=@Cmp_ID )
				where rd.Emp_ID=@Emp_ID and rd.Cmp_ID=@Cmp_ID)
		end
		else if @Rpt_Manager='Branch Manager'
			begin 
		set @S_Emp_IDs=(select  mn.Emp_id from T0080_EMP_MASTER EM  inner join T0095_INCREMENT INC on EM.emp_id=INC.Emp_ID
		and inc.Increment_Effective_Date=(select Max(Increment_Effective_Date) as Increment_Effective_Date from T0095_INCREMENT where EMP_id=@Emp_ID and Cmp_ID=@cmp_id )
			inner join T0030_BRANCH_MASTER BM on bm.Branch_ID=INC.Branch_ID  inner join T0095_MANAGERS MN on mn.branch_id=bm.Branch_ID and bm.Cmp_id=mn.Cmp_id)
		 end

		else if @Rpt_Manager='Head of Department'
		 begin
		 set @S_Emp_IDs =(select  DMn.Emp_id from T0080_EMP_MASTER EM  inner join T0095_INCREMENT INC on EM.emp_id=INC.Emp_ID and inc.Increment_Effective_Date=(select Max(Increment_Effective_Date) as Increment_Effective_Date from T0095_INCREMENT where EMP_id=28201 and Cmp_ID=@cmp_id )
		inner join T0040_DEPARTMENT_MASTER DM on DM.Dept_Id=INC.dept_id  inner join T0095_Department_Manager DMN on Dmn.Dept_id=DM.Dept_id and dm.Cmp_id=DMn.Cmp_id)
		 end
   --else if @Rpt_Manager='HR'
   --begin 

   --end
   -- select @S_Emp_IDs 
    
            
  --Select @S_Emp_IDs = ISNULL(Emp_Superior,0) from T0080_EMP_MASTER            
  --WHERE Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID            
            
  Select top 1 DeviceID from T0095_Emp_IMEI_Details where Emp_ID = @S_Emp_IDs and IS_Active = 1            
  order by 1 desc            
       
  End          

    ELSE IF (@Type = 'ClaimApprovalUpdate')           
	BEGIN            
	Create table #S_EMP_IDs(
	Emp_id  Nvarchar(max)
	)
	  set @scheme_id =0
	set @Rpt_Manager = ''
	set @S_Emp_IDs=0  
	set @scheme_id=(select Max(Scheme_ID) from T0095_EMP_SCHEME where type='Claim' and Emp_id=@emp_id and Effective_Date=(select Max(Effective_date) from T0095_EMP_SCHEME  where Emp_ID=@emp_id and cmp_id=@Cmp_ID and Type='Claim'))       
	
   
	 
	declare @str Nvarchar(max)=('select '+cast(concat('Rpt_Mgr_',@Rpt_lvl) as nvarchar)+'  from V0050_Scheme_Detail where Scheme_Id='+cast(@scheme_id as varchar(100)))
	

	
	insert into #S_EMP_IDs (emp_id)
	exec (@str)
	
	set @Rpt_Manager=(select Cast(emp_id as nvarchar) from #S_EMP_IDs) 

	

		if @Rpt_Manager='Reporting Manager'
		begin
		 set @S_Emp_IDs =(select rd.R_Emp_ID from T0080_EMP_MASTER em inner join T0090_EMP_REPORTING_DETAIL RD on em.Emp_ID=rd.Emp_ID 
and rd.Effect_Date=(select Max(Effect_Date) as Effect_Date from  T0090_EMP_REPORTING_DETAIL  where emp_id=@Emp_ID and Cmp_ID=@Cmp_ID )
	where rd.Emp_ID=@Emp_ID and rd.Cmp_ID=@Cmp_ID)
 end
 else if @Rpt_Manager='Branch Manager'
 begin 
 set @S_Emp_IDs=(select  mn.Emp_id from T0080_EMP_MASTER EM  inner join T0095_INCREMENT INC on EM.emp_id=INC.Emp_ID
 and inc.Increment_Effective_Date=(select Max(Increment_Effective_Date) as Increment_Effective_Date from T0095_INCREMENT where EMP_id=@Emp_ID and Cmp_ID=@cmp_id )
inner join T0030_BRANCH_MASTER BM on bm.Branch_ID=INC.Branch_ID  inner join T0095_MANAGERS MN on mn.branch_id=bm.Branch_ID and bm.Cmp_id=mn.Cmp_id)
 end
 else if @Rpt_Manager='Head of Department'
 begin
 set @S_Emp_IDs =(select  DMn.Emp_id from T0080_EMP_MASTER EM  inner join T0095_INCREMENT INC on EM.emp_id=INC.Emp_ID and inc.Increment_Effective_Date=(select Max(Increment_Effective_Date) as Increment_Effective_Date from T0095_INCREMENT where EMP_id=28201 and Cmp_ID=@cmp_id )
inner join T0040_DEPARTMENT_MASTER DM on DM.Dept_Id=INC.dept_id  inner join T0095_Department_Manager DMN on Dmn.Dept_id=DM.Dept_id and dm.Cmp_id=DMn.Cmp_id)
 end
 else
 begin 
 set @S_Emp_IDs=(select Emp_id from T0080_EMP_MASTER where emp_code = Cast(SUBSTRING(@Rpt_Manager, 1, 5) as numeric) and Cmp_ID=@Cmp_ID)
end
   --else if @Rpt_Manager='HR'
   --begin 

   --end
           
          
  Select top 1 DeviceID from T0095_Emp_IMEI_Details where Emp_ID = @S_Emp_IDs and IS_Active = 1            
  order by 1 desc            
       
  End   
  --Added by Yogesh on 07032024-----End---------------------------------------        
 ELSE            
 BEGIN            
  DECLARE @S_Emp_ID INT            
  Select @S_Emp_ID = ISNULL(Emp_Superior,0) from T0080_EMP_MASTER            
  WHERE Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID            
            
  Select top 1 DeviceID from T0095_Emp_IMEI_Details where Emp_ID = @S_Emp_ID and IS_Active = 1            
  order by 1 desc  
  Drop table #S_EMP_IDs
 END            
END                    
            
            
-- Exec [SP_MOBILE_HRMS_WEBSERVICE_GetActiveToken] @Cmp_ID= 120,@Emp_ID = 14561,@Type='Ticket' 