  
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_CURRENCY_MASTER]  
   @Curr_ID numeric(18,0) output  
  ,@Cmp_ID numeric(18,0)  
  ,@Curr_Name varchar(50)  
  ,@Curr_Rate numeric(18,2)  
  ,@Curr_Major char(1)  
  ,@Curr_Symbol varchar(10)  
  ,@Curr_Sub_Name varchar(50)   
  ,@tran_type varchar(1)  
   
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
    set @Curr_Name = dbo.fnc_ReverseHTMLTags(@Curr_Name)  --added by Ronak 081021   
	set @Curr_Symbol = dbo.fnc_ReverseHTMLTags(@Curr_Symbol)  --added by Ronak 081021
	set @Curr_Sub_Name = dbo.fnc_ReverseHTMLTags(@Curr_Sub_Name)  --added by Ronak 081021

  if @Tran_type ='i'   
   begin  
   if exists(select Curr_ID from T0040_Currency_Master WITH (NOLOCK) where Upper(Curr_Name) = Upper(@Curr_Name) and Cmp_ID = @Cmp_ID)  
    begin  
     set @Curr_ID = 0  
     return  
    end  
      
    select @Curr_ID = isnull(max(Curr_ID),0) + 1 From T0040_CURRENCY_MASTER WITH (NOLOCK)  
      
    insert into T0040_CURRENCY_MASTER(  
       Curr_ID   
      ,Cmp_ID   
      ,Curr_Name   
      ,Curr_Rate   
      ,Curr_Major   
      ,Curr_Symbol   
      ,Curr_Sub_Name   
      )  
     values(  
             @Curr_ID   
      ,@Cmp_ID   
      ,@Curr_Name   
      ,@Curr_Rate   
      ,@Curr_Major   
      ,@Curr_Symbol   
      ,@Curr_Sub_Name   
      )   
      
   IF  @Curr_Major = 'Y'  
    BEGIN  
     UPDATE T0040_CURRENCY_MASTER set Curr_Major = 'N' where Curr_ID <> @Curr_ID and Cmp_ID = @Cmp_ID  
    END  
  End   
 Else If @tran_type ='u'   
    begin  
    if exists(select Curr_ID from T0040_Currency_Master WITH (NOLOCK) where Upper(Curr_Name) = Upper(@Curr_Name)   
         and Cmp_ID = @Cmp_ID and Curr_ID <> @Curr_ID )  
     begin  
          
      set @Curr_ID = 0  
      return  
     end  
  
     UPDATE  T0040_CURRENCY_MASTER  
     SET     Curr_Name = @Curr_Name,   
       Curr_Major = @Curr_Major,   
       Curr_Rate = @Curr_Rate,   
       Curr_Symbol = @Curr_Symbol,   
             Curr_Sub_Name = @Curr_Sub_Name  
     where Curr_ID  = @Curr_ID  
       
    IF  @Curr_Major = 'Y'  
      BEGIN  
        
       UPDATE T0040_CURRENCY_MASTER set Curr_Major = 'N' where Curr_ID <> @Curr_ID and Cmp_ID = @Cmp_ID   
      END  
    end  
 Else If @tran_type ='d'   
   Begin  
   if Exists(select Curr_ID from T0180_CURRENCY_CONVERSION WITH (NOLOCK) where Cmp_ID=@CMP_ID and Curr_ID=@Curr_ID)  
      begin  
       RAISERROR('@@ Reference Exists @@',16,2)  
       RETURN   
   end   
     if Exists(select Curr_ID from T0140_Travel_Settlement_Expense WITH (NOLOCK) where Cmp_ID=@CMP_ID and Curr_ID=@Curr_ID)  
      begin  
       RAISERROR('@@ Reference Exists @@',16,2)  
       RETURN   
      end   
     if Exists(select Curr_ID from T0130_Travel_Approval_Other_Detail WITH (NOLOCK) where Cmp_ID=@CMP_ID and Curr_ID=@Curr_ID)  
      begin  
       RAISERROR('@@ Reference Exists @@',16,2)  
       RETURN   
      end    
        
    
   DELETE FROM T0040_CURRENCY_MASTER where Curr_ID  = @Curr_ID  
   End  
     
     
 RETURN  
  
  
  
  