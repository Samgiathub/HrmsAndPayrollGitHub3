-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Search_ClaimDetail]
	@Cmp_ID numeric(18,0),
	@Status varchar(10),
	@SearchCondition varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @Query varchar(max)=''

	if @Status = 'P'
	BEGIN
		  set @Query =' SELECT     CA.Claim_App_ID, CA.Cmp_ID, CA.Claim_ID, 
							  CA.Claim_App_Date,CA.Claim_App_Code, 
							CA.Claim_App_Amount, CA.Claim_App_Description, 
							  CA.Claim_App_Doc, CA.Claim_App_Status, dbo.T0040_CLAIM_MASTER.Claim_Name, 
							  ISNULL(CA.Emp_ID, 0) AS Emp_ID, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
							  dbo.T0040_CLAIM_MASTER.Claim_Max_Limit, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Mobile_No, 
							  dbo.T0080_EMP_MASTER.Other_Email, ISNULL(dbo.T0095_INCREMENT.Branch_ID, 0) AS Branch_ID, dbo.T0080_EMP_MASTER.Emp_code, 
							  SEMP.Emp_Full_Name as S_emp_name,CA.S_Emp_ID as S_emp_ID, 
							  dbo.T0080_EMP_MASTER.Alpha_Emp_Code + '' - '' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS Emp_Full_Name_New, 
							  dbo.T0080_EMP_MASTER.Alpha_Emp_Code,SEMP.Emp_Full_Name as Supervisor, dbo.T0095_INCREMENT.Desig_ID,
							  dbo.T0095_INCREMENT.Vertical_ID,dbo.T0095_INCREMENT.SubVertical_ID,  
							  case when Submit_Flag=0 then ''Submitted'' else ''Drafted'' End as Draft_status,
							  Submit_Flag,dbo.T0095_INCREMENT.Dept_ID,   
							  ISNULL(dbo.T0095_INCREMENT.Grd_ID, 0) as Grd_ID,''01/01/1900'' As Claim_Apr_Date
			FROM         dbo.T0100_CLAIM_APPLICATION CA WITH (NOLOCK) inner join
						T0110_CLAIM_APPLICATION_DETAIL CD WITH(NOLOCK) on CA.Claim_App_ID = cd.Claim_App_ID LEFT OUTER JOIN
							  dbo.T0040_CLAIM_MASTER WITH (NOLOCK)  ON cd.Claim_ID = dbo.T0040_CLAIM_MASTER.Claim_ID LEFT OUTER JOIN
							  dbo.T0080_EMP_MASTER AS SEMP WITH (NOLOCK)  ON CA.S_Emp_ID = SEMP.Emp_ID left join
							  dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON CA.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
							  dbo.T0095_INCREMENT WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID
			where  CD.Cmp_ID = ' +Convert(varchar(20),@Cmp_ID) + ''

			exec (@Query + @SearchCondition)
	END
	ELSE IF @Status = 'A'
	BEGIN
		set @Query ='SELECT DISTINCT CAD.EMP_ID,CAD.CLAIM_APR_ID,CAD.CMP_ID,
					CAD.CLAIM_APP_ID,EM.EMP_FIRST_NAME,EM.EMP_FULL_NAME,CA.CLAIM_APR_PENDING_AMOUNT,EM.EMP_LEFT
					,EM.EMP_CODE,CAD.CLAIM_STATUS AS CLAIM_APR_STATUS,CA.CLAIM_APR_DATE AS CLAIM_APR_DATE,CA.CLAIM_APP_DATE,CAP.S_EMP_ID,
					I.BRANCH_ID,I.DESIG_ID,I.GRD_ID,CLAIM_APP_CODE,CLAIM_APP_DOC,EM.ALPHA_EMP_CODE,CLAIM_LIMIT_TYPE,OTHER_EMAIL,MOBILE_NO,CAD.CLAIM_ID,CM.CLAIM_NAME
					--CAD.CLAIM_APP_AMOUNT,CAD.CLAIM_ID,CM.CLAIM_NAME,CAD.CLAIM_APR_DTL_ID,CAD.CLAIM_APR_AMOUNT,
			FROM T0130_CLAIM_APPROVAL_DETAIL CAD WITH (NOLOCK)
				INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID=CAD.EMP_ID AND EM.CMP_ID=CAD.CMP_ID
				LEFT JOIN T0040_CLAIM_MASTER CM WITH (NOLOCK) ON CM.CLAIM_ID=CAD.CLAIM_ID
				LEFT JOIN T0120_CLAIM_APPROVAL CA WITH (NOLOCK) ON CA.CLAIM_APR_ID=CAD.CLAIM_APR_ID AND CA.EMP_ID=CAD.EMP_ID
				LEFT JOIN T0100_CLAIM_APPLICATION CAP WITH(NOLOCK) ON CAP.CLAIM_APP_ID =CA.CLAIM_APP_ID AND CA.EMP_ID = CAP.EMP_ID
				INNER JOIN DBO.T0095_INCREMENT I WITH (NOLOCK)  ON EM.INCREMENT_ID = I.INCREMENT_ID
				AND CM.CMP_ID=CAD.CMP_ID
			where  CAD.Cmp_ID =' +Convert(varchar(20),@Cmp_ID) + ''
		exec (@Query + @SearchCondition)
	END

END
