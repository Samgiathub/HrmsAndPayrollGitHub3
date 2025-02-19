



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_Hrms_Appraisal_Initiation_Final]

@Appr_Int_Id       numeric(18,0),
@Is_TEAM_To_Submit int,
@Is_TEAM_Submit	   int,
@Is_Sup_To_Submit  int,
@Is_Sup_Submit     int,
@Is_Emp_To_Submit  int,
@Is_Emp_Submit     int,
@Is_Accept         int,
@Is_Initiated      int, 
@Cmp_Id            NUMERIC(18,0),
@BRANCH_ID		   NUMERIC(18,0)
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF @BRANCH_ID = 0 
  SET @BRANCH_ID = NULL
  
If @Is_TEAM_Submit=1

Begin

	SELECT   HID.Appr_Int_Id, HID.Is_Accept,HID.start_date, HID.end_date,EM.Emp_ID, EM.Emp_code, EM.Emp_Full_Name, EM.Emp_Superior, E.Emp_Full_Name AS Employee_Superior, 
                      HID.Is_Emp_Submit, HID.Is_Sup_submit,HID.Is_TEAM_submit
FROM         dbo.T0090_Hrms_Appraisal_Initiation_Detail AS HID WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON HID.Emp_Id = EM.Emp_ID Left Outer JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON EM.Emp_Superior = E.Emp_ID where Appr_Int_Id=@Appr_Int_Id And Is_TEAM_Submit=1 And Em.Cmp_Id=@Cmp_Id AND EM.BRANCH_ID = ISNULL(@BRANCH_ID,EM.BRANCH_iD)
End          

ELSE If @Is_TEAM_To_Submit=1

Begin

	SELECT   HID.Appr_Int_Id, HID.Is_Accept,HID.start_date, HID.end_date, EM.Emp_ID, EM.Emp_code, EM.Emp_Full_Name, EM.Emp_Superior, E.Emp_Full_Name AS Employee_Superior, 
                      HID.Is_Emp_Submit, HID.Is_Sup_submit,HID.Is_TEAM_submit
FROM         dbo.T0090_Hrms_Appraisal_Initiation_Detail AS HID WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON HID.Emp_Id = EM.Emp_ID Left Outer JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON EM.Emp_Superior = E.Emp_ID where Appr_Int_Id=@Appr_Int_Id And Is_TEAM_Submit=2 And Em.Cmp_Id=@Cmp_Id AND EM.BRANCH_ID = ISNULL(@BRANCH_ID,EM.BRANCH_iD)                                                                                    
End          

ELSE If @Is_Sup_Submit=1

Begin

	SELECT   HID.Appr_Int_Id, HID.Is_Accept,HID.start_date, HID.end_date,EM.Emp_ID, EM.Emp_code, EM.Emp_Full_Name, EM.Emp_Superior, E.Emp_Full_Name AS Employee_Superior, 
                      HID.Is_Emp_Submit, HID.Is_Sup_submit,HID.Is_TEAM_submit
FROM         dbo.T0090_Hrms_Appraisal_Initiation_Detail AS HID WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON HID.Emp_Id = EM.Emp_ID Left Outer JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON EM.Emp_Superior = E.Emp_ID where Appr_Int_Id=@Appr_Int_Id And Is_Sup_Submit=1 And Em.Cmp_Id=@Cmp_Id AND EM.BRANCH_ID = ISNULL(@BRANCH_ID,EM.BRANCH_iD)                                                                                     
End                      

Else If @Is_Sup_To_Submit=1
Begin

	SELECT   HID.Appr_Int_Id, HID.Is_Accept,HID.start_date, HID.end_date, EM.Emp_ID, EM.Emp_code, EM.Emp_Full_Name, EM.Emp_Superior, E.Emp_Full_Name AS Employee_Superior, 
                      HID.Is_Emp_Submit, HID.Is_Sup_submit,HID.Is_TEAM_submit
FROM         dbo.T0090_Hrms_Appraisal_Initiation_Detail AS HID WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON HID.Emp_Id = EM.Emp_ID Left Outer JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON EM.Emp_Superior = E.Emp_ID where Appr_Int_Id=@Appr_Int_Id And Is_Sup_Submit=2 And Em.Cmp_Id=@Cmp_Id AND EM.BRANCH_ID = ISNULL(@BRANCH_ID,EM.BRANCH_iD)                                                                                     
End       

Else IF @Is_Emp_Submit=1
                   
     Begin

	SELECT   HID.Appr_Int_Id, HID.Is_Accept,HID.start_date, HID.end_date, EM.Emp_ID, EM.Emp_code, EM.Emp_Full_Name, EM.Emp_Superior, E.Emp_Full_Name AS Employee_Superior, 
                      HID.Is_Emp_Submit, HID.Is_Sup_submit,HID.Is_TEAM_submit
FROM         dbo.T0090_Hrms_Appraisal_Initiation_Detail AS HID WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON HID.Emp_Id = EM.Emp_ID Left Outer JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON EM.Emp_Superior = E.Emp_ID where Appr_Int_Id=@Appr_Int_Id And Is_Emp_Submit=1 And Em.Cmp_Id=@Cmp_Id AND EM.BRANCH_ID = ISNULL(@BRANCH_ID,EM.BRANCH_iD)                                          
                      
End                   

Else IF @Is_Emp_To_Submit=1
                   
     Begin

	SELECT   HID.Appr_Int_Id, HID.Is_Accept,HID.start_date, HID.end_date, EM.Emp_ID, EM.Emp_code, EM.Emp_Full_Name, EM.Emp_Superior, E.Emp_Full_Name AS Employee_Superior, 
                      HID.Is_Emp_Submit, HID.Is_Sup_submit,HID.Is_TEAM_submit
FROM         dbo.T0090_Hrms_Appraisal_Initiation_Detail AS HID WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON HID.Emp_Id = EM.Emp_ID Left Outer JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON EM.Emp_Superior = E.Emp_ID where Appr_Int_Id=@Appr_Int_Id And Is_Emp_Submit=2 And Em.Cmp_Id=@Cmp_Id AND EM.BRANCH_ID = ISNULL(@BRANCH_ID,EM.BRANCH_iD)
                      
End                   

Else If @Is_Accept=1

   Begin
	SELECT   HID.Appr_Int_Id, HID.Is_Accept,HID.start_date, HID.end_date, EM.Emp_ID, EM.Emp_code, EM.Emp_Full_Name, EM.Emp_Superior, E.Emp_Full_Name AS Employee_Superior, 
                      HID.Is_Emp_Submit, HID.Is_Sup_submit
FROM         dbo.T0090_Hrms_Appraisal_Initiation_Detail AS HID WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON HID.Emp_Id = EM.Emp_ID Left Outer JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON EM.Emp_Superior = E.Emp_ID where Appr_Int_Id=@Appr_Int_Id And Is_Accept=1 And Em.Cmp_Id=@Cmp_Id AND EM.BRANCH_ID = ISNULL(@BRANCH_ID,EM.BRANCH_iD)                                          
End

Else If @Is_Accept=2

   Begin
	SELECT   HID.Appr_Int_Id, HID.Is_Accept,HID.start_date, HID.end_date, EM.Emp_ID, EM.Emp_code, EM.Emp_Full_Name, EM.Emp_Superior, E.Emp_Full_Name AS Employee_Superior, 
                      HID.Is_Emp_Submit, HID.Is_Sup_submit
FROM         dbo.T0090_Hrms_Appraisal_Initiation_Detail AS HID WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON HID.Emp_Id = EM.Emp_ID Left Outer JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON EM.Emp_Superior = E.Emp_ID where Appr_Int_Id=@Appr_Int_Id And Is_Accept=2 And Em.Cmp_Id=@Cmp_Id AND EM.BRANCH_ID = ISNULL(@BRANCH_ID,EM.BRANCH_iD)                                          
End

 Else If @Is_Accept=0

   Begin
    SELECT   HID.Appr_Int_Id, HID.Is_Accept,HID.start_date, HID.end_date, EM.Emp_ID, EM.Emp_code, EM.Emp_Full_Name, EM.Emp_Superior, E.Emp_Full_Name AS Employee_Superior, 
                      HID.Is_Emp_Submit, HID.Is_Sup_submit
FROM         dbo.T0090_Hrms_Appraisal_Initiation_Detail AS HID WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON HID.Emp_Id = EM.Emp_ID Left Outer JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON EM.Emp_Superior = E.Emp_ID where Appr_Int_Id=@Appr_Int_Id And Is_Accept=0 And Em.Cmp_Id=@Cmp_Id AND EM.BRANCH_ID = ISNULL(@BRANCH_ID,EM.BRANCH_iD)                                          
End      
Else If @Is_Initiated=1

   Begin
   

    SELECT   HID.Appr_Int_Id, HID.Is_Accept,HID.start_date, HID.end_date, EM.Emp_ID, EM.Emp_code, EM.Emp_Full_Name, EM.Emp_Superior, E.Emp_Full_Name AS Employee_Superior, 
                      HID.Is_Emp_Submit, HID.Is_Sup_submit
FROM         dbo.T0090_Hrms_Appraisal_Initiation_Detail AS HID WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON HID.Emp_Id = EM.Emp_ID Left Outer JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON EM.Emp_Superior = E.Emp_ID where Appr_Int_Id=@Appr_Int_Id And Em.Cmp_Id=@Cmp_Id AND EM.BRANCH_ID = ISNULL(@BRANCH_ID,EM.BRANCH_iD)                                          
End      

--Else
  -- Begin
	--SELECT   HID.Appr_Int_Id, HID.Is_Accept, EM.Emp_ID, EM.Emp_code, EM.Emp_Full_Name, EM.Emp_Superior, E.Emp_Full_Name AS Employee_Superior, 
      --                HID.Is_Emp_Submit, HID.Is_Sup_submit
--FROM         dbo.T0090_Hrms_Appraisal_Initiation_Detail AS HID INNER JOIN
  --                    dbo.T0080_EMP_MASTER AS EM ON HID.Emp_Id = EM.Emp_ID INNER JOIN
    --                  dbo.T0080_EMP_MASTER AS E ON EM.Emp_Superior = E.Emp_ID where Appr_Int_Id=@Appr_Int_Id And Em.Cmp_Id=@Cmp_Id
                      
--End                   
RETURN

--0 For Rejected
--1 For Accepted
--2 For Pending




