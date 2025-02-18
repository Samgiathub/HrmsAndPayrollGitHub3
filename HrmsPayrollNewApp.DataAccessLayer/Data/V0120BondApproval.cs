using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120BondApproval
{
    public string? EmpFullName { get; set; }

    public string? BondName { get; set; }

    public decimal BondAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal BondId { get; set; }

    public DateTime BondAprDate { get; set; }

    public string BondAprCode { get; set; } = null!;

    public decimal BondAprAmount { get; set; }

    public decimal BondAprNoOfInstallment { get; set; }

    public decimal BondAprInstallmentAmount { get; set; }

    public decimal BondAprDeductFromSal { get; set; }

    public string? MobileNo { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpLeft { get; set; }

    public decimal? BondAmount { get; set; }

    public string? BranchName { get; set; }

    public decimal? EmpCode { get; set; }

    public string? DeductionType { get; set; }

    public string? OtherEmail { get; set; }

    public string? DeptName { get; set; }

    public string DesigName { get; set; } = null!;

    public decimal? GrossSalary { get; set; }

    public decimal? Ctc { get; set; }

    public DateTime? DateOfJoin { get; set; }

    public decimal? BasicSalary { get; set; }

    public string? AlphaEmpCode { get; set; }

    public DateTime InstallmentStartDate { get; set; }

    public string? BondApprovalRemarks { get; set; }

    public string? AprAttachmentPath { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubverticalId { get; set; }

    public decimal? DeptId { get; set; }

    public string? VerticalName { get; set; }

    public string? SubverticalName { get; set; }

    public string? ReferenceName { get; set; }

    public string BondReturnMode { get; set; } = null!;

    public int? BondReturnMonth { get; set; }

    public int? BondReturnYear { get; set; }

    public string? BondReturnStatus { get; set; }

    public DateTime? BondReturnDate { get; set; }

    public decimal? BranchId { get; set; }
}
