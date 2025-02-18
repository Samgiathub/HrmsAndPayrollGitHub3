using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100LoanApplicationBackupbyronakk02112022
{
    public string LoanName { get; set; } = null!;

    public decimal LoanAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LoanId { get; set; }

    public DateTime LoanAppDate { get; set; }

    public string LoanAppCode { get; set; } = null!;

    public decimal LoanAppAmount { get; set; }

    public decimal LoanAppNoOfInsttlement { get; set; }

    public decimal LoanAppInstallmentAmount { get; set; }

    public string LoanAppComments { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string? EmpFirstName { get; set; }

    public string LoanStatus { get; set; } = null!;

    public string? EmpLeft { get; set; }

    public string? MobileNo { get; set; }

    public string? OtherEmail { get; set; }

    public decimal BranchId { get; set; }

    public decimal? EmpCode { get; set; }

    public decimal? REmpId { get; set; }

    public decimal LoanMaxLimit { get; set; }

    public decimal? LoanAprAmount { get; set; }

    public string? WorkEmail { get; set; }

    public decimal? LoanAprId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? DeptName { get; set; }

    public string DesigName { get; set; } = null!;

    public decimal? GrossSalary { get; set; }

    public decimal? Ctc { get; set; }

    public DateTime? DateOfJoin { get; set; }

    public decimal? BasicSalary { get; set; }

    public string? BranchName { get; set; }

    public decimal? GuarantorEmpId { get; set; }

    public byte LoanGuarantor { get; set; }

    public DateTime InstallmentStartDate { get; set; }

    public string? LoanApprovalRemarks { get; set; }

    public string? LoanInterestType { get; set; }

    public decimal LoanInterestPer { get; set; }

    public DateTime? LoanRequireDate { get; set; }

    public string? AttachmentPath { get; set; }

    public byte IsAttachment { get; set; }

    public decimal NoOfInstLoanAmt { get; set; }

    public decimal TotalLoanIntAmount { get; set; }

    public decimal LoanIntInstallmentAmount { get; set; }

    public byte IsPrincipalFirstThanInt { get; set; }

    public decimal LoanTakenAmount { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? GuarantorEmpId2 { get; set; }

    public decimal LoanGuarantor2 { get; set; }

    public byte IsSubsidyLoan { get; set; }

    public decimal HideLoanMaxAmount { get; set; }

    public string? BankName { get; set; }

    public string? IncBankAcNo { get; set; }

    public string IfscCode { get; set; } = null!;
}
