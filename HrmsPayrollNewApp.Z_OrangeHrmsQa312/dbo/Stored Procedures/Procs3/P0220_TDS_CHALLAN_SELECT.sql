


-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0220_TDS_CHALLAN_SELECT]
	@Challan_Id numeric,
	@Month numeric,
	@Year numeric
	
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
			
				
			if @Challan_Id <> 0
				begin																		
									
					SELECT     T.Challan_Id, cmp_id, Month, Year, Payment_Date, Bank_ID, Bank_Name, Bank_BSR_Code, Paid_By, Cheque_No, CIN_No, Cheque_Date, ED_Cess, 
										  Interest_Amount, Penalty_Amount, Other_Amount, Total_Amount,challan_type,T.Tax_Amount
								
					FROM         T0220_TDS_CHALLAN  TC WITH (NOLOCK) inner JOIN
								(
									SELECT SUM((SD.TDS_Amount + SD.Additional_Amount)) As Tax_Amount,sd.Challan_Id
									FROM   T0220_TDS_CHALLAN  C WITH (NOLOCK) inner JOIN 
										   T0230_TDS_CHALLAN_DETAIL SD WITH (NOLOCK) ON SD.Challan_Id = C.Challan_Id 									
									GROUP BY SD.Challan_Id,C.Month,C.Year									
								) T ON T.Challan_Id = tc.Challan_Id
								
					WHERE T.Challan_Id = @Challan_Id
					
					
					SELECT     T0230_TDS_CHALLAN_DETAIL.Tran_Id, T0230_TDS_CHALLAN_DETAIL.Challan_Id, T0230_TDS_CHALLAN_DETAIL.Emp_Id, 
										  --convert(varchar,cast(T0230_TDS_CHALLAN_DETAIL.TDS_Amount as money),1) as Tax, 
										  T0230_TDS_CHALLAN_DETAIL.TDS_Amount as Tax,
										  --convert(varchar,CAST(T0230_TDS_CHALLAN_DETAIL.Ed_Cess AS money),1) as Ed_Cess,
										  T0230_TDS_CHALLAN_DETAIL.Ed_Cess as Ed_Cess,
										   T0080_EMP_MASTER.Emp_Full_Name as Emp_Name , 
										  --convert(varchar,cast((T0230_TDS_CHALLAN_DETAIL.TDS_Amount + T0230_TDS_CHALLAN_DETAIL.Ed_Cess)as money),1) as Total
										  (T0230_TDS_CHALLAN_DETAIL.TDS_Amount + T0230_TDS_CHALLAN_DETAIL.Ed_Cess + Additional_Amount) as Total
										  , T0080_EMP_MASTER.Alpha_Emp_Code as Emp_code
										  ,B.Branch_Name,D.Dept_Name,Ds.Desig_Name,0 As Tax_Paid,Additional_Amount  --Added by Jaina 15-02-2019
					FROM         T0230_TDS_CHALLAN_DETAIL WITH (NOLOCK) INNER JOIN
								 T0080_EMP_MASTER WITH (NOLOCK) ON T0230_TDS_CHALLAN_DETAIL.Emp_Id = T0080_EMP_MASTER.Emp_ID
								 inner join T0095_Increment I WITH (NOLOCK) on I.Emp_id=T0080_EMP_MASTER.Emp_Id 
											and I.Increment_Id=(SELECT MAX(Increment_Id) AS Increment_Id   
																FROM T0095_Increment WITH (NOLOCK)
																WHERE  emp_id=T0080_EMP_MASTER.Emp_Id GROUP BY emp_ID)  
								left JOIN T0030_BRANCH_MASTER B WITH (NOLOCK) ON B.Branch_ID = I.Branch_ID
								left JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON D.Dept_Id = I.Dept_ID
								left JOIN T0040_DESIGNATION_MASTER Ds WITH (NOLOCK) ON Ds.Desig_ID = I.Desig_Id
					WHERE     (T0230_TDS_CHALLAN_DETAIL.Challan_Id = @Challan_Id)
					
					-- for xml kdk - tax - addded by mitesh 12042013
					
					SELECT     T0230_TDS_CHALLAN_DETAIL.Tran_Id, T0230_TDS_CHALLAN_DETAIL.Challan_Id, T0230_TDS_CHALLAN_DETAIL.Emp_Id, 
										  T0230_TDS_CHALLAN_DETAIL.TDS_Amount as Tax, T0230_TDS_CHALLAN_DETAIL.Ed_Cess, EM.Emp_Full_Name as Emp_Name , (T0230_TDS_CHALLAN_DETAIL.TDS_Amount + T0230_TDS_CHALLAN_DETAIL.Ed_Cess) as Total
										  , EM.Alpha_Emp_Code as Emp_code,EM.Pan_No,EM.Gender , DM.Desig_Name , MS.Month_End_Date
										  
					FROM         T0230_TDS_CHALLAN_DETAIL WITH (NOLOCK) INNER JOIN
								 T0080_EMP_MASTER EM WITH (NOLOCK) ON T0230_TDS_CHALLAN_DETAIL.Emp_Id = EM.Emp_ID INNER JOIN
								 T0095_INCREMENT INC WITH (NOLOCK) on EM.Increment_ID = INC.Increment_ID			inner join
								 T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON INC.desig_id = DM.desig_id		left outer JOIN 
								 T0200_MONTHLY_SALARY MS WITH (NOLOCK) on EM.Emp_ID = MS.Emp_ID and month(ms.Month_End_Date) = @Month and year(ms.Month_End_Date) = @Year								
					WHERE     (T0230_TDS_CHALLAN_DETAIL.Challan_Id = @Challan_Id)
									

				end
			Else
				begin
					
					SELECT @Challan_Id = Challan_Id from T0220_TDS_CHALLAN WITH (NOLOCK) where MONTH = @Month and YEAR = @Year
					
					SELECT     Challan_Id, cmp_id, Month, Year, Payment_Date, Bank_ID, Bank_Name, Bank_BSR_Code, Paid_By, Cheque_No, CIN_No, Cheque_Date, Tax_Amount, ED_Cess, 
										  Interest_Amount, Penalty_Amount, Other_Amount, Total_Amount
					FROM         T0220_TDS_CHALLAN WITH (NOLOCK)
					WHERE Challan_Id = @Challan_Id
					
					SELECT     T0230_TDS_CHALLAN_DETAIL.Tran_Id, T0230_TDS_CHALLAN_DETAIL.Challan_Id, T0230_TDS_CHALLAN_DETAIL.Emp_Id, 
                      T0230_TDS_CHALLAN_DETAIL.TDS_Amount as Tax, T0230_TDS_CHALLAN_DETAIL.Ed_Cess, T0080_EMP_MASTER.Emp_Full_Name AS Emp_Name, 
                      T0230_TDS_CHALLAN_DETAIL.TDS_Amount + T0230_TDS_CHALLAN_DETAIL.Ed_Cess AS Total, T0080_EMP_MASTER.Alpha_Emp_Code as Emp_code
					FROM         T0230_TDS_CHALLAN_DETAIL WITH (NOLOCK) INNER JOIN
					  T0080_EMP_MASTER WITH (NOLOCK) ON T0230_TDS_CHALLAN_DETAIL.Emp_Id = T0080_EMP_MASTER.Emp_ID
					WHERE     (T0230_TDS_CHALLAN_DETAIL.Challan_Id = @Challan_Id)
									
				end
			
		
END



