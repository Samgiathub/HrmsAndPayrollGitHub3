




---------------------------------------------------------  
--Created By Girish on 14-june-2010 for Dynamic reports-- 
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
---------------------------------------------------------   
CREATE PROCEDURE [dbo].[SP_GET_EMP_COUSTOMIZE_RECORDS]   
  @Cmp_ID  numeric  
 ,@Month  numeric        
 ,@Year  numeric      
 ,@Branch_ID  numeric   = 0  
 ,@Cat_ID  numeric  = 0  
 ,@Grd_ID  numeric = 0  
 ,@Type_ID  numeric  = 0  
 ,@Dept_ID  numeric  = 0  
 ,@Desig_ID  numeric = 0  
 ,@Emp_ID  numeric  = 0  
 ,@Constraint varchar(max) = ''  
 ,@Field   varchar(max)=''  
   
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
    
 Declare @Emp_Count numeric(18,0)  
 set @Emp_Count=0  
 
  Declare @From_Date datetime        
 Declare @To_Date datetime  

  
select @From_Date = dbo.GET_MONTH_ST_DATE(isnull(@Month,1),isnull(@Year,2000))  
select @To_Date = dbo.GET_MONTH_END_DATE(isnull(@Month,1),isnull(@Year,2000))  

 Declare @Emp_Cons Table  
  (  
   Emp_ID numeric  
  )  
 set @Field = replace(@Field,'--Select All--#','')  
 set @Field = replace(@Field,'#--Select All--','')  
 set @Field = replace(@Field,'#--Select All--#','#')  
 if @Constraint <> ''  
  begin  
   Insert Into @Emp_Cons  
   select  cast(data  as numeric) from dbo.Split (@Constraint,',')   
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
    or @To_Date >= left_date and  @From_Date <= left_date )   
  end  
  		
	CREATE table #Temp
	(
		SR_NO Numeric(18,0)Default 0
	)	
  
  Declare @Report_Field Table  
  (  
   Fileld_Name Varchar(200)  
  )  
 if @Field <> ''  
  begin  
   Insert Into @Report_Field  
   select  cast(data  as varchar) from dbo.Split (@Field,'#')   
  end  
 else  
  Begin  
   Return  
  End   
CREATE table #Emp_Final_Field   
  (  
   Emp_ID numeric,  
   Filed_Name varchar(200),  
   Filed_Value varchar(1000),  
   Filed_Count numeric(18,0) default 0,  
   Total_Count numeric(18,0) default 0  
  )  
Declare @Temp Table  
  (  
   Emp_ID numeric,  
   Filed_Value varchar(200)  
  )    
  
Update  @Report_Field set  Fileld_Name = Replace(Fileld_Name,' ','_')  
  
 Declare @Emp_ID_T numeric(18,0)  
 declare curCust cursor for                      
  select Emp_ID from @Emp_Cons  
  open curCust                        
   fetch next from curCust into @Emp_ID_T  
    while @@fetch_status = 0                      
   begin                      
   Insert into #Emp_Final_Field   
   select @Emp_ID_T,Fileld_Name,'',0,0 from @Report_Field  
   fetch next from curCust into @Emp_ID_T  
   end                      
 close curCust                      
 deallocate curCust        
 
 
    
Declare @Emp_ID_Field_T  Varchar(200)  
declare curCust_Field cursor for                      
 select Fileld_Name from @Report_Field  
 open curCust_Field                        
  fetch next from curCust_Field into @Emp_ID_Field_T  
   while @@fetch_status = 0    
    begin      
  
    Declare @dbname as  nvarchar(4000)  
  DECLARE @New_Loc_Name AS nVARCHAR(1000)   
     Declare @BranchCode As nvarchar(1000)  
        Declare @LocationNameOUT as nvarchar(1000)  
        DECLARE @ParmDefinition_Br AS nVARCHAR(1000)  
        Declare @New_Br_Name As nVarchar(400)  
        Declare @Set_Field as varchar(8000)  
        set @Set_Field=''  
  set @dbname=''  
  set @Set_Field=replace(@Field,'#',',')  
  set @Set_Field = replace(@Set_Field,' ','_')  
  set @Set_Field ='COMPANY_NAME,EMP_CODE,FULL_NAME,INITIAL_NAME,FIRST_NAME,SECOND_NAME,LAST_NAME,ENROLL_NO,DATE_OF_JOIN,BASIC_SALARY,GROSS_SALARY,DATE_OF_CONFIRMATION,BRANCH,SHIFT,DEPARTMENT,DESIGNATION,GENDER,STATUS,MARITAL_STATUS,GRADE,DATE_OF_BIRTH,MANAGER_NAME,EMP_LEFT,OT_APPLICABLE,LATE_MARK_APPLICABLE,PT_APPLICABLE,FULL_PF_APPLICABLE,FIX_SALARY_APPLICABLE,GRATUITY_APPLICABLE,YEARLY_BONUS_APPLICABLE,ON_PROBATION,PROBATION_PERIOD,PT_AMOUNT,MOBILE_NO,WORKING_REGION,WORKING_POSTBOX,LEFT_DATE,HOME_TELEPHONE,PERSONAL_EMAIL,WORK_TELEPHONE,WORKING_EMAIL,WORKING_ADDRESS,WORKING_TOWN,PERMANENT_ADDRESS,PERMANENT_REGION,PERMANENT_TOWN,PERMANENT_POSTBOX,NATIONALITY,DRIVING_LICENSE,DRIVING_LICENSE_EXPIRY,PAN_NO,ESIC_NO,PF_NO,IMAGE_NAME,YEARLY_BONUS_AMOUNT,YEARLY_BONUS_PERCENTAGE,BANK_ACOUNT_NO,PAYMENT_MODE,SALARY_BASIS_ON,WAGES_TYPE,BLOOD_GROUP,RELIGION,HEIGHT,MARK_OF_IDENTIFICATION,DESPENCERY,DOCTOR_NAME,DESPENCERY_ADDRESS,INSURANCE_NO'  
        set @dbname ='update #Emp_Final_Field  set Filed_Value= q.' + @Emp_ID_Field_T + ' from #Emp_Final_Field EFF inner join(select Emp_ID,cmp_id,'+ @Set_Field + ' from V0080_Employee_Master_Coustomize_report)q on EFF.Emp_ID=q.Emp_ID where EFF.Filed_Name = ''' + @Emp_ID_Field_T + ''' And EFF.Emp_ID = q.Emp_ID'  
        SET @ParmDefinition_Br = '@level tinyint, @BranchNameOUT varchar(500) OUTPUT';   
  EXECUTE sp_executeSQL  @dbname,@ParmDefinition_Br, @BranchCode,@BranchNameOUT = @New_Br_Name OUTPUT;              
 fetch next from curCust_Field into @Emp_ID_Field_T  
end                      
close curCust_Field                      
deallocate curCust_Field    
  
  
 Declare @F_Count as numeric(18,0)  
 Declare @Total_Count as numeric(18,0)  
   
 select @F_Count = Count(Emp_ID) from #Emp_Final_Field group by Emp_ID  
 select @Total_Count = Count(Emp_ID) from @Emp_Cons    
 Update #Emp_Final_Field set Filed_Count = isnull(@F_Count,0),Total_Count=isnull(@Total_Count,0)  
 Update  #Emp_Final_Field set  Filed_Name = Replace(Filed_Name,'_',' ')  
 
 ----Below Code Developed By Nikunj 3-Feb-2011 For Modification of Cusomize Report
   Declare @Field_Name_Cur As Varchar(50)
   Declare @Field_Value_Cur As Varchar(50)
   Declare @Str_Query As Varchar(500)
   
   Declare @Count As Int
		Set @Count=0
	Declare @Id As Numeric(18,0)	
		Set @Id=1
   Declare test Cursor For Select Filed_Name from #Emp_Final_Field Group By Filed_Name
   Open test
   Fetch Next From test into @Field_Name_Cur
   while @@fetch_status = 0    
    begin      
			set @Field_Name_Cur=replace(@Field_Name_Cur,' ','_')
			set @Field_Name_Cur=replace (@Field_Name_Cur,'.','_')	
			
			Set @Str_Query ='CREATE table #Temp ADD ['+ @Field_Name_Cur +'] Varchar(50) Default 0'
			exec(@Str_Query)   
			
   Fetch Next From test into @Field_Name_Cur
   End
   Close test
   deallocate test
   
   Set @Field_Name_Cur=''
   Set @Str_Query=''
   
   
   Declare @Str_Query_Ins As Varchar(500)   
   Declare test2 Cursor For Select Cast(Filed_Value AS Varchar(50)),Filed_Name from #Emp_Final_Field 
   Open test2
   Fetch Next From test2 into @Field_Value_Cur,@Field_Name_Cur
   while @@fetch_status = 0    
    begin    
		set @Field_Name_Cur=replace(@Field_Name_Cur,' ','_')
		set @Field_Name_Cur=replace (@Field_Name_Cur,'.','_')	
      If @Count=0
		Begin		
			Set @Str_Query_Ins = 'Insert Into #Temp (SR_NO,'+ @Field_Name_Cur +') Values('+ Cast(@Id as Varchar(50)) +','''+ @Field_Value_Cur +''')'								
			exec(@Str_Query_Ins)		
		End	
	  Else	
		Begin
			Set @Str_Query ='Update #Temp Set ' + @Field_Name_Cur + '=''' + @Field_Value_Cur + ''' Where SR_NO=' + cast(@Id as varchar(50))		   	
		   	exec(@Str_Query)		   	
		End	
			
	Set @Count = @Count+1	
		
	If @Count = @F_Count
		Begin
			Set @Count = 0
			Set @Id = @Id + 1
		End
	
   Fetch Next From test2 into  @Field_Value_Cur,@Field_Name_Cur
   End
   Close test2
   deallocate test2
   
   Select * From #temp
   
Drop Table #Emp_Final_Field
Drop Table  #temp

RETURN  
  



