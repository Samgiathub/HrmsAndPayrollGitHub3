CREATE PROCEDURE [dbo].[SP_Mobile_WebService_ChgAppFavById]
	@Row_Id numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Emp_ID numeric(18,0)
AS	
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
			SELECT Request_id,Cmp_id,Emp_ID,Request_Type_id,Change_Reason,Request_Date,Shift_From_Date,Shift_To_Date
			
			--,Curr_Details,New_Details,Curr_Tehsil,Curr_District,Curr_Thana,Curr_City_Village,Curr_State,Curr_Pincode,New_Tehsil,New_District
			--,New_Thana,New_City_Village,New_State,New_Pincode,Request_status,Quaulification_ID,Specialization,Passing_Year,Score,Quaulification_Star_Date,Quaulification_End_Date

			--,Dependant_Name,Dependant_Gender,convert(varchar(50),Dependant_DOB ,103) as Dependant_DOB,Dependant_Age,Dependant_Relationship,Dependant_Is_Resident,Dependant_Is_Dependant
			
			--,Pass_Visa_Citizenship,Pass_Visa_No,Pass_Visa_Issue_Date,Pass_Visa_Exp_Date,Pass_Visa_Review_Date,Pass_Visa_Status,License_ID,License_Type
			--,License_IssueDate,License_No,License_ExpDate,License_Is_Expired,Image_path,Curr_IFSC_Code,Curr_Account_No,Curr_Branch_Name,New_IFSC_Code,New_Account_No
			--,New_Branch_Name,Nominess_Address,Nominess_Share,Nominess_For,Nominees_Row_ID,Hospital_Name,Hospital_Address,Admit_Date,MediCalim_Approval_Amount
			--,Old_Pan_No,New_Pan_No,Old_Adhar_No,New_Adhar_No,Loan_Skip_Details,Loan_Month,Loan_Year
			--,Child_Birth_Date,Dep_OccupationID,Dep_HobbyID,Dep_HobbyName
			--,Dep_DepCompanyName,Dep_CmpCity,Dep_Standard_ID,Dep_Shcool_College,Dep_SchCity,Dep_ExtraActivity
			
			,Emp_Fav_Sport_id,Emp_Fav_Sport_Name,Emp_Hobby_id
			,Emp_Hobby_Name,Emp_Fav_Food,Emp_Fav_Restro,Emp_Fav_Trv_Destination,Emp_Fav_Festival,Emp_Fav_SportPerson,Emp_Fav_Singer
			--,Dep_PancardNo
			--,Dep_AdharcardNo,Dep_Height,Dep_Weight
			,OtherHobby,Image_path
			,OtherSports,Curr_Emp_Fav_Sport_id,Curr_Emp_Fav_Sport_Name,Curr_Emp_Hobby_id,Curr_Emp_Hobby_Name
			,Curr_Emp_Fav_Food,Curr_Emp_Fav_Restro,Curr_Emp_Fav_Trv_Destination,Curr_Emp_Fav_Festival,Curr_Emp_Fav_SportPerson,Curr_Emp_Fav_Singer
			FROM T0090_Change_Request_Application
			WHERE Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Request_id = @Row_Id 
			
	
END

