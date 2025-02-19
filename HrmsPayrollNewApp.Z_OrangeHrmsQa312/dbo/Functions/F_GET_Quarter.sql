CREATE FUNCTION F_GET_Quarter    
 (    
  @month int    
      
 )    
RETURNS Varchar(20)    
AS    
  begin    
  Declare @Claim_Apr_Quarter varchar(20),@Claim_Apr_mon int    
    
   set @Claim_Apr_mon = (@month)    
      
   if isnull(@month,'') <> ''    
    begin    
    if(@Claim_Apr_mon<=3)    
    begin    
     set @Claim_Apr_Quarter='Fourth Quarter'     
    end     
    else if(@Claim_Apr_mon>3 and @Claim_Apr_mon<=6)    
      begin    
       set @Claim_Apr_Quarter= 'First Quarter'     
    end    
    else if(@Claim_Apr_mon>6 and @Claim_Apr_mon<=9)    
     begin    
       set @Claim_Apr_Quarter= 'Second Quarter'     
    end    
    else     
    begin    
       set @Claim_Apr_Quarter= 'Third Quarter'     
    end    
    end        
       
   RETURN @Claim_Apr_Quarter     
  end    
    
    