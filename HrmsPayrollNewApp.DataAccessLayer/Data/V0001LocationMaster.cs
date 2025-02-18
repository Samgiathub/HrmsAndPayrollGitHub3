using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0001LocationMaster
{
    public decimal LocId { get; set; }

    public string? LocName { get; set; }

    public string LocCatName { get; set; } = null!;
}
