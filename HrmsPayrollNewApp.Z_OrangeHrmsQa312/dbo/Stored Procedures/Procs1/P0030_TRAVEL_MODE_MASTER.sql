  
  
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE  PROCEDURE [dbo].[P0030_TRAVEL_MODE_MASTER]  
   @Travel_Mode_ID numeric(18,0) output  
  ,@Travel_Mode_Name  varchar(100)  
  ,@Cmp_ID numeric(18,0)  
  ,@tran_type varchar(1)  
  ,@User_Id numeric(18,0) = 0   
        ,@IP_Address varchar(30)= ''  
        ,@Designation varchar(max)=''  
        ,@GST_Applicable tinyint = 0 --Added by Jaina 16-09-2017  
        ,@MODE_TYPE NUMERIC(18,0) = 0 -- ADDED BY RAJPUT ON 05072019  
   
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
  
declare @OldValue as varchar(max)  
declare @OldTravel_Mode_Name as varchar(100)  
declare @OldTravel_Mode_ID as varchar(100)  
declare @OldGst_Applicable as tinyint  
  
  
 set @OldValue=''  
  set @OldTravel_Mode_Name = ''  
  set @OldTravel_Mode_ID = ''  
    
 if(@Designation='')  
 set @Designation=Null;  
   
    
 create table #tempDesig    
 (  
 desig_ID numeric(18,0)  
 )  
      
  if (isnull(@Designation,'') <> '')    
 Begin  
  insert into #tempDesig  
   select DATA from dbo.Split(@Designation,'#') as data   
 End  
      
  --------  
    
  --select CHARINDEX(cast(@Travel_Mode_ID as varchar(50)),DM.Mode_Of_Travel,0)--,case when isnull(DM.Mode_Of_Travel,'')='' then cast(@Travel_Mode_ID as varchar(50)) Else DM.Mode_Of_Travel + '#' + cast(@Travel_Mode_ID as varchar(50)) End  
  --from T0040_DESIGNATION_MASTER DM inner join #tempDesig TD on DM.Desig_ID=TD.desig_ID  
  --where DM.Cmp_ID=@Cmp_ID and CHARINDEX(cast(@Travel_Mode_ID as varchar(50)),DM.Mode_Of_Travel,0) = 0  
  --and DM.Desig_ID=702  
  --return  
  
  
    
  --update DM set DM.Mode_Of_Travel = case when isnull(DM.Mode_Of_Travel,'')='' then cast(@Travel_Mode_ID as varchar(50)) Else DM.Mode_Of_Travel + '#' + cast(@Travel_Mode_ID as varchar(50)) End  
  --from T0040_DESIGNATION_MASTER DM inner join #tempDesig TD on DM.Desig_ID=TD.desig_ID  
  --where DM.Cmp_ID=@Cmp_ID and CHARINDEX(cast(@Travel_Mode_ID as varchar(50)),DM.Mode_Of_Travel,0) = 0  
    
    
  set @Travel_Mode_Name = dbo.fnc_ReverseHTMLTags(@Travel_Mode_Name)  --added by Ronak 081021
 If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'  
  BEGIN  
   If @Travel_Mode_Name = ''  
    BEGIN  
     Insert Into dbo.T0080_Import_Log Values (0,0,0,'Travel Mode Name is not Properly Inserted',0,'Enter Proper Travel Mode Name',GetDate(),'Travel Mode Master',NULL)        
     Return  
    END  
      
  END  
    
 If Upper(@tran_type) ='I'  
   begin  
     
    if exists (Select Travel_Mode_ID  from T0030_TRAVEL_MODE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and  Upper(Travel_Mode_Name) = Upper(@Travel_Mode_Name)  )   
     begin  
      set @Travel_Mode_ID = 0  
      Return   
     end  
       
    declare @desigID as numeric(18,0)    
    
  
       
    SELECT @Travel_Mode_ID = ISNULL(MAX(Travel_Mode_ID),0) + 1  FROM T0030_TRAVEL_MODE_MASTER WITH (NOLOCK)   
           
    INSERT INTO T0030_TRAVEL_MODE_MASTER  
                          (Travel_Mode_ID,Travel_Mode_Name, Cmp_ID, Login_ID,Create_Date,Modify_Date,GST_Applicable,MODE_TYPE)  
    VALUES     (@Travel_Mode_ID,@Travel_Mode_Name,@Cmp_ID, @User_Id,GETDATE(),GETDATE(),@GST_Applicable,@MODE_TYPE)   
      
      
      
     set @OldValue = 'New Value' + '#'+ 'Travel Mode Name :' +ISNULL( @Travel_Mode_Name,'') + '#'   
     ------  
   end   
     
 Else if @Tran_Type = 'U'  
    begin  
    If Exists(select  Travel_Mode_ID From T0030_TRAVEL_MODE_MASTER  WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(Travel_Mode_Name) = upper(@Travel_Mode_Name)  
            and Travel_Mode_ID <> @Travel_Mode_ID )  
     begin  
      set @Travel_Mode_ID = 0  
      return   
     end  
     --Add By Paras 12-10-2012  
     select @oldTravel_Mode_Name  =ISNULL(Travel_Mode_Name,'')  
     ,@OldTravel_Mode_ID  =ISNULL(Travel_Mode_ID,0)  
     ,@OldGst_Applicable = ISNULL(GST_Applicable,0)  
     From T0030_TRAVEL_MODE_MASTER WITH (NOLOCK)  
     Where Cmp_ID = @Cmp_ID and Travel_Mode_ID = @Travel_Mode_ID       
       
       ---  
       UPDATE    T0030_TRAVEL_MODE_MASTER  
     SET       Travel_Mode_Name = @Travel_Mode_Name,  
         GST_Applicable = @GST_Applicable,  
         MODE_TYPE = @MODE_TYPE  
        --DesigID=@Designation-  
     WHERE     Travel_Mode_ID = @Travel_Mode_ID  
       
     ----Add By Paras 12-10-2012  
     set @OldValue = 'old Value' + '#'+ 'Travel Mode Name :' + @OldTravel_Mode_name  + '#'   
            + '#'+ 'GST Applicable :' + CONVERT(varchar,@OldGst_Applicable)  + '#'  
         + 'New Value' + '#'+ 'Travel Mode Name :' +ISNULL( @Travel_Mode_Name,'')  
            + '#'+ 'GST Applicable :' + CONVERT(varchar,@Gst_Applicable) + '#'  
     ------  
  end  
       
 Else If @tran_type ='D'  
   Begin  
     
    if Exists(select Travel_mode_id from T0110_Travel_Application_Other_Detail WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Travel_Mode_Id=@Travel_Mode_ID)  
     begin  
      RAISERROR('@@ Reference Exists @@',16,2)  
      RETURN   
     end  
     select @OldTravel_Mode_Name  =ISNULL(Travel_Mode_Name,'') ,@OldTravel_Mode_ID  =ISNULL(travel_mode_id,0) From T0030_TRAVEL_MODE_MASTER WITH (NOLOCK) Where Cmp_ID=@Cmp_ID and Travel_Mode_ID = @Travel_Mode_ID    
      
    DELETE FROM T0030_TRAVEL_MODE_MASTER WHERE Cmp_ID=@Cmp_ID and Travel_Mode_ID = @Travel_Mode_ID  
       
    set @OldValue = 'old Value' + '#'+ 'Travel Mode Name :' + @OldTravel_Mode_Name  + '#'   
         + 'GST Applicable :' + CONVERT(varchar,@Gst_Applicable) + '#'  
    -----  
      
   End  
   exec P9999_Audit_Trail 0,@Tran_Type,'Travel Mode Master',@OldValue,@Travel_Mode_ID,@User_Id,@IP_Address  
     
/*Added below code for inserting data into Travel Mode Detail Table to with Mode Id and Designation ID by Sumit on 19012017*/  
  
 if (@tran_type <> 'D')  
  Begin  
    
   delete from T0040_Travel_Mode_Details where Travel_Mode_ID=@Travel_Mode_ID and Cmp_ID=@Cmp_ID  
    
   declare DesigUpdate Cursor for  
    select desig_ID from #tempDesig  
      
    Open DesigUpdate  
     Fetch next from DesigUpdate into @desigID  
     While @@FETCH_STATUS=0  
      Begin  
       if Not Exists(select 1 from T0040_Travel_Mode_Details WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Travel_Mode_ID=@Travel_Mode_ID and Desig_ID=@desigID)  
        Begin  
         insert into T0040_Travel_Mode_Details (Travel_Mode_ID,Desig_ID,Modified_Date,Cmp_ID)  
           values(@Travel_Mode_ID,@desigID,GETDATE(),@Cmp_ID)  
        End   
       Fetch next from DesigUpdate into @desigID  
      End  
    Close DesigUpdate  
    Deallocate DesigUpdate  
      
     update  T set T.Mode_OF_Travel=QRY.CSV  
     from  T0040_DESIGNATION_MASTER T  
     inner join   
       (  
        select case when CHARINDEX(' ',TE.CSV,0)=0 then REPLACE(TE.CSV,'#','') Else TE.CSV end as CSV,TE.Desig_ID as DesigID from  
         (  
          SELECT  Desig_Id , STUFF((SELECT ' ' + s.Travel_Mode_ID FROM   
            (   
             select ( cast(Travel_Mode_ID as varchar(50)) + '#' ) as Travel_Mode_ID,Desig_Id from T0040_Travel_Mode_Details WITH (NOLOCK)  
            )s   
          WHERE s.Desig_Id = t.Desig_Id FOR XML PATH('')),1,1,'') AS CSV  
          FROM T0040_Travel_Mode_Details AS t WITH (NOLOCK) GROUP BY t.Desig_Id  
         ) as TE  
       ) QRY on T.Desig_ID=QRY.DesigID   
     where Cmp_ID=@Cmp_ID     
      
   drop table #tempDesig   
  End     
     
 RETURN  
  
  
  
  