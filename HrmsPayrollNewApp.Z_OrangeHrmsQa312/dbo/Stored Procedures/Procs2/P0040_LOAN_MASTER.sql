  
  
CREATE PROCEDURE [dbo].[P0040_LOAN_MASTER]  
   @Loan_ID numeric(18) output  
  ,@Cmp_ID numeric(18,0)  
  ,@Loan_Name varchar(50)  
  ,@Loan_Max_Limit numeric(18,0)  
  ,@Loan_Comments Varchar(100)  
  ,@Company_Loan numeric(1,0)  
  ,@tran_type char  
  ,@Max_Limit_on_Basic_Gross tinyint =0  
  ,@Allowance_Id_String_Max_Limit Varchar(max) = ''  --added by mehul 20092021  
  ,@No_Of_Times  Numeric(9,2) = 1 --Integer = 1 --Integer ro Numeric Change to Ankit 04032016  
  ,@Loan_Guarantor Numeric(1,0) = 0 --Ankit 01052014  
  ,@Maxlimit_Desigwise Numeric(1,0) = 0 --added by nilesh patel on 17102014  
  ,@Is_Interest_Subsidy_Limit tinyint = 0 -- Added by Gadriwala 08122014  
  ,@Interest_Recovery_Per  numeric(18,2) = 0 -- Added by Gadriwala 08122014  
  ,@Subsidy_Desig_Id_String varchar(max) = '' -- Added by Gadriwala 08122014  
  ,@Interest_Type  varchar(20) = '' --Added by Gadriwala Muslim 10032015  
  ,@Interest_Per  numeric(18,4) = 0 --Added by Gadriwala Muslim 10032015  
  ,@Is_Attachment tinyint = 0 --Added by Gadriwala Muslim 11032015  
  ,@Is_Eligible tinyint = 0 -- Added by Gadriwala Muslim  12032015  
  ,@Eligible_Days numeric(18,0) = 0 -- Added by Gadriwala Muslim  12032015  
  ,@Subsidy_Bond_Days numeric(18,2) = 0 -- Added by Gadriwala Muslim 10042015  
  ,@Is_GPF tinyint = 0 -- Added by Nilesh Patel on 15072015  
  ,@Eligible_Afte_Join_Month numeric(18,2) = 0 -- Added by Nilesh Patel on 15072015  
  ,@Min_Day_Btn_two_App numeric(18,2) = 0 -- Added by Nilesh Patel on 15072015  
  ,@Max_GPF_Amount_Per numeric(18,2) = 0 -- Added by Nilesh Patel on 15072015  
  ,@Is_Principal_First_than_Int numeric(18,2) = 0 -- Added by Nilesh Patel on 15072015  
  ,@Loan_Guarantor2 numeric(18,2) = 0 --Mukti 17112015  
  ,@Loan_Is_Grade_Wise numeric(18,2) = 0 --Added by nilesh patel on 18012016  
  ,@Loan_Grade_Details varchar(500) = '' --Added by nilesh patel on 18012016  
  ,@Loan_Short_Name varchar(50) = '' --added jimit 11042016  
  ,@User_Id numeric(18,0) = 0 -- Add By Mukti 05072016  
  ,@IP_Address varchar(30)= '' -- Add By Mukti 05072016  
  ,@is_Subsidy_loan tinyint= 0  
  ,@Subsidy_Bond_month numeric(18,2) = 0  
  ,@Is_Intrest_Amount_As_Perquisite_IT integer = 0  
  ,@Standard_Interest_Rates numeric(18,2) = 0  
  ,@Standard_Interest_Effective_date DateTime = '01/01/1900'  
  ,@Hide_Loan_Max_Amount tinyint = 0  
  ,@Loan_Application_Reason_Required tinyint = 0  --Added By Jimit 16102018  
  ,@Max_Installment Numeric(18,0) = 0    --Added By Jimit 16102018  
  ,@IsContractDue int =0  --Added by ronakk 27032023
  ,@ContractDueDays int =0 --Added by ronakk 27032023 

AS  
  
        SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
  
declare @Trans_ID Numeric(18,0) --added by nilesh patel on 17102014  
declare @ID Numeric(18,0) --added by nilesh patel on 17102014  
declare @Amount Numeric(18,0) --added by nilesh patel on 17102014  
declare @Max_Design_Tran_id Numeric(18,0) --added by nilesh patel on 26112014  
  
 -- Add By Mukti 05072016(start)  
  declare @OldValue as  varchar(max)  
  Declare @String as varchar(max)  
  set @String=''  
  set @OldValue =''  
 -- Add By Mukti 05072016(end)   
  
Set NoCount On;  
            set @Loan_Name = dbo.fnc_ReverseHTMLTags(@Loan_Name)  --added by Ronak 100121  
			set @Loan_Comments = dbo.fnc_ReverseHTMLTags(@Loan_Comments)  --added by Ronak 100121  
		
 if @tran_type ='I'   
  begin  
   IF ISNULL(@Loan_Name,'') = ''  
    BEGIN  
     RAISERROR (N'Loan Name cannot be blank.', 16, 2);   
    END  
    
   If exists(Select Loan_ID  from dbo.T0040_LOAN_MASTER WITH (NOLOCK)  
      Where (Upper(Loan_Name) = Upper(@Loan_Name))and Cmp_ID = @Cmp_ID)   
    or exists (Select Loan_ID  from dbo.T0040_LOAN_MASTER WITH (NOLOCK)  
      Where (IsNull(@Loan_Short_Name ,'') <> '' AND  Upper(Loan_Short_Name) = Upper(@Loan_Short_Name))  
        and Cmp_ID = @Cmp_ID)  
          
    Begin  
     set @Loan_ID=0  
    End  
   else  
    begin  
     if @Loan_Short_Name <> ''  
      Begin  
       If exists(Select Loan_ID  from dbo.T0040_LOAN_MASTER WITH (NOLOCK) Where (Upper(Loan_Short_Name) = Upper(@Loan_Short_Name)) and Cmp_ID = @Cmp_ID)   
       Begin  
        set @Loan_ID=0  
       End  
      End  
          
     select @Loan_ID = isnull(max(Loan_ID),0) from dbo.T0040_LOAN_MASTER WITH (NOLOCK)  
  
     if @Loan_ID is null or @Loan_ID = 0  
      set @Loan_ID =1  
     else  
      set @Loan_ID = @Loan_ID + 1    
        
     insert into dbo.T0040_LOAN_MASTER  
      (Loan_ID,Loan_Name,Cmp_ID,Loan_Max_Limit,Loan_Comments,Company_Loan,Max_Limit_on_Basic_Gross,Allowance_Id_String_Max_Limit,No_Of_Times,Loan_Guarantor,Desig_max_limit,Is_Interest_Subsidy_Limit,Interest_Recovery_Per,Subsidy_Desig_ID_String,Loan_Interest_Type,Loan_Interest_Per,Is_attachment,Is_Eligible,Eligible_Days,Subsidy_Bond_Days,Is_GPF,GPF_Eligible_Month,GPF_days_diff_application,GPF_Max_Loan_per,Is_Principal_First_than_Int,Loan_Guarantor2,Is_Grade_Wise,Grade_Details,Loan_Short_Name,Is_Subsidy_Loan,Subsidy_Bond_month,Is_Intrest_Amount_As_Perquisite_IT,Hide_Loan_Max_Amount,Loan_Application_Reason_Required,Max_Installment,IsContractDue,ContractDueDays)   
     values  
      (@Loan_ID,@Loan_Name,@Cmp_ID,@Loan_Max_Limit,@Loan_Comments,@Company_Loan,@Max_Limit_on_Basic_Gross,@Allowance_Id_String_Max_Limit,@No_Of_Times,@Loan_Guarantor,ISNULL(@Maxlimit_Desigwise,0),@Is_Interest_Subsidy_Limit,@Interest_Recovery_Per,@Subsidy_Desig_Id_String,@Interest_Type,@Interest_Per,@Is_Attachment,@Is_Eligible,@Eligible_Days,@Subsidy_Bond_Days,@Is_GPF,@Eligible_Afte_Join_Month,@Min_Day_Btn_two_App,@Max_GPF_Amount_Per,@Is_Principal_First_than_Int,@Loan_Guarantor2,@Loan_Is_Grade_Wise,@Loan_Grade_Details,@Loan_Short_Name,@Is_Subsidy_Loan,@Subsidy_Bond_month,@Is_Intrest_Amount_As_Perquisite_IT,@Hide_Loan_Max_Amount,@Loan_Application_Reason_Required,@Max_Installment,@IsContractDue,@ContractDueDays)  
       
     -- Added by nilesh patel on 17102014 --start  
     IF @Maxlimit_Desigwise = 1  
     begin  
        
       set @Trans_ID = 0  
                    
       DECLARE Loan_Cursor CURSOR FOR SELECT LEFT(data,CHARINDEX(',',data)-1), right(data,LEN(data)-CHARINDEX(',',data)) FROM dbo.Split(@Allowance_Id_String_Max_Limit,'#')  
                    
       OPEN Loan_Cursor   
                  fetch next from Loan_Cursor into @ID,@Amount  
                   while @@fetch_status = 0  
        Begin  
           
          select @Trans_ID = isnull(max(Trans_ID),0) + 1 from dbo.T0040_Loan_Maxlimit_Design WITH (NOLOCK)  
            
          insert into dbo.T0040_Loan_Maxlimit_Design(Trans_ID,Loan_ID,Desig_Id,Loan_Max_Limit)  
          VALUES(@Trans_ID,@Loan_ID,cast(@ID AS numeric(18,0)),cast(@Amount AS numeric(18,2)))  
            
          fetch next from Loan_Cursor into @ID,@Amount  
        End  
                Close Loan_Cursor   
                   deallocate Loan_Cursor  
                   
     end    
     -- Added by nilesh patel on 17102014 --End  
      --Added by Gadriwala Muslim 09122014 - Start  
     If isnull(@Is_Interest_Subsidy_Limit,0) = 1  
      begin  
        set @Trans_ID = 0  
        If @Subsidy_Desig_Id_String <> ''   
         begin  
           DECLARE Subsidy_Cursor CURSOR FOR SELECT LEFT(data,CHARINDEX(',',data)-1), right(data,LEN(data)-CHARINDEX(',',data)) FROM dbo.Split(@Subsidy_Desig_Id_String ,'#')  
                      
            OPEN Subsidy_Cursor   
              fetch next from Subsidy_Cursor into @ID,@Amount  
            while @@fetch_status = 0  
             Begin  
                
               select @Trans_ID = isnull(max(Tran_ID),0) + 1 from dbo.T0040_Subsidy_Max_Limit_Design_Wise WITH (NOLOCK)  
                 
               insert into dbo.T0040_Subsidy_Max_Limit_Design_Wise(Tran_ID,Loan_ID,Design_ID,Subsidy_Max_Limit)  
               VALUES(@Trans_ID,@Loan_ID,cast(@ID AS numeric(18,0)),cast(@Amount AS numeric(18,2)))  
                 
               fetch next from Subsidy_Cursor into @ID,@Amount  
             End  
            Close Subsidy_Cursor   
            deallocate Subsidy_Cursor  
         end  
      end  
     --Added by Gadriwala Muslim 09122014 - End  
       
     if @Is_Intrest_Amount_As_Perquisite_IT = 1   
      Begin  
       Exec P0050_LOAN_INTEREST_DETAILS @Cmp_ID,@Loan_ID,@Standard_Interest_Rates,@Standard_Interest_Effective_date  
      End   
   
   -- Add By Mukti 05072016(start)  
    exec P9999_Audit_get @table = 'T0040_LOAN_MASTER' ,@key_column='Loan_ID',@key_Values=@Loan_ID,@String=@String output  
    set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))    
   -- Add By Mukti 05072016(end)   
    end  
  end   
 else if @tran_type ='U'   
    begin  
      
   --added jimit 12042016  
   If exists (Select Loan_ID  from dbo.T0040_LOAN_MASTER WITH (NOLOCK)  
      Where Upper(Loan_Name) = Upper(@Loan_Name)   
        and Cmp_ID = @Cmp_ID and Loan_ID <> @Loan_Id)   
    or exists (Select Loan_ID  from dbo.T0040_LOAN_MASTER WITH (NOLOCK)  
      Where (IsNull(@Loan_Short_Name ,'') <> '' AND  Upper(Loan_Short_Name) = Upper(@Loan_Short_Name))  
        and Cmp_ID = @Cmp_ID and Loan_ID <> @Loan_Id)   
    Begin  
     set @Loan_ID=0  
     RETURN  
    End  
    --ended  
    -- Add By Mukti 05072016(start)  
      exec P9999_Audit_get @table='T0040_LOAN_MASTER' ,@key_column='Loan_ID',@key_Values=@Loan_ID,@String=@String output  
      Select @String  
      set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
    -- Add By Mukti 05072016(end)  
      
     Update dbo.T0040_LOAN_MASTER   
     Set Loan_Name = @Loan_Name,  
      Loan_Max_Limit=@Loan_Max_Limit,  
      Loan_Comments=@Loan_Comments,  
      Company_Loan =@Company_Loan,  
      Max_Limit_on_Basic_Gross = @Max_Limit_on_Basic_Gross,  
      Allowance_Id_String_Max_Limit = @Allowance_Id_String_Max_Limit,  
      No_Of_Times = @No_Of_Times,  
      Loan_Guarantor = @Loan_Guarantor,  
      Desig_max_limit = @Maxlimit_Desigwise,  
      Is_Interest_Subsidy_Limit = @Is_Interest_Subsidy_Limit,  -- Added by Gadriwala 08122014  
      Interest_Recovery_Per=  @Interest_Recovery_Per, -- Added by Gadriwala 08122014  
      Subsidy_Desig_Id_String = @Subsidy_Desig_Id_String, -- Added by Gadriwala 08122014  
      Loan_Interest_Type = @Interest_Type,   --Added by Gadriwala Muslim 10032015  
      Loan_Interest_Per = @Interest_Per, --Added by Gadriwala Muslim 10032015  
      Is_Attachment = @Is_Attachment, --Added by Gadriwala Muslim 11032015  
      Is_Eligible = @Is_Eligible, --Added by Gadriwala Muslim 12032015  
      Eligible_Days = @Eligible_Days, --Added by Gadriwala Muslim 12032015  
      Subsidy_Bond_Days = @Subsidy_Bond_Days, -- Added by Gadriwala Muslim 10042015  
      Is_GPF = @Is_GPF, -- Added by Nilesh Patel on 15072015  
      GPF_Eligible_Month = @Eligible_Afte_Join_Month, -- Added by Nilesh Patel on 15072015  
      GPF_days_diff_application  = @Min_Day_Btn_two_App, -- Added by Nilesh Patel on 15072015  
      GPF_Max_Loan_per = @Max_GPF_Amount_Per, -- Added by Nilesh Patel on 15072015  
      Is_Principal_First_than_Int = @Is_Principal_First_than_Int, -- Added by Nilesh Patel on 20072015  
      Loan_Guarantor2=@Loan_Guarantor2,  --Mukti 17112015  
      Is_Grade_Wise = @Loan_Is_Grade_Wise,  
      Grade_Details = @Loan_Grade_Details,  
      Loan_Short_Name = @Loan_Short_Name  --added jimit 12042016  
      ,Is_Subsidy_Loan =@Is_Subsidy_Loan  
      ,Subsidy_Bond_month=@Subsidy_Bond_month  
      ,Is_Intrest_Amount_As_Perquisite_IT = @Is_Intrest_Amount_As_Perquisite_IT  
      ,Hide_Loan_Max_Amount = @Hide_Loan_Max_Amount  
      ,Loan_Application_Reason_Required = @Loan_Application_Reason_Required  --Added By Jimit 16102018  
      ,Max_Installment = @Max_Installment  --Added By Jimit 16102018  
	  ,IsContractDue = @IsContractDue --Added by ronakk 27032023
	  ,ContractDueDays = @ContractDueDays --Added by ronakk 27032023
      where Loan_ID = @Loan_ID and Cmp_ID = @Cmp_ID   
        
        
        
   -- Add By Mukti 05072016(start)  
    exec P9999_Audit_get @table = 'T0040_LOAN_MASTER' ,@key_column='Loan_ID',@key_Values=@Loan_ID,@String=@String output  
    set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))    
   -- Add By Mukti 05072016(end)   
     
     -- Added by nilesh patel on 17102014 --start  
     IF @Maxlimit_Desigwise = 1  
     begin   
       Create table #Loan_Max_limit_1  
                         (  
                        ID varchar(max),  
                        Amount varchar(max)  
                         )  
                         Select @Max_Design_Tran_id = ISNULL(Trans_ID,0) from dbo.T0040_Loan_Maxlimit_Design WITH (NOLOCK) where Loan_ID = @Loan_ID   
       if @Max_Design_Tran_id <> 0  
       Begin  
        Insert INTO #Loan_Max_limit_1  
        SELECT LEFT(data,CHARINDEX(',',data)-1), right(data,LEN(data)-CHARINDEX(',',data)) FROM dbo.Split(@Allowance_Id_String_Max_Limit,'#')  
          
        update  dbo.T0040_Loan_Maxlimit_Design  
        Set Loan_Max_Limit = (SELECT cast(Amount as numeric) From #Loan_Max_limit_1 where ID = Desig_Id)  
        where Loan_ID = @Loan_ID   
       End  
      Else  
       Begin  
         set @Trans_ID = 0  
                    
         DECLARE Loan_Cursor CURSOR FOR SELECT LEFT(data,CHARINDEX(',',data)-1), right(data,LEN(data)-CHARINDEX(',',data)) FROM dbo.Split(@Allowance_Id_String_Max_Limit,'#')  
                      
         OPEN Loan_Cursor   
           fetch next from Loan_Cursor into @ID,@Amount  
         while @@fetch_status = 0  
          Begin  
             
            select @Trans_ID = isnull(max(Trans_ID),0) + 1 from dbo.T0040_Loan_Maxlimit_Design WITH (NOLOCK)  
              
            insert into dbo.T0040_Loan_Maxlimit_Design(Trans_ID,Loan_ID,Desig_Id,Loan_Max_Limit)  
            VALUES(@Trans_ID,@Loan_ID,cast(@ID AS numeric(18,0)),cast(@Amount AS numeric(18,2)))  
              
            fetch next from Loan_Cursor into @ID,@Amount  
          End  
         Close Loan_Cursor   
         deallocate Loan_Cursor  
       End   
     end   
     Else  
      Begin  
       delete  from dbo.T0040_Loan_Maxlimit_Design where Loan_ID=@Loan_ID    
      End   
     -- Added by nilesh patel on 17102014 --End  
     --Added by Gadriwala Muslim 09122014 - Start  
     If isnull(@Is_Interest_Subsidy_Limit,0) = 1  
      begin  
       If exists(select 1 from T0040_Subsidy_Max_Limit_Design_Wise WITH (NOLOCK) where Loan_ID = @Loan_ID)  
        begin   
           Create table #Loan_Max_limit_2  
           (  
             ID varchar(max),  
             Amount varchar(max)  
           )  
           Insert INTO #Loan_Max_limit_2  
           SELECT LEFT(data,CHARINDEX(',',data)-1), right(data,LEN(data)-CHARINDEX(',',data)) FROM dbo.Split(@Subsidy_Desig_Id_String ,'#')  
             
           Update dbo.T0040_Subsidy_Max_Limit_Design_Wise  
              set Subsidy_Max_Limit = (SELECT cast(Amount as numeric) From #Loan_Max_limit_2 where ID = Design_Id)  
               where Loan_ID = @Loan_ID  
        end  
       else  
        begin  
         set @Trans_ID = 0  
                    
           DECLARE Subsidy_Cursor CURSOR FOR SELECT LEFT(data,CHARINDEX(',',data)-1), right(data,LEN(data)-CHARINDEX(',',data)) FROM dbo.Split(@Subsidy_Desig_Id_String ,'#')  
                      
            OPEN Subsidy_Cursor   
              fetch next from Subsidy_Cursor into @ID,@Amount  
            while @@fetch_status = 0  
             Begin  
                
               select @Trans_ID = isnull(max(Tran_ID),0) + 1 from dbo.T0040_Subsidy_Max_Limit_Design_Wise WITH (NOLOCK)  
                 
               insert into dbo.T0040_Subsidy_Max_Limit_Design_Wise(Tran_ID,Loan_ID,Design_ID,Subsidy_Max_Limit)  
               VALUES(@Trans_ID,@Loan_ID,cast(@ID AS numeric(18,0)),cast(@Amount AS numeric(18,2)))  
                 
               fetch next from Subsidy_Cursor into @ID,@Amount  
             End  
            Close Subsidy_Cursor   
            deallocate Subsidy_Cursor    
            
        end  
           
      end  
     --Added by Gadriwala Muslim 09122014 - End  
       
     if @Is_Intrest_Amount_As_Perquisite_IT = 1   
      Begin  
       Exec P0050_LOAN_INTEREST_DETAILS @Cmp_ID,@Loan_ID,@Standard_Interest_Rates,@Standard_Interest_Effective_date  
      End   
     Else  
      Begin  
       Delete  from dbo.T0050_Loan_Interest_Details where Loan_ID = @Loan_ID  
      End  
    end    
      
 else if @tran_type ='d' or @tran_type ='D'   
   begin  
    -- Add By Mukti 05072016(start)  
      exec P9999_Audit_get @table='T0040_LOAN_MASTER' ,@key_column='Loan_ID',@key_Values=@Loan_ID,@String=@String output  
      set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
    -- Add By Mukti 05072016(end)  
      
    delete  from dbo.T0040_LOAN_MASTER where Loan_ID=@Loan_ID     
    delete  from dbo.T0040_Loan_Maxlimit_Design where Loan_ID=@Loan_ID  -- Added by nilesh patel on 17102014  
    delete  from dbo.T0040_Subsidy_Max_Limit_Design_Wise where Loan_ID = @Loan_ID -- Added by Gadriwala Muslim 09122014    
    delete  from dbo.T0050_Loan_Interest_Details where Loan_ID = @Loan_ID   
   End  
   exec P9999_Audit_Trail @CMP_ID,@Tran_type,'Loan Master',@OldValue,@Loan_ID,@User_Id,@IP_Address  
RETURN  
  
  