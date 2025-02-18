using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090AdvancePaymentApproval
{
    public decimal AdvApprovalId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime? ApplicationDate { get; set; }

    public decimal RequestedAmount { get; set; }

    public string EmpRemarks { get; set; } = null!;

    public DateTime? ApprovalDate { get; set; }

    public decimal? ApprovalAmount { get; set; }

    public string? SuperiorRemarks { get; set; }

    public string AdvanceStatus { get; set; } = null!;

    public decimal? ApprovedBy { get; set; }

    public DateTime CreateDate { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmpFirstName { get; set; }

    public decimal? EmpCode { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal BranchId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public string? ReasonName { get; set; }

    public int ResId { get; set; }
}
