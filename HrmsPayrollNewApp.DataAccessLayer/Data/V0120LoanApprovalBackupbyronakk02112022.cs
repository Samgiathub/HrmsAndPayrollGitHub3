using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120LoanApprovalBackupbyronakk02112022
{
    public string? EmpFullName { get; set; }

    public string? LoanName { get; set; }

    public decimal LoanAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? LoanAppId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LoanId { get; set; }

    public DateTime LoanAprDate { get; set; }

    public string LoanAprCode { get; set; } = null!;

    public decimal LoanAprAmount { get; set; }

    public decimal LoanAprNoOfInstallment { get; set; }

    public decimal LoanAprInstallmentAmount { get; set; }

    public string LoanAprIntrestType { get; set; } = null!;

    public decimal LoanAprIntrestPer { get; set; }

    public decimal LoanAprIntrestAmount { get; set; }

    public decimal LoanAprDeductFromSal { get; set; }

    public decimal LoanAprPendingAmount { get; set; }

    public string LoanAprBy { get; set; } = null!;

    public DateTime? LoanAprPaymentDate { get; set; }

    public string LoanAprPaymentType { get; set; } = null!;

    public decimal? BankId { get; set; }

    public string LoanAprChequeNo { get; set; } = null!;

    public string? MobileNo { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpLeft { get; set; }

    public DateTime? LoanAppDate { get; set; }

    public string? LoanAppCode { get; set; }

    public decimal? LoanMaxLimit { get; set; }

    public string? LoanAprStatus { get; set; }

    public decimal BranchId { get; set; }

    public decimal? EmpCode { get; set; }

    public string? DeductionType { get; set; }

    public string? LoanNumber { get; set; }

    public string? OtherEmail { get; set; }

    public string? DeptName { get; set; }

    public string DesigName { get; set; } = null!;

    public decimal? GrossSalary { get; set; }

    public decimal? Ctc { get; set; }

    public DateTime? DateOfJoin { get; set; }

    public decimal? BasicSalary { get; set; }

    public string? AlphaEmpCode { get; set; }

    public byte? LoanGuarantor { get; set; }

    public decimal? GuarantorEmpId { get; set; }

    public DateTime InstallmentStartDate { get; set; }

    public string? LoanApprovalRemarks { get; set; }

    public decimal SubsidyRecoverPerc { get; set; }

    public byte? IsInterestSubsidyLimit { get; set; }

    public decimal? InterestRecoveryPer { get; set; }

    public string? SubsidyDesigIdString { get; set; }

    public string? LoanInterestType { get; set; }

    public decimal? LoanInterestPer { get; set; }

    public byte? IsAttachment { get; set; }

    public byte? IsEligible { get; set; }

    public decimal? EligibleDays { get; set; }

    public string? AppLoanInterestType { get; set; }

    public decimal? AppLoanInterestPer { get; set; }

    public DateTime? LoanRequireDate { get; set; }

    public string? AttachmentPath { get; set; }

    public string? AprAttachmentPath { get; set; }

    public decimal? SubsidyBondDays { get; set; }

    public DateTime? ActualSubsidyStartDate { get; set; }

    public decimal OpeningSubsidyAmount { get; set; }

    public decimal NoOfInstLoanAmt { get; set; }

    public decimal TotalLoanIntAmount { get; set; }

    public decimal LoanIntInstallmentAmount { get; set; }

    public decimal LoanAprPendingIntAmount { get; set; }

    public byte? IsPrincipalFirstThanInt { get; set; }

    public decimal? LoanTakenAmount { get; set; }

    public decimal? LoanPaidAmount { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? GuarantorEmpId2 { get; set; }

    public decimal? LoanGuarantor2 { get; set; }

    public string? VerticalName { get; set; }

    public string? SubVerticalName { get; set; }

    public decimal InterestAmount { get; set; }

    public decimal SubSidyAmount { get; set; }

    public byte? IsSubsidyLoan { get; set; }

    public byte IsGpf { get; set; }

    public decimal AdId { get; set; }

    public byte HideInReports { get; set; }
}
