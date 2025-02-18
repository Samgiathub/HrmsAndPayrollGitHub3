using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999AutoEscalateSetting
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public byte IsEnable { get; set; }

    public decimal EscalateAfterDays { get; set; }

    public decimal AutoApprove { get; set; }

    public byte IsSqlJobAgent { get; set; }

    public byte IsAutoReject { get; set; }
}
