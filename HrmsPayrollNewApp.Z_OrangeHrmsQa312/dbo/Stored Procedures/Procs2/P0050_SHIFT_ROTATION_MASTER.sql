  
-- =============================================  
-- Author:   Nimesh Parmar  
-- Create date:  09 April, 2015  
-- Last Updated: 07 October, 2015  
-- Description:  To Insert/Update/Delete Shift Rotation Detail  
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
-- =============================================  

CREATE PROCEDURE [dbo].[P0050_SHIFT_ROTATION_MASTER]  
 @Cmp_ID numeric(18,0),  
 @Tran_ID numeric(18,0) Output,  
 @Rotation_Name varchar(100),   
 @ShiftIDs varchar(max) = '',  
 @Tran_Type varchar(1),  
 @Sorting_No int,  
   
 @Rotation_Type int = 1,  
 @Change_Mode int = 0,  
 @Change_On smallint = 0,  
 @Change_After smallint = 0,  
 @Skip_WeekOff bit = 0,  
 @ChangeOn_Day tinyint = 0  
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
BEGIN  
   
 Declare @SQL varchar(max);  
 SET @SQL = '';  
 Declare @Day int;  
 set @Day= 1;  
 Declare @Index int;  
 SET @Index = 0;  
 Declare @tempVal varchar(25);  
 if (RIGHT(@ShiftIDs,1) <> ',')  
  SET @ShiftIDs = @ShiftIDs + ',';  
    
   
 Set @Rotation_Name = RTRIM(LTRIM(@Rotation_Name));  
   
 DECLARE @SHIFT_DETAIL VARCHAR(MAX)  
 IF (@Rotation_Type = 0)  
 BEGIN  
  SET @SHIFT_DETAIL = @ShiftIDs  
  SET @ShiftIDs = '';  
  WHILE (@Day  < 32)  
  BEGIN  
   SET @ShiftIDs = @ShiftIDs + '0,'  
   SET @Day = @Day +1;  
  END     
 END  
   
   
   
 DECLARE @Existing int;  
 DECLARE @OldValue as varchar(MAX) = ''

 Select @Existing = Tran_ID From T0050_Shift_Rotation_Master WITH (NOLOCK) Where Tran_ID <> @Tran_ID And Cmp_ID = @Cmp_ID AND Rotation_Name = @Rotation_Name;  
 IF (@Existing IS NOT NULL) BEGIN   
  Set @Tran_ID = 0;  
  Return 0;  
 END  
   
 Select @Existing = Tran_ID From T0050_Shift_Rotation_Master WITH (NOLOCK) Where Tran_ID <> @Tran_ID And Cmp_ID = @Cmp_ID AND Sorting_No = @Sorting_No;  
 IF (@Existing IS NOT NULL) BEGIN   
  Set @Tran_ID = 0;  
  Return 0;  
 END  
   
   
      set @Rotation_Name = dbo.fnc_ReverseHTMLTags(@Rotation_Name)  --added by Ronak 081021   
 IF (@Tran_Type ='U') BEGIN     
  while (@Day < 32) BEGIN    
   SET @tempVal = SUBSTRING(@ShiftIDs, @Index, CHARINDEX(',', @ShiftIDs, @Index) - @Index)     
   SET @Index = CHARINDEX(',', @ShiftIDs, @Index )+1     
   SET @SQL = @SQL + 'Day' + CAST(@Day As varchar) + '=' + @tempVal + ',';  
   SET @Day = @Day + 1;      
  END  
 END  
 ELSE  
  SET @SQL = @ShiftIDs;  
   
 IF NOT (@Change_On = 9 AND @Rotation_Type = 0)  
  SET @ChangeOn_Day = 0  
   
   
    
 If (@Tran_Type = 'I') BEGIN  
    
  Select @Tran_ID = ISNULL((Select MAX(Tran_ID) From T0050_Shift_Rotation_Master WITH (NOLOCK)),0) +1;  
  SET @SQL = 'Insert Into T0050_Shift_Rotation_Master(Cmp_ID,Tran_ID,Rotation_Name,Day1,Day2,Day3,Day4,Day5,Day6,  
    Day7,Day8,Day9,Day10,Day11,Day12,Day13,Day14,Day15,Day16,Day17,Day18,Day19,Day20,Day21,Day22,  
    Day23,Day24,Day25,Day26,Day27,Day28,Day29,Day30,Day31,SysDate,Sorting_No,  
    Rotation_Type,Change_Mode,Change_On,Change_After,Skip_WeekOff,ChangeOn_Day)Values(' + Cast(@Cmp_ID As Varchar(20)) + ',' +  
    Cast(@Tran_ID As Varchar(20)) + ',''' + @Rotation_Name + ''',' + @SQL + 'getDate(),  
    ' + Cast(@Sorting_No As Varchar) + ',' + Cast(@Rotation_Type As Varchar) + ',' +   
    Cast(@Change_Mode As Varchar) + ',' + Cast(@Change_On As Varchar) + ',' +   
    Cast(@Change_After As Varchar) + ',' + Cast(@Skip_WeekOff as Varchar) + ',' + Cast(@ChangeOn_Day as Varchar) + ');'      
  Exec(@SQL);     

	set @OldValue = 'New Value' + '#'+ 'Tran_ID :' + cast(ISNULL(@Tran_ID,0) as varchar(5)) 
	+ '#' + 'Rotation_Name :' + cast(ISNULL(@Rotation_Name,0) as varchar(50)) 
	+ '#' + 'SQL :' + cast(isnull(@SQL,0) as varchar(500)) 
	+ '#' + 'Sorting_No :' + cast(isnull(@Sorting_No,0) as varchar(Max))  
	+ '#' + 'Rotation_Type  :' + cast(isnull(@Rotation_Type,0) as varchar(5)) 
	+ '#' + 'Change_Mode :' + cast(isnull(@Change_Mode,0) as varchar(5))
	+ '#' + 'Change_On :' + cast(ISNULL(@Change_On,0) as varchar(5))   
	+ '#' + 'Change_After :' + cast(ISNULL(@Change_After,0) as varchar(5))              
	+ '#' + 'Skip_WeekOff :' + cast(ISNULL(@Skip_WeekOff,0) as varchar(5))
	+ '#' + 'ChangeOn_Day :' + cast(ISNULL(@ChangeOn_Day,0) as varchar(5))
					


 END  
 ELSE If (@Tran_Type = 'U') BEGIN  

  SET @SQL = 'Update T0050_Shift_Rotation_Master Set Sorting_No=' + Cast(@Sorting_No As Varchar) + ',  
    Rotation_Name=''' + @Rotation_Name + ''',' +   
    'Rotation_Type=' +  Cast(@Rotation_Type As Varchar) +',' +   
    'Change_Mode=' +  Cast(@Change_Mode As Varchar) +',' +   
    'Change_On=' +  Cast(@Change_On As Varchar) +',' +   
    'Change_After=' +  Cast(@Change_After As Varchar) +',' +       
    'Skip_WeekOff=' + Cast(@Skip_WeekOff as Varchar) + ',' +   
    'ChangeOn_Day=' + Cast(@ChangeOn_Day as Varchar) + ',' +   
    @SQL + 'SysDate=getDate() Where Cmp_ID=' + Cast(@Cmp_ID As Varchar) + ' And   
    Tran_ID=' + Cast(@Tran_ID As Varchar)  
      
  Exec(@SQL)    

  set @OldValue = 'Old Value' + '#'+ 'Tran_ID :' + cast(ISNULL(@Tran_ID,0) as varchar(5)) 
	+ '#' + 'Rotation_Name :' + cast(ISNULL(@Rotation_Name,0) as varchar(50)) 
	+ '#' + 'SQL :' + cast(isnull(@SQL,0) as varchar(500)) 
	+ '#' + 'Sorting_No :' + cast(isnull(@Sorting_No,0) as varchar(Max))  
	+ '#' + 'Rotation_Type  :' + cast(isnull(@Rotation_Type,0) as varchar(5)) 
	+ '#' + 'Change_Mode :' + cast(isnull(@Change_Mode,0) as varchar(5))
	+ '#' + 'Change_On :' + cast(ISNULL(@Change_On,0) as varchar(5))   
	+ '#' + 'Change_After :' + cast(ISNULL(@Change_After,0) as varchar(5))              
	+ '#' + 'Skip_WeekOff :' + cast(ISNULL(@Skip_WeekOff,0) as varchar(5))
	+ '#' + 'ChangeOn_Day :' + cast(ISNULL(@ChangeOn_Day,0) as varchar(5))
					


 END  
    ELSE If (@Tran_Type = 'D') BEGIN   
  IF EXISTS(SELECT 1 FROM T0050_Emp_Monthly_Shift_Rotation WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Rotation_ID=@Tran_ID)  
   SET @Tran_ID = 0;  
  ELSE  
   BEGIN  
    DELETE FROM T0050_Shift_Rotation_Master WHERE Cmp_ID=@Cmp_ID And Tran_ID=@Tran_ID  
    DELETE FROM T0050_SHIFT_ROTATION_DETAIL WHERE Cmp_ID=@Cmp_ID And Rotation_ID=@Tran_ID  
   END  
 END  
   
 If (@Tran_Type = 'I' OR @Tran_Type = 'U') AND @Rotation_Type = 0  
 BEGIN      
    
  SELECT T.Id, T.Data   
  INTO #rotDetail  
  FROM dbo.Split(@SHIFT_DETAIL, ',') T  
  WHERE DATA <> ''  
    
      
  DECLARE @Shift_Tran_ID NUMERIC  
    
  SELECT @Shift_Tran_ID= ISNULL(MAX(Shift_Tran_ID),0)   
  FROM T0050_SHIFT_ROTATION_DETAIL WITH (NOLOCK)  
    
  DELETE FROM T0050_SHIFT_ROTATION_DETAIL  WHERE Rotation_ID=@Tran_ID AND CMP_ID=@CMP_ID  
    
  INSERT INTO dbo.T0050_SHIFT_ROTATION_DETAIL (Cmp_ID,Shift_Tran_ID, Rotation_ID,Shift_ID,Sort_ID)  
  SELECT @Cmp_ID, @Shift_Tran_ID + T.Id, @Tran_ID, SM.Shift_ID, T.Id  
  FROM (SELECT Id,Cast(data As Numeric) As Shift_ID FROM #rotDetail Where IsNull(data,'') <> '') T   
    INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON T.Shift_ID=SM.Shift_ID  
  WHERE SM.Cmp_ID=@Cmp_Id  
    
 END  
	
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Shift Rotation Master',@OldValue,0,0,0
END  
  
  