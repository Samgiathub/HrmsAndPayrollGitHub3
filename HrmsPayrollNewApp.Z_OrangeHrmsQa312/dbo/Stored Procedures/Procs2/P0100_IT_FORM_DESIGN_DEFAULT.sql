
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_IT_FORM_DESIGN_DEFAULT]
@Cmp_ID  Numeric,
@Fin_year Varchar(20),
@Login_ID Numeric = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 

Declare @Form_Id Numeric
Declare @IT_Id Numeric

select @Form_Id = Form_Id from T0040_Form_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID

exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 1, 'Basic', 0, 0 , 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 0, 0, 0, 0, @Fin_year,0, 'Basic'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 101, 'Total Earnings', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 0, 0, 0, 0, @Fin_year,0, 'Total Earnings'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 103, '1 Gross Salary', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 0, 0, 0, @Fin_year,1, 'Gross Salary'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 104, 'a Salary u/s 17(1)', 0, 0 , 0, 0, 1, 1, 101, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 4, 0, 0, @Fin_year,0, 'a Salary u/s 17(1)'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 105, 'b Perquisites Value u/s 17(2)(as per From 12B)', 0, 0 , 0, 201, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 4, 0, 0, @Fin_year,0, 'b Perquisites Value u/s 17(2)(as per From 12B)'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 106, 'c Profit in lieu of salary u/s 17(3)(as per Form 1)', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 4, 0, 0, @Fin_year,0, 'c Profit in lieu of salary u/s 17(3)(as per Form 1)'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 120, 'd Total (a + b + c)', 0, 0 , 0, 0, 1, 104, 106, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 3, 1, 4, 0, 0, @Fin_year,0, 'd Total (a + b + c)' -- Change By Sajid Sorting Number Instead of 132

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Previous Employer Gross salary' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 122, 'e Previous employer gross salary', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 6, 0, 0, @Fin_year,0, 'e Pervious employer gross salary',2 -- Change By Sajid Sorting Number Instead of 194
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 125, 'Total (d + e)', 0, 0 , 0, 0, 1, 120, 122, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 1, 0, 0, 0, 0, @Fin_year,0, 'f Total (d + e)' -- Added By Sajid 



exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 133, '2 Less : Allowance to the extent exempt u/s. 10', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 0, 0, 0, @Fin_year,1, 'Less : Exemption U/S 10'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 134, 'HRA', 0, 0 , 0, 7, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, 'HRA'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 135, 'Conveyance', 0, 0 , 0, 9, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, 'Conveyance'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 136, 'Education', 0, 0 , 0, 8, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, 'Education'

--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Medical Allowance' and Cmp_ID = @Cmp_ID
--exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 137, 'Medical', 0, 0 , 0, 0, 3, 137, 137, '', 0, 15000, 0, 1, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, 'Medical'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 162, 'Total Allowance Exemption', 0, 0 , 0, 0, 1, 134, 136, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 2, 1, 6, 0, 0, @Fin_year,0, 'Total Allowance Exemption'



exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 163, '3 Balance (1(d) - 2)', 0, 0 , 0, 0, 2, 120, 162, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 3, 1, 0, 0, 0, @Fin_year,0, '3 Balance (1(d) - 2)',1


exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 171, '4. Deduction', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 2, 1, 0, 0, 0, @Fin_year,0, '4. Deduction' -- Change By Sajid Sorting Number Instead of 164
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 172, 'a. Standard Deduction', 0, 0 , 0, 169, 3, 172, 172, '', 0, 0, 0, 1, 0, @Login_ID,  0, 'I',@Form_Id, 1, 0, 0, 0, 0, @Fin_year,0, 'a. Standard Deduction',0,0,50000 -- Added By Sajid   Help Require Hardik Bhai
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 173, 'b. Tax on Employment', 0, 0 , 0, 10, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,1, 'Less : Prof. Tax'  -- Change By Sajid Sorting Number Instead of 165
select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Previous employer PT' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 174, 'c. Previous employer PT', 0, 0 , 0, 0, 3, 174, 174, '', 0, 2500, 0, 1, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 6, 0, 0, @Fin_year,0, 'c. Previous employer PT' -- Change By Sajid Sorting Number Instead of 166
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 175, 'Total PT', 0, 0 , 0, 0, 1, 173, 174, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 2, 1, 6, 0, 0, @Fin_year,0, 'Total PT' -- Added By Sajid

exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 180, '5. Aggregate of 4(a)+4(b)+4(c)', 0, 0 , 0, 0, 1, 172, 174, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 2, 1, 0, 0, 0, @Fin_year,0, '5. Aggregate of 4(a)+4(b)+4(c)',4  -- Change By Sajid Sorting Number Instead of 191

exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 182, 'Total Deduction', 0, 0 , 0, 0, 4, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 2, 1, 0, 0, 0, @Fin_year,0, 'Total Deduction',0,0,0,'{162}+{180}'  -- Added by sajid

exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 192, '6. Income Chargable under the Head Salaries (3+1(e)-5)', 0, 0 , 0, 0, 4, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 3, 1, 0, 0, 0, @Fin_year,1, 'Income under Head Salary',31,0,0,'{163}+{122}-{180}' -- Change By Sajid Type Formula  -- Help Require Hardik Bhai
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 193, '7. Add: Income from other income reported the by employee.', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 0, 0, 0, @Fin_year,1, 'Any Other Income'



select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Capital Gain' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 195, 'Capital Gain', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, 'Capital Gain'

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Income Other than Salary & House Property' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 196, 'Income from other source', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, 'Income from other source'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 197, 'Income from House Property', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, 'Income from House Property'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 198, 'Taxable salary from Previous Employer', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, 'Taxable salary from Previous Employer'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 206, 'Total', 0, 0 , 0, 0, 1, 194, 198, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 0, 10, 0, 0, @Fin_year,0, 'Total'


select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Interest on housing loan (For Tax exemption) Sec 24' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 207, 'Interest On Housing Loan (Sec 24)', 0, 0 , 0, 0, 3, 207, 207, '', 0, 200000, 0, 1, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, 'Interest On Housing Loan (Sec 24)'

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Income from self occupied property' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 208, 'Income from self occupied property', 0, 0 , 0, 0, 0, 0, 0, '', 0, 200000, 0, 1, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 0, 10, 0, 0, @Fin_year,0, 'Income from self occupied property'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 211, 'Total (Income from Property)', 0, 0 , 0, 0, 1, 207, 208, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 0, 10, 0, 0, @Fin_year,0, 'Total (Income from Property)' -- Change By Sajid Caption Change
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 215, 'Total Income from House Property', 0, 0 , 0, 0, 3, 211, 211, '', 0, 200000, 0, 1, 0, @Login_ID,  0, 'I',@Form_Id, 0, 0, 10, 0, 0, @Fin_year,0, 'Total Income from House Property' -- Add By Sajid
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 217, '8. Total Amount of Other Income (Sum of 7)', 0, 0 , 0, 0, 2, 206, 215, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 2, 1, 10, 0, 0, @Fin_year,0, '8. Total Amount of Other Income (Sum of 7)',0 -- Channge By Sajid Caption and To_ID 


--exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 218, '*', 0, 0 , 0, 0, 2, 163, 191, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 0, 10, 0, 0, @Fin_year,0, '*'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 223, '9. Gross Total Income (6 + 8)', 0, 0 , 0, 0, 4, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 3, 1, 0, 0, 0, @Fin_year,1, '9. Gross Total Income (6 + 8)',0,0,0,'{192}+{217}' -- Change By Caption and Type_ID Formula  -- Help Require Hardik Bhai
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 224, '10. Deduction under chapter VIA', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 0, 0, 0, @Fin_year,1, '10. Deduction under chapter VIA'

------------Start 80C Field ----------------------------------------

exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 225, 'a. 80C', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, 'a. 80C'

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'ULIP' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 226, '1. ULIP', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, '1. ULIP'

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'NSC VIII ISSUE' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 227, '2. NSC', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, '2. NSC'

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Public Provident Fund' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 228, '3. PPF', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, '3. PPF'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 229, '4.(a)  EPF', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, '4.(a)  EPF'
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 230, '(b) Vol.EPF', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 13, 0, 0, @Fin_year,0, '(b) Vol.EPF'

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Previous Employer PF' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 231, '(c) Previous employer PF', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 13, 0, 0, @Fin_year,0, '(c) Previous employer PF'

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'HOUSING LOAN REPAYMENT' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 235, '5. Housing Loan Principal Repayment', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, '5. Housing Loan Principal Repayment'

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'L.I.C.' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 236, '6. L.I.C', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, '6. L.I.C'

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Bank FD' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 237, '7. Bank FD', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, '7. Bank FD'

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'EDUCATION FEES' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 238, '8. School Fees', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, '8. School Fees'

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'UTI PENSION PLAN' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 239, '9. Deduction under pension scheme', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, '9. Deduction under pension scheme' -- Change By Sajid Sorting Number Instead of 244

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'POCTD' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 240, '10. Post Office CTD', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 10, 0, 0, @Fin_year,0, '10. Post Office CTD' -- Change By Sajid Sorting Number Instead of 245

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'NSC INTEREST' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 241, '11. NSC INTEREST', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 10, 0, 0, @Fin_year,0, '11. NSC INTEREST' -- Change By Sajid Sorting Number Instead of 246

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'ELSS' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 242, '12. ELSS', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 10, 0, 0, @Fin_year,0, '12. ELSS' -- Change By Sajid Sorting Number Instead of 247

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'NSS' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 243, '13. NSS', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 10, 0, 0, @Fin_year,0, '13. NSS' -- Change By Sajid Sorting Number Instead of 248

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Registration and Stamp duty' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 244, '14. Registration and Stamp duty', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 10, 0, 0, @Fin_year,0, '14. Registration and Stamp duty' -- Change By Sajid Sorting Number Instead of 249

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Sukanya Samriddhi Yojana' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 245, '15. Sukanya Samriddhi Yojana', 0, 0 , 0, 0, 0, 0, 0, '', 0, 150000, 0, 1, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 10, 0, 0, @Fin_year,0, '15. Sukanya Samriddhi Yojana' -- Change By Sajid Sorting Number Instead of 250

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Other' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 247, '16. Other', 0, 0 , 0, 0, 0, 0, 0, '', 0, 150000, 0, 1, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 10, 0, 0, @Fin_year,0, '16. Other' -- Change By Sajid Sorting Number Instead of 243

exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 250, 'Total 80C', 0, 0 , 0, 0, 3, 226, 247, '', 0, 150000, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 10, 0, 0, @Fin_year,0, 'Total 80C' -- Change By Sajid Sorting Number Instead of 243

------------------END 80C Field ---------------------------

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80 CCA(JEEVAN SURAKSHA)' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 251, 'b. 80 CCA(JEEVAN SURAKSHA)', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 6, 0, 0, @Fin_year,0, 'b. 80 CCA(JEEVAN SURAKSHA)' -- Change By Sajid Sorting Number Instead of 227 and Caption



select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80CCC' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 252, 'c. 80CCC', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID, @IT_Id, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, 'c. 80CCC'  -- Change By Sajid Sorting Number Instead of 225 and Caption

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80 CCD(PENSION)' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 253, 'd. 80 CCD(PENSION)', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, 'd. 80 CCD(PENSION)' -- Change By Sajid Sorting Number Instead of 228 and Caption

exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 255, 'Total (80C (1 To 16), 80CCA, 80CCC, 80CCD)', 0, 0 , 0, 0, 3, 250, 253, '', 0, 150000, 0, 1, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 0, 0, 0, @Fin_year,0, 'Total (80C (1 To 16), 80CCA, 80CCC, 80CCD)',6  -- Change By Sajid Caption and Sorting Number 269

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80 CCD - 1B' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 256, '(e) 80 CCD - 1B', 0, 0 , 0, 0, 3, 256, 256, '', 0, 50000, 0, 1, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 6, 0, 0, @Fin_year,0, '(e) 80 CCD - 1B'  -- Change By Sajid Sorting Number Instead of 279 and Caption Change

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '(a) Basic 10% for Old Regime or 14% for New Regime' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 257, '(a) Basic 10% for Old Regime or 14% for New Regime', 0, 0 , 0, 174, 0, 257, 257, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 8, 0, 0, @Fin_year,0, '(a) Basic 10% for Old Regime or 14% for New Regime'  -- Change By Sajid Sorting Number Instead of 279 and Caption Change

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '(b) NPS Acutal Paid' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 258, '(b) NPS Acutal Paid', 0, 0 , 0, 0, 0, 258, 258, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 8, 0, 0, @Fin_year,0, '(b) NPS Acutal Paid'  -- Change By Sajid Sorting Number Instead of 279 and Caption Change

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Difference' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 259, 'Difference', 0, 0 , 0, 0, 3, 257, 257, '', 0, 150000, 0, 1, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 8, 0, 0, @Fin_year,0, 'Difference'  -- Change By Sajid Sorting Number Instead of 279 and Caption Change

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80 CCD - 2B' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 260, '80 CCD - 2B', 0, 0 , 0, 0, 0, 260, 260, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 8, 0, 0, @Fin_year,0, '80 CCD - 2B'  -- Change By Sajid Sorting Number Instead of 279 and Caption Change


---------------------------END 80C + 80CCA + 80CCD ---------------

---------------------------Start 80D Mediclam -----------

exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 265, '(f) Section 80D', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, '(f) Section 80D'  -- Added By Sajid

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80D (Self/Family) - Below 60 Yrs Age' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 266, '80D (Self/Family) - Below 60 Yrs Age', 0, 0 , 0, 0, 3, 266, 266, '', 0, 25000, 0, 1, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, '80D (Self/Family) - Below 60 Yrs Age' -- Change By Sajid Sorting Number Instead of 270 and Caption Change. -- Hardkbhai

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80D (Self/Family) - Above 60 Yrs Age' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 267, '80D (Self/Family) - Above 60 Yrs Age', 0, 0 , 0, 0, 3, 267, 267, '', 0, 50000, 0, 1, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, '80D (Self/Family) - Above 60 Yrs Age' -- Add By Sajid -- Hardkbhai

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80D (Parents) - Below 60 Yrs Age' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 268, '80D (Parents) - Below 60 Yrs Age', 0, 0 , 0, 0, 3, 268, 268, '', 0, 25000, 0, 1, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, 'Medical (Parents) - Below 60 Yrs Age'  -- Change By Sajid Sorting Number Instead of 271 and Caption Change. -- Hardkbhai

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80D (Parents) - Above 60 Yrs Age' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 269, '80D (Parents) - Above 60 Yrs Age', 0, 0 , 0, 0, 3, 269, 269, '', 0, 50000, 0, 1, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, 'Medical (Parents) - Above 60 Yrs Age'  -- Added By Sajid

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Health Check Up' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 270, '>> Health Check Up', 0, 0 , 0, 0, 0, 0, 0, '', 0, 5000, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, '>> Health Check Up'  -- Added By Sajid

exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 271, 'Total of 80D', 0, 0 , 0, 0, 1, 266, 270, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, 'Total of 80D',41  --Added By Sajid

---------------------------END 80D Mediclam -----------


select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80DD' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 272, '(g) 80DD', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, '(g) 80DD'  -- Change By Sajid Caption

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80 DDB' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 273, '(h) 80 DDB', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 6, 0, 0, @Fin_year,0, '(h) 80 DDB' -- Change By Sajid Sorting Number Instead of 278 and Caption Change

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80 E' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 274, '(i) 80 E', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 6, 0, 0, @Fin_year,0, '(i) 80 E',42 -- Change By Sajid Sorting Number Instead of 275 and Caption Change

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80 EE' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 275, '(j) 80 EE', 0, 0 , 0, 0, 3, 275, 275, '', 0, 50000, 0, 1, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 6, 0, 0, @Fin_year,0, '(j) 80 EE' -- Change By Sajid Sorting Number Instead of 276 and Caption Change

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80EEA' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 276, '(k) 80 EEA', 0, 0 , 0, 0, 3, 276, 276, '', 0, 150000, 0, 1, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 6, 0, 0, @Fin_year,0, '(k) 80 EEA' 

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Sec.80 G (Donation)' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 277, '(l) 80G (Donation)', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, '(l) 80G (Donation)'  -- Change By Sajid Caption

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Authorized University or Eduction institution Donation' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 278, 'i) Approved University', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, 'i) Approved University'  -- Change By Sajid Caption

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Fund setup by State Government for the medical relief to the poor' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 279, 'ii) Medical Relief', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, 'ii) Medical Relief'  -- Change By Sajid Caption

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Donation to Institution which satisfies conditions under section 80G(5)' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 280, 'iii) Institution under section 80G(5)', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, 'iii) Institution under section 80G(5)'  -- Change By Sajid Caption

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Donation to notified temple, mosque, gurudwara church or other place (for renovation or repair)' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 281, 'iv) Repair of temple', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, 'iv) Repair of temple'  -- Change By Sajid Caption

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Sec.80GGC (Contribution To Political Party)' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 282, 'v) 80GGC (Cont. To Political Party)', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 0, 1, 10, 0, 0, @Fin_year,0, 'v) 80GGC (Cont. To Political Party)'

exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 283, 'Total of 80G', 0, 0 , 0, 0, 1, 278, 282, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 6, 0, 0, @Fin_year,0, 'Total of 80G',43  --Added By Sajid

----------------------------------------------------------------
select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80TTA' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 287, '(m) 80TTA', 0, 0 , 0, 0, 3, 287, 287, '', 0, 10000, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 6, 0, 0, @Fin_year,0, '(m) 80TTA'  -- Change By Sajid Sorting Number Instead of 277 and Caption Change

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80TTB' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 288, '(n) 80TTB', 0, 0 , 0, 0, 3, 288, 288, '', 0, 50000, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 6, 0, 0, @Fin_year,0, '(n) 80TTB'  -- Change By Sajid Sorting Number Instead of 277 and Caption Change

select @IT_ID = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80 U' and Cmp_ID = @Cmp_ID
exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 289, '(o) 80 U', 0, 0 , 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  @IT_Id, 'I',@Form_Id, 1, 1, 6, 0, 0, @Fin_year,0, '(o) 80 U'  -- Change By Sajid Sorting Number Instead of 277 and Caption Change


-----------------------------------------------------------------

exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 300, '11. Aggregate of deductible amount under Chapter VI A', 0, 0 , 0, 0, 4, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 2, 1, 0, 0, 0, @Fin_year,0, '11. Aggregate of deductible amount under Chapter VI A',9,0,0,'{255}+{256}+{270}+{272}+{273}+{274}+{275}+{276}+{283}+{287}+{288}+{289}'  -- Change By Sajid Sorting Number Instead of 294 and Caption Change and Formula {255}+{270}+{272}+{280}+{286}+{287}+{288}+{289}+{285} -- Help Require Hardik Bhai

exec P0100_IT_FORM_DESIGN 0, @Cmp_ID, '', 305, '12. Total Taxable Income (9 - 11)', 2, 0 , 0, 0, 2, 223, 300, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 3, 1, 0, 0, 0, @Fin_year,1, '12. Total Taxable Income (9 - 11)',0

---Added by Hardik 22/03/2014
exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'', 311,'13. Tax on Total Income', 0, 0 , 0, 101, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 0, 0, 0, @Fin_year,0,'13. Tax on Total Income',10  -- Change By Sajid Caption
exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'', 312,'14. Less: Sec. 87A', 0, 0 , 0, -102, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 0, 0, 0, @Fin_year,0,'14. Less: Sec. 87A',47 -- Change By Sajid Caption
exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'', 313,'15. Surcharge', 0, 0 , 0, 102, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 0, 0, 0, @Fin_year,0,'15. Surcharge',11,10510540,10 -- Change By Sajid Caption
exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'', 314,'16. Health and Education Cess', 0, 0 , 0, 104, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 0, 0, 0, @Fin_year,1,'16. Health and Education Cess',12,0,4 -- Change By Sajid Caption
exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'', 315,'17. Total Tax', 0, 0 , 0, 105, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 0, 0, 0, @Fin_year,0,'17. Total Tax' -- Change By Sajid Caption
exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'', 316,'18. Less:Relief Under section 89', 0, 0 , 0, 121, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 0, 0, 0, @Fin_year,0,'18. Less:Relief Under section 89',14 -- Change By Sajid Caption
exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'', 317,'Less:TDS deducted from other income reported by employee', 0, 0 , 0, 120, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 4, 0, 0, @Fin_year,0,'Less:TDS deducted from other income reported by employee',16

exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'', 321,'Tax Payable', 0, 0 , 0, 103, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 0, 0, 0, @Fin_year,1,'Total Tax Payable' 
exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'', 322,'Less: TDS Paid', 0, 0 , 0, 107, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 0, 0, 0, @Fin_year,1,'Tax Deducted',15
exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'', 323,'19. FINAL TAX PAYABLE/REFUNDABLE', 0, 0 , 0, 108, 0, 0, 0, '', 0, 0, 0, 0, 0, @Login_ID,  0, 'I',@Form_Id, 0, 1, 0, 0, 0, @Fin_year,1,'Balance Tax' -- Change By Sajid Caption



RETURN




