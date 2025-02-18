using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0350ExitClearanceApprovalDetail
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ApprovalId { get; set; }

    public decimal ClearanceId { get; set; }

    public decimal RecoveryAmt { get; set; }

    public string? Remarks { get; set; }

    public string? AttachmentPath { get; set; }

    public byte NotApplicable { get; set; }

    public string? Status { get; set; }
}
