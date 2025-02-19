  
  
  
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[Get_TravelMode_Desg]  
 @Desg_ID Numeric(18,0),  
 @flag tinyint =0,
 @Cmp_id as integer
AS  
BEGIN  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
 Declare @ModeOfTravel As Varchar(MAX)  
 set @ModeOfTravel = ''  
 Create table #GetTravelMode  
 (  
  Travel_Mode_ID numeric(18,0),  
  Cmp_ID numeric(18,0),  
  Travel_Mode_Name varchar(100),  
  Mode_Type INT,  
  LoginID numeric(18,0)  
 )  
   
 select @ModeOfTravel= Mode_of_Travel From T0040_DESIGNATION_MASTER WITH (NOLOCK) where Desig_ID = @Desg_ID and Cmp_ID=@Cmp_id 
   
 if @flag=1  
  Begin  
    
    
   insert into #GetTravelMode  
   select Travel_mode_ID,Cmp_ID,Travel_Mode_Name,Mode_Type,Login_ID from  
    T0030_TRAVEL_MODE_MASTER WITH (NOLOCK) where Travel_Mode_ID in (select items from dbo.Split2(@ModeOfTravel,'#'))  
      
      
   insert into #GetTravelMode  
    values(99999,0,'Special',0,0)  
      
    
   select * from #GetTravelMode   
    
  End  
 Else  
  Begin   
    
   select * from T0030_TRAVEL_MODE_MASTER WITH (NOLOCK)  
   where Travel_Mode_ID in (select items from dbo.Split2(@ModeOfTravel,'#'))  and cmp_id= @Cmp_id 
  End   
 --select * from T0030_TRAVEL_MODE_MASTER where Travel_Mode_ID in (select items from dbo.Split2(@ModeOfTravel,'#'))  
  
END  
  
  