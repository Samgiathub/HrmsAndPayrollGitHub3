  
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0100_WEEKOFF_ADJ]  
   @W_Tran_ID numeric(18) output  
  ,@Cmp_ID numeric(18,0)  
  ,@Emp_ID numeric(18,0)  
  ,@For_Date datetime  
  ,@Weekoff_Day varchar(250)  
  ,@Weekoff_Day_value varchar(250)  
  ,@Alt_W_name varchar(100)  
  ,@Alt_W_Full_Day_Cont varchar(100)  
  ,@Alt_W_Half_Day_Cont varchar(100)  
  ,@Is_P_Comp  tinyint  
  ,@tran_type char  
  ,@User_Id numeric(18,0) = 0 -- Added for Audit Trail by Ali 09102013  
  ,@IP_Address varchar(30)= '' -- Added for Audit Trail by Ali 09102013  
  ,@IsMakerChecker BIT = null  
  ,@OddOrEven Char(5) = null  
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
		
			Create Table #Emp_data(
		Day_name varchar(200)
		)

		Insert Into #Emp_data    
		Select cast(data  as varchar) From dbo.Split(@Weekoff_Day,'#')     


     -- Added for Audit Trail by Ali 09102013 -- Start  
     Declare @Old_Emp_Name as varchar(200)  
     Declare @Old_Emp_Id numeric(18,0)  
     Declare @Old_Branch_Name as varchar(100)  
     Declare @New_Branch_Name as varchar(100)  
     Declare @Old_For_Date as datetime  
     Declare @Old_Weekoff_Day varchar(250)  
     Declare @Oldvalue as varchar(max)  
            
     Set @Old_Emp_Name = ''  
     Set @Old_Emp_Id = 0  
     Set @Old_Branch_Name = ''  
     Set @New_Branch_Name = ''  
     Set @Old_For_Date = null  
     Set @Old_Weekoff_Day = ''  
     Set @Oldvalue = ''  
     -- Added for Audit Trail by Ali 09102013 -- End  
    
  --- Added By Ali 13122013 Start ---  
    
    Declare @Sal_St_Date Datetime          
    Declare @Sal_end_Date Datetime        
    Declare @manual_salary_Period as numeric(18,0)   
    set @manual_salary_Period = 0  
    Declare @Salary_Cycle_id as numeric   
    set @Salary_Cycle_id  = 0      
    declare @is_salary_cycle_emp_wise as tinyint     
    set @is_salary_cycle_emp_wise = 0    
    Declare @TempFromDate datetime  
    Declare @TempToDate datetime  
      
   -- SET @TempFromDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@For_Date)-1),@For_Date),101)  
    --SET @TempToDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,@For_Date))),DATEADD(mm,1,@For_Date)),101)  
--select @TempFromDate,@TempToDate      
          Declare @From_Date datetime  
    Declare @To_Date datetime  
      
    select @is_salary_cycle_emp_wise = isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name = 'Salary Cycle Employee Wise'      
            
    IF @is_salary_cycle_emp_wise = 1      
   BEGIN    
      SELECT @Salary_Cycle_id = SalDate_id from T0095_Emp_Salary_Cycle WITH (NOLOCK) where Emp_id = @Emp_ID AND Effective_date in      
      (SELECT max(effective_date) as effective_date from T0095_Emp_Salary_Cycle  WITH (NOLOCK)      
      where Emp_id = @Emp_ID AND Effective_date <=  @For_Date      
      GROUP by Emp_id)            
      SELECT @Sal_St_Date = Salary_st_date FROM T0040_Salary_Cycle_Master WITH (NOLOCK) where Tran_Id = @Salary_Cycle_id     
        
     END    
     ELSE    
     BEGIN    
      select Top 1 @Sal_St_Date = Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0)  
      from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID          
      and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @For_Date and Cmp_ID = @Cmp_ID)          
     END    
      
    if isnull(@Sal_St_Date,'') = ''            
    begin             
      set @From_Date  = @TempFromDate             
      set @To_Date = @TempToDate            
    end             
    else if day(@Sal_St_Date) =1          
    begin            
      set @From_Date  = @TempFromDate             
      set @To_Date = @TempToDate            
    end             
    else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1           
    begin                 
      if @manual_salary_Period = 0         
      Begin    
     If DATENAME(dd,@Sal_St_Date) <= Datename(dd,@For_Date) -- Added this condition by Hardik 01/11/2014  
      Begin  
       set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@For_Date) as varchar(10)) + '-' +  cast(year(@For_Date)as varchar(10)) as smalldatetime)            
       set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))         
      End  
     Else  
      Begin  
       set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@For_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@For_Date) )as varchar(10)) as smalldatetime)            
       set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))         
      End  
  
     Set @From_Date = @Sal_St_Date        
     Set @To_Date = @Sal_End_Date    
    end        
     else        
      begin           
        select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where Month(from_date) = Month(@For_Date) And Year(from_date) = Year(@For_Date)  
        Set @From_Date = @Sal_St_Date        
     Set @To_Date = @Sal_End_Date            
      End         
    End    
     
  --- Added By Ali 13122013 End ---  
     --Select @To_Date,* from T0200_MONTHLY_SALARY where Emp_ID=@Emp_Id and  Month_End_Date >= @To_Date and Cmp_ID = @Cmp_ID  
  if Exists(Select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_Id and  Month_End_Date >= @To_Date and Cmp_ID = @Cmp_ID) -- Changed For_date to To_Date Ali 13122013  
    Begin  
     RAISERROR ('Months Salary Exists', 16, 2)   
     return   
    End  
      
      
  
  If @tran_type ='I'   
   begin  
   if exists (Select W_Tran_ID  from T0100_WEEKOFF_ADJ  WITH (NOLOCK) Where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID AND For_Date=@For_Date)   
    begin  
      
      
      Select @W_Tran_ID = W_Tran_ID  from T0100_WEEKOFF_ADJ WITH (NOLOCK) Where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID AND For_Date=@For_Date  
        
        -- Added for Audit Trail by Ali 09102013 -- Start  
         Select   
         @Old_Emp_Id = Emp_ID  
         ,@Old_For_Date = For_Date  
         ,@Old_Weekoff_Day = Weekoff_Day  
         From T0100_WEEKOFF_ADJ WITH (NOLOCK) Where W_Tran_ID = @W_Tran_ID  
            
         Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID =  @Old_Emp_Id)  
         Set @Old_Branch_Name = (select Branch_Name from V0080_Employee_Master where Cmp_ID = @Cmp_ID and Emp_ID = @Old_Emp_Id)               
        -- Added for Audit Trail by Ali 09102013 -- End  
          
          
      Update  T0100_WEEKOFF_ADJ   
      Set  Weekoff_Day  = @Weekoff_Day,  
        For_Date  = @For_Date,  
        Weekoff_Day_Value = @Weekoff_Day_Value,  
        Alt_W_name = @Alt_W_name,  
        Alt_W_Full_Day_Cont =@Alt_W_Full_Day_Cont,  
        Alt_W_Half_Day_Cont=@Alt_W_Half_Day_Cont,  
        Is_P_Comp=@Is_P_Comp,  
        IsMakerChecker = @IsMakerChecker ,
		WeekOffOddEven = @OddOrEven
      where W_Tran_ID = @W_Tran_ID and Cmp_ID = @Cmp_ID   
        
        -- Added for Audit Trail by Ali 09102013 -- Start  
        Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID =  @Emp_ID)  
        Set @New_Branch_Name = (select Branch_Name from V0080_Employee_Master where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID)  
        set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'')   
            + '#' + 'Branch abc Name :' + ISNULL(@Old_Branch_Name,'')               
            + '#' + 'Effective Date :' + cast(ISNULL(@Old_For_Date,'') as nvarchar(11))   
            + '#' + 'Off Day :' + ISNULL(@Old_Weekoff_Day,'')  
            + '#' +   
            'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'')   
            + '#' + 'Branch abc Name :' + ISNULL(@New_Branch_Name,'')               
            + '#' + 'Effective Date :' + cast(ISNULL(@For_Date,'') as nvarchar(11))   
            + '#' + 'Off Day :' + ISNULL(@Weekoff_Day,'')  
              
        exec P9999_Audit_Trail @Cmp_ID,'U','Employee Weekoff',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1  
        -- Added for Audit Trail by Ali 09102013 -- Start  
        
  
       
    end  
   else  
    begin  
      
	 
      set @OddOrEven = NULL
     Select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1  from T0100_WEEKOFF_ADJ WITH (NOLOCK)  
     If isNull(@OddOrEven , '') <> '' and  isNull(@OddOrEven , '') = 'Odd'  
     Begin   
       SELECT @Alt_W_Full_Day_Cont = STUFF((SELECT '#' + Cast(Srno as varchar)  
       FROM T0010_Yearly_Odd_Even_WeekOff where SRNo % 2  <> 0   and WeekOffDate >= @For_Date  
	   and name = @Alt_W_name
	   --name in (select Day_name from #Emp_data)
	   FOR XML PATH('')) ,1,1,'')   
       --select @Alt_W_Full_Day_Cont  
  
       SELECT @Alt_W_name = STUFF((SELECT '#' + Cast(Name as varchar)  
       FROM T0010_Yearly_Odd_Even_WeekOff where SRNo % 2  <> 0   and WeekOffDate >= @For_Date  
       and name = @Alt_W_name
	   --and name in (select Day_name from #Emp_data)
	   FOR XML PATH('')) ,1,1,'')   
       --select @Alt_W_name  
		
		--select Replace(@Weekoff_Day,'#',',')
		--Select Name from T0010_Yearly_Odd_Even_WeekOff t where t.Name in (Cast(Replace(@Weekoff_Day,'#',',') as varchar) )
	

	   --select 	STUFF((SELECT '#' + Cast(Name as varchar)  
    --   FROM T0010_Yearly_Odd_Even_WeekOff where SRNo % 2  <> 0   and WeekOffDate >= @For_Date  
	   --and name in (select Day_name from #Emp_data)
    --   FOR XML PATH('')) ,1,1,'') 


	   --select 123
     END  
     If isNull(@OddOrEven , '') <> '' and  isNull(@OddOrEven , '') = 'Even'  
     Begin   
	 
       SELECT @Alt_W_Full_Day_Cont = STUFF((SELECT '#' + Cast(Srno as varchar)  
       FROM T0010_Yearly_Odd_Even_WeekOff where SRNo % 2  = 0   and WeekOffDate >= @For_Date  
	    and name = @Alt_W_name
       FOR XML PATH('')) ,1,1,'')   
       --select @Alt_W_Full_Day_Cont  
  
       SELECT @Alt_W_name = STUFF((SELECT '#' + Cast(Name as varchar)  
       FROM T0010_Yearly_Odd_Even_WeekOff where SRNo % 2  = 0   and WeekOffDate >= @For_Date  
	    and name = @Alt_W_name
       FOR XML PATH('')) ,1,1,'')   
       --select @Alt_W_name  
  
     END  
	 set @OddOrEven = NULL
     Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day,Weekoff_Day_Value,Alt_W_name,Alt_W_Full_Day_Cont,Alt_W_Half_Day_Cont,Is_P_Comp,IsMakerChecker,WeekOffOddEven)  
     values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day,@Weekoff_Day_Value,@Alt_W_name,@Alt_W_Full_Day_Cont,@Alt_W_Half_Day_Cont,@Is_P_Comp,@IsMakerChecker,@OddOrEven)  
       
        -- Added for Audit Trail by Ali 09102013 -- Start  
        Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID)  
        Set @Old_Branch_Name = (select Branch_Name from V0080_Employee_Master where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID)  
          
        set @OldValue = 'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'')   
             + '#' + 'Branch abc Name :' + ISNULL(@Old_Branch_Name,'')               
             + '#' + 'Effective Date :' + cast(ISNULL(@For_Date,'') as nvarchar(11))   
             + '#' + 'Off Day :' + ISNULL(@Weekoff_Day,'')               
                
        exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee Weekoff',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1              
        -- Added for Audit Trail by Ali 09102013 -- End  
            
    end   
   end  
  else if @tran_type ='U'   
   begin  
     
        -- Added for Audit Trail by Ali 09102013 -- Start  
         Select   
         @Old_Emp_Id = Emp_ID  
         ,@Old_For_Date = For_Date  
         ,@Old_Weekoff_Day = Weekoff_Day  
         From T0100_WEEKOFF_ADJ WITH (NOLOCK) Where W_Tran_ID = @W_Tran_ID  
            
         Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID =  @Old_Emp_Id)  
         Set @Old_Branch_Name = (select Branch_Name from V0080_Employee_Master where Cmp_ID = @Cmp_ID and Emp_ID = @Old_Emp_Id)               
        -- Added for Audit Trail by Ali 09102013 -- End  
        
    set @OddOrEven = NULL

    Update T0100_WEEKOFF_ADJ   
    Set  Weekoff_Day = @Weekoff_Day,  
      For_Date = @For_Date,  
      Weekoff_Day_Value = @Weekoff_Day_Value,  
      Alt_W_name = @Alt_W_name,  
      Alt_W_Full_Day_Cont =@Alt_W_Full_Day_Cont,  
      Alt_W_Half_Day_Cont=@Alt_W_Half_Day_Cont,  
      Is_P_Comp=@Is_P_Comp,  
      IsMakerChecker = @IsMakerChecker  ,
	  WeekOffOddEven = @OddOrEven
    where W_Tran_ID = @W_Tran_ID and Cmp_ID = @Cmp_ID   
      
        -- Added for Audit Trail by Ali 09102013 -- Start  
        Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID =  @Emp_ID)  
        Set @New_Branch_Name = (select Branch_Name from V0080_Employee_Master where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID)  
        set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'')   
            + '#' + 'Branch abc Name :' + ISNULL(@Old_Branch_Name,'')               
            + '#' + 'Effective Date :' + cast(ISNULL(@Old_For_Date,'') as nvarchar(11))   
            + '#' + 'Off Day :' + ISNULL(@Old_Weekoff_Day,'')  
            + '#' +   
            'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'')   
            + '#' + 'Branch abc Name :' + ISNULL(@New_Branch_Name,'')               
            + '#' + 'Effective Date :' + cast(ISNULL(@For_Date,'') as nvarchar(11))   
            + '#' + 'Off Day :' + ISNULL(@Weekoff_Day,'')  
        exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee Weekoff',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1  
        -- Added for Audit Trail by Ali 09102013 -- Start  
      
   end   
 Else If @tran_type ='D'  
  begin  
   -- Salary Exist Condition Added by Mihir 24102011  
   declare @W_For_Date as datetime  
   declare @W_Emp_Id as numeric  
   select @W_For_Date = For_Date,@W_Emp_Id=Emp_ID from T0100_WEEKOFF_ADJ WITH (NOLOCK) where W_Tran_ID = @W_Tran_ID   
   if Not Exists(Select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@W_Emp_Id and Month_End_Date >= @For_Date )--Currnet Month Salary Employee Weekoff delete change by paras 16/07/2013  
    Begin  
      
        -- Added for Audit Trail by Ali 09102013 -- Start  
        Select   
        @Old_Emp_Id = Emp_ID  
        ,@Old_For_Date = For_Date  
        ,@Old_Weekoff_Day = Weekoff_Day  
        From T0100_WEEKOFF_ADJ WITH (NOLOCK) Where W_Tran_ID = @W_Tran_ID  
          
        Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID =  @Old_Emp_Id)  
        Set @Old_Branch_Name = (select Branch_Name from V0080_Employee_Master where Cmp_ID = @Cmp_ID and Emp_ID = @Old_Emp_Id)  
          
        set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'')   
             + '#' + 'Branch abc Name :' + ISNULL(@Old_Branch_Name,'')               
             + '#' + 'Effective Date :' + cast(ISNULL(@Old_For_Date,'') as nvarchar(11))   
             + '#' + 'Off Day :' + ISNULL(@Old_Weekoff_Day,'')               
                
        exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee Weekoff',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1              
        -- Added for Audit Trail by Ali 09102013 -- End  
          
     delete  from T0100_WEEKOFF_ADJ where W_Tran_ID = @W_Tran_ID  
    End  
   Else  
    begin  
     set @W_Tran_Id = 0  
     return  
    End  
  end   
  
 RETURN  
  
  
/*For Shift Rotation*/  
If Exists(Select 1 From T0050_EMP_MONTHLY_SHIFT_ROTATION WITH (NOLOCK) Where Emp_ID=@Emp_Id AND Effective_Date < @For_Date)  
 BEGIN  
  DECLARE @ROTATION_ID NUMERIC  
  DECLARE @CONSTRAINT VARCHAR(MAX)  
  SELECT TOP 1 @ROTATION_ID=ROTATION_ID FROM T0050_EMP_MONTHLY_SHIFT_ROTATION WITH (NOLOCK) WHERE Emp_ID=@Emp_Id  AND Effective_Date < @For_Date  
  ORDER BY Effective_Date DESC  
  
  SET @CONSTRAINT = CAST(@EMP_ID AS VARCHAR(MAX))  
  EXEC P0050_ASSIGN_SHIFT_BY_ROTATION @Cmp_ID=@CMP_ID, @Effective_Date=@For_Date, @Constraint=@CONSTRAINT  
 END   
/*End of Code*/  
  
	   drop table #Emp_data  
  
  