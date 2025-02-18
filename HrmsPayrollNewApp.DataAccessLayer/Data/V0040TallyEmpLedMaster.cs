using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040TallyEmpLedMaster
{
    public decimal TallyLedId { get; set; }

    public decimal CmpId { get; set; }

    public string TallyLedName { get; set; } = null!;

    public string? ParentTallyLedName { get; set; }
}
