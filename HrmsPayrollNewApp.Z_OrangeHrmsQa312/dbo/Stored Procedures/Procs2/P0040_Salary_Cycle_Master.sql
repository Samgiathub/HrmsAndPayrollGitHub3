  
  
  
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_Salary_Cycle_Master]  
@Tran_ID as numeric output,  
@Cmp_ID numeric(18,0),  
@Name As Varchar(100),  
@Salary_St_Date As Datetime,  
@tran_type as char(1),  
@User_Id numeric(18,0) = 0 ,  
@IP_Address varchar(30)= ''   
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
 declare @OldValue as varchar(max)  
 declare @Old_Name as varchar(50)   
 declare @Old_Start_Date as datetime  
   
 set @OldValue = ''  
 set @Old_Name = ''  
 set @Old_Start_Date = NULL  
     set @Name = dbo.fnc_ReverseHTMLTags(@Name)  --added by Ronak 081021
BEGIN  
 if @tran_type = 'I'  
 begin  
    If  Exists(Select 1 From T0040_Salary_Cycle_Master WITH (NOLOCK) Where Cmp_Id = @Cmp_ID And   
       (upper(Name) = upper(@Name) or day(Salary_st_date) = day(@Salary_St_Date)) )  
   begin  
    set @Tran_ID = 0  
    Return  
   end        
         
   INSERT INTO T0040_Salary_Cycle_Master (Cmp_id, Name, Salary_st_date)  
   VALUES (@Cmp_id,@Name,@Salary_st_date)  
      
   select @Tran_ID = Tran_ID from T0040_Salary_Cycle_Master WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Name = @Name  
     
   -- Added By Ali 04102013 - Start  
     
   set @OldValue = 'New Value # Salary Cycle Name : ' +ISNULL( @Name,'') + '# Cmp Id : ' + CONVERT(nvarchar(10),@Cmp_ID) + '# Salary Start Date : ' + convert(nvarchar(21),@Salary_St_Date)  
   exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Salary Cycle Master',@OldValue,@Tran_ID,@User_Id,@IP_Address  
   -- Added By Ali 04102013 - End  
     
     
  end  
 else if  @tran_type = 'U'  
 begin  
   If  Exists(Select 1 From T0040_Salary_Cycle_Master WITH (NOLOCK) Where Cmp_Id = @Cmp_ID And   
       upper(Name) = upper(@Name) AND tran_id <> @Tran_ID)  
   begin      
    set @Tran_ID = 0  
    Return  
   end        
     
    -- Added By Ali 04102013 - Start  
     set @Old_Name = (Select Name from T0040_Salary_Cycle_Master WITH (NOLOCK) where Tran_Id = @Tran_ID)  
     set @Old_Start_Date = (Select Salary_st_date from T0040_Salary_Cycle_Master WITH (NOLOCK) where Tran_Id = @Tran_ID)  
     set @OldValue = 'old Value # Salary Cycle Name : ' +ISNULL( @Old_Name,'') + '# Cmp Id : ' + CONVERT(nvarchar(10),@Cmp_ID) + '# Salary Start Date : ' + convert(nvarchar(21),@Old_Start_Date)  
         + ' New Value # Salary Cycle Name : ' +ISNULL( @Name,'') + '# Cmp Id : ' + CONVERT(nvarchar(10),@Cmp_ID) + '# Salary Start Date : ' + convert(nvarchar(21),@Salary_St_Date)  
     exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Salary Cycle Master',@OldValue,@Tran_ID,@User_Id,@IP_Address  
    -- Added By Ali 04102013 - End  
     
    UPDATE    T0040_Salary_Cycle_Master  
    SET  Name = @Name,   
     Salary_st_date = @Salary_st_date  
    WHERE TRan_id = @Tran_ID  
      
 end  
 else if @tran_type = 'D'  
 begin  
     
   if not exists (SELECT 1 from T0095_Emp_Salary_Cycle WITH (NOLOCK) where SalDate_id = @Tran_ID )  
    begin  
     -- Added By Ali 04102013 - Start  
     set @Old_Name = (Select Name from T0040_Salary_Cycle_Master WITH (NOLOCK) where Tran_Id = @Tran_ID)  
     set @Old_Start_Date = (Select Salary_st_date from T0040_Salary_Cycle_Master WITH (NOLOCK) where Tran_Id = @Tran_ID)  
     set @OldValue = 'old Value # Salary Cycle Name : ' +ISNULL( @Old_Name,'') + '# Cmp Id : ' + CONVERT(nvarchar(10),@Cmp_ID) + '# Salary Start Date : ' + convert(nvarchar(21),@Old_Start_Date)  
     exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Salary Cycle Master',@OldValue,@Tran_ID,@User_Id,@IP_Address  
     -- Added By Ali 04102013 - End  
       
     delete from T0040_Salary_Cycle_Master where Tran_ID=@Tran_ID  
      
    end  
   else  
    begin   
     Raiserror('Refernce Exists',16,2)  
    end  
 end  
   
   
END  
  
  
  
  