using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0350ExitClearanceAllowanceDetail
{
    public string? ItemName { get; set; }

    public decimal RecoveryAmt { get; set; }

    public decimal? CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? AdCalculateOn { get; set; }

    public byte? ForFnf { get; set; }

    public string? AdFlag { get; set; }
}
