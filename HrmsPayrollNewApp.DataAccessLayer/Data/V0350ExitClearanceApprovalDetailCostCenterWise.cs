using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0350ExitClearanceApprovalDetailCostCenterWise
{
    public string ItemName { get; set; } = null!;

    public decimal TranId { get; set; }

    public decimal ApprovalId { get; set; }

    public decimal ClearanceId { get; set; }

    public decimal RecoveryAmt { get; set; }

    public string? Remarks { get; set; }

    public string? AttachmentPath { get; set; }

    public byte NotApplicable { get; set; }

    public decimal HodId { get; set; }

    public decimal CmpId { get; set; }

    public byte Active { get; set; }

    public string? ARemarks { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public int DeptId { get; set; }

    public string? Status { get; set; }

    public decimal? CenterId { get; set; }
}
