using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140LeaveTransaction
{
    public decimal LeaveTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LeaveId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal LeaveOpening { get; set; }

    public decimal LeaveCredit { get; set; }

    public decimal LeaveUsed { get; set; }

    public decimal? LeavePosting { get; set; }

    public decimal LeaveClosing { get; set; }

    public decimal? LeaveAdjLMark { get; set; }

    public decimal? LeaveCancel { get; set; }

    public string LeaveName { get; set; } = null!;

    public byte CanApplyFraction { get; set; }

    public decimal? LeaveUsedComp { get; set; }

    public string? DefaultShortName { get; set; }
}
