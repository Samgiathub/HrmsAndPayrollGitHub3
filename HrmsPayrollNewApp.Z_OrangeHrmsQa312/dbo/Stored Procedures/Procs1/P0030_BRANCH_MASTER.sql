      
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---      
CREATE PROCEDURE [dbo].[P0030_BRANCH_MASTER]        
 @Branch_ID   numeric(9) output        
   ,@Cmp_ID    numeric(9)        
   ,@State_ID   numeric(9)        
   ,@Branch_Code  varchar(50)        
   ,@Branch_Name  varchar(100)        
   ,@Branch_City  varchar(30)        
   ,@Branch_Address  varchar(2000)        
   ,@Comp_Name   varchar(200)        
   ,@tran_type   varchar(1)       
   ,@Is_Contractor_Branch tinyint =0  
   ,@User_Id   numeric(18,0) = 0 
   ,@IP_Address   varchar(30)= ''  
   ,@Loc_Id    numeric(9) = 0     
   ,@District_Id    numeric(9) = 0 
   ,@Tehsil_Id    numeric(9) = 0 
   ,@RC_No    Varchar(50) = '' 
   ,@Zone    Varchar(50) = '' 
   ,@Ward_No   Varchar(50) = '' 
   ,@Census_No   Varchar(50) = '' 
   ,@IsActive   tinyint=1      
   ,@InEffeDate   datetime  = NULL      
   ,@PF_No    VARCHAR(20)  = NULL 
   ,@ESIC_No   VARCHAR(20)  = NULL 
   ,@GUID    VARCHAR(2000)= '' 
   ,@Import_Flag  tinyint=0   
   ,@Sal_St_Date  DATETIME  = NULL 
   ,@CopyHolidayFrom NUMERIC(18,0)= 0 
   ,@CopyHolidaySince DATETIME  = NULL 
   ,@ContPersonName  VARCHAR(50) = '' 
   ,@ContEmail   VARCHAR(50) = ''   
   ,@ContMobileNo  varchar(30) = '' 
   ,@ContAadhaar  VARCHAR(30) = ''  
   ,@ContGSTNumber  VARCHAR(30) = ''  
   ,@NatureOfWork  VARCHAR(500) = ''  
   ,@NoOfLabourEmp  NUMERIC(18,0) = 0
   ,@DateOfCommencement DATETIME = ''    
   ,@DateOfTermination DATETIME = ''   
   ,@VendorCode   VARCHAR(20) = '' 
   ,@ContTransType  char(1) = ''      
   ,@ContDetId   NUMERIC(18,0) = 0     
   ,@LICENCE_DOC VArchar(50) = ''
AS        
SET NOCOUNT ON       
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED      
SET ARITHABORT ON      
      
      
 declare @loginname as varchar(50)        
 Declare @Domain_Name as varchar(50)        
 Declare @Pre_Code as varchar(50)        
 Declare @For_DAte Datetime         
 Declare @Gen_ID  numeric         
 declare @OldValue as varchar(max)      
 set @OldValue = ''      
      
  -- Add By Mukti 05082016(start)      
 Declare @String as varchar(max)      
 set @String=''       
 -- Add By Mukti 05082016(end)       
   set @Branch_Name = dbo.fnc_ReverseHTMLTags(@Branch_Name)  --added by mansi 061021    
    set @Branch_Code = dbo.fnc_ReverseHTMLTags(@Branch_Code)  --added by mansi 121021 
	 set @Branch_Address = dbo.fnc_ReverseHTMLTags(@Branch_Address)  --added by mansi 121021 
	  set @Comp_name = dbo.fnc_ReverseHTMLTags(@Comp_name)  --added by mansi 121021 
 
	
         
 If @State_ID = 0        
  set @State_ID = 0        
          
  if @Comp_Name =''        
    set @Comp_Name =null        
          
  if @InEffeDate=''      
   set @InEffeDate=null        
          
   If @tran_type  = 'I' Or @tran_type = 'U'      
 BEGIN       
  If @Branch_Code = ''      
   BEGIN      
    Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Branch Code is not Properly Inserted',0,'Enter Proper Branch Code:(Branch Name : ' + @Branch_Name + ')',GetDate(),'Branch Master',@GUID)            
    Return      
   END      
        
  If @Branch_Name = ''      
   BEGIN      
    Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Branch Name is not Properly Inserted',0,'Enter Proper Branch Name:(Branch Name : ' + @Branch_Name + ')',GetDate(),'Branch Master',@GUID)            
    Return      
   END      
       
  If @Branch_City = '' and @Import_Flag = 0      
   BEGIN      
  Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Branch City is not Properly Inserted: (Branch Name : ' + @Branch_Name + ')',0,'Enter Proper Branch City',GetDate(),'Branch Master',@GUID)            
    Return      
   END      
        
  If @State_ID = 0 and @Import_Flag = 0      
   BEGIN      
    Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'State Name is not Properly Inserted',0,'Enter Proper State Name:(Branch Name : ' + @Branch_Name + ')',GetDate(),'Branch Master',@GUID)            
    Return      
   END      
         
  If @Loc_Id = 0 and @Import_Flag = 0      
   BEGIN      
    Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Country Name is not Properly Inserted',0,'Enter Proper Country Name:(Branch Name : ' + @Branch_Name + ')',GetDate(),'Branch Master',@GUID)            
    Return      
   END     
   
   --Added by Ronakk 17022022
         
		 --Comment by ronakk 15032022

		-- If @District_Id = 0 and @Import_Flag = 0      
		--BEGIN      
		-- Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'District Name is not Properly Inserted',0,'Enter Proper District Name:(Branch Name : ' + @Branch_Name + ')',GetDate(),'Branch Master',@GUID)            
		-- Return      
		--END  


		--If @Tehsil_Id = 0 and @Import_Flag = 0      
		--BEGIN      
		-- Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Tehsil Name is not Properly Inserted',0,'Enter Proper Tehsil Name:(Branch Name : ' + @Branch_Name + ')',GetDate(),'Branch Master',@GUID)            
		-- Return      
		--END  

   --End by Ronakk 17022022

  if exists(Select 1 From T0030_BRANCH_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Upper(Branch_Code) = Upper(@Branch_Code) and Branch_ID <> @Branch_ID)      
   BEGIN         
    Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Same Branch Code is exists',0,'Please Enter valid branch code :(Branch Code : ' + @Branch_Code + ')',GetDate(),'Branch Master',@GUID)            
    Return      
   End      
  Set @Branch_Name = LTRIM(@Branch_Name)      
  Set @Branch_Name = RTRIM(@Branch_Name)      
  if exists(Select 1 From T0030_BRANCH_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Upper(Branch_Name) = Upper(@Branch_Name) and Branch_ID <> @Branch_ID)      
   BEGIN      
    Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Same Branch Name is exists',0,'Please Enter valid branch name :(Branch Name : ' + @Branch_Name + ')',GetDate(),'Branch Master',@GUID)            
    Return      
   End      
 END      
        
 If @tran_type  = 'I'        
  Begin        
  if exists (Select Branch_ID  from dbo.T0030_BRANCH_MASTER WITH (NOLOCK) Where Upper(Branch_Name) = Upper(@Branch_Code) and Cmp_ID = @Cmp_ID)         
    begin        
  Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Enter Valid Branch Details',0,'Same Branch Details are already exists in Branch Master:(Branch Name : ' + @Branch_Name + ')',GetDate(),'Branch Master',@GUID)            
  set @Branch_ID = 0        
     Return        
    end        
          
    select @Branch_ID = Isnull(max(Branch_ID),0) + 1  From dbo.T0030_BRANCH_MASTER   WITH (NOLOCK)      
      
	  --Change by Ronakk 17022022

    INSERT INTO dbo.T0030_BRANCH_MASTER        
               (Branch_ID, Cmp_ID, State_ID,Branch_Code, Branch_Name, Branch_City, Branch_Address,Comp_name,Is_Contractor_Branch,Location_ID,District_ID,Tehsil_ID,PT_RC_No,PT_Zone,PT_Ward_No,PT_Census_No,IsActive,InActive_EffeDate,PF_No,ESIC_No)  -- Added By Ali 03122013      
    VALUES     (@Branch_ID,@Cmp_ID,@State_ID,@Branch_Code,@Branch_Name,@Branch_City,@Branch_Address,@Comp_name,@Is_Contractor_Branch,@Loc_Id, @District_Id,@Tehsil_Id,@RC_No,@Zone,@Ward_No,@Census_No,@IsActive,@InEffeDate,@PF_No,@ESIC_No)  -- Added By Ali 03122013      
          
 --Deepal 23072020      
 if @ContPersonName <> ''      
 BEGIN      
  exec P0035_CONTRACTOR_DETAIL_MASTER @Branch_ID ,@ContPersonName ,@ContEmail ,@ContMobileNo ,@ContAadhaar ,@ContGSTNumber ,@NatureOfWork ,@NoOfLabourEmp ,@DateOfCommencement ,@DateOfTermination ,@VendorCode ,@tran_type , 0,@LICENCE_DOC      
 END      
 --End Deepal 23072020      
    select @Domain_Name = Domain_Name From  T0010_COMPANY_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID         
            
    set @loginname = @Branch_Code + @Domain_Name      
          
          
    Select @For_Date = case when isnull(@Sal_St_Date,'1900-01-01') = '1900-01-01' then From_Date Else @Sal_St_Date End From T0010_Company_Master WITH (NOLOCK) Where Cmp_ID =@Cmp_ID        
    set @Gen_ID = 0  --Above Condition added by Sumit on 12122016      
         
        
    Exec P0040_GENERAL_SETTING   @Gen_ID output ,@Cmp_ID,@Branch_ID,@For_Date,1,1,0,'00:00',0,1,0,0,1,1,0,0,0,'',0,0,0,1,0,0,0,'00:00','00:00','00:00','00:00',0,'00:00',1,21000,3.25,0,0,'00:00',0,0,0,0,0,@For_Date,0,1,'I',@For_Date,5/*Gr_Min_Year*/,0,26/*
  
    
Gr_ProRata_Cal*/,1,0,0,15/*Gr_Days*/,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,'',0,0,0,0,'',0,0,0,'',0,0,0,0,1,0,0,'',0,0,'',0,0,0,0,'',0,0,0,0,'','',0,0,0,0,0,0,0,'',0,@User_Id,@IP_Address   ,'00:00','00:00',7000,0,
  
    
0,0,21000  /*  ,'00:00','00:00',7000,0,0,0,21000 Bonus Limit --Ankit 22032016 */             
         
          
    if @Gen_ID > 0         
     --Exec P0050_GENERAL_DETAIL 0,@Cmp_ID,@Gen_ID,3.67,12,1.1,8.33,0.5,0.01,15000,15000,'I'   --commented by Hardik 13/03/2015 as PF rule changed A/c. 2 1.10 to 0.85 from 01/01/2015      
     Exec P0050_GENERAL_DETAIL 0,@Cmp_ID,@Gen_ID,3.67,12,0.50,8.33,0.5,0.00,15000,15000,'I'         
           
 ----added by Krushna for default gujarat state PT slab add 15-10-2019      
 --    exec P0040_PROFESSIONAL_SETTING @Cmp_ID,@Branch_ID,@For_Date,1,1,5999,0,'I','ALL'      
 --    exec P0040_PROFESSIONAL_SETTING @Cmp_ID,@Branch_ID,@For_Date,2,6000,8999,80,'I','ALL'      
 --    exec P0040_PROFESSIONAL_SETTING @Cmp_ID,@Branch_ID,@For_Date,3,9000,11999,150,'I','ALL'      
 --    exec P0040_PROFESSIONAL_SETTING @Cmp_ID,@Branch_ID,@For_Date,4,12000,9999999999,200,'I','ALL'      
           
    --Added by Jaina 11-04-2018 Start      
     ---------------------- Professional Tax -------------------------------      
        
   --declare @Row_ID numeric(18,0)      
   --select @Row_ID = Isnull(max(Row_ID),0) + 1  From T0040_PROFESSIONAL_SETTING      
         
   --insert INTO T0040_PROFESSIONAL_SETTING (Cmp_ID,Branch_ID,For_Date,Row_ID,From_Limit,To_Limit,Amount,Applicable_PT_Male_Female)      
   --SELECT @Cmp_id,@Branch_ID,PT.For_Date,@Row_ID + ROW_NUMBER() over (ORDER BY Row_ID) As Row_ID,      
   --  PT.From_Limit,PT.To_Limit,PT.Amount,PT.Applicable_PT_Male_Female      
   --   FROM T0040_PROFESSIONAL_SETTING PT       
   --  INNER JOIN T0030_BRANCH_MASTER BM ON PT.Branch_ID=BM.Branch_ID      
   --  INNER JOIN (SELECT TOP 1 BRANCH_ID FROM T0030_BRANCH_MASTER       
   --     WHERE State_ID=@State_ID AND Cmp_ID = @Cmp_id) BM1 ON BM.Branch_ID=BM1.Branch_ID      
   --WHERE BM.CMP_ID = @CMP_ID           
                   
     ---------------------- Professional Tax -------------------------------      
    --Added by Jaina 11-04-2018 End      
          
     --Added By Ramiz on 23/07/2018 for Adding Holidays Automatically from Old Branch --       
   IF @CopyHolidayFrom > 0 AND @CopyHolidaySince <> ''      
   BEGIN      
    DECLARE @FROM_HOLIDAY AS NUMERIC      
    DECLARE @NEW_Hday_ID AS NUMERIC      
      
     DECLARE Holiday_Cursor CURSOR FOR       
     SELECT Hday_ID FROM T0040_HOLIDAY_MASTER WITH (NOLOCK) WHERE Branch_ID = @CopyHolidayFrom AND CMP_ID = @Cmp_ID AND (H_From_Date >= @CopyHolidaySince OR Is_Fix = 'Y')      
     OPEN Holiday_Cursor       
       FETCH NEXT FROM Holiday_Cursor INTO @FROM_HOLIDAY      
     WHILE @@FETCH_STATUS = 0      
      BEGIN      
             
       SELECT @NEW_Hday_ID = Isnull(MAX(Hday_ID),0) + 1  From dbo.T0040_HOLIDAY_MASTER WITH (NOLOCK)      
            
       INSERT INTO T0040_HOLIDAY_MASTER      
        (Hday_ID,cmp_Id,Hday_Name,H_From_Date ,H_To_Date ,Is_Fix,Hday_Ot_setting,Branch_ID,Is_Half,Is_P_Comp,Message_Text,Sms,is_National_Holiday, Is_optional,Multiple_Holiday,Is_Unpaid_Holiday)      
       SELECT @NEW_Hday_ID,Cmp_Id,Hday_Name,H_From_Date ,H_To_Date ,Is_Fix,Hday_Ot_setting,@Branch_ID,Is_Half,Is_P_Comp,Message_Text,Sms,is_National_Holiday, Is_optional,Multiple_Holiday,Is_Unpaid_Holiday      
       FROM T0040_HOLIDAY_MASTER WITH (NOLOCK)      
       WHERE Cmp_Id = @Cmp_ID AND Hday_ID = @FROM_HOLIDAY      
             
       FETCH NEXT FROM Holiday_Cursor INTO @FROM_HOLIDAY      
      END      
     CLOSE Holiday_Cursor       
     DEALLOCATE Holiday_Cursor      
   END      
           
  -- Add By Mukti 05082016(start)      
   exec P9999_Audit_get @table = 'T0030_BRANCH_MASTER' ,@key_column='Branch_ID',@key_Values=@Branch_ID,@String=@String output      
   set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))      
  -- Add By Mukti 05082016(end)              
  End        
 Else if @Tran_Type = 'U'        
  begin        
   IF Exists(select Branch_ID From dbo.T0030_BRANCH_MASTER WITH (NOLOCK) Where upper(Branch_Name) = upper(@Branch_Name) and Cmp_ID = @Cmp_ID and Branch_ID <> @Branch_ID)        
  Begin       
    set @Branch_ID = 0        
    Return         
  End        
      
    select @Domain_Name = Domain_Name From  T0010_COMPANY_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID         
            
    select @Pre_Code = Branch_Code From dbo.T0030_BRANCH_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID           
       
 -- Add By Mukti 05072016(start)      
   exec P9999_Audit_get @table='T0030_BRANCH_MASTER' ,@key_column='Branch_ID',@key_Values=@Branch_ID,@String=@String output      
   set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))      
  -- Add By Mukti 05072016(end)      
               
          
   UPDATE    dbo.T0030_BRANCH_MASTER        
   SET              Cmp_ID = @Cmp_ID,          
        Branch_Code=@Branch_Code,        
                    Branch_Name = @Branch_Name,         
                    Branch_City = @Branch_City,         
                    Branch_Address = @Branch_Address,        
                    State_ID = @State_ID,         
                    Comp_Name = @Comp_Name,      
                    Is_Contractor_Branch = @Is_Contractor_Branch,      
        Location_ID = @Loc_Id ,-- Added By Ali 03122013   
		
		 District_ID = @District_Id ,  --Added by ronakk 17022022
		 Tehsil_ID = @Tehsil_Id , --Added by ronakk 17022022 


        PT_RC_No = @RC_No,      
        PT_Zone = @Zone,      
        PT_Ward_No  = @Ward_NO,      
        PT_Census_No = @Census_No,      
        IsActive=@IsActive,      
        InActive_EffeDate=@InEffeDate,      
        PF_No = @PF_No,      
        ESIC_No = @ESIC_No      
   where Branch_ID = @Branch_ID        
        
  --Deepal 23072020      
  IF @CONTTRANSTYPE  = 'I'      
  BEGIN      
   EXEC P0035_CONTRACTOR_DETAIL_MASTER @BRANCH_ID ,@CONTPERSONNAME ,@CONTEMAIL ,@CONTMOBILENO ,@CONTAADHAAR ,@CONTGSTNUMBER ,@NATUREOFWORK ,@NOOFLABOUREMP ,@DATEOFCOMMENCEMENT ,@DATEOFTERMINATION ,@VENDORCODE , @CONTTRANSTYPE , 0 , @LICENCE_DOC     
  END      
  ELSE      
  BEGIN       
   if @ContPersonName <> ''      
   Begin      
    EXEC P0035_CONTRACTOR_DETAIL_MASTER @BRANCH_ID ,@CONTPERSONNAME ,@CONTEMAIL ,@CONTMOBILENO ,@CONTAADHAAR ,@CONTGSTNUMBER ,@NATUREOFWORK ,@NOOFLABOUREMP ,@DATEOFCOMMENCEMENT ,@DATEOFTERMINATION ,@VENDORCODE , @TRAN_TYPE , @ContDetId ,@LICENCE_DOC     
   End      
  END      
 --End Deepal 23072020      
      
  -- Add By Mukti 05082016(start)      
  exec P9999_Audit_get @table = 'T0030_BRANCH_MASTER' ,@key_column='Branch_ID',@key_Values=@Branch_ID,@String=@String output      
   set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))      
  -- Add By Mukti 05082016(end)              
  end        
 Else if @Tran_Type = 'D'        
  begin          
  -- Add By Mukti 05072016(start)      
   exec P9999_Audit_get @table='T0030_BRANCH_MASTER' ,@key_column='Branch_ID',@key_Values=@Branch_ID,@String=@String output      
   set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))      
  -- Add By Mukti 05072016(end)      
        
   Delete From T0040_PROFESSIONAL_SETTING where Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID       
   Delete From T0040_WEEKOFF_MASTER where Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID       
        
    -------------Start by Ramiz on 10092014--------------------------      
  declare @Gen_Id_T numeric      
      
  declare Cur_delete Cursor for      
   select gen_id from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID= @Cmp_ID and Branch_id = @Branch_ID      
    open Cur_delete      
     fetch next from Cur_delete into @Gen_Id_T      
     While @@FETCH_STATUS = 0      
     begin      
      Delete from T0050_General_Detail where gen_Id = @Gen_Id_T and CMP_ID = @Cmp_ID       
      Exec P0040_GENERAL_SETTING   @Gen_Id_T output ,@Cmp_ID,@Branch_ID,@For_Date,1,1,0,'00:00',0,1,0,0,1,1,0,0,0,'',0,0,0,1,0,0,0,'00:00','00:00','00:00','00:00',0,'00:00',1,15000,3.25,0,0,'00:00',0,0,0,0,0,@For_Date,0,1,'D',@For_Date,0,0,0,1,0,0,0,0,0,0
  
    
,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,'',0,0,0,0,'',0,0,0,'',0,0,0,0,1,0,0,'',0,0,'',0,0,0,0,'',0,0,0,0,'','',0,0,0,0,0,0,0,'',0,@User_Id,@IP_Address        
     fetch next from Cur_delete into @Gen_Id_T      
     end      
    close Cur_delete      deallocate Cur_delete      
          
    -------------Ended by Ramiz on 10092014--------------------------      
          
       
 DELETE FROM dbo.T0040_HOLIDAY_MASTER WHERE Branch_ID = @Branch_ID  and Cmp_ID = @Cmp_ID --Added By Ramiz on 25/07/2018      
 DELETE FROM DBO.T0035_CONTRACTOR_DETAIL_MASTER WHERE BRANCH_ID = @BRANCH_ID  --Deepal on 23/07/2020      
    DELETE FROM dbo.T0030_BRANCH_MASTER WHERE Branch_ID = @Branch_ID  and Cmp_ID = @Cmp_ID       
          
  END          
 EXEC P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Branch Master',@OldValue,@Branch_ID,@User_Id,@IP_Address      
      
 RETURN        
        
        