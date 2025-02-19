CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_TravelAPI_Data]  
 @TRAVEL_APPLICATION_ID NUMERIC(18,0),  
 @Rpt_Level  INT = 0,  
 @EMP_ID INT = 0,  
 @Type char   
   
AS  
BEGIN  
  
 Declare @chkInter int  
  
  
 SELECT @chkInter = Chk_International FROM T0100_TRAVEL_APPLICATION WHERE Travel_Application_ID = @TRAVEL_APPLICATION_ID   
   
 If (@chkInter = 0 and @Type = 'P')  
 Begin  
   
  If(@Rpt_Level = 0 OR @Rpt_Level = 1)   
   BEGIN  
  
  ---travel  
    SELECT * FROM T0100_TRAVEL_APPLICATION WHERE TRAVEL_APPLICATION_ID = @TRAVEL_APPLICATION_ID  
  
  ---travel_Details  
    If(@Type = 'P' and @Rpt_Level = 0  or @Type = 'P' and @Rpt_Level = 1)  
     Begin   
      SELECT distinct td.Travel_App_Detail_ID,td.Cmp_ID,Travel_App_ID,td.Place_Of_Visit,td.Travel_Purpose,  
      td.Instruct_Emp_ID,Emp_Full_Name_new as 'Instruct_Emp_Name',td.Travel_Mode_ID,td.From_Date,td.Period,td.To_Date,td.Remarks  
      ,td.State_ID,td.City_ID,isnull(td.Loc_ID,0) as Loc_ID  
      ,td.Project_ID,TravelTypeId,State_Name,City_Name, '' as CountryName  
      ,Travel_Type_Name,0 as Leave_ID,'' as LeaveType,0 as Leave_Approval_ID,0 as Night_Day  
      ,0 as Rpt_Level,'' as 'Approval_Comments'  
      FROM T0110_TRAVEL_APPLICATION_DETAIL as td inner join T0020_STATE_MASTER as st on td.State_ID = st.State_ID  
      INNER JOIN T0030_CITY_MASTER as CM on cm.City_ID = td.City_ID  
      Left JOIN T0040_Travel_Type as ty on ty.Travel_Type_Id = td.TravelTypeId  
      Left join V0080_Employee_Master as em on em.Emp_Id = td.Instruct_Emp_ID  
      WHERE Travel_App_ID = @TRAVEL_APPLICATION_ID  
      and td.Cmp_ID=(select Cmp_ID from T0100_TRAVEL_APPLICATION where Travel_Application_ID=@TRAVEL_APPLICATION_ID)--Added by Yogesh on 02032023  
    End  
    Else  
     Begin  
       
      SELECT distinct td.Travel_App_Detail_ID,td.Cmp_ID,td.Travel_Application_ID as 'Travel_App_ID',td.Place_Of_Visit,td.Travel_Purpose,  
      td.Instruct_Emp_ID,Emp_Full_Name_new as 'Instruct_Emp_Name',td.Travel_Mode_ID,td.From_Date,td.Period,td.To_Date,td.Remarks  
      ,td.State_ID,td.City_ID,isnull(td.Loc_ID,0) as Loc_ID  
      ,td.Project_ID,TravelTypeId,State_Name,City_Name, '' as CountryName  
      ,ty.Travel_Type_Name,0 as Leave_ID,'' as LeaveType,0 as Leave_Approval_ID,0 as Night_Day  
      ,0 as Rpt_Level,Approval_Comments  
      FROM V0115_TRAVEL_APPLICATION_DETAIL_LEVEL as td inner join T0020_STATE_MASTER as st on td.State_ID = st.State_ID  
      INNER JOIN T0030_CITY_MASTER as CM on cm.City_ID = td.City_ID  
      Left JOIN T0040_Travel_Type as ty on ty.Travel_Type_Id = td.TravelTypeId  
      Left join V0080_Employee_Master as em on em.Emp_Id = td.Instruct_Emp_ID  
      LEFT OUTER JOIN (SELECT Travel_Application_ID,chk_adv,chk_agenda,tour_Agenda,IMP_Business_Appoint,KRA_Tour,Attached_Doc_File  
      ,Approval_Comments FROM T0115_TRAVEL_LEVEL_APPROVAL WHERE rpt_level = (SELECT MAX(rpt_level) AS rpt_level FROM T0115_TRAVEL_LEVEL_APPROVAL   
      WHERE Travel_Application_ID = @TRAVEL_APPLICATION_ID) AND Travel_Application_ID = @TRAVEL_APPLICATION_ID) AS Qry ON td.Travel_Application_ID = Qry.Travel_Application_ID   
      WHERE td.Travel_Application_ID = @TRAVEL_APPLICATION_ID  
      and td.Cmp_ID=(select Cmp_ID from T0100_TRAVEL_APPLICATION where Travel_Application_ID=@TRAVEL_APPLICATION_ID)--Added by Yogesh on 02032023  
    End  
  
  ---travel_Other_Details  
    
    SELECT distinct t.Travel_App_Other_Detail_Id,t.Cmp_ID,t.Travel_App_ID,t.Travel_Mode_Id,For_date,t.Description,t.Amount,Self_Pay  
    ,t.modify_Date,To_Date,Curr_ID,SGST,CGST,IGST,GST_No,GST_Company_Name,Tran_ID,Travel_Mode,From_Place,To_Place,Mode_Name,  
    Mode_No,City,Check_Out_Date,No_Passenger,Booking_Date,Pick_Up_Address,Pick_Up_Time,Drop_Address,Bill_No,T1.Description,Travel_Mode_Name  
    ,Login_ID,Create_Date,GST_Applicable,Mode_Type,0 as 'Curr_ID','' as 'Curr_Name',0.00 as 'Curr_Rate','' as 'Curr_Major',  
    '' as 'Curr_Symbol',  
    '' as 'Curr_Sub_Name'  
    FROM T0110_Travel_Application_Other_Detail T Left outer join T0110_TRAVEL_APPLICATION_MODE_DETAIL T1 on   
    T.Travel_App_Other_Detail_Id=T1.Travel_App_Other_Detail_ID and T.Travel_App_ID=T1.Travel_App_ID   
    Left outer join T0030_TRAVEL_MODE_MASTER as MM on MM.Travel_Mode_ID = T1.Travel_Mode  
    Where T.Travel_App_ID =@TRAVEL_APPLICATION_ID and t.Cmp_ID = t1.Cmp_ID  
    and t.Cmp_ID=(select Cmp_ID from T0100_TRAVEL_APPLICATION where Travel_Application_ID=@TRAVEL_APPLICATION_ID)--Added by Yogesh on 02032023  
  
    
  ---travel_Advance_Details  
    SELECT Travel_Advance_Detail_ID,Cmp_ID,Travel_App_ID,Expence_Type,Amount,Adv_Detail_Desc,0 as 'Curr_ID','' as 'Curr_Name',0.00 as 'Curr_Rate','' as 'Curr_Major','' as 'Curr_Symbol','' as 'Curr_Sub_Name'  
    FROM T0110_TRAVEL_ADVANCE_DETAIL WHERE TRAVEL_APP_ID = @TRAVEL_APPLICATION_ID  
  
  -------Date Validation  
    select TAD.From_Date,TAD.To_Date from T0130_TRAVEL_APPROVAL_DETAIL as TAD inner join T0120_TRAVEL_APPROVAL as TA ON   
    TAD.Travel_Approval_ID = TA.Travel_Approval_ID where TA.Approval_Status = 'A' AND TA.Emp_ID=@EMP_ID  
  
   End  
  ELSE   
   BEGIN  
     
    ---travel  
    SELECT top 1 ta.Travel_Application_ID,ta.Cmp_ID,ta.Emp_ID,ta.S_Emp_ID,ta.Application_Date,ta.Application_Code,ta.Application_Status,ta.Login_ID,ta.Create_Date,    
    ta.Modify_Date,ta.chk_Adv,ta.chk_Agenda,tpr.Tour_Agenda,tpr.IMP_Business_Appoint,tpr.KRA_Tour,tpr.Attached_Doc_File,ta.Chk_International,Approval_Comments  
    FROM T0100_TRAVEL_APPLICATION as ta left join T0115_TRAVEL_LEVEL_APPROVAL as tpr on ta.Travel_Application_ID = tpr.Travel_Application_ID    
    WHERE ta.Travel_Application_ID = @TRAVEL_APPLICATION_ID  
    And Rpt_Level = (Select MAX(Rpt_Level) As Rpt_level From T0115_TRAVEL_LEVEL_APPROVAL   
    Where Travel_Application_ID = @TRAVEL_APPLICATION_ID)   
      
  
    ---travel_Details  
    SELECT DISTINCT Row_ID,td.Tran_ID,td.Travel_Application_Id,td.Cmp_ID,td.Place_Of_Visit,td.Travel_Purpose  
    ,td.Instruct_Emp_ID,Emp_Full_Name_new as 'Instruct_Emp_Name',  
    td.Travel_Mode_ID,td.From_Date,td.Period,td.To_Date,  
    td.Remarks,Leave_Approval_ID,td.Leave_ID,td.State_ID,td.City_ID,isnull(td.Loc_ID,0) as Loc_ID,td.Project_ID,Half_Leave_Date  
    ,lm.Leave_Name,Night_Day,State_Name,  
    City_Name, '' as CountryName  
    ,Travel_Type_Name,0 as Leave_ID,lm.Leave_Name as LeaveType,0 as Leave_Approval_ID,0 as Night_Day  
    ,ISnull(Rpt_Level,0) as Rpt_Level  
    from T0115_TRAVEL_APPROVAL_DETAIL_LEVEL as td  
    Left join V0080_Employee_Master as em on em.Emp_Id = td.Instruct_Emp_ID  
    left join T0040_LEAVE_MASTER as lm on td.Leave_ID =  lm.Leave_ID   
    left join T0020_STATE_MASTER as st on td.State_ID = st.State_ID  
    left JOIN T0030_CITY_MASTER as CM on cm.City_ID = td.City_ID  
    left join T0110_TRAVEL_APPLICATION_DETAIL  as tad  on tad.Travel_App_ID = td.Travel_Application_Id  
    left join T0040_Travel_Type as ty on   
    Travel_Type_Id = TravelTypeId and ty.Cmp_Id = tad.Cmp_ID   
    left join T0115_TRAVEL_LEVEL_APPROVAL as ta       
    on td.Travel_Application_Id= ta.Travel_Application_ID --and td.Tran_ID= ta.Tran_Id   
    WHERE td.Travel_Application_Id = @TRAVEL_APPLICATION_ID and Rpt_Level = (@Rpt_Level - 1) --and ta.Tran_Id = td.Tran_ID  
    --=================================Commented by Yogesh on 04032023==================================================================================  
    ---travel_Other_Details  
  
    --if (select Count(*) from T0110_Travel_Application_Other_Detail where  Travel_App_ID=18)<>0   
    --begin  
    --SELECT tdl.Travel_Apr_Other_Detail_ID as 'Travel_App_Other_Detail_Id',t.Cmp_ID,tla.Travel_Application_ID as 'Travel_App_ID',  
    --tdl.Travel_Mode_Id,TDL.For_date,tdl.Description,tdl.Amount,TDL.Self_Pay  
    --,tdl.modify_Date,TDL.To_Date,TDL.Curr_ID,tdl.SGST,tdl.CGST,tdl.IGST,tdl.GST_No,tdl.GST_Company_Name,tdl.Tran_ID,  
    --tdl.Travel_Mode_ID as Travel_Mode,  
    --From_Place,To_Place,Mode_Name,  
    --Mode_No,City,Check_Out_Date,No_Passenger,Booking_Date,Pick_Up_Address,Pick_Up_Time,Drop_Address,Bill_No,T1.Description,Travel_Mode_Name  
    --,mm.Login_ID,Create_Date,GST_Applicable,Mode_Type,0 as 'Curr_ID','' as 'Curr_Name',0.00 as 'Curr_Rate','' as 'Curr_Major',  
    --'' as 'Curr_Symbol',  
    --'' as 'Curr_Sub_Name'  
    --FROM T0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL as tdl inner join T0115_TRAVEL_LEVEL_APPROVAL as tla  
    --on tdl.Tran_ID = tla.Tran_Id   
    --left join T0110_Travel_Application_Other_Detail as t   
    --on t.Travel_App_ID = tla.Travel_Application_ID  
    --Left outer join T0115_TRAVEL_APPROVAL_OTHER_MODE_DETAIL_LEVEL T1 on   
    --tdl.Travel_Apr_Other_Detail_ID=T1.Travel_Approval_Other_Detail_ID   
    --Left outer join T0030_TRAVEL_MODE_MASTER as MM on MM.Travel_Mode_ID = tdl.Travel_Mode_ID  
    --where  tla.Travel_Application_ID = @TRAVEL_APPLICATION_ID and tla.Cmp_ID = tla.Cmp_ID  
    --And Rpt_Level = (Select MAX(Rpt_Level) As Rpt_level From T0115_TRAVEL_LEVEL_APPROVAL   
    --Where Travel_Application_ID = @TRAVEL_APPLICATION_ID)   
    --and t.Cmp_ID=(select Cmp_ID from T0100_TRAVEL_APPLICATION where Travel_Application_ID=@TRAVEL_APPLICATION_ID) and t.Cmp_ID is not null --Added by Yogesh on 02032023  
    --=================================Commented by Yogesh on 04032023==================================================================================  
    --=================================Added by Yogesh on 04032023==================================================================================  
    SELECT distinct  
    (select Max(Travel_Apr_Other_Detail_ID) from T0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL where Tran_Id=tla.Tran_Id Group by Tran_Id  ) as Travel_App_Other_Detail_Id,  
    tdl.Cmp_ID,tla.Travel_Application_ID as 'Travel_App_ID',  
    tdl.Travel_Mode_Id as Travel_Mode,  
    TDL.For_date,tdl.Description,tdl.Amount,TDL.Self_Pay,  
    --,tdl.modify_Date  
    (select Max(modify_Date) from T0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL where Tran_Id=tla.Tran_Id Group by Tran_Id  ) as modify_Date  
    ,TDL.To_Date,TDL.Curr_ID,tdl.SGST,tdl.CGST,tdl.IGST,tdl.GST_No,tdl.GST_Company_Name,tdl.Tran_ID,  
    tdl.Travel_Mode_ID as Travel_Mode,--Rpt_Level,  
    From_Place,To_Place,Mode_Name,  
    Mode_No,City,  
    (select max(Check_Out_Date) from T0115_TRAVEL_APPROVAL_OTHER_MODE_DETAIL_LEVEL where Other_Tran_ID=tla.Tran_Id )as Check_Out_Date,  
    No_Passenger,  
    (select max(Booking_Date) from T0115_TRAVEL_APPROVAL_OTHER_MODE_DETAIL_LEVEL where Other_Tran_ID=tla.Tran_Id )as Booking_Date,  
    Pick_Up_Address  
    ,(select max(Pick_Up_Time) from T0115_TRAVEL_APPROVAL_OTHER_MODE_DETAIL_LEVEL where Other_Tran_ID=tla.Tran_Id )as Pick_Up_Time  
    ,Drop_Address,Bill_No,T1.Description,Travel_Mode_Name  
    ,mm.Login_ID,Create_Date,GST_Applicable,Mode_Type,0 as 'Curr_ID','' as 'Curr_Name',0.00 as 'Curr_Rate','' as 'Curr_Major',  
    '' as 'Curr_Symbol',  
    '' as 'Curr_Sub_Name'  
    FROM T0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL as tdl inner join T0115_TRAVEL_LEVEL_APPROVAL as tla  
    on tdl.Tran_ID = tla.Tran_Id   
    left join T0110_Travel_Application_Other_Detail as t   
    on t.Travel_App_ID = tla.Travel_Application_ID  
    Left outer join T0115_TRAVEL_APPROVAL_OTHER_MODE_DETAIL_LEVEL T1 on   
    tdl.Travel_Apr_Other_Detail_ID=T1.Travel_Approval_Other_Detail_ID and tdl.Tran_ID=t1.Other_Tran_ID  
    Left outer join T0030_TRAVEL_MODE_MASTER as MM on MM.Travel_Mode_ID = tdl.Travel_Mode_ID  
    where  tla.Travel_Application_ID = @TRAVEL_APPLICATION_ID and tla.Cmp_ID = tla.Cmp_ID  
    And Rpt_Level = (Select MAX(Rpt_Level) As Rpt_level From T0115_TRAVEL_LEVEL_APPROVAL   
    Where Travel_Application_ID = @TRAVEL_APPLICATION_ID)   
  
    and MM.Cmp_ID=(select Cmp_ID from T0100_TRAVEL_APPLICATION where Travel_Application_ID=@TRAVEL_APPLICATION_ID)  --Added by Yogesh on 02032023  
      
    --=================================Added by Yogesh on 04032023==================================================================================  
      
    
  
  
  
    ---travel_Advance_Details   
    SELECT distinct adl.Tran_Id as 'Travel_Advance_Detail_ID',adl.Cmp_ID,adl.Travel_App_ID,adl.Expence_Type,adl.Amount,adl.Adv_Detail_Desc,  
    0 as 'Curr_ID','' as 'Curr_Name',0.00 as 'Curr_Rate','' as 'Curr_Major','' as 'Curr_Symbol','' as 'Curr_Sub_Name'  
    FROM T0115_TRAVEL_APPROVAL_ADVDETAIL_LEVEL  as adl  
    inner join T0115_TRAVEL_LEVEL_APPROVAL as tla on adl.Tran_Id = tla.Tran_Id and tla.Travel_Application_ID = adl.Travel_App_ID  
    left join T0110_TRAVEL_ADVANCE_DETAIL as ad on ad.Travel_App_ID = adl.Travel_App_ID   
    WHERE adl.Travel_App_ID = @TRAVEL_APPLICATION_ID and tla.Tran_Id = (select max(Tran_Id) from T0115_TRAVEL_LEVEL_APPROVAL where Travel_Application_ID = @TRAVEL_APPLICATION_ID)   
    and tla.Cmp_ID = adl.Cmp_ID  
  
  
    -------Date Validation  
    select TAD.From_Date,TAD.To_Date from T0130_TRAVEL_APPROVAL_DETAIL as TAD inner join T0120_TRAVEL_APPROVAL as TA ON   
    TAD.Travel_Approval_ID = TA.Travel_Approval_ID where TA.Approval_Status = 'A' AND TA.Emp_ID=@EMP_ID  
      
   End   
  
 End  
 ELSE IF(@chkInter = 0 and @Type!= 'P')  
 Begin  
  
    SELECT top 1 ta.Travel_Application_ID,ta.Cmp_ID,ta.Emp_ID,ta.S_Emp_ID,ta.Application_Date,ta.Application_Code,ta.Application_Status,ta.Login_ID,ta.Create_Date,    
    ta.Modify_Date,ta.chk_Adv,ta.chk_Agenda,tpr.Tour_Agenda,tpr.IMP_Business_Appoint,tpr.KRA_Tour,tpr.Attached_Doc_File,ta.Chk_International,Approval_Comments   
    FROM T0100_TRAVEL_APPLICATION as ta left join T0115_TRAVEL_LEVEL_APPROVAL as tpr on ta.Travel_Application_ID = tpr.Travel_Application_ID    
	--and Rpt_Level = (Select isnull(MAX(Rpt_Level),0) As Rpt_level From T0115_TRAVEL_LEVEL_APPROVAL   
	--Where Travel_Application_ID = 446)   
    WHERE ta.Travel_Application_ID = @TRAVEL_APPLICATION_ID And Rpt_Level = (Select MAX(Rpt_Level) As Rpt_level From T0115_TRAVEL_LEVEL_APPROVAL   
    Where Travel_Application_ID = @TRAVEL_APPLICATION_ID)   
  
  
    ---travel_Details  
    SELECT DISTINCT td.Tran_ID as 'Travel_App_Detail_ID',td.Cmp_ID,td.Travel_Application_Id as 'Travel_App_ID',td.Place_Of_Visit,  
    td.Travel_Purpose  
    ,td.Instruct_Emp_ID,Emp_Full_Name_new as 'Instruct_Emp_Name',  
    td.Travel_Mode_ID,td.From_Date,td.Period,td.To_Date,  
    td.Remarks,td.State_ID,td.City_ID,isnull(td.Loc_ID,0) as Loc_ID,td.Project_ID,Travel_Type_Id as 'TravelTypeId',  
    State_Name,City_Name, '' as CountryName,  
    Travel_Type_Name,td.Leave_ID,lm.Leave_Name as LeaveType,isnull(Leave_Approval_ID,0) as Leave_Approval_ID,ISnull(Night_Day,0) as Night_Day,ISnull(Rpt_Level,0) as Rpt_Level  
    from T0115_TRAVEL_APPROVAL_DETAIL_LEVEL as td  
    Left join V0080_Employee_Master as em on em.Emp_Id = td.Instruct_Emp_ID  
    left join T0040_LEAVE_MASTER as lm on td.Leave_ID =  lm.Leave_ID   
    left join T0020_STATE_MASTER as st on td.State_ID = st.State_ID  
    left JOIN T0030_CITY_MASTER as CM on cm.City_ID = td.City_ID  
    left join T0110_TRAVEL_APPLICATION_DETAIL  as tad  on tad.Travel_App_ID = td.Travel_Application_Id  
    left join T0040_Travel_Type as ty on   
    Travel_Type_Id = TravelTypeId and ty.Cmp_Id = tad.Cmp_ID   
    left join T0115_TRAVEL_LEVEL_APPROVAL as ta       
    on td.Travel_Application_Id= ta.Travel_Application_ID --and td.Tran_ID= ta.Tran_Id   
    WHERE td.Travel_Application_Id = @TRAVEL_APPLICATION_ID and Rpt_Level = (Select MAX(Rpt_Level) As Rpt_level From T0115_TRAVEL_LEVEL_APPROVAL   
    Where Travel_Application_ID = @TRAVEL_APPLICATION_ID) and ta.Tran_Id = td.Tran_ID   
    and td.Cmp_ID=(select Cmp_ID from T0100_TRAVEL_APPLICATION where Travel_Application_ID=@TRAVEL_APPLICATION_ID)--Added by Yogesh on 02032023  
  
  
   ---travel_Other_Details  
    SELECT distinct tdl.Travel_Apr_Other_Detail_ID as 'Travel_App_Other_Detail_Id',t.Cmp_ID,tla.Travel_Application_ID as 'Travel_App_ID',  
     tdl.Travel_Mode_Id,TDL.For_date,tdl.Description,tdl.Amount,TDL.Self_Pay  
     ,tdl.modify_Date,TDL.To_Date,TDL.Curr_ID,tdl.SGST,tdl.CGST,tdl.IGST,tdl.GST_No,tdl.GST_Company_Name,tdl.Tran_ID,  
     tdl.Travel_Mode_ID as Travel_Mode,  
     From_Place,To_Place,Mode_Name,  
     Mode_No,City,Check_Out_Date,No_Passenger,Booking_Date,Pick_Up_Address,Pick_Up_Time,Drop_Address,Bill_No,T1.Description,Travel_Mode_Name  
     ,mm.Login_ID,Create_Date,GST_Applicable,Mode_Type,0 as 'Curr_ID','' as 'Curr_Name',0.00 as 'Curr_Rate','' as 'Curr_Major',  
     '' as 'Curr_Symbol',  
     '' as 'Curr_Sub_Name'  
     FROM T0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL as tdl inner join T0115_TRAVEL_LEVEL_APPROVAL as tla  
     on tdl.Tran_ID = tla.Tran_Id left join T0110_Travel_Application_Other_Detail as t   
     on t.Travel_App_ID = tla.Travel_Application_ID   
     Left outer join T0115_TRAVEL_APPROVAL_OTHER_MODE_DETAIL_LEVEL T1 on   
     tdl.Travel_Apr_Other_Detail_ID=T1.Travel_Approval_Other_Detail_ID and  tdl.Tran_ID=t1.Other_Tran_ID  
     Left outer join T0030_TRAVEL_MODE_MASTER as MM on MM.Travel_Mode_ID = tdl.Travel_Mode_ID  
     where  tla.Travel_Application_ID = @TRAVEL_APPLICATION_ID and tla.Cmp_ID = tla.Cmp_ID  
     And Rpt_Level = (Select MAX(Rpt_Level) As Rpt_level From T0115_TRAVEL_LEVEL_APPROVAL   
     Where Travel_Application_ID = @TRAVEL_APPLICATION_ID)  
     and t.Cmp_ID=(select Cmp_ID from T0100_TRAVEL_APPLICATION where Travel_Application_ID=@TRAVEL_APPLICATION_ID)--Added by Yogesh on 02032023  
  
    
  ---travel_Advance_Details  
        SELECT distinct adl.Tran_Id as 'Travel_Advance_Detail_ID',adl.Cmp_ID,adl.Travel_App_ID,adl.Expence_Type,adl.Amount,adl.Adv_Detail_Desc,  
    0 as 'Curr_ID','' as 'Curr_Name',0.00 as 'Curr_Rate','' as 'Curr_Major','' as 'Curr_Symbol','' as 'Curr_Sub_Name'  
    FROM T0115_TRAVEL_APPROVAL_ADVDETAIL_LEVEL  as adl  
    inner join T0115_TRAVEL_LEVEL_APPROVAL as tla on adl.Tran_Id = tla.Tran_Id and tla.Travel_Application_ID = adl.Travel_App_ID  
    left join T0110_TRAVEL_ADVANCE_DETAIL as ad on ad.Travel_App_ID = adl.Travel_App_ID   
    WHERE adl.Travel_App_ID = @TRAVEL_APPLICATION_ID and tla.Tran_Id = (select max(Tran_Id) from T0115_TRAVEL_LEVEL_APPROVAL where Travel_Application_ID = @TRAVEL_APPLICATION_ID)   
    and tla.Cmp_ID = adl.Cmp_ID  
  
    -------Date Validation  
    select TAD.From_Date,TAD.To_Date from T0130_TRAVEL_APPROVAL_DETAIL as TAD inner join T0120_TRAVEL_APPROVAL as TA ON   
    TAD.Travel_Approval_ID = TA.Travel_Approval_ID where TA.Approval_Status = 'A' AND TA.Emp_ID=@EMP_ID  
 END  
 ELSE  
  Begin  
    
 If(@Rpt_Level = 0 OR @Rpt_Level = 1)   
  Begin  

    SELECT DISTINCT td.Travel_App_Detail_ID,td.Cmp_ID,Travel_App_ID,td.Place_Of_Visit,td.Travel_Purpose,  
    td.Instruct_Emp_ID,Emp_Full_Name_new as 'Instruct_Emp_Name',td.Travel_Mode_ID,td.From_Date,td.Period,td.To_Date,td.Remarks  
    , 0 as 'State_ID', 0 as 'City_ID'  
    ,isnull(td.Loc_ID,0) as Loc_ID  
    ,td.Project_ID,TravelTypeId,'' as 'State_Name', '' as 'City_Name',lm.Loc_name as 'CountryName'  
    ,Travel_Type_Name,0 as Leave_ID,'' as LeaveType,0 as Leave_Approval_ID,0 as Night_Day  
    ,0 as Rpt_Level  
    FROM T0110_TRAVEL_APPLICATION_DETAIL as td   
    Left JOIN T0040_Travel_Type as ty on ty.Travel_Type_Id = td.TravelTypeId  
    left join T0001_LOCATION_MASTER as lm on lm.Loc_ID = td.Loc_ID  
    Left join V0080_Employee_Master as em on em.Emp_Id = td.Instruct_Emp_ID  
    WHERE Travel_App_ID = @TRAVEL_APPLICATION_ID  
  End  
  Else   
  Begin  
    SELECT DISTINCT Row_ID,td.Tran_ID,td.Travel_Application_Id,td.Cmp_ID,td.Place_Of_Visit,td.Travel_Purpose  
    ,td.Instruct_Emp_ID,Emp_Full_Name_new as 'Instruct_Emp_Name', 0 as 'State_ID', 0 as 'City_ID',  
    '' as 'State_Name', '' as 'City_Name',lmn.Loc_name as 'CountryName',  
    td.Travel_Mode_ID,td.From_Date,td.Period,td.To_Date,td.Remarks,Leave_Approval_ID,td.Leave_ID  
    ,isnull(td.Loc_ID,0) as Loc_ID,td.Project_ID,Half_Leave_Date,lm.Leave_Name,Night_Day  
    ,Travel_Type_Name,0 as Leave_ID,lm.Leave_Name as LeaveType,0 as Leave_Approval_ID,0 as Night_Day  
    ,ISnull(Rpt_Level,0) as Rpt_Level  
    from T0115_TRAVEL_APPROVAL_DETAIL_LEVEL as td  
    Left join V0080_Employee_Master as em on em.Emp_Id = td.Instruct_Emp_ID  
    left join T0040_LEAVE_MASTER as lm on td.Leave_ID =  lm.Leave_ID   
    left join T0001_LOCATION_MASTER as lmn on lmn.Loc_ID = td.Loc_ID  
  
    left join T0110_TRAVEL_APPLICATION_DETAIL  as tad  on tad.Travel_App_ID = td.Travel_Application_Id  
    left join T0040_Travel_Type as ty on   
    Travel_Type_Id = TravelTypeId and ty.Cmp_Id = tad.Cmp_ID   
    left join T0115_TRAVEL_LEVEL_APPROVAL as ta   
    on td.Travel_Application_Id= ta.Travel_Application_ID   
    WHERE td.Travel_Application_Id = @TRAVEL_APPLICATION_ID and Rpt_Level = (@Rpt_Level - 1)  
  End  
  
  
    
  SELECT * from T0110_Travel_Application_Other_Detail T Left outer join T0110_TRAVEL_APPLICATION_MODE_DETAIL T1 on   
    T.Travel_App_Other_Detail_Id=T1.Travel_App_Other_Detail_ID and T.Travel_App_ID=T1.Travel_App_ID   
    Left outer join T0030_TRAVEL_MODE_MASTER as MM on MM.Travel_Mode_ID = T1.Travel_Mode  
    left outer join T0040_CURRENCY_MASTER as cm on cm.Curr_ID = t.Curr_ID  
    Where T.Travel_App_ID =@TRAVEL_APPLICATION_ID and t.Cmp_ID = t1.Cmp_ID  
  
   SELECT * FROM T0110_TRAVEL_ADVANCE_DETAIL as t   
   left outer join T0040_CURRENCY_MASTER as cm on cm.Curr_ID = t.Curr_ID  
   WHERE TRAVEL_APP_ID = @TRAVEL_APPLICATION_ID  
   and t.Cmp_ID=(select Cmp_ID from T0100_TRAVEL_APPLICATION where Travel_Application_ID=@TRAVEL_APPLICATION_ID)--Added by Yogesh on 02032023  
  
   -------Date Validation  
    select TAD.From_Date,TAD.To_Date from T0130_TRAVEL_APPROVAL_DETAIL as TAD inner join T0120_TRAVEL_APPROVAL as TA ON   
    TAD.Travel_Approval_ID = TA.Travel_Approval_ID where TA.Approval_Status = 'A' AND TA.Emp_ID=@EMP_ID  
  
 END  
  
  
END
