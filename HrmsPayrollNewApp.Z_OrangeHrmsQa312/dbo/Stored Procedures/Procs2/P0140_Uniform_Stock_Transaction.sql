  
CREATE PROCEDURE [dbo].[P0140_Uniform_Stock_Transaction]  
 @Stock_ID Numeric(18,0) Output,  
 @Cmp_ID Numeric(18,0),  
 @Uni_ID Numeric(18,0),  
 @For_Date Datetime,  
 @No_of_Uniform Numeric(18,0),  
 @tran_type varchar(1),  
 @Modify_by varchar(20),  
 @Ip_Address varchar(25),  
 @Fabric_Price Numeric(18,2)  
AS  
BEGIN  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
 Declare @Stock_Balance Numeric(18,0)  
 Declare @Temp_max_Date Datetime  
 Declare @Pre_Closing numeric(18,2)  
 Declare @Chg_For_Date datetime  
 Declare @Chg_Stock_ID numeric   
 Declare @Temp_Uniform_Bal numeric (18,2)   
 DECLARE @Stock_Opening numeric (18,2)   
 set @Temp_Max_Date = null  
 set @Stock_Balance = 0  
    
 if @tran_type = 'I'  
  Begin  
    
   if @For_Date ='01/01/1900'  
   Begin  
    Set @Stock_ID = 0  
    return  
   End  
     
  -- if EXISTS(Select Stock_ID From T0140_Uniform_Stock_Transaction WITH (NOLOCK) where For_Date=@For_Date and Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID) --commented by mansi 
  if EXISTS(Select Stock_ID From T0140_Uniform_Stock_Transaction WITH (NOLOCK) where For_Date=@For_Date and Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID and Modify_Date=GetDate()) --added by mansi
    BEGIN   
      
     Select @Stock_ID=Stock_ID From T0140_Uniform_Stock_Transaction WITH (NOLOCK) where For_Date=@For_Date and Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID  
     Select Top 1 @Stock_Balance = Stock_Balance From T0140_Uniform_Stock_Transaction WITH (NOLOCK) where Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID  
       
     if NOT EXISTS(select Uni_ID from T0050_Uniform_Master_Detail WITH (NOLOCK)  where Uni_Effective_Date < @For_Date and Uni_ID = @Uni_ID and cmp_ID = @cmp_ID)  
      begin   
       Set @Stock_ID = 0  
       RAISERROR ('Effective date should be greater', 16, 2)  
       RETURN  
      end  
        
     update T0140_Uniform_Stock_Transaction  
     set --Stock_Opening=@Stock_Balance,  
     Stock_Credit=Stock_Credit + @No_of_Uniform,       
     Stock_Balance= (Stock_Opening + Stock_Credit + @No_of_Uniform)-Stock_Debit,  
     Fabric_Price=@Fabric_Price  
     where Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID and For_Date = @For_Date  
    END  
   else  
    BEGIN  
	  
     select @Stock_Balance = isnull(Stock_Balance,0) from T0140_Uniform_Stock_Transaction WITH (NOLOCK)  
     where for_date = (select max(for_date) from T0140_Uniform_Stock_Transaction  WITH (NOLOCK)  
     where for_date < @for_date and Uni_ID = @Uni_ID and cmp_ID = @cmp_ID)   
     and cmp_ID = @cmp_ID and Uni_ID = @Uni_ID  
     --print @Stock_Balance       
     if NOT EXISTS(select Uni_ID from T0050_Uniform_Master_Detail WITH (NOLOCK) where Uni_Effective_Date < @For_Date and Uni_ID = @Uni_ID and cmp_ID = @cmp_ID)  
      begin   
       Set @Stock_ID = 0  
       RAISERROR ('Effective date should be greater', 16, 2)  
       RETURN  
      end  
     Select @Stock_ID = Isnull(Max(Stock_ID),0) + 1 From T0140_Uniform_Stock_Transaction WITH (NOLOCK)   
       
     Insert into T0140_Uniform_Stock_Transaction(Stock_ID,Cmp_ID,Uni_ID,For_Date,Stock_Opening,Stock_Credit,Stock_Debit,Stock_Balance,Stock_Posting,Modify_By,Modify_Date,Ip_Address,Fabric_Price)  
     VALUES(@Stock_ID,@Cmp_ID,@Uni_ID,@For_Date,@Stock_Balance,@No_of_Uniform,0,@Stock_Balance + @No_of_Uniform,0,@Modify_by,SYSDATETIME(),@Ip_Address,@Fabric_Price)        
    END  
      
  if Exists(SELECT 1 From T0140_Uniform_Stock_Transaction WITH (NOLOCK) where Uni_ID = @Uni_ID AND Cmp_ID = @CMP_Id)  
   BEGIN   
  
    if @Pre_Closing is null  
     set @Pre_Closing = 0  
                       
     declare cur1 cursor for   
      Select Stock_ID,For_Date from dbo.T0140_Uniform_Stock_Transaction WITH (NOLOCK) where Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID and for_date > @for_date order by for_date  
     open cur1  
     fetch next from cur1 into @Chg_Stock_ID,@Chg_For_Date  
     while @@fetch_status = 0  
     begin  
        
      select @Pre_Closing = isnull(Stock_Balance,0) from T0140_Uniform_Stock_Transaction WITH (NOLOCK)   
         where for_date = (select max(for_date) from T0140_Uniform_Stock_Transaction  WITH (NOLOCK)   
          where for_date < @Chg_For_Date and Uni_ID = @Uni_ID and cmp_ID = @cmp_ID)   
          and cmp_ID = @cmp_ID and Uni_ID = @Uni_ID  
            
      update dbo.T0140_Uniform_Stock_Transaction set   
        Stock_Opening = @Pre_Closing  
       ,Stock_Balance = @Pre_Closing + Stock_Credit - Stock_Debit   
       ,Stock_Posting=0  
       --Fabric_Price=@Fabric_Price           
      where Stock_ID = @Chg_Stock_ID      
      fetch next from cur1 into @Chg_Stock_ID,@Chg_For_Date  
     end       
     close cur1  
     deallocate cur1   
   END  
  End  
 else if @tran_type = 'D'  
  BEGIN  
    UPDATE UST  
     SET UST.Stock_Debit = 0,--UST.Stock_Debit - @No_of_Pieces,  
      UST.Stock_Credit = 0,   
      UST.Stock_Balance = UST.Stock_Opening  
      --UST.Stock_Balance = @Stock_Opening + @No_of_Pieces --Mukti(05062017)  
    From T0140_Uniform_Stock_Transaction UST    
    Where Cmp_ID = @Cmp_ID and Uni_ID = @Uni_ID and For_Date = @For_Date  
      
    if Exists(SELECT 1 From T0140_Uniform_Stock_Transaction WITH (NOLOCK) where Uni_ID = @Uni_ID AND Cmp_ID = @CMP_Id)  
    BEGIN          
     if @Pre_Closing is null  
      set @Pre_Closing = 0  
                        
      declare cur1 cursor for   
       Select Stock_ID,For_Date from dbo.T0140_Uniform_Stock_Transaction WITH (NOLOCK) where Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID and for_date > @for_date order by for_date  
      open cur1  
      fetch next from cur1 into @Chg_Stock_ID,@Chg_For_Date  
      while @@fetch_status = 0  
      begin  
       --select @Temp_max_Date   = max(For_Date)  from dbo.T0140_Uniform_Stock_Transaction where Uni_ID = @Uni_ID and for_date = @Chg_For_Date  
       --Select @Pre_Closing=Stock_Balance from T0140_Uniform_Stock_Transaction where Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID and for_date = @Chg_For_Date  
       select @Pre_Closing = isnull(Stock_Balance,0) from T0140_Uniform_Stock_Transaction WITH (NOLOCK)   
          where for_date = (select max(for_date) from T0140_Uniform_Stock_Transaction WITH (NOLOCK)  
           where for_date < @Chg_For_Date and Uni_ID = @Uni_ID and cmp_ID = @cmp_ID)   
           and cmp_ID = @cmp_ID and Uni_ID = @Uni_ID  
         
       --select @Chg_For_Date,@Pre_Closing  
       update dbo.T0140_Uniform_Stock_Transaction set   
         Stock_Opening = @Pre_Closing  
        ,Stock_Balance = @Pre_Closing + Stock_Credit - Stock_Debit   
        --,Stock_Balance = @Pre_Closing + Stock_Credit    
        ,Stock_Posting=0   
        --Fabric_Price=@Fabric_Price  
               
       where Stock_ID = @Chg_Stock_ID      
        
       fetch next from cur1 into @Chg_Stock_ID,@Chg_For_Date  
      end       
      close cur1  
      deallocate cur1   
    END  
   --Added By Mukti(end)05062017  
     
  END  
RETURN @Stock_ID  
END  