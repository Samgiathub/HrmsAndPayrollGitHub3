



---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0120_GRADEWISE_ALLOWANCE]  
@Tran_ID numeric,  
@Cmp_ID numeric,  
@Ad_ID numeric,  
@Tran_Type varchar(1),  
@Constraint varchar(MAX),
@AD_Level Numeric,
@MyXML  xml

AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF OBJECT_ID('tempdb..#temp_Table') IS NOT NULL
BEGIN
	DROP TABLE #temp_Table
END


CREATE TABLE #Grade
(
	Grd_ID numeric,
	AD_Mode varchar(10),
	AD_Percentage numeric(18,5),-- Changed by Gadriwala Muslim 19032015
	AD_MAX_LIMIT numeric(18,2),
	AD_NON_TAX_LIMIT numeric(18,2)
)


select Grade.detail.value('(Grd_ID/text())[1]','numeric(18,2)') as Grd_ID, 
       Grade.detail.value('(AD_MODE/text())[1]','varchar(100)') as AD_MODE, 
       Grade.detail.value('(AD_PERCENTAGE/text())[1]','numeric(18,5)') as AD_PERCENTAGE,  -- Changed by Gadriwala Muslim 19032015
       Grade.detail.value('(AD_MAX_LIMIT/text())[1]','numeric(18,2)') as AD_MAX_LIMIT, 
       Grade.detail.value('(AD_NON_TAX_LIMIT/text())[1]','numeric(18,2)') as AD_NON_TAX_LIMIT
    into #Temptable from @MyXML.nodes('/NewDataSet/Table1') as Grade(detail)

declare @Grd_ID_Temp numeric(18,0)   
declare @AD_Mode_temp varchar(20)   
declare @AD_Percentage_Temp numeric(18,5)  -- Changed by Gadriwala Muslim 19032015 
declare @AD_MAX_LIMIT_temp numeric(18,2)   
declare @AD_NON_TAX_LIMIT_Temp numeric(18,2)   

if @Tran_Type = 'I'  
 Begin  
  
 
declare curAD cursor for                      
  select  Grd_ID,AD_Mode,AD_Percentage,AD_MAX_LIMIT,AD_NON_TAX_LIMIT from #Temptable                  
 open curAD                        
 fetch next from curAD into @Grd_ID_Temp ,@AD_Mode_temp, @AD_Percentage_Temp,@AD_MAX_LIMIT_temp,@AD_NON_TAX_LIMIT_Temp
 while @@fetch_status = 0                      
  begin     
     
   if Not exists (select Grd_ID from T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Ad_ID=@Ad_ID and Grd_ID=@Grd_ID_Temp)  
    BEgin  
     print @Grd_ID_Temp  
     select @Tran_ID = Isnull(max(Tran_ID),0) + 1  From T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK)  
     print @Tran_ID  
     
     if @AD_Mode_temp ='%'
     BEGIN
    
     insert into T0120_GRADEWISE_ALLOWANCE(Tran_ID,Cmp_ID,Ad_ID,Grd_ID,Sys_Date,AD_Level,AD_MODE,AD_PERCENTAGE,AD_MAX_LIMIT,AD_NON_TAX_LIMIT)  
     values(@Tran_ID,@Cmp_ID,@Ad_ID,@Grd_ID_Temp,Getdate(),@AD_Level,@AD_Mode_temp,@AD_Percentage_Temp,@AD_MAX_LIMIT_temp,@AD_NON_TAX_LIMIT_Temp)  
     end
     else
      BEGIN
   
      insert into T0120_GRADEWISE_ALLOWANCE(Tran_ID,Cmp_ID,Ad_ID,Grd_ID,Sys_Date,AD_Level,AD_MODE,AD_AMOUNT,AD_MAX_LIMIT,AD_NON_TAX_LIMIT)  
     values(@Tran_ID,@Cmp_ID,@Ad_ID,@Grd_ID_Temp,Getdate(),@AD_Level,@AD_Mode_temp,@AD_Percentage_Temp,@AD_MAX_LIMIT_temp,@AD_NON_TAX_LIMIT_Temp)  
      end
     
     
    End  
      
  fetch next from curAD into @Grd_ID_Temp ,@AD_Mode_temp, @AD_Percentage_Temp,@AD_MAX_LIMIT_temp,@AD_NON_TAX_LIMIT_Temp
  end                      
 close curAD                      
 deallocate curAD   


                   
End  
else if @Tran_Type = 'U'  
 Begin  
 
delete from T0120_GRADEWISE_ALLOWANCE where Ad_Id = @Ad_ID and Cmp_ID=@Cmp_ID  
  
  declare curAD cursor for                      
  select  Grd_ID,AD_Mode,AD_Percentage,AD_MAX_LIMIT,AD_NON_TAX_LIMIT from #Temptable                  
 open curAD                        
 fetch next from curAD into @Grd_ID_Temp ,@AD_Mode_temp, @AD_Percentage_Temp,@AD_MAX_LIMIT_temp,@AD_NON_TAX_LIMIT_Temp
 while @@fetch_status = 0                      
  begin     
  
  
--  select @AD_Percentage_Temp,@AD_Mode_temp
     
   if Not exists (select Grd_ID from T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Ad_ID=@Ad_ID and Grd_ID=@Grd_ID_Temp)  
    BEgin  
     print @Grd_ID_Temp  
     select @Tran_ID = Isnull(max(Tran_ID),0) + 1  From T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK)   
    
     if @AD_Mode_temp ='%'
     BEGIN
    
     insert into T0120_GRADEWISE_ALLOWANCE(Tran_ID,Cmp_ID,Ad_ID,Grd_ID,Sys_Date,AD_Level,AD_MODE,AD_PERCENTAGE,AD_MAX_LIMIT,AD_NON_TAX_LIMIT)  
     values(@Tran_ID,@Cmp_ID,@Ad_ID,@Grd_ID_Temp,Getdate(),@AD_Level,@AD_Mode_temp,@AD_Percentage_Temp,@AD_MAX_LIMIT_temp,@AD_NON_TAX_LIMIT_Temp)  
     end
     else
      BEGIN
   
      insert into T0120_GRADEWISE_ALLOWANCE(Tran_ID,Cmp_ID,Ad_ID,Grd_ID,Sys_Date,AD_Level,AD_MODE,AD_AMOUNT,AD_MAX_LIMIT,AD_NON_TAX_LIMIT)  
     values(@Tran_ID,@Cmp_ID,@Ad_ID,@Grd_ID_Temp,Getdate(),@AD_Level,@AD_Mode_temp,@AD_Percentage_Temp,@AD_MAX_LIMIT_temp,@AD_NON_TAX_LIMIT_Temp)  
      end
    
    
    End  
      
  fetch next from curAD into @Grd_ID_Temp ,@AD_Mode_temp, @AD_Percentage_Temp,@AD_MAX_LIMIT_temp,@AD_NON_TAX_LIMIT_Temp
  end                      
 close curAD                      
 deallocate curAD 
                
               
                      
End  
  
else if @Tran_Type = 'D'  
 Begin  
  Delete from  T0120_GRADEWISE_ALLOWANCE where Ad_ID = @Ad_ID and Cmp_ID = @Cmp_ID  
 End  
  
RETURN  
  



