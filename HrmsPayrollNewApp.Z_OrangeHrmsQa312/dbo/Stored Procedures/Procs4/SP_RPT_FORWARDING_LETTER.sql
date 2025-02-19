



---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_FORWARDING_LETTER]  
  @Cmp_ID  numeric  
 ,@From_Date  datetime  
 ,@To_Date  datetime   
 ,@Letter  varchar(500)  
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
      
 --Code commented by Mihir Trivedi on 31032012  
 /*DEclare @Forwading table  
  (  
  Cmp_ID  numeric(18,0),  
  Cmp_Name varchar(50),  
  Cmp_Address varchar(500),  
  PF_NO varchar(20),  
  Letter  varchar(500),  
  Let_Month numeric(18,0),  
  Let_Year numeric(18,0)  
  )  
    
 insert into @Forwading*/  
 Select Cmp_ID,Cmp_Name,Cmp_Address,PF_NO,@Letter as Letter,month(@From_Date) as Let_Month,Year(@From_Date) as Let_Year  from t0010_Company_master WITH (NOLOCK) where cmp_Id= @Cmp_ID  
    
 --select * from @Forwading   
    
 RETURN  
  
  
  

