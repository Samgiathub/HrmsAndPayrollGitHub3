

CREATE PROCEDURE [dbo].[P0190_Seniority_Award_Slab]  

@Tran_Id numeric,
@cmp_id Numeric,
@AD_id Numeric,
@Tran_Type varchar(1)   ,
@MyXML  xml

AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

IF OBJECT_ID('tempdb..#temp_Table') IS NOT NULL
BEGIN
	DROP TABLE #temp_Table
END


CREATE TABLE #Seniority
(
	Tran_Id Numeric,
	From_Age Numeric(18,2),
	To_Age Numeric(18,2),
	Mode Varchar,
	Amount Numeric(18,2),
	remarks Varchar(500)
)


select Seniority.detail.value('(Tran_Id/text())[1]','numeric(18,0)') as Tran_Id, 
       Seniority.detail.value('(From_Age/text())[1]','numeric(18,2)') as From_Age,
       Seniority.detail.value('(To_Age/text())[1]','numeric(18,2)') as To_Age, 
       Seniority.detail.value('(Mode/text())[1]','varchar(50)') as Mode,
       Seniority.detail.value('(Amount/text())[1]','numeric(18,2)') as Amount,
       Seniority.detail.value('(remarks/text())[1]','varchar(500)') as remarks
    into #Temptable from @MyXML.nodes('/NewDataSet/Table1') as Seniority(detail)


Declare @Tran_ID_Temp Numeric(18,0)
declare	@From_Age_Temp Numeric(18,2)
declare	@To_Age_Temp Numeric(18,2)
declare @Mode_Temp Varchar(50)
declare	@Amount_Temp Numeric(18,2)
declare @remarks_Temp Varchar(500) 

if @Tran_Type = 'I'  
 Begin  
  
 
declare curAD cursor for                      
  select  Tran_ID,From_Age,To_Age,Mode,Amount,Remarks from #Temptable                  
 open curAD                        
 fetch next from curAD into @Tran_ID_Temp,@From_Age_Temp,@To_Age_temp,@Mode_Temp,@Amount_Temp,@Remarks_temp 
 while @@fetch_status = 0                      
  begin     
     
   if Not exists (select tran_id from T0190_Seniority_Award_Slab WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Ad_ID=@Ad_ID and Tran_id=@Tran_ID_Temp)  
    BEgin  
     
      insert into T0190_Seniority_Award_Slab(Cmp_ID,Ad_ID,From_Age,To_Age,Mode,Amount,Remarks)  
     values(@Cmp_ID,@Ad_ID,@From_Age_Temp,@To_Age_temp,@Mode_Temp,@Amount_Temp,@Remarks_temp )  
     
    End  
      
  fetch next from curAD  into @Tran_ID_Temp,@From_Age_Temp,@To_Age_temp,@Mode_Temp,@Amount_Temp,@Remarks_temp 
  end                      
 close curAD                      
 deallocate curAD   


                   
End  
else if @Tran_Type = 'U'  
 Begin  
 
delete from T0190_Seniority_Award_Slab where Ad_Id = @Ad_ID and Cmp_ID=@Cmp_ID  
  
declare curAD cursor for                      
  select  Tran_ID,From_Age,To_Age,Mode,Amount,Remarks from #Temptable                  
 open curAD                        
 fetch next from curAD into @Tran_ID_Temp,@From_Age_Temp,@To_Age_temp,@Mode_Temp,@Amount_Temp,@Remarks_temp 
 while @@fetch_status = 0                      
  begin     
     
   if Not exists (select tran_id from T0190_Seniority_Award_Slab WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Ad_ID=@Ad_ID and Tran_id=@Tran_Id)  
    BEgin  
     
      insert into T0190_Seniority_Award_Slab(Cmp_ID,Ad_ID,From_Age,To_Age,Mode,Amount,Remarks)  
     values(@Cmp_ID,@Ad_ID,@From_Age_Temp,@To_Age_temp,@Mode_Temp,@Amount_Temp,@Remarks_temp )  
     
    End  
      
  fetch next from curAD into @Tran_ID_Temp,@From_Age_Temp,@To_Age_temp,@Mode_Temp,@Amount_Temp,@Remarks_temp 
  end                      
 close curAD                      
 deallocate curAD   
               
                      
End  
  
else if @Tran_Type = 'D'  
 Begin  
  Delete from  T0190_Seniority_Award_Slab where Ad_ID = @Ad_ID and Cmp_ID = @Cmp_ID  
 End  
  
RETURN  
  



