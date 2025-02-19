-- =============================================  
-- Author: satish viramgami  
-- Create date: 02/09/2020  
-- Description: Add Mobile brand and Sub-models master in vivo WB   
-- Table T0040_MOBILE_CATEGORY  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Mobile_Category]  
  @Mobile_Cat_ID numeric(18,0),  
  @Cmp_ID numeric(18,0),  
  @Mobile_Cat_Name varchar(100),  
  @ParentCategory_ID numeric(18,0),  
  @Effective_Date DateTime='',  
  @Login_ID numeric(18,0)=0,  
  @IsSalesActive numeric=0,  
  @IsStockActive numeric=0,  
  @IsActive numeric=0,  
  @Tran_Type CHAR(1)='',  
  @Result VARCHAR(100) OUTPUT,  
  @SearchValue VARCHAR(100)=''  
AS  
BEGIN  
    set @Mobile_Cat_Name = dbo.fnc_ReverseHTMLTags(@Mobile_Cat_Name)  --added by Ronak 081021  
  IF @Tran_Type='I'  
  BEGIN  
   IF Exists (select 1 from T0040_MOBILE_CATEGORY where Cmp_Id = @Cmp_ID and Mobile_Cat_Name = @Mobile_Cat_Name and ParentCategory_ID = @ParentCategory_ID and (Is_Active = 1 Or Is_Active = 0))  
   BEGIN  
    SET @Result = ''  
   END  
   ELSE  
   BEGIN  
    INSERT INTO T0040_MOBILE_CATEGORY (Cmp_ID,Mobile_Cat_Name,ParentCategory_ID,Sale_Active,Stock_Active,Is_Active,Effective_Date,System_Date,Login_ID)  
    VALUES (@Cmp_ID,@Mobile_Cat_Name,@ParentCategory_ID,@IsSalesActive,@IsStockActive,@IsActive,@Effective_Date,GETDATE(),@Login_ID)  
      
    SET @Result = 'Record Insert Sucessfully#True'  
   END  
  END  
  ELSE IF @Tran_Type='U'  
  BEGIN  
     
   IF EXISTS(SELECT 1 FROM T0040_MOBILE_CATEGORY WITH(NOLOCK) WHERE Mobile_Cat_ID=@Mobile_Cat_ID)   
   BEGIN  
    IF Exists (select 1 from T0040_MOBILE_CATEGORY where Cmp_Id = @Cmp_ID and Mobile_Cat_Name = @Mobile_Cat_Name and ParentCategory_ID = @ParentCategory_ID and Mobile_Cat_ID <> @Mobile_Cat_ID and (Is_Active = 1 Or Is_Active = 0))  
    BEGIN  
     SET @Result = ''  
    END  
    ELSE  
    BEGIN  
      UPDATE T0040_MOBILE_CATEGORY  
      SET Mobile_Cat_Name = @Mobile_Cat_Name,  
       ParentCategory_ID = @ParentCategory_ID,  
       Cmp_ID = @Cmp_ID,  
       Sale_Active = @IsSalesActive,  
       Stock_Active = @IsStockActive,  
       Is_Active = @IsActive ,  
       Effective_Date = @Effective_Date  
      WHERE Mobile_Cat_ID=@Mobile_Cat_ID  
      IF (@ParentCategory_ID = 0)  
      BEGIN  
       
       UPDATE T0040_MOBILE_CATEGORY  
        SET Is_Active = @IsActive  
        WHERE ParentCategory_ID = (SELECT Mobile_Cat_ID FROM T0040_MOBILE_CATEGORY where Mobile_Cat_ID = @Mobile_Cat_ID and cmp_ID = @Cmp_ID and ParentCategory_ID = 0)  
      END  
      SET @Result = 'Record Updated Sucessfully#True'  
    END  
   END  
   ELSE  
   BEGIN  
     SET @Result = 'Record Not Found#False'  
   END  
  END  
  ELSE IF @Tran_Type='S'  
  BEGIN  
    
   IF (OBJECT_ID('tempdb..#tempParent') IS NOT NULL)  
   BEGIN  
    DROP TABLE #tempParent  
   END  
     
   IF (OBJECT_ID('tempdb..#tempChild') IS NOT NULL)  
   BEGIN  
    DROP TABLE #tempChild  
   END  
     
   IF (OBJECT_ID('tempdb..#CombineTable') IS NOT NULL)  
   BEGIN  
    DROP TABLE #CombineTable  
   END  
     
   create table #tempParent  
   (ROWID int identity(1,1) primary key,  
   Mobile_Cat_ID int,  
   Cmp_ID numeric,  
   Mobile_Cat_Name varchar(100),  
   ParentCategory_ID numeric,  
   System_Date datetime,  
   Login_ID numeric,  
   Is_Active tinyint,  
   Effective_Date datetime,  
   Sale_Active tinyint,  
   Stock_Active tinyint  
   )  
  
   create table #tempChild  
   (ROWID int identity(1,1) primary key,  
   Mobile_Cat_ID int,  
   Cmp_ID numeric,  
   Mobile_Cat_Name varchar(100),  
   ParentCategory_ID numeric,  
   System_Date datetime,  
   Login_ID numeric,  
   Is_Active tinyint,  
   Effective_Date datetime,  
   Sale_Active tinyint,  
   Stock_Active tinyint  
   )  
  
   create table #CombineTable  
   (ROWID int identity(1,1) primary key,  
   Mobile_Cat_ID int,  
   Cmp_ID numeric,  
   Mobile_Cat_Name varchar(100),  
   ParentCategory_ID numeric,  
   System_Date datetime,  
   Login_ID numeric,  
   Is_Active tinyint,  
   Effective_Date datetime,  
   Sale_Active tinyint,  
   Stock_Active tinyint)  
  
   insert into #tempParent  
   select * from T0040_MOBILE_CATEGORY  
      where ParentCategory_ID =0  
     and Cmp_ID=@Cmp_ID  
     and Is_Active=1  
   ORDER by Mobile_Cat_ID asc  
  
   insert into #tempChild  
   select * from T0040_MOBILE_CATEGORY   
   where ParentCategory_ID <> 0  
     and Cmp_ID=@Cmp_ID  
     and Is_Active=1  
   ORDER by Mobile_Cat_ID asc  
  
   --select * from #tempParent  
   --select * from #tempChild  
  
   DECLARE @MAXID INT, @Counter INT--, @Mobile_Cat_ID INT  
  
   SET @Mobile_Cat_ID = 0  
   SET @COUNTER = 1  
   SELECT @MAXID = COUNT(*) FROM #tempParent  
  
   WHILE (@COUNTER <= @MAXID)  
   BEGIN  
    --DO THE PROCESSING HERE   
    SELECT @Mobile_Cat_ID = PT.Mobile_Cat_ID  
    FROM #tempParent AS PT  
    WHERE PT.ROWID = @COUNTER  
         
    insert into #CombineTable  
    select PL.Mobile_Cat_ID,PL.Cmp_ID,PL.Mobile_Cat_Name,PL.ParentCategory_ID,  
        PL.System_Date,PL.Login_ID,PL.Is_Active,PL.Effective_Date,PL.Sale_Active,PL.Stock_Active    
    from #tempParent PL WHERE PL.ROWID = @COUNTER  
         
    insert into #CombineTable  
    select CL.Mobile_Cat_ID,CL.Cmp_ID,CL.Mobile_Cat_Name,CL.ParentCategory_ID,  
        CL.System_Date,CL.Login_ID,CL.Is_Active,CL.Effective_Date,CL.Sale_Active,CL.Stock_Active    
    from #tempChild CL WHERE CL.ParentCategory_ID = @Mobile_Cat_ID  
      
    SET @Mobile_Cat_ID = 0  
    SET @COUNTER = @COUNTER + 1  
   END  
  
   --select * from T0040_MOBILE_CATEGORY  
   select CM.Mobile_Cat_ID,CM.Cmp_ID,CM.Mobile_Cat_Name,CM.ParentCategory_ID,  
       CM.System_Date,CM.Login_ID,CM.Is_Active,CM.Effective_Date,CM.Sale_Active,CM.Stock_Active,  
       0 as Sale, 0 as Stock  
   from #CombineTable CM   
   where ((CM.Mobile_Cat_Name like '%'+ @SearchValue + '%') or (CM.Mobile_Cat_Name = ''))   
     
   --SELECT  Mobile_Cat_ID,Cmp_ID,Mobile_Cat_Name,  
   --        ParentCategory_ID,System_Date,Login_ID,  
   --  Sale_Active,Stock_Active  
   --FROM T0040_MOBILE_CATEGORY WITH(NOLOCK)  
   --WHERE Cmp_ID=@Cmp_ID  
  END  
  ELSE IF @Tran_Type='D'  
  BEGIN  
   UPDATE T0040_MOBILE_CATEGORY  
    SET Is_Active = 0  
    WHERE Mobile_Cat_ID=@Mobile_Cat_ID and cmp_ID = @Cmp_ID  
   IF (@ParentCategory_ID = 0)  
   BEGIN  
      
    UPDATE T0040_MOBILE_CATEGORY  
     SET Is_Active = 0  
     WHERE ParentCategory_ID = (SELECT Mobile_Cat_ID FROM T0040_MOBILE_CATEGORY where Mobile_Cat_ID = @Mobile_Cat_ID and cmp_ID = @Cmp_ID and ParentCategory_ID = 0)  
   END  
   SET @Result = 'Record Delete Sucessfully#True'  
  END  
END  
  
  
  
  