    
    
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
CREATE PROCEDURE [dbo].[P0040_DESIGNATION_MASTER]        
  @Desig_ID NUMERIC(18,0) OUTPUT        
 ,@Cmp_ID NUMERIC(18,0)        
 ,@Desig_Name VARCHAR(100)        
 ,@Desig_Dis_No NUMERIC(18,0)        
 ,@Def_ID NUMERIC(18,0)        
 ,@Parent_ID NUMERIC(18,0)        
 ,@Is_Main   NUMERIC(18,0)      
 ,@tran_type VARCHAR(1)        
 ,@Mode_Of_Travel VARCHAR(50) = '' -- Added By Hiral 11 Sep,2012      
 ,@User_Id NUMERIC(18,0) = 0   -- Change By Paras 23-10-2012    
 ,@IP_Address VARCHAR(30)= ''  -- Change By Paras 23-10-2012     
 ,@Optional_Allow_Per numeric(18,2) =0    
 ,@Desig_Code VARCHAR(50) = ''    
 ,@IsActive tinyint = 1    
 ,@InEffeDate datetime=null    
 ,@GUID Varchar(2000) = ''    
 ,@Absconding_Reminder Tinyint = 0 --Added By Ramiz on 24052017    
AS     
    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
 DECLARE @OldValue AS  VARCHAR(MAX)    
 DECLARE @OldDesig_Name AS VARCHAR(100)    
 DECLARE @OldDesig_Dis_No AS VARCHAR(18)    
 DECLARE @OldDef_ID  AS VARCHAR(18)    
 DECLARE @OldParent_ID  AS VARCHAR(18)    
 DECLARE @OldIs_Main  AS VARCHAR(18)    
 DECLARE @OldMode_Of_Travel AS VARCHAR(50)    
 declare @Old_Optional_Allow_Per AS VARCHAR(50)    
 declare @OldActive as varchar(20)    
 declare @OldEffDate as varchar(50)    
 declare @modeID as numeric(18,0)    
 declare @OldAbsconding as varchar(20)    
     
     
 SET @OldValue = ''    
 SET @OldDesig_Name = ''    
 SET @OldDesig_Dis_No = ''    
 SET @OldDef_ID = ''    
 SET @OldParent_ID = ''    
 SET @OldIs_Main = ''    
 SET @OldMode_Of_Travel =''    
 set @Old_Optional_Allow_Per =0    
 set @OldActive=1    
 set @OldEffDate=''    
 set @OldAbsconding = 0    
     
 IF @Parent_ID = 0        
  SET @Parent_ID = NULL        
           
 --Added By Hiral 27 Sep,2012           
 IF @Mode_Of_Travel = ''       
  SET @Mode_Of_Travel = NULL    
     
 if @InEffeDate=''    
  set @InEffeDate=null     
 ---Added by Sumit on 19012017---------------------------------------------------------     
    if (OBJECT_ID('tempdb..#tempTravelMode') is null)    
  Begin    
   create table #tempTravelMode    
     (    
     mode_ID numeric(18,0)    
     )    
         
   if (isnull(@Mode_Of_Travel,'') <> '')      
    Begin    
     insert into #tempTravelMode    
      select DATA from dbo.Split(@Mode_Of_Travel,'#') as data     
    End      
  End       
    ---Ended by Sumit on 19012017-----------    
        
        set @Desig_Name = dbo.fnc_ReverseHTMLTags(@Desig_Name)  --added by mansi 061021  
		set @Desig_Code = dbo.fnc_ReverseHTMLTags(@Desig_Code)  --added by mansi 061021  
         
 IF @tran_type ='I'         
  BEGIN        
   if @Desig_Name = ''    
    Begin    
     Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Designation Name is not Properly Inserted',0,'Enter Proper Designation Name "'+ @Desig_Name +'"',GetDate(),'Designation Master',@GUID)          
     Return    
    End    
   if @Desig_Code = ''    
    Begin    
     Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Designation Code is not Properly Inserted',0,'Enter Proper Designation Code  "'+ @Desig_Code +'"' ,GetDate(),'Designation Master',@GUID)          
     Return    
    End    
        
   SET @Desig_Name = LTRIM(@Desig_Name)    
   SET @Desig_Name = RTRIM(@Desig_Name)    
       
   IF EXISTS(SELECT Desig_ID FROM T0040_DESIGNATION_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID         
      AND UPPER(Desig_Name) = UPPER(@Desig_Name) )  -- Modified by Mitesh 04/08/2011 for different collation db.      
    BEGIN        
     SET @Desig_ID = 0    
     Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Same Designation already exists.please Enter Valid Designation Name',0,'Same Designation already exists.please Enter Valid Designation Name "'+ @Desig_Name +'"',GetDate(),'Designation Master',@GUID)          
     RETURN              
    END     
       
   IF EXISTS(SELECT Desig_ID FROM T0040_DESIGNATION_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID         
      AND UPPER(Desig_Code) = UPPER(@Desig_Code) )     
    BEGIN        
     SET @Desig_ID = 0    
     Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Same Designation code already exists.please Enter Valid Designation code',0,'Same Designation code already exists.please Enter Valid Designation code "'+ @Desig_Name +'"',GetDate(),'Designation Ma
  
ster',@GUID)          
     RETURN              
    END        
       
   SELECT @Desig_ID = ISNULL(MAX(Desig_ID),0) + 1  FROM T0040_DESIGNATION_MASTER WITH (NOLOCK)       
         
   INSERT INTO T0040_DESIGNATION_MASTER      
     (Desig_ID, Cmp_ID, Desig_Name, Desig_Dis_No, Def_ID, Parent_ID, Is_Main    
     ,Mode_Of_Travel,Optional_allow_per,Desig_Code,IsActive,InActive_EffeDate , Absconding_Reminder)        
    VALUES (@Desig_ID, @Cmp_ID, @Desig_Name, @Desig_Dis_No, @Def_ID, @Parent_ID, @Is_Main    
     ,@Mode_Of_Travel,@Optional_allow_per,@Desig_Code,@IsActive,@InEffeDate , @Absconding_Reminder)         
         
   /*if @Is_Main = 1        
    Begin        
     Update T0040_DESIGNATION_MASTER set Is_Main =0 Where Cmp_Id=@Cmp_Id and Desig_Id<>@Desig_ID        
    End  */      
          
   --Add By PAras 12-10-2012    
    SET @OldValue = 'New Value' + '#'+ 'Designation Name :' +ISNULL( @Desig_Name,'') + '#'  + 'Designation Dis No :' + CAST(ISNULL(@Desig_Dis_No,0) AS VARCHAR(18)) + '#' + 'Def ID :' +CAST(ISNULL(@Def_ID,0)AS VARCHAR(20)) + '#' + 'Parent ID :' +CAST(ISNULL(@Parent_ID,0)AS VARCHAR(18)) + ' #'+ 'Is Main :' +CAST(ISNULL(@Is_Main,0)AS VARCHAR(18)) + ' #' +'Mode Of Travel:' + '#' + ISNULL(@Mode_Of_Travel,'') + '#'  + 'IsActive :' + CAST(ISNULL(@IsActive,1) AS VARCHAR(18)) + ' #'+ 'InEffeDate :' +CAST(@InEffeDate AS VARCHAR(18)) + '#'  + 'Absconding_Reminder :' + CAST(ISNULL(@Absconding_Reminder,0) AS VARCHAR(2))    
   ----           
  END       
        
 ELSE IF @tran_type ='U'         
  BEGIN        
       
       
     IF EXISTS(SELECT Desig_ID FROM T0040_DESIGNATION_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID         
        AND UPPER(Desig_Name) = UPPER(@Desig_Name) AND Desig_ID <> @Desig_ID)  -- Modified by Mitesh 04/08/2011 for different collation db.      
      BEGIN        
       SET @Desig_ID = 0        
       RETURN              
      END       
         
     --Add by Paras 12-10-2012    
     SELECT @OldDesig_Name = ISNULL(Desig_Name,''), @OldDesig_Dis_No = ISNULL(Desig_Dis_No,'')    
       ,@OldDef_ID = ISNULL(Def_ID,0), @OldParent_ID = ISNULL(Parent_ID,0)    
       ,@OldIs_Main = ISNULL(Is_Main,0), @OldMode_Of_Travel = CAST(ISNULL(Mode_Of_Travel,0)AS VARCHAR(18))    
       ,@OldActive=ISNULL(IsActive,1)    
       ,@OldEffDate=cast(InActive_EffeDate as varchar(50))    
       ,@OldAbsconding =  ISNULL(Absconding_Reminder,0)    
      FROM dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Desig_ID = @Desig_ID     
                    
     UPDATE T0040_DESIGNATION_MASTER        
       SET  Desig_Name = @Desig_Name    
        ,Desig_Dis_No = @Desig_Dis_No     
        ,Def_ID = @Def_ID    
        ,Parent_ID = @Parent_ID    
        ,Is_Main = @Is_Main    
        ,Mode_Of_Travel = @Mode_Of_Travel    
        ,Optional_allow_per=@Optional_Allow_Per    
        ,Desig_Code = @Desig_Code          
        ,IsActive=@IsActive    
        ,InActive_EffeDate=@InEffeDate    
        ,Absconding_Reminder = @Absconding_Reminder    
       WHERE (Desig_ID = @Desig_ID)        
             
     SET @OldValue = 'old Value' + '#'+ 'Designation Name :' + @OldDesig_Name   + '#'  + 'Designation Dis No :' + @OldDesig_Dis_No  + '#' + 'Def ID :' +@OldDef_ID     + '#' + 'Parent Id :' + @OldParent_ID    + ' #'+ 'Main :' + @OldIs_Main    + ' #'+ 'Mode
  
 Of Travel: '+ @OldMode_Of_Travel + ' #'+ 'IsActive: '+ @OldActive  + ' #'+ 'InEffeDate: '+ @OldEffDate + ' #'+ 'Absconding_Reminder: '+ @OldAbsconding     
        + 'New Value' + '#'+ 'Designation Name :' +ISNULL( @Desig_Name,'') + '#'  + 'Designation Dis No :' + CAST(ISNULL(@Desig_Dis_No,0) AS VARCHAR(18)) + '#' + 'Def ID :' +CAST(ISNULL(@Def_ID,0)AS VARCHAR(20)) + '#' + 'Parent ID :' +CAST(ISNULL(@Parent_ID,0)AS VARCHAR(18)) + ' #'+ 'Is Main :' +CAST(ISNULL(@Is_Main,0)AS VARCHAR(18)) + ' #' + 'Optional Allow Percentage :' +ISNULL(@Mode_Of_Travel,'') + ' #' + ' :' +ISNULL(@Old_Optional_Allow_Per,0) + ' #'+ 'Is Active :' +CAST(ISNULL(@IsActive,1)AS VARCHAR(18)) + ' #'+ 'Absconding_Reminder :' + CAST(@Absconding_Reminder AS VARCHAR(2)) + ' #'+ 'InEffeDate :' + CAST(ISNULL(@Absconding_Reminder,0) AS VARCHAR(2))    
                  
        
  END        
      
 ELSE IF @tran_type ='d'        
  BEGIN        
      
   if exists (select 1  from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @cmp_id and Desig_Id = @Desig_Id)    
    BEGIN    
     RAISERROR('@@ Reference Esits @@',16,2)    
     RETURN    
    end    
   else IF exists (select 1  from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID = @cmp_id and Desig_Id = @Desig_Id)    
    BEGIN    
     RAISERROR('@@ Reference Esits @@',16,2)    
     RETURN    
    END    
   ELSE    
    BEGIN      
       
     --Add By PAras 20-10-2012    
     SELECT @OldDesig_Name = ISNULL(Desig_Name,''), @OldDesig_Dis_No = ISNULL(Desig_Dis_No,'')    
       ,@OldDef_ID = ISNULL(Def_ID,0), @OldParent_ID = ISNULL(Parent_ID,0)    
       ,@OldIs_Main =ISNULL(Is_Main,0), @OldMode_Of_Travel = ISNULL(Mode_Of_Travel,'') ,    
       @Old_Optional_Allow_Per  = isnull(Optional_allow_per,0)    
       ,@OldActive=ISNULL(IsActive,1)    
       ,@OldEffDate=InActive_EffeDate , @OldAbsconding = ISNULL(Absconding_Reminder,0)    
      FROM dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Desig_ID = @Desig_ID    
         
         
     DELETE FROM T0040_DESIGNATION_MASTER WHERE Desig_ID = @Desig_ID        
         
     SET @OldValue = 'old Value' + '#'+ 'Designation Name :' + @OldDesig_Name + '#'  + 'Designation Dis No :' +@OldDesig_Dis_No  + '#' + 'Def ID :' + @OldDef_ID + '#' + 'Parent ID :' + @OldParent_ID + ' #'+ 'Is Main :' +@OldIs_Main + ' #' + 'Mode Of Trav 
 
el:' + @OldMode_Of_Travel + ' #' + 'IsActive:' + @OldActive + ' #' + 'InEffDate:' + @OldEffDate + ' #' + 'Absconding Reminder:' + @OldAbsconding     
   end    
  END        
       
    ELSE IF (@tran_type='M')    
  BEGIN    
         
   UPDATE T0040_DESIGNATION_MASTER    
    SET Mode_Of_Travel=@Mode_Of_Travel    
    WHERE (Desig_ID = @Desig_ID)       
       
  END    
     
      
   EXEC P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Designation Master',@OldValue,@Desig_ID,@User_Id,@IP_Address    
   --Added by Sumit on 19012017 for updating Travel Mode in Mode details ---------------------------------------------------------------------------------        
   if (@tran_type <> 'D')    
  Begin    
      
   delete from T0040_Travel_Mode_Details where Desig_ID=@Desig_ID and Cmp_ID=@Cmp_ID    
      
   declare DesigUpdate Cursor for    
    select mode_ID from #tempTravelMode    
        
    Open DesigUpdate    
     Fetch next from DesigUpdate into @modeID    
     While @@FETCH_STATUS=0    
      Begin    
       if Not Exists(select 1 from T0040_Travel_Mode_Details WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Travel_Mode_ID=@modeID and Desig_ID=@Desig_ID)    
        Begin           
         insert into T0040_Travel_Mode_Details (Travel_Mode_ID,Desig_ID,Modified_Date,Cmp_ID)    
           values(@modeID,@Desig_ID,GETDATE(),@Cmp_ID)    
        End     
       Fetch next from DesigUpdate into @modeID    
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
        
   drop table #tempTravelMode     
  End     
 RETURN    