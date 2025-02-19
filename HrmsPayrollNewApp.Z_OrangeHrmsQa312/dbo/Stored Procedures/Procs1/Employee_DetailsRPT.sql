

CREATE PROCEDURE [dbo].[Employee_DetailsRPT] 
AS
    
SET NOCOUNT OFF;
BEGIN

		BEGIN		
				select EMP_full_Name,emp_code,date_of_join,date_of_birth,blood_Group,street_1,city,state,nationality,mobile_no,EM.Image_Name,Signature_Image_Name,BM.Branch_Name, 
				DM.Dept_Name,CM.Cmp_Name,CM.Cmp_Address,Cmp_City,Cmp_Phone,Cmp_State_Name,Cmp_PinCode
				from T0080_EMP_MASTER EM
				INNER JOIN T0030_BRANCH_MASTER BM  ON EM.Branch_ID = BM.Branch_Id  
				INNER JOIN T0040_DEPARTMENT_MASTER DM  ON EM.Dept_ID = DM.Dept_Id   
				INNER JOIN T0010_COMPANY_MASTER CM  ON EM.Cmp_ID = CM.Cmp_Id  
		END
		
END
