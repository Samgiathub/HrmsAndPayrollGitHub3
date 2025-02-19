  
  
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0050_CANTEEN_MASTER]  
 @Cmp_Id Numeric(18,0),   
 @Cnt_Id Numeric(18,0) Output,  
 @Cnt_Name Varchar(50),  
 @From_Time Varchar(10),  
 @To_Time Varchar(10),  
 @Ip_Id numeric(18,0)=0,  
 @effective_Date Varchar(20)='',  
 @Image Varchar(200)='', -- Added by rajput on 05032019  
 @XmlDetail Xml,  
 @Tran_type varchar(1),
 @CutOff_Time varchar(10),
 @Is_Active int
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
BEGIN  
    set @Cnt_Name = dbo.fnc_ReverseHTMLTags(@Cnt_Name) --Ronak_060121  
   
 --BEGIN TRY     
   
  IF (@Tran_type = 'I' OR @Tran_type = 'U') BEGIN  
   --Varifying Canteen Detail Values      
   --SELECT CanteenDetail.detail.value('(Tran_Id/text())[1]', 'Numeric(18,0)') As Tran_Id,  
   --  CanteenDetail.detail.value('(Effective_Date/text())[1]', 'DateTime') As Effective_Date,  
   --  CanteenDetail.detail.value('(Amount/text())[1]', 'Numeric(18,2)') As Amount  
   --INTO #TmpVerfy  
   --FROM @XmlDetail.nodes('/dsDetail/tblDetail') As CanteenDetail(detail)  
       
   --IF NOT EXISTS(SELECT 1 FROM #TmpVerfy Where Effective_Date IS NOT NULL) BEGIN  
   -- RAISERROR (N'Canteen detail must be entered.', 16, 2);   
   -- RETURN 0;  
   --END  
   --End Verification  
     
   --Check if there is already record exist with same canteen detail name  
   IF EXISTS(SELECT 1 FROM dbo.T0050_CANTEEN_MASTER T WITH (NOLOCK) WHERE T.Cmp_Id=@Cmp_Id AND T.Cnt_Name=@Cnt_Name AND T.Cnt_ID<>@Cnt_Id and ip_id = @Ip_Id) BEGIN     
    RAISERROR (N'There is already record exist with same canteen detail name.', 16, 2);   
    RETURN 0;  
   END  
     
   --Check if there is already record exist in the database containing same time.  
   IF EXISTS(SELECT 1 FROM dbo.T0050_CANTEEN_MASTER T WITH (NOLOCK) WHERE T.Cmp_Id=@Cmp_Id AND T.Cnt_ID<>@Cnt_ID AND  Ip_Id=@Ip_Id and  
     ((CAST(T.From_Time As DateTime) Between CAST(@From_Time As DateTime) AND Cast(@To_Time As DateTime)) OR  
     (CAST(T.To_Time As DateTime) Between CAST(@From_Time As DateTime) AND Cast(@To_Time As DateTime)))  
     AND @effective_Date = System_Date      --Added By Jimit 19082019 for checking Effective date provision also chiripal  
     )   
    BEGIN     
      
    SELECT @From_Time=From_Time,@To_Time=To_Time FROM dbo.T0050_CANTEEN_MASTER T WITH (NOLOCK) WHERE T.Cmp_Id=@Cmp_Id AND Ip_Id=@Ip_Id  and  T.Cnt_ID<>@Cnt_ID AND  
     ((CAST(T.From_Time As DateTime) Between CAST(@From_Time As DateTime) AND Cast(@To_Time As DateTime)) OR  
     (CAST(T.To_Time As DateTime) Between CAST(@From_Time As DateTime) AND Cast(@To_Time As DateTime)))   
    DECLARE @ERR VARCHAR(256);  
    SET @ERR = 'There is already canteen detail exist for ' + @From_Time + ' To '  + @To_Time;  
    RAISERROR (@ERR, 16, 2);   
    RETURN 0;  
   END  
     
   IF (@Tran_type = 'I') BEGIN  
    SELECT @Cnt_Id=ISNULL((SELECT MAX(Cnt_Id) From dbo.T0050_CANTEEN_MASTER T WITH (NOLOCK) ),0)+1;  
     
    INSERT INTO dbo.T0050_CANTEEN_MASTER(Cmp_Id,Cnt_Id,Cnt_Name,From_Time,To_Time,System_Date,Ip_Id,Canteen_Image,CutOff_Time,Is_Active)  
    VALUES(@Cmp_Id,@Cnt_Id,@Cnt_Name,@From_Time,@To_Time,@effective_Date,@Ip_Id,@Image,@CutOff_Time,@Is_Active);  
   END ELSE IF (@Tran_type = 'U') BEGIN  
    UPDATE dbo.T0050_CANTEEN_MASTER  
    SET  Cnt_Name=@Cnt_Name, From_Time=@From_Time,To_Time=@To_Time,System_Date=@effective_Date,Ip_Id=@ip_id,Canteen_Image=@Image,
	CutOff_Time = @CutOff_Time,Is_Active = @Is_Active
    WHERE Cmp_ID=@Cmp_Id AND Cnt_ID=@Cnt_Id  
    --change System-Date of cuurrunet date to efective date in both insert and update case on 02-02-2021  
   END   
     
     
   --IF (@XmlDetail IS NOT NULL)    
   -- EXEC dbo.P0050_CANTEEN_DETAIL @Cmp_Id, @Cnt_Id, @XmlDetail;  
     
    IF (@XmlDetail IS NOT NULL)    
    EXEC P0050_CANTEEN_DETAIL_New @Cmp_Id, @Cnt_Id, @effective_Date,@Tran_type,@XmlDetail;  
     
     
   If (@Cnt_Id = 0)  
    RAISERROR (N'Canteen Detail Cannot be saved.', 16, 2);   
  END ELSE IF (@Tran_type = 'D') BEGIN  
   DELETE FROM dbo.T0050_CANTEEN_DETAIL  
   WHERE Cmp_ID=@Cmp_Id AND Cnt_ID=@Cnt_Id  
     
   DELETE FROM dbo.T0050_CANTEEN_MASTER  
   WHERE Cmp_ID=@Cmp_Id AND Cnt_ID=@Cnt_Id  
     
   --COMMIT;  
   --RETURN 0;  
  END ELSE IF (@Tran_type = 'S') BEGIN  
    
   --SELECT * FROM dbo.T0050_CANTEEN_MASTER T WHERE T.Cmp_ID=@Cmp_ID AND T.Cnt_ID=@Cnt_Id  
     
    SELECT t.*,CD.Effective_Date FROM dbo.T0050_CANTEEN_MASTER T WITH (NOLOCK) 
	left join (select max(Effective_Date) as Effective_Date , cnt_id from  T0050_CANTEEN_DETAIL WITH (NOLOCK) 
	where Cmp_Id=@cmp_id and Cnt_Id=@Cnt_Id group by cnt_id)CD on T.Cnt_Id = CD.Cnt_Id   
	WHERE T.Cmp_ID=@Cmp_ID AND T.Cnt_ID=@Cnt_Id  
     
     
   SELECT * FROM dbo.T0050_CANTEEN_DETAIL T WITH (NOLOCK) WHERE T.Cmp_ID=@Cmp_ID AND T.Cnt_ID=@Cnt_Id Order By Effective_Date ASC;  
   SET @Cnt_Id = 0;   
   --COMMIT;  
  END    
     
  RETURN 0;  
    
  --EXIT_SP:  
     
 --END TRY  
  
 /*  
 BEGIN CATCH  
  SET @Cnt_Id = 0;      
 END CATCH  
 */  
 SET NOCOUNT OFF;  
END  
  
  